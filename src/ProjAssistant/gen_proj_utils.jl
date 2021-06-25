function gen_top_proj(mod::Module)

    modpath = (pathof(mod))
    # isnothing(modpath) && error("Module `", mod , "` must have a path to be a top project")
    @eval mod begin
        
        # ---------------------------------------------------------------------
        _joinpath(dir, dfargs) = isempty(dfargs) ? 
            joinpath(dir) : joinpath(dir, $(dfname)(dfargs...))

        # ---------------------------------------------------------------------
        istop_proj() = true
        projectname() = $(string(mod))
        # projectdir() = $(dirname(dirname(pathof(mod))))
        projectdir() = projectname() # Test
        projectdir(args...) = _joinpath(projectdir(), args)
        
        # ---------------------------------------------------------------------
        # folders
        devdir(args...)  = _joinpath(projectdir(["dev"]), args)
        datadir(args...) = _joinpath(projectdir(["data"]), args)
        srcdir(args...) = _joinpath(projectdir(["src"]), args)
        plotsdir(args...) = _joinpath(projectdir(["plots"]), args)
        scriptsdir(args...) = _joinpath(projectdir(["scripts"]), args)
        papersdir(args...) = _joinpath(projectdir(["papers"]), args)
        
        # ---------------------------------------------------------------------
        # subdata
        procdir(args...) = _joinpath(datadir(["processed"]), args)
        rawdir(args...) = _joinpath(datadir(["raw"]), args)
        cachedir(args...) = _joinpath(datadir(["cache"]), args)
        
    end
   
end

function gen_sub_proj(currmod::Module, parentmod::Module = parentmodule(currmod))

    !isdefined(parentmod, :projectname) && 
        error("Parent module ($(parentmod)) is not a project.")
    
    @eval currmod begin 
        istop_proj() = false
        projectname() = string(nameof($currmod))
    end
    
    for funname in (:plotsdir, :procdir, :rawdir, :cachedir)
        father_fun = getproperty(parentmod, funname)
        _joinpath = getproperty(parentmod, :_joinpath)
        @eval currmod begin 
            $funname(args...) = $(_joinpath)($(father_fun)(projectname()), args)
        end
    end
end

function create_proj_dirs(mod::Module)
    for funname in (
            :datadir, :srcdir, :plotsdir, :scriptsdir, 
            :papersdir, :procdir, :rawdir, :cachedir, :devdir
        )
        if isdefined(mod, funname)
            dir = getproperty(mod, funname)()
            mkpath(dir)
        end
    end
end

# TODO: Transform to your layout
# function print_proj_layout()
#     """
#     │projectdir          <- Project's main folder. It is initialized as a Git
#     │                       repository with a reasonable .gitignore file.
#     │
#     ├── _research        <- WIP scripts, code, notes, comments,
#     │   |                   to-dos and anything in an alpha state.
#     │   └── tmp          <- Temporary data folder.
#     │
#     ├── data             <- **Immutable and add-only!**
#     │   ├── sims         <- Data resulting directly from simulations.
#     │   ├── exp_pro      <- Data from processing experiments.
#     │   └── exp_raw      <- Raw experimental data.
#     │
#     ├── plots            <- Self-explanatory.
#     ├── notebooks        <- Jupyter, Weave or any other mixed media notebooks.
#     │
#     ├── papers           <- Scientific papers resulting from the project.
#     │
#     ├── scripts          <- Various scripts, e.g. simulations, plotting, analysis,
#     │   │                   The scripts use the `src` folder for their base code.
#     │   └── intro.jl     <- Simple file that uses DrWatson and uses its greeting.
#     │
#     ├── src              <- Source code for use in this project. Contains functions,
#     │                       structures and modules that are used throughout
#     │                       the project and in multiple scripts.
#     │
#     ├── README.md        <- Optional top-level README for anyone using this project.
#     ├── .gitignore       <- by default ignores _research, data, plots, videos,
#     │                       notebooks and latex-compilation related files.
#     │
#     ├── Manifest.toml    <- Contains full list of exact package versions used currently.
#     └── Project.toml     <- Main project file, allows activation and installation.
#                             Includes DrWatson by default.
#     """ |> println
# end