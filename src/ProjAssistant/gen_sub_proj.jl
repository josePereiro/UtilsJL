
function gen_sub_proj(currmod::Module, parentmod = parentmodule(currmod))

    # ---------------------------------------------------------------------
    # Check parenthood
    !isdefined(parentmod, :projectname) && 
        error("Parent module ($(parentmod)) is not a project.")

    # ---------------------------------------------------------------------
    # Check symbols
    @eval currmod begin
        $(_check_symbols)(mod, 
            [
                :istop_proj, :projectname, 
                :plotsdir, :scriptsdir,
                :procdir, :rawdir, :cachedir, 
                :sprocdat, :srawdat, :scache, :lprocdat, :lrawdat, :lcache
            ]
        )
    end

    # ---------------------------------------------------------------------
    # projectname
    @eval currmod begin 
        istop_proj() = false
        projectname() = $(string(nameof(currmod)))
    end
    
    # ---------------------------------------------------------------------
    # subdirs
    for funname in (:plotsdir, :scriptsdir, :procdir, :rawdir)
        @eval currmod begin 
            function $funname(args...) 
                parfun = $parentmod.$funname
                subdir = parfun(projectname())
                $(_joinpath)(subdir, args)
            end
        end
    end

    @eval currmod begin
        cachedir() = joinpath($parentmod.cachedir(), projectname())
        cachedir(arg, args...) = joinpath(cachedir(), $(cfname)(arg, args...))
    end
    
    # ---------------------------------------------------------------------
    # ls fun
    for funname in [:plotsdir, :scriptsdir, :procdir, :rawdir, :cachedir]
        lsfun = Symbol(:ls, funname)
        @eval currmod begin 
            function $lsfun(args...)
                dir = $(funname)(args...)
                fs = readdir(dir)
                println(join(fs, "\n"))
            end
        end
    end

    # ---------------------------------------------------------------------
    # save/load dat
    @eval currmod begin 
        sprocdat(f::Function, arg, args...; kwargs...) = $(sdat)(f, procdir(arg, args...); kwargs...)
        sprocdat(dat, arg, args...; kwargs...) = $(sdat)(dat, procdir(arg, args...); kwargs...)

        sdat = sprocdat

        srawdat(f::Function, arg, args...; kwargs...) = $(sdat)(f, rawdir(arg, args...); kwargs...)
        srawdat(dat, arg, args...; kwargs...) = $(sdat)(dat, rawdir(arg, args...); kwargs...)

        lprocdat(f::Function, arg, args...; kwargs...) = $(ldat)(f, procdir(arg, args...); kwargs...)
        lprocdat(arg, args...; kwargs...) = $(ldat)(procdir(arg, args...); kwargs...)
        
        ldat = lprocdat

        lrawdat(f::Function, arg, args...; kwargs...) = $(ldat)(f, rawdir(arg, args...); kwargs...)
        lrawdat(arg, args...; kwargs...) = $(ldat)(rawdir(arg, args...); kwargs...)
    end

    # ---------------------------------------------------------------------
    # save/load cache
    @eval currmod begin
        scache(f::Function, arg, args...; kwargs...) = $(scache)(f(), [cachedir()], arg, args...; kwargs...)
        scache(f::Function; kwargs...) = $(scache)(f(), [cachedir()], time(), rand(); kwargs...)
        scache(dat, arg, args...; kwargs...) = $(scache)(dat, [cachedir()], arg, args...; kwargs...)
        scache(dat; kwargs...) = $(scache)(dat, [cachedir()], time(), rand(); kwargs...)
        
        lcache(arg, args...; kwargs...) = $(lcache)([cachedir()], arg, args...; kwargs...)
        lcache(f::Function, arg, args...; kwargs...) = $(lcache)(f, [cachedir()], arg, args...; kwargs...)
        
        delcache(args...; kwargs...) = $(delcache)([cachedir()], args...; kwargs...)
    end

    # ---------------------------------------------------------------------
    # globals
    @eval currmod begin

        const _GLOBALS_EXT = ".global.jls"
        _global_file(gid) = procdir(string(gid), _GLOBALS_EXT)

        function lglob(gid::Symbol)
            fname = _global_file(gid)
            !isfile(fname) && error("global is missing, gid '", gid, "'")
            return ldat(fname; verbose = false)
        end

        lglob(gid::Symbol, gids::Symbol...) = map(lglob, (gid, gids...))

        ## ------------------------------------------------------------
        function sglob(dat, gid::Symbol)
            fname = _global_file(gid)
            sdat(dat, fname; verbose = false)
        end

        function sglob(;kwargs...)
            for (gid, dat) in kwargs
                sglob(dat, gid)
            end
        end

        sglob(f::Function, gid::Symbol) = sglob(f(), gid)

        ## ------------------------------------------------------------
        delglob(gid::Symbol) = rm(_global_file(gid); force = true)

    end
    
end

# ---------------------------------------------------------------------
macro gen_sub_proj()
    quote $(gen_sub_proj)(@__MODULE__) end
end

macro gen_sub_proj(dirkw)
    # get dir
    validarg = Meta.isexpr(dirkw, :(=)) 
    k, parent = dirkw.args
    validarg &= (k == :parent) && (parent isa Symbol)
    !validarg && error("An expression `parent=mod::Module` is expected, got ", dirkw)
    
    quote $(gen_sub_proj)(@__MODULE__, $(esc(parent))) end
end

