module UtilsJL

   import Requires: @require

   include("GeneralUtils/GeneralUtils.jl")
   include("SimulationUtils/SimulationUtils.jl")
   include("DevTools/DevTools.jl")
   include("ProjAssistant/ProjAssistant.jl")


   function __init__()

      @require Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80" begin
         include("PlotUtils/PlotUtils.jl")
      end

      @require Distributed = "8ba89e20-285c-5b6f-9357-94700520ee1b" begin
         include("DistributedUtils/DistributedUtils.jl")
      end
      
   end

end # module
