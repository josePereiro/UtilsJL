## ------------------------------------------------------------------------------
# Container
mutable struct GDModel{T}
    # current state
    iter::Int
    xi::T
    fi::T
    ϵi::T
    ϵii::T
    Δx::T
    sense::T

    # params
    target::T
    maxΔx::T
    maxiter::Int
    gdth::Real
    verbose::Bool
end

# constructor
function GDModel(;
        target, maxΔx, 
        maxiter = Int(1e4), 
        it0 = 1, 
        gdth,
        verbose = true,
    )

    iter = Int(it0)
    maxiter = Int(maxiter)
    xi = zero(target)
    fi = zero(target)
    ϵi = zero(target)
    ϵii = zero(target)
    Δx = zero(target)
    sense = zero(target)

    GDModel{typeof(target)}(
        # state
        iter, xi, fi, ϵi, ϵii, Δx, sense,
        # params
        target, maxΔx, maxiter, gdth, verbose
    )
end

gd_value(gdmodel::GDModel) = gdmodel.xi

## ------------------------------------------------------------------------------
# Vectorize version
_default_Err_fun(gdmodel::GDModel{T}) where T<:AbstractArray = 
    abs.(gdmodel.target - gdmodel.fi) ./ ifelse.(iszero.(gdmodel.target), 1.0, abs.(gdmodel.target))
_default_break_cond(gdmodel::GDModel{T}) where T<:AbstractArray = 
    maximum(gdmodel.ϵi) < gdmodel.gdth 
_default_get_step(gdmodel::GDModel{T}) where T<:AbstractArray = 
    gdmodel.sense .* gdmodel.maxΔx .* min.(1.0, gdmodel.ϵi)
function _default_get_sense(gdmodel::GDModel{T}) where T<:AbstractArray 
    Δϵ = gdmodel.ϵi .- gdmodel.ϵii
    zeros = iszero.(Δϵ)
    sense = gdmodel.sense .* -sign.(gdmodel.ϵi .- gdmodel.ϵii)
    if any(zeros)
        rsense = rand(-1:1, length(Δϵ))
        sense = ifelse.(zeros, rsense, sense)
    end
    return sense
end

    
function grad_desc_vec!(f::Function, gdmodel::GDModel{T};
        x0::T, x1::T,
        toshow::Vector = [],
        Err::Function = _default_Err_fun,
        break_cond::Function = _default_break_cond,
        oniter!::Function = (dgmodel) -> false,
        get_sense::Function = _default_get_sense,
        get_step::Function = _default_get_step,
    ) where {T<:AbstractArray}

    # initializing
    gdmodel.xi .= x0
    gdmodel.fi .= f(gdmodel)
    gdmodel.ϵii .= Err(gdmodel)
    gdmodel.sense .= ones(length(gdmodel.target))
    gdmodel.Δx .= zero(gdmodel.xi)
    gdmodel.xi .= x1

    prog = ProgressThresh(gdmodel.gdth, "Grad desc: ")
    it0 = gdmodel.iter
    while true

        gdmodel.xi += gdmodel.Δx
        gdmodel.fi .= f(gdmodel)
        gdmodel.ϵi .= Err(gdmodel)
        gdmodel.sense .= get_sense(gdmodel)
        gdmodel.Δx .= get_step(gdmodel)
        
        # callback
        ret = oniter!(gdmodel)
        ret && return gdmodel
        
        if gdmodel.verbose
            maxϵᵢ = maximum(gdmodel.ϵi)
            update!(prog, maxϵᵢ; showvalues = vcat(
                    [
                        ("it", gdmodel.iter),
                        ("maxϵᵢ", maxϵᵢ),
                        ("ϵᵢ", gdmodel.ϵi),
                        ("sense", gdmodel.sense),
                        ("xᵢ", gdmodel.xi),
                        ("t", gdmodel.target),
                        ("fi", gdmodel.fi),
                    ], toshow
                )
            )
        end

        gdmodel.ϵii .= gdmodel.ϵi

        # break condition
        break_cond(gdmodel) && break
        gdmodel.iter >= gdmodel.maxiter &&  break

        gdmodel.iter += 1
    end
    gdmodel.verbose && finish!(prog)

    return gdmodel
