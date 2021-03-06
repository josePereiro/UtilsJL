function run_OnDiskMonitor_tests()
    n = 1000
    m = UtilsJL.SimulationUtils.OnDiskMonitor(@__DIR__, "monitor_test.jld2"; dt = 1.0)
    UtilsJL.SimulationUtils.reset!(m)
    UtilsJL.SimulationUtils.clear_file(m)
    @assert isempty(m.cache)
    @assert !isfile(m.file)

    # Watch task (It can be in another process)
    tests_results = []
    cvals = []
    @async UtilsJL.SimulationUtils.watch(m) do ddat
        isempty(ddat) && return
        check = true
        dvals = ddat[:vals]
        for dval in dvals
            check &= dval in cvals
        end
        push!(tests_results, check)
    end

    # Fake job to monitor
    for i in 1:n
        push!(cvals, i)
        UtilsJL.SimulationUtils.record!(m) do dat
            dat[:vals] = cvals
        end
        sleep(5.0/n)
    end
    UtilsJL.SimulationUtils.reset!(m)
    sleep(1.0)
    
    @test isempty(m.cache)
    @test length(cvals) == n
    @test all(tests_results)

    UtilsJL.SimulationUtils.clear_file(m)
    @test !isfile(m.file)
end
run_OnDiskMonitor_tests()