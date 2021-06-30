function test_IterChunk(iter, chnklen)

    # ---------------------------------------------------------
    # filterless
    chnkgens = UtilsJL.GeneralUtils.chunks(iter; chnklen)
    chnks = collect.(chnkgens)
    # chnks = UtilsJL.GeneralUtils.chunks(iter; chnklen)
    
    # correct layout
    @test maximum(length.(chnks)) == chnklen

    # all the same
    itervec = vec(collect(iter))
    chunkvec = vec(collect(Iterators.flatten(chnks)))
    @test all(itervec .== chunkvec)

    SizeType = Base.IteratorSize(iter)
    if !(SizeType isa Base.SizeUnknown)
        @test length(iter) == sum(length.(chnks))

        nchnks = length(chnks)
        chnks2 = UtilsJL.GeneralUtils.chunks(iter; nchnks)
        chunkvec2 = vec(collect(Iterators.flatten(chnks2)))
        @test all(itervec .== chunkvec2)
    end

end

let
    N = 10
    chnklen = 11
    N0 = 10 * chnklen

    for iter in [
            [1:(N0 + i) for i in 1:N]..., 
            [(N0 + i):-1:1 for i in 1:N]..., 
            [0.0:0.1:(N0 + i) for i in 1:N]..., 
            [0.0:0.1:(N0 + i) for i in 1:N]..., 
            [(N0 + i):-0.1:0.0 for i in 1:N]..., 
            [(k for k in 1:(N0 + i)) for i in 1:N]...,
            [(k for k in 1:(N0 + i) if isodd(k)) for i in 1:N]...,
            Iterators.product(1:50, collect(10:50), ["A", "B"]),
            [Set(rand(N0 + i)) for i in 1:N]..., 
            string(rand('A':'Z', 100)...),
            rand(100),
            view(rand(100), :),
            rand(100, 10),
            rand(100, 10, 3),
        ]

        iterT = typeof(iter)
        @info("Testing chunks", iterT)

        test_IterChunk(iter, chnklen)
    end
end