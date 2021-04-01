using UtilsJL
using Test

@testset "UtilsJL.jl" begin
    include("ProjAssistant_tests/ProjAssistant_tests.jl")
    include("SimulationsUtils_tests/SimulationsUtils_tests.jl")
    include("DevTools/DevTools_tests.jl")
end
