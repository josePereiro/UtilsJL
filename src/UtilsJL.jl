module UtilsJL

   import Requires: @require
   import Dates: Time, now
   import Distributed: myid, remotecall_wait
   import Statistics
   import SparseArrays: AbstractSparseArray, sparse, issparse
   import BSON
   import Serialization: serialize, deserialize
   import DrWatson
   const DW = DrWatson
   import Printf: @sprintf
   import Logging
   import Logging: SimpleLogger, global_logger, with_logger
   import ProgressMeter: ProgressThresh, Progress, next!, finish!, update!
   using Base.Threads

   include("DistributedUtils/DistributedUtils.jl")
   include("GeneralUtils/GeneralUtils.jl")
   include("SimulationUtils/SimulationUtils.jl")
   include("DevTools/DevTools.jl")
   include("ProjAssistant/ProjAssistant.jl")


   function __init__()
      
      # ResultsManagement
      _init_globals()

      @require Plots="91a5bcdd-55d7-5caf-9e0b-520d859cae80" begin
         include("PlotUtils/PlotUtils.jl")
      end

      
   end

   export MASTERW, set_MASTERW, print_inmw, println_inmw, print_ifmw, println_ifmw, 
      tagprint_inmw, tagprintln_inmw, tagprint_ifmw, tagprintln_ifmw

   export load_data, save_data, load_commit_hash, load_commit_short_hash, load_patch

   export dfname

   export set_cache_dir, temp_cache_file, save_cache,
      load_cache, delete_temp_caches,  
      backup_temp_cache, is_temp_cache_file

   export sparsity, logspace, to_symbol_dict, struct_to_dict, err_str, get_chuncks

   export compressed_copy, uncompressed_copy

   export DictTree

   export save_gif, make_grid, add_margin, centered, plot_to_img

end # module
