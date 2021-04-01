const _sci_pool = Dict{Int, Symbol}()
let
    empty!(_sci_pool)
    ds = 1:10
    for d in ds
        srtf = "%0.$(d)e"
        fun = Symbol("_sci", d)
        @eval begin
            $fun(n) = @sprintf($srtf, n)
        end
        _sci_pool[d] = fun
    end
end
function sci(n; d::Int = 1) 
    d = clamp(d, 1, 10)
    scifun = getproperty(@__MODULE__, _sci_pool[d])
    scifun(n)
end