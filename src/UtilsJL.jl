module UtilsJL

    import Dates: Time, now
    import Distributed: myid, remotecall_wait
    import SparseArrays: AbstractSparseArray, sparse, issparse
    import BSON
    import Serialization: serialize, deserialize
    import DrWatson: wload, tagsave, wsave
    import PkgTemplates: Git, Template, generate

    include("commons.jl")
    include("compress.jl")
    include("print_inmw.jl")
    include("cache.jl")
    include("save_load_data.jl")
    include("mypkg_generate.jl")

end # module
