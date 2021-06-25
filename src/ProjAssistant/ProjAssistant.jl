module ProjectAssistant

    import DrWatson: tagsave, wload, wsave
    import DataFileNames: dfname, parse_dfname, tryparse_dfname
    import Logging
    import Logging: SimpleLogger, global_logger, with_logger
    import Base.Threads: @threads
    import Serialization: serialize, deserialize


    include("cache.jl")
    include("DictTree.jl")
    include("save_load_data.jl")
    include("group_files.jl")
    include("walkdown.jl")
    include("gen_proj_utils.jl")

    function __init__()
        _init_globals()
    end
end