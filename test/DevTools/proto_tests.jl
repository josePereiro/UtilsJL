function proto_tests()

    @test @eval begin
        UtilsJL.DevTools.@proto struct TestStruct
            w::Float64
            x::Float64
            y::Float64
            
            TestStruct() = new()
            TestStruct(x) = TestStruct()
        end
        
        testfun(b::TestStruct) = fieldnames(TestStruct)
        testfun(TestStruct()) == testfun(TestStruct(1)) == (:w, :x, :y)
    end
    @test @isdefined TestStruct

    @test @eval begin
        UtilsJL.DevTools.@proto struct TestStruct
            w::Float64
            x::Float64
            y::Float64
            z::Float64
            
            TestStruct() = new()
            TestStruct(x) = TestStruct()
        end
        
        testfun(b::TestStruct) = fieldnames(TestStruct)
        testfun(TestStruct()) == testfun(TestStruct(1)) == (:w, :x, :y, :z)
    end
    @test @isdefined TestStruct
end
proto_tests()