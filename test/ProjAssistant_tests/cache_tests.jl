function cache_tests()
    
    @info "cache_tests"
    UtilsJL.ProjectAssistant.set_cache_dir(tempdir())
    UtilsJL.ProjectAssistant.set_verbose(false)
    for i in 1:10
        data = rand(10,10)
        data_cid = UtilsJL.ProjectAssistant.save_cache(data)
        ldata = UtilsJL.ProjectAssistant.load_cache(data_cid)
        @test all(ldata .==  data)
        
        UtilsJL.ProjectAssistant.delete_cache(data_cid)
        ldata = UtilsJL.ProjectAssistant.load_cache(data_cid, :DELETED)
        @test ldata == :DELETED
    end
end
cache_tests()