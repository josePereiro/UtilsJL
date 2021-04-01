function gen_top_proj(mod::Module)

    @eval(mod, projectname() = $(DrWatson.projectname()))
    @eval(mod, projectdir() = $(DrWatson.projectdir()))
    @eval(mod, devdir() = $(DrWatson.projectdir("dev")))

    for funname in (:datadir, :srcdir, :plotsdir, :scriptsdir, :papersdir)
        @eval mod $(funname)(args...) = $(getproperty(DrWatson, funname))(args...)
    end

    # subdata
    @eval(mod, procdir(args...) = datadir("processed", args...))
    @eval(mod, rawdir(args...) = datadir("raw", args...))
    @eval(mod, cachedir(args...) = datadir("cache", args...))
end

function gen_sub_proj(currmod::Module, parentmod::Module = parentmodule(currmod))

    @eval(currmod, projectname() = string(nameof($currmod)))

    for funname in (:plotsdir, :procdir, :rawdir, :cachedir)
        father_fun = getproperty(parentmod, funname)
        @eval(currmod, $funname(args...) = $father_fun(projectname(), args...))
    end
end

function create_proj_dirs(mod::Module)
    for funname in (:datadir, :srcdir, :plotsdir, :scriptsdir, 
            :papersdir, :procdir, :rawdir, :cachedir, :devdir)
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