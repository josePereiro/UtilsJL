module GeneralUtils

    import SparseArrays: AbstractSparseArray, sparse, issparse
    import Printf: @sprintf
    
    include("compress.jl")
    include("unclassified.jl")
    include("IterChunk.jl")
    include("DictTree.jl")
    include("sci.jl")
    
end