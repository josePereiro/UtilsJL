function _io_print(print_fun, headline, dat, file, more...)
    print_fun(headline, 
        "\ndir: ", relpath(dirname(abspath(file))),
        "\nfile: ", basename(file),
        "\nsize: ", filesize(file), " bytes",
        "\ndata type: ", typeof(dat),
        more...,
        "\n"
    )
end

function _io_error_print(print_fun, err, file, more...)
    print_fun("ERROR", 
        "\ndir: ", relpath(dirname(abspath(file))),
        "\nfile: ", basename(file),
        "\nerr: ", err_str(err),
        more...,
        "\n"
    )
end