using UtilsJL
using Test

@testset "UtilsJL.jl" begin
    include("ResultsManagement_tests/ResultsManagements_tests.jl")
    include("SimulationsUtils_tests/SimulationsUtils_tests.jl")
end
