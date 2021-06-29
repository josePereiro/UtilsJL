module PlotsUtils

    import Images
    import FileIO   
    import FixedPointNumbers: N0f8
    import Colors: RGB
    import Plots
    import Plots: AbstractPlot
    import DataFileNames: dfname

    include("gif.jl")
    include("grid.jl")
    include("ticks.jl")
    include("savefig.jl")
end