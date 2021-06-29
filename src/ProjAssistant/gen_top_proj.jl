_joinpath(dir, dfargs) = isempty(dfargs) ? joinpath(dir) : joinpath(dir, dfname(dfargs...))

function _check_symbols(mod, symbols)
    foreach(symbols) do symbol 
        isdefined(mod, symbol) && error(
            "Project generation fails, ", symbol, " already exist. ", 
            "If this is intended place the generator function at the to of the containing module."
        )
    end
end

# ---------------------------------------------------------------------
function gen_top_proj(mod::Module, dir = nothing)

    if isnothing(dir)
        modpath = pathof(mod)
        isnothing(modpath) && error("Module `", mod , "` must have a path to be a top project")
        dir = dirname(dirname(modpath))
    end

    @eval mod begin
        
        # ---------------------------------------------------------------------
        # Check symbols
        $(_check_symbols)(mod, 
            [
                :istop_proj, :projectname, :projectdir, 
                :devdir, :datdir, :srcdir, :plotsdir, :scriptsdir, :papersdir,
                :procdir, :rawdir, :cachedir, 
                :sdat, :sprocdat, :srawdat, :scache, 
                :ldat, :lprocdat, :lrawdat, :lcache
            ]
        )
        
        # ---------------------------------------------------------------------
        istop_proj() = true
        projectname() = $(string(nameof(mod)))
        projectdir() = $(dir)
        projectdir(args...) = $(_joinpath)(projectdir(), args)
        
        # ---------------------------------------------------------------------
        # folders
        devdir(args...)  = $(_joinpath)(projectdir(["dev"]), args)
        datdir(args...) = $(_joinpath)(projectdir(["data"]), args)
        srcdir(args...) = $(_joinpath)(projectdir(["src"]), args)
        plotsdir(args...) = $(_joinpath)(projectdir(["plots"]), args)
        scriptsdir(args...) = $(_joinpath)(projectdir(["scripts"]), args)
        papersdir(args...) = $(_joinpath)(projectdir(["papers"]), args)
        
        # ---------------------------------------------------------------------
        # subfolders
        procdir(args...) = $(_joinpath)(datdir(["processed"]), args)
        rawdir(args...) = $(_joinpath)(datdir(["raw"]), args)
        cachedir() = datdir(["cache"])
        cachedir(arg, args...) = datdir(["cache"], $(cfname)(arg, args...))

        # ---------------------------------------------------------------------
        # save/load data
        sdat(f::Function, arg, args...; kwargs...) = $(sdat)(f, datdir(arg, args...); kwargs...)
        sdat(dat, arg, args...; kwargs...) = $(sdat)(dat, datdir(arg, args...); kwargs...)

        sprocdat(f::Function, arg, args...; kwargs...) = $(sdat)(f, procdir(arg, args...); kwargs...)
        sprocdat(dat, arg, args...; kwargs...) = $(sdat)(dat, procdir(arg, args...); kwargs...)

        srawdat(f::Function, arg, args...; kwargs...) = $(sdat)(f, rawdir(arg, args...); kwargs...)
        srawdat(dat, arg, args...; kwargs...) = $(sdat)(dat, rawdir(arg, args...); kwargs...)
        
        ldat(f::Function, arg, args...; kwargs...) = $(ldat)(f, datdir(arg, args...); kwargs...)
        ldat(arg, args...; kwargs...) = $(ldat)(datdir(arg, args...); kwargs...)

        lprocdat(f::Function, arg, args...; kwargs...) = $(ldat)(f, procdir(arg, args...); kwargs...)
        lprocdat(arg, args...; kwargs...) = $(ldat)(procdir(arg, args...); kwargs...)

        lrawdat(f::Function, arg, args...; kwargs...) = $(ldat)(f, rawdir(arg, args...); kwargs...)
        lrawdat(arg, args...; kwargs...) = $(ldat)(rawdir(arg, args...); kwargs...)

        # ---------------------------------------------------------------------
        # save/load cache
        scache(f::Function, arg, args...; kwargs...) = $(scache)(f(), [cachedir()], arg, args...; kwargs...)
        scache(f::Function; kwargs...) = $(scache)(f(), [cachedir()], time(), rand(); kwargs...)
        scache(dat, arg, args...; kwargs...) = $(scache)(dat, [cachedir()], arg, args...; kwargs...)
        scache(dat; kwargs...) = $(scache)(dat, [cachedir()], time(), rand(); kwargs...)
        
        lcache(arg, args...; kwargs...) = $(lcache)([cachedir()], arg, args...; kwargs...)
        lcache(f::Function, arg, args...; kwargs...) = $(lcache)(f, [cachedir()], arg, args...; kwargs...)
        
        delcache(arg, args...; kwargs...) = $(delcache)([cachedir()], arg, args...; kwargs...)
    end
   
end

# ---------------------------------------------------------------------
macro gen_top_proj()
    quote $(gen_top_proj)(@__MODULE__) end
end

macro gen_top_proj(dirkw)
    # get dir
    validarg = Meta.isexpr(dirkw, :(=)) 
    k, dir = dirkw.args
    validarg &= (k == :dir) && (dir isa AbstractString)
    !validarg &&
        error("An expression `dir=path::AbstractString` is expected")
    
    quote $(gen_top_proj)(@__MODULE__, $(esc(dir))) end
end


