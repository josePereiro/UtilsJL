## ------------------------------------------------------------
# gen proj test
_TO_REMOVE = []
for fun_flag in [true, false]

    RTAG = string(rand(UInt))
    TopMod = Symbol("Top", RTAG)
    Sub1Mod = Symbol("Sub1")
    Sub2Mod = Symbol("Sub2")
    Sub3Mod = Symbol("Sub3")
    TopDir = joinpath(tempdir(), string(TopMod))
    rm(TopDir; force = true, recursive = true)
    push!(_TO_REMOVE, TopDir)
    try
        # ---------------------------------------------------------------------
        # verbose
        UtilsJL.ProjAssistant.set_verbose(fun_flag)

        # ---------------------------------------------------------------------
        # prepare test "project"
        @info("Test project", TopMod, Sub1Mod, TopDir)
        @eval module $(TopMod)

            import UtilsJL
            if $(fun_flag); UtilsJL.ProjAssistant.gen_top_proj(@__MODULE__, $(TopDir))
                else; UtilsJL.ProjAssistant.@gen_top_proj dir=$(TopDir)
            end
            
            function __init__()
                if $(fun_flag); UtilsJL.ProjAssistant.create_proj_dirs(@__MODULE__)
                    else; UtilsJL.ProjAssistant.@create_proj_dirs
                end
            end

            module $(Sub1Mod)

                import UtilsJL
                if $(fun_flag); UtilsJL.ProjAssistant.gen_sub_proj(@__MODULE__)
                    else; UtilsJL.ProjAssistant.@gen_sub_proj
                end

                module $(Sub2Mod)
                    
                    module $(Sub3Mod)

                        import Main.$(TopMod).$(Sub1Mod)
                        import UtilsJL
                        
                        if $(fun_flag); UtilsJL.ProjAssistant.gen_sub_proj(@__MODULE__, $(Sub1Mod))
                            else; UtilsJL.ProjAssistant.@gen_sub_proj(parent=$(Sub1Mod))
                        end

                        function __init__()
                            if $(fun_flag); UtilsJL.ProjAssistant.create_proj_dirs(@__MODULE__)
                                else; UtilsJL.ProjAssistant.@create_proj_dirs
                            end
                            
                        end
                    end
                end # module $(Sub2Mod)

                function __init__()
                    if $(fun_flag); UtilsJL.ProjAssistant.create_proj_dirs(@__MODULE__)
                        else; UtilsJL.ProjAssistant.@create_proj_dirs
                    end
                    
                end
            end # module $(Sub1Mod)
        end

        Top = getproperty(Main, TopMod)
        Sub1 = getproperty(Top, Sub1Mod)
        Sub2 = getproperty(Sub1, Sub2Mod)
        Sub3 = getproperty(Sub2, Sub3Mod)

        ## ------------------------------------------------------------
        # Test
        @testset "gen_projects" begin

            ## ------------------------------------------------------------
            # TopMod
            for funname in (
                    :projectdir,
                    :devdir, :datdir, :srcdir, :plotsdir, :scriptsdir, :papersdir,
                    :procdir, :rawdir, :cachedir, 
                )
                fun = getproperty(Top, funname)
                @test isdir(fun())

                df = fun("bla", (;A = 1), "jls")
                @test UtilsJL.ProjAssistant.isvalid_dfname(df)
                @test df == fun(df)
            end

            # SubMod
            for Mod in [Sub1, Sub3]
                for funname in (
                        :plotsdir, :scriptsdir,
                        :procdir, :rawdir, :cachedir,  
                    )
                    fun = getproperty(Mod, funname)
                    @test isdir(fun())

                    df = fun("bla", (;A = 1), "jls")
                    @test UtilsJL.ProjAssistant.isvalid_dfname(df)
                    @test df == fun(df)

                    sub1fun = getproperty(Sub1, funname)
                    sub3fun = getproperty(Sub3, funname)

                    @test sub1fun() == dirname(sub3fun())
                end
            end

            @test Top.istop_proj()
            @test !Sub1.istop_proj()
            @test !Sub3.istop_proj()

            ## ------------------------------------------------------------
            # save/load data
            for Mod in [Top, Sub1, Sub3]
                @info("save/load data", Mod)
                mkdir = true
                for (sfunsym, lfunsym) in [
                        (:sprocdat, :lprocdat), 
                        (:srawdat, :lrawdat), 
                        (:sdat, :ldat)
                    ]

                    @show sfunsym, lfunsym
                    sfun = getproperty(Mod, sfunsym)
                    lfun = getproperty(Mod, lfunsym)

                    dat0 = rand(10, 10)

                    for fargs in [
                            ("test_file", (;h = hash(dat0)), "jls"),
                            (["subdir"], "test_file", (;h = hash(dat0)), "jls"),
                        ]
                        cfile1 = sfun(dat0, fargs...; mkdir)
                        @test isfile(cfile1)
                        dat1 = lfun(fargs...)
                        @test all(dat0 .== dat1)
                        dat1 = lfun(cfile1)
                        @test all(dat0 .== dat1)
                        cfile2 = sfun(dat0, cfile1; mkdir)
                        @test cfile1 == cfile2
                        dat1 = lfun(cfile1)
                        @test all(dat0 .== dat1)
                    end
                    
                    @test lfun("NOT_A_FILE", hash(tempname()), ".jls") do
                        true
                    end
                end
            end

            ## ------------------------------------------------------------
            # save/load cache
            @info("Top cache")
            for Mod in [Top, Sub1, Sub3]

                @info("save/load cache", Mod)
                scache = Mod.scache
                lcache = Mod.lcache
                cachedir = Mod.cachedir

                dat0 = rand(10, 10)
                
                cid = (:TEST, :CACHE, hash(dat0))
                cfile = scache(dat0, cid)
                @test isfile(cfile)
                dat1 = lcache(cid)
                @test all(dat0 .== dat1)
                
                cfile = scache(dat0)
                @test isfile(cfile)
                dat1 = lcache(cfile)
                @test all(dat0 .== dat1)

            end
        end

        Top

    finally
        rm.(_TO_REMOVE; force = true, recursive = true)
    end
end