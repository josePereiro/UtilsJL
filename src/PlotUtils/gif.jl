## ----------------------------------------------------------------------------
function plot_to_img(p::AbstractPlot; ext = "png", clear = true)
    fn = string(tempname(), ".", ext)
    try
        savefig(p, fn)
        return Images.load(fn)
    finally
        clear && rm(fn; force = true)
    end
end

## ----------------------------------------------------------------------------
function _make_mat(imgs)
    length(unique!(size.(imgs))) != 1 && error("All imgs must have the same size")
    
    w, h = size(first(imgs))
    d = length(imgs)
    img_mat = Array{RGB{N0f8}}(undef, w, h, d)
    @views for (i, img) in enumerate(imgs)
        img_mat[:, :, i] = img[:, :]
    end
    img_mat
end

## ----------------------------------------------------------------------------
function save_gif(ps::Vector, fn::AbstractString = string(tempname(), ".gif"); fps = 10.0) 
    !endswith(fn, ".gif") && error("filename must end with .gif")
    imgs = plot_to_img.(ps)
    mat = _make_mat(imgs)
    FileIO.save(fn, mat; fps)
    fn
end
save_gif(fn::AbstractString, ps::Vector; fps = 10.0) = save_gif(ps, fn; fps)

