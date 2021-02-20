module UtilsJL

   import Dates: Time, now
   import Distributed: myid, remotecall_wait
   import SparseArrays: AbstractSparseArray, sparse, issparse
   import BSON
   import Serialization: serialize, deserialize
   import DrWatson
   const DW = DrWatson
   import PkgTemplates: Git, Template, generate
   import Printf: @sprintf
   import Plots: savefig, AbstractPlot
   import FixedPointNumbers: N0f8
   import Colors: RGB
   import Images
   import FileIO
   import Logging
   import Logging: SimpleLogger, global_logger, with_logger
   import ProgressMeter: ProgressThresh, Progress, next!, finish!, update!

   include("DistrubutedUtils/DistributedUtils.jl")
   include("GeneralUtils.jl/GeneralUtils.jl")
   include("ResultsManagement/ResultsManagement.jl")
   include("PlotUtils/PlotUtils.jl")
   include("SimulationUtils/SimulationUtils.jl")

   function __init__()
      
      # ResultsManagement
      _init_globals()
      
   end

   export MASTERW, set_MASTERW, print_inmw, println_inmw, print_ifmw, println_ifmw, 
      tagprint_inmw, tagprintln_inmw, tagprint_ifmw, tagprintln_ifmw

   export load_data, save_data, load_commit_hash, load_commit_short_hash, load_patch

   export mysavename

   export set_cache_dir, temp_cache_file, save_cache,
      load_cache, delete_temp_caches, CACHE_DIR, 
      backup_temp_cache, is_temp_cache_file

   export sparsity, logspace, to_symbol_dict, struct_to_dict, err_str, get_chuncks

   export compressed_copy, uncompressed_copy

   export DictTree

   export save_gif, make_grid, add_margin, centered, plot_to_img

end # module
