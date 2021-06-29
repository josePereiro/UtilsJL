## ----------------------------------------------------------------------------
const RED_PIX = RGB{N0f8}(1.0,0.0,0.0)
const GREEN_PIX = RGB{N0f8}(0.0,1.0,0.0)
const BLUE_PIX = RGB{N0f8}(0.0,0.0,1.0)
const BLACK_PIX = RGB{N0f8}(0.0,0.0,0.0)
const WHITE_PIX = RGB{N0f8}(1.0,1.0,1.0)

## ----------------------------------------------------------------------------
function add_margin(a::Matrix, topm::Int, botm::Int, leftm::Int, rightm::Int, tofill)
    M, N = size(a)
    new_a = fill(tofill, M + topm + botm, N + leftm + rightm)
    M, N = size(new_a)
    new_a[(topm + 1):(M - botm), (leftm + 1):(N - rightm)] .= a
    new_a
end
add_margin(a::Matrix, m::Int, tofill) = add_margin(a, m, m, m, m, tofill)

## ----------------------------------------------------------------------------
function _auto_layout(d)
    w = round(Int, sqrt(d), RoundUp)
    h = round(Int, d / w, RoundUp)
    @assert w * h >= d
    (w, h)
end

## ----------------------------------------------------------------------------
function centered(a, nM, nN, tofill)
    any((nM, nN) .< size(a))  && error("a($(size(a))) do not fit in nsize($nM, $nN)")
    M, N = size(a)
    topm = div(nM - M, 2)
    botm = nM - M - topm
    leftm = div(nN - N, 2)
    rightm = nN - N - leftm
    add_margin(a, topm, botm, leftm, rightm, tofill)
end
centered(a, gsize, tofill) = centered(a, gsize..., tofill)

## ----------------------------------------------------------------------------
function make_grid(arrs::Vector{Matrix{T}};
        layout = _auto_layout(length(arrs)),
        margin::Int = 5, 
        tofill = zero(T)
    ) where {T}
    rows, cols = layout
    
    M = maximum(first.(size.(arrs))) + 2 * margin
    N = maximum(last.(size.(arrs))) + 2 * margin

    grid = Matrix{T}(undef, rows * M, cols * N)
    c = 1
    for row in 1:rows
        for col in 1:cols
            centered_a = c > length(arrs) ? tofill : centered(arrs[c], (M, N), tofill)
            ri = (row - 1) * M + 1
            ci = (col - 1) * N + 1
            grid[ri:ri + M - 1, ci:ci + N - 1] .= centered_a
            c += 1
        end
    end
    grid
end

function make_grid(ps::Vector{T}; 
            layout = _auto_layout(length(ps)),
            margin::Int = 5, 
            tofill = WHITE_PIX
        ) where (T<:AbstractPlot) 
    imgs = plot_to_img.(ps)
    make_grid(imgs; layout, margin, tofill)
end

