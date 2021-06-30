# ------------------------------------------------------------
function threadchannel(fun::Function, Ch::Channel; 
        nthrs::Int = nthreads(),
        skipth::Function = (thid) -> false,
    )

    @threads for _ in 1:nthrs
        thid = threadid()
        (skipth(thid) == true) && continue

        for dat in Ch
            flag = fun(thid, dat)
            flag == :break && break
            flag == :continue && continue
            flag == :return && return
        end
    end
end