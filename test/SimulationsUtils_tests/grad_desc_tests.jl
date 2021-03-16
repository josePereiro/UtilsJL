function test_grad_desc()

    # Vectorize
    for i in 1:1000
        target = [10.0 * rand() + 5.0, 10.0 * rand() + 5.0]
        x0 = [0.0, 0.0]
        rexps = rand(1:10, 2)
        maxΔx = 1.0 ./ rexps
        x1 = x0 .+ maxΔx .* 0.1
        gdth = 1e-10

        function up_fun(gdmodel) 
            xs = UtilsJL.gd_value(gdmodel)
            xs .^ rexps
        end
        gdmodel = UtilsJL.grad_desc_vec(up_fun; target, x0, x1, maxΔx, gdth)
        @test all(isapprox.(up_fun(gdmodel), target; atol = 1e-8))
    end

    # Scalar
    @testset begin
        for i in 1:1000
            target = 10.0 * rand() + 5.0
            x0 = 0.0
            rexp = rand(1:10)
            maxΔx = 1.0 / rexp
            x1 = x0 + maxΔx * 0.1
            maxiter = 1e4
            gdth = 1e-10

            function up_fun(gdmodel) 
                x = UtilsJL.gd_value(gdmodel)
                x ^ rexp
            end
            gdmodel = UtilsJL.grad_desc(up_fun; target, x0, x1, maxΔx, gdth, maxiter)
            @test all(isapprox.(up_fun(gdmodel), target; atol = 1e-8))
        end
    end

end
test_grad_desc()