module GeneralUtils

    import SparseArrays: AbstractSparseArray, sparse, issparse
    import Printf: @sprintf
    
    include("compress.jl")
    include("unclassified.jl")
    include("get_chuncks.jl")
    include("sci.jl")
    
end