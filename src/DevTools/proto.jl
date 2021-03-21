function walkargs(f::Function, ex::Expr)
    for (argi, arg) in enumerate(ex.args)
        f(ex, argi)
        arg isa Expr && walkargs(f, arg)
    end    
end

function _proto(name::Symbol, toproto_expr)
    # Change name
    rname = Symbol(name, rand(UInt128))
    walkargs(toproto_expr) do ex, argi
        if ex.args[argi] == name
            ex.args[argi] = rname
        end
    end

    # Assigment
    assig_exp = :($name = $rname)
    
    return quote
        $(esc(toproto_expr))
        $(esc(assig_exp))
    end
end

macro proto(struct_exp)
    # Check input
    (typeof(struct_exp) != Expr || struct_exp.head != :struct) && 
        error("An struct constructor expected!!!")
    
    # Change name
    name = struct_exp.args[2]
    _proto(name::Symbol, struct_exp)
end

macro proto(name_str, toproto_expr)
    # Check input
    (typeof(name_str) != String) && 
        error("The first arg must by an `String` specifing the proto name!!!")
    (typeof(toproto_expr) != Expr) && 
        error("The secund arg must be an expression!!!")
    
    # Change name
    name = Symbol(name_str)
    _proto(name::Symbol, toproto_expr)
end
