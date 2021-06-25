"""
    The id of the master worker
"""
MASTERW = 1
_set_MASTERW(w) = (global MASTERW = w)
set_MASTERW(MW::Int, ws::Vector{Int} = workers()) = 
    (remotecall_wait.([_set_MASTERW], ws, [MW]); MW)

print_inmw(ss...) = (remotecall_wait(Base.print, MASTERW, ss...); nothing)
println_inmw(ss...) = (remotecall_wait(Base.println, MASTERW, ss...); nothing)
print_ifmw(ss...) = myid() == MASTERW ? Base.print(ss...) : nothing
println_ifmw(ss...) = myid() == MASTERW ? Base.println(ss...) : nothing


function wtag(io::IO)
    ws = min(displaysize(io) |> last, 80) 
    return lpad(
        string( " Worker ", myid(), " (", getpid(), ") [", Time(now()), "] "), 
        ws, "-"
    )
end

tagprint_inmw(ss...; tag::String = wtag(stdout)) = 
    !isempty(tag) ? print_inmw(tag, "\n", ss...) : print_inmw(ss...)
tagprintln_inmw(ss...; tag::String = wtag(stdout)) = 
    !isempty(tag) ? println_inmw(tag, "\n", ss...) : println_inmw(ss...)

tagprint_ifmw(ss...; tag::String = wtag(stdout)) = 
    !isempty(tag) ? print_ifmw(tag, "\n", ss...) : print_ifmw(ss...)
tagprintln_ifmw(ss...; tag::String = wtag(stdout)) = 
    !isempty(tag) ? println_ifmw(tag, "\n", ss...) : println_ifmw(ss...)

