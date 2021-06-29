## ------------------------------------------------------------
# gen proj test
_TopMod = Symbol("Top", rand(UInt))
_SubMod = Symbol("Sub", _TopMod)
_TopDir = joinpath(tempdir(), string(_TopMod))
rm(_TopDir; force = true, recursive = true)
for fun_flag in [true, false]
    try
        # ---------------------------------------------------------------------
        # verbose
        UtilsJL.ProjAssistant.set_verbose(fun_flag)

        # ---------------------------------------------------------------------
        # prepare test "project"
        @info("Test project", _TopMod, _SubMod, _TopDir)
        @eval module $(_TopMod)

            import UtilsJL
            if $(fun_flag); UtilsJL.ProjAssistant.gen_top_proj(@__MODULE__, $(_TopDir))
                else; UtilsJL.ProjAssistant.@gen_top_proj dir=$(_TopDir)
            end
            
            function __init__()
                if $(fun_flag); UtilsJL.ProjAssistant.create_proj_dirs(@__MODULE__)
                    else; UtilsJL.ProjAssistant.@create_proj_dirs
                end
            end

            module $(_SubMod)

                import UtilsJL
                if $(fun_flag); UtilsJL.ProjAssistant.gen_sub_proj(@__MODULE__)
                    else; UtilsJL.ProjAssistant.@gen_sub_proj
                end

                function __init__()
                    if $(fun_flag); UtilsJL.ProjAssistant.create_proj_dirs(@__MODULE__)
                        else; UtilsJL.ProjAssistant.@create_proj_dirs
                    end
                    
                end
            end
        end

        Top = getproperty(Main, _TopMod)
        Sub = getproperty(Top, _SubMod)

        ## ------------------------------------------------------------
        # Test
        @testset "gen_projects" begin

            ## ------------------------------------------------------------
            # TopDirs
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

            # SubDirs
            for funname in (
                    :plotsdir, :scriptsdir,
                    :procdir, :rawdir, :cachedir,  
                )
                fun = getproperty(Sub, funname)
                @test isdir(fun())

                df = fun("bla", (;A = 1), "jls")
                @test UtilsJL.ProjAssistant.isvalid_dfname(df)
                @test df == fun(df)
            end

            @test Top.istop_proj()
            @test !Sub.istop_proj()

            ## ------------------------------------------------------------
            # save/load data
            for Mod in [Top, Sub]
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
            for Mod in [Top, Sub]

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
        rm(_TopDir; force = true, recursive = true)
    end;
end