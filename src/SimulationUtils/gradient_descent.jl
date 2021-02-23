# Vectorize form
_default_Err_fun(target::Vector) = (fᵢ) -> abs.(target .- fᵢ) ./ ifelse.(iszero.(target), 1.0, abs.(target))
_default_break_cond(th) = (ϵᵢ) -> maximum(ϵᵢ) < th 
function grad_desc_vec(f::Function;
        target::Vector,
        x0::Vector, x1::Vector,
        maxΔ::Vector = abs.(x0 - x1), th = 1e-5,
        maxiters::Int = 1000, 
        toshow::Vector = [],
        Err = _default_Err_fun(target),
        break_cond = _default_break_cond(th),
        verbose = true,
        oniter::Function = (it, fᵢ, xᵢ, Δx) -> (false, zero(x0))
    )

    # initializing
    xᵢ₋₁, xᵢ = x0, x1
    fᵢ₋₁ = f(xᵢ₋₁)
    ϵᵢ₋₁ = Err(fᵢ₋₁)
    Δx = zero(xᵢ)
    sense = ones(length(target))

    verbose && (prog = ProgressThresh(th, "Grad desc: "))
    for it in 1:maxiters
        
        xᵢ += Δx
        fᵢ = f(xᵢ)
        ϵᵢ = Err(fᵢ)
        sense .*= -sign.(ϵᵢ .- ϵᵢ₋₁)
        Δx = sense .* maxΔ .* min.(1.0, ϵᵢ)

        # Dev
        # @info("Dev", it, tuple(ϵᵢ), tuple(sense), tuple(Δx))
        # println()
        
        
        # callback
        ret, val = oniter(it, fᵢ, xᵢ, Δx)
        ret && return val
        
        xᵢ₋₁ =  xᵢ
        ϵᵢ₋₁ = ϵᵢ
        
        if verbose
            maxϵᵢ = maximum(ϵᵢ)
            update!(prog, maxϵᵢ; showvalues = vcat(
                    [
                        ("it", it),
                        ("maxϵᵢ", maxϵᵢ),
                        ("ϵᵢ", ϵᵢ),
                        ("sense", sense),
                        ("xᵢ", xᵢ),
                        ("t", target),
                        ("fᵢ", fᵢ),
                    ], toshow
                )
            )
        end

        # break condition
        break_cond(ϵᵢ) && break
        
    end
    verbose && finish!(prog)

    return xᵢ
end

## ----------------------------------------------------------------------------
_default_Err_fun(target::Real) = (fᵢ) -> abs(target - fᵢ) / ifelse(iszero(target), 1.0, abs(target))

function grad_desc(f::Function;
        target::Real,
        x0::Real, x1::Real,
        maxΔ::Real = abs(x0 - x1), th = 1e-5,
        maxiters::Int = Int(1e4), 
        verbose = true,
        toshow::Vector = [],
        Err::Function = _default_Err_fun(target),
        oniter::Function = (it, fᵢ, xᵢ, sense) -> (false, zero(x0))
    )

    # initializing
    xᵢ₋₁, xᵢ = x0, x1
    fᵢ₋₁ = f(xᵢ₋₁)
    ϵᵢ₋₁ = Err(fᵢ₋₁)
    sense = one(target)

    verbose && (prog = ProgressThresh(th, "Grad desc: "))
    for it in 1:maxiters
        
        fᵢ = f(xᵢ)
        ϵᵢ = Err(fᵢ)
        sense *= ϵᵢ > ϵᵢ₋₁ ? -1.0 : 1.0
        iszero(sense) && error("sense == 0. Descend gets stocked, target unreachable!!!")
        Δx = sense * maxΔ * ϵᵢ
        
        # callback
        ret, val = oniter(it, fᵢ, xᵢ, Δx)
        ret && return val
        
        ϵᵢ < th && break
        
        xᵢ += Δx
        ϵᵢ₋₁ = ϵᵢ

        verbose && update!(prog, ϵᵢ; showvalues = vcat(
                [
                    ("it", it),
                    ("ϵᵢ", ϵᵢ),
                    ("sense", sense),
                    ("xᵢ", xᵢ),
                    ("Δx", Δx),
                    ("t", target),
                    ("fᵢ", fᵢ),
                ], toshow
            )
        )
    end
    verbose && finish!(prog)

    return xᵢ
end