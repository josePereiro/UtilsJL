function walkargs(f::Function, ex::Expr)
    for (argi, arg) in enumerate(ex.args)
        f(ex, argi)
        arg isa Expr && walkargs(f, arg)
    end    
end

macro proto(struct_exp)
    # Check input
    (typeof(struct_exp) != Expr || struct_exp.head != :struct) && 
        error("An struct constructor expected!!!")
    
    # Change name
    name = struct_exp.args[2]
    rname = Symbol(name, rand(UInt128))
    walkargs(struct_exp) do ex, argi
        if ex.args[argi] == name
            ex.args[argi] = rname
        end
    end

    # Assigment
    assig_exp = :($name = $rname)
    
    return quote
        $(esc(struct_exp))
        $(esc(assig_exp))
    end
end