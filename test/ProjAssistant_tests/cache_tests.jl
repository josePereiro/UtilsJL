function cache_tests()
    
    @info "cache_tests"
    UtilsJL.ProjAssistant.set_cache_dir(tempdir())
    N = 15
    dat0 = rand(N)

    cfile = UtilsJL.ProjAssistant.cfname("my_dat", N)
    cfile = UtilsJL.ProjAssistant.scache(dat0, cfile)
    @test isfile(cfile)
    dat1 = UtilsJL.ProjAssistant.lcache(cfile)
    @test all(dat0 .== dat1)
    UtilsJL.ProjAssistant.delcache("my_dat", N)
    @test !isfile(cfile)

    cfile = UtilsJL.ProjAssistant.scache(dat0, "my_dat", N)
    dat1 = UtilsJL.ProjAssistant.lcache("my_dat", N)
    @test all(dat0 .== dat1)
    UtilsJL.ProjAssistant.delcache("my_dat", N)
    @test !isfile(cfile)
    
    cfile = UtilsJL.ProjAssistant.scache(() -> dat0, "my_dat", N)
    dat1 = UtilsJL.ProjAssistant.lcache("my_dat", N)
    @test all(dat0 .== dat1)
    UtilsJL.ProjAssistant.delcache(cfile)
    @test !isfile(cfile)
    
    cfile = UtilsJL.ProjAssistant.scache(() -> dat0)
    dat1 = UtilsJL.ProjAssistant.lcache(cfile)
    @test all(dat0 .== dat1)
    UtilsJL.ProjAssistant.delcache(cfile)
    @test !isfile(cfile)
    
    cfile = UtilsJL.ProjAssistant.scache(dat0)
    dat1 = UtilsJL.ProjAssistant.lcache(cfile)
    @test all(dat0 .== dat1)
    UtilsJL.ProjAssistant.delcache(cfile)
    @test !isfile(cfile)

end
cache_tests()