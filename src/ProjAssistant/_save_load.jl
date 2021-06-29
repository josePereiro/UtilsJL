# ------------------------------------------------------------------
function _load(file)
    if endswith(file, ".jls")
        deserialize(file)
    else
        FileIO.load(file)
    end
end

# ------------------------------------------------------------------
function _save(file, dat)
    if endswith(file, ".jls")
        serialize(file, dat)
    else
        FileIO.save(file, dat)
    end
end