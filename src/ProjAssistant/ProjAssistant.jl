module ProjAssistant

    import DrWatson
    import DataFileNames
    import DataFileNames: dfname, parse_dfname, 
                        tryparse_dfname, isvalid_dfname
    import Logging
    import Logging: SimpleLogger, global_logger, with_logger
    import Base.Threads: @threads
    import Serialization: serialize, deserialize
    import FileIO
    import ..GeneralUtils: err_str

    include("_io_print.jl")
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