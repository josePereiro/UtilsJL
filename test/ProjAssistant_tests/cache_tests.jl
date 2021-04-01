function cache_tests()
    
    @info "cache_tests"
    UtilsJL.set_cache_dir(tempdir())
    UtilsJL.set_verbose(false)
    for i in 1:10
        data = rand(10,10)
        data_cid = UtilsJL.save_cache(data)
        ldata = UtilsJL.load_cache(data_cid)
        @test all(ldata .==  data)
        
        UtilsJL.delete_cache(data_cid)
        ldata = UtilsJL.load_cache(data_cid, :DELETED)
        @test ldata == :DELETED
    end
end
cache_tests()