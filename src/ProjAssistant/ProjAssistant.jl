module ProjAssistant

    using DataFileNames
    import DrWatson
    import Logging
    import Logging: SimpleLogger, global_logger, with_logger
    using Base.Threads
    import Serialization: serialize, deserialize
    import FileIO
    import ..GeneralUtils: err_str

    include("_io_print.jl")
    include("io_global_conf.jl")
    include("_save_load.jl")
    include("scache_lcache.jl")
    include("sdat_ldat.jl")
    include("group_files.jl")
    include("walkdown.jl")
    include("gen_sub_proj.jl")
    include("gen_top_proj.jl")
    include("create_proj_dirs.jl")

    function __init__()
        _init_globals()
    end
end