end

function grad_desc_vec(f::Function;
        x0::T, x1::T,
        target::T, 
        maxΔx::T = abs.(x0 - x1), 
        gdth::Real = 1e-5, 
        maxiter = Int(1000), 
        it0 = 1, 
        verbose = true,
        kwargs...
    ) where {T<:AbstractArray}

    gdmodel = GDModel(;target, maxΔx, maxiter, it0, gdth, verbose)
    grad_desc_vec!(f, gdmodel; x0, x1, kwargs...)

end

## ------------------------------------------------------------------------------
# Scalar version
_default_Err_fun(gdmodel::GDModel{T}) where T<:Real = 
    abs(gdmodel.target - gdmodel.fi) / ifelse(iszero(gdmodel.target), 1.0, abs(gdmodel.target))
_default_break_cond(gdmodel::GDModel{T}) where T<:Real = gdmodel.ϵi < gdmodel.gdth 
_default_get_step(gdmodel::GDModel{T}) where T<:Real = gdmodel.sense * gdmodel.maxΔx * min.(1.0, gdmodel.ϵi)
function _default_get_sense(gdmodel::GDModel{T}) where T<:Real 
    Δϵ = gdmodel.ϵi - gdmodel.ϵii
    iszero(Δϵ) ? rand(-1:1) : gdmodel.sense * -sign(gdmodel.ϵi - gdmodel.ϵii)
end

function grad_desc!(f::Function, gdmodel::GDModel{T};
        x0::T, x1::T,
        toshow::Vector = [],
        Err::Function = _default_Err_fun,
        break_cond::Function = _default_break_cond,
        oniter!::Function = (dgmodel) -> false,
        get_sense::Function = _default_get_sense,
        get_step::Function = _default_get_step
    ) where {T<:Real}

    # initializing
    gdmodel.xi = x0
    gdmodel.fi = f(gdmodel)
    gdmodel.ϵii = Err(gdmodel)
    gdmodel.sense = one(gdmodel.target)
    gdmodel.Δx = zero(gdmodel.xi)
    gdmodel.xi = x1

    prog = ProgressThresh(gdmodel.gdth, "Grad desc: ")
    it0 = gdmodel.iter
    while true

        gdmodel.xi += gdmodel.Δx
        gdmodel.fi = f(gdmodel)
        gdmodel.ϵi = Err(gdmodel)
        gdmodel.sense = get_sense(gdmodel)
        gdmodel.Δx = get_step(gdmodel)
        
        # callback
        ret = oniter!(gdmodel)
        ret && return gdmodel
        
        if gdmodel.verbose
            update!(prog, gdmodel.ϵi; showvalues = vcat(
                    [
                        ("it", gdmodel.iter),
                        ("ϵᵢ", gdmodel.ϵi),
                        ("sense", gdmodel.sense),
                        ("xᵢ", gdmodel.xi),
                        ("t", gdmodel.target),
                        ("fi", gdmodel.fi),
                    ], toshow
                )
            )
        end

        gdmodel.ϵii = gdmodel.ϵi

        # break condition
        break_cond(gdmodel) && break
        gdmodel.iter >= gdmodel.maxiter &&  break

        gdmodel.iter += 1
    end
    gdmodel.verbose && finish!(prog)

    return gdmodel
end

function grad_desc(f::Function;
        x0::T, x1::T,
        target::T, 
        maxΔx::T = abs.(x0 - x1), 
        gdth::Real = 1e-5, 
        maxiter = Int(1000), 
        it0 = 1, 
        verbose = true,
        kwargs...
    ) where {T<:Real}

    gdmodel = GDModel(;target, maxΔx, maxiter, it0, gdth, verbose)
    grad_desc!(f, gdmodel; x0, x1, kwargs...)

end
