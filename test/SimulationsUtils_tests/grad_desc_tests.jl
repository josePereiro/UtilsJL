function test_grad_desc()

    # Vectorize
    for i in 1:10
        target = [10.0 * rand() + 5.0, 10.0 * rand() + 5.0]
        x0 = [0.0, 0.0]
        x1 = [0.1, 0.1]
        maxΔ = [1.0, 1.0]
        f(xs) = (xs .^ [1, 2]) .+ reverse(xs)
        th = 1e-10
        xs = Utils.grad_desc_vec(f;target, x0, x1, maxΔ, th)
        @test all(isapprox.(f(xs), target; atol = 1e-8))
    end

    # Vectorize
    for i in 1:10
        target = 10.0 * rand() + 5.0
        x0 = 0.0
        x1 = 0.1
        maxΔ = 1.0
        f(xs) = xs ^ 2 
        th = 1e-10
        xs = Utils.grad_desc_vec(f;target, x0, x1, maxΔ, th)
        @test all(isapprox.(f(xs), target; atol = 1e-8))
    end

end