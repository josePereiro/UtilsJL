export MASTERW, set_MASTERW, print_inmw, println_inmw, print_ifmw, println_ifmw, 
       tagprint_inmw, tagprintln_inmw, tagprint_ifmw, tagprintln_ifmw
"""
    The id of the master worker
"""
MASTERW = 1
set_MASTERW(w) = (global MASTERW = w)

print_inmw(ss...) = (remotecall_wait(Core.print, MASTERW, ss...); nothing)
println_inmw(ss...) = (remotecall_wait(Core.println, MASTERW, ss...); nothing)
print_ifmw(ss...) = myid() == MASTERW ? Core.print(ss...) : nothing
println_ifmw(ss...) = myid() == MASTERW ? Core.println(ss...) : nothing


function wtag(io::IO)
    ws = min(displaysize(io) |> last, 80) 
    return lpad(
        string(
            " Worker ", myid(), " (", getpid(), ")",
            " [", Time(now()), "] "
        ), 
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

