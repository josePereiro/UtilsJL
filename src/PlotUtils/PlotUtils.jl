module PlotsUtils

    import Images
    import FileIO   
    import FixedPointNumbers: N0f8
    import Colors: RGB
    import Plots: savefig, AbstractPlot

    include("gif.jl")
    include("grid.jl")
    include("ticks.jl")
end