using Pkg
Pkg.activate("..")
################################################
# testing speed part: Custom convolution vs DSP vs IMG Filtering
################################################

using BenchmarkTools: @btime
using DSP: conv
using ImageFiltering: imfilter, Fill

const INPUT_PATH = "input.txt"
const NEIGHBOURS_DIST = 1
const NEIGHBOUR_THR = 4

function read_input(path::String = INPUT_PATH)::Matrix{Int8}
	lines = readlines(path)
	mat_bool = Int8[c == '@' for line in lines for c in line]
	mat_bool = transpose(reshape(mat_bool, length(lines), length(lines[1])))
	return mat_bool
end

function get_kernel(shift::Int)::Matrix{Int8}
	kernel = ones(Int8, 2 * shift + 1, 2 * shift + 1)
	kernel[shift+1, shift+1] = 0
	return kernel
end

function get_single_border_values(shift::Int, max_len::Int)::Tuple{Int, Int}
	return (max(1 + shift, 1), min(max_len + shift, max_len))
end

function get_two_border_values(m_size::Tuple{Int, Int}, x_shift::Int = 0, y_shift::Int = 0)::Tuple{Int, Int, Int, Int}
	dim_x, dim_y = m_size
	left_x, right_x = get_single_border_values(x_shift, dim_x)
	top_y, bot_y = get_single_border_values(y_shift, dim_y)
	return (left_x, right_x, top_y, bot_y)
end

function shift_matrix(m::Matrix{Int8}, x_shift::Int = 0, y_shift::Int = 0)::Matrix{Int8}
	left_x, right_x, top_y, bot_y = get_two_border_values(size(m), x_shift, y_shift)
	return m[left_x:right_x, top_y:bot_y]
end

function custom_convolution(m::Matrix{Int8}, shift::Int = NEIGHBOURS_DIST)::Matrix{Int8}
	dim_x, dim_y = size(m)
	res_m = zeros(Int8, dim_x, dim_y)
	for x in (-shift):shift, y in (-shift):shift
		# don't take the matrix itself
		if x != 0 || y != 0
			# println("For shift $x, $y...")
			left_x, right_x, top_y, bot_y = get_two_border_values(size(res_m), -x, -y)
			res_m[left_x:right_x, top_y:bot_y] += shift_matrix(m, x, y)
			# println("matrix after:")
			# display(res_m)
		end
	end
	return res_m .* m
end

function dsp_convolution(mat::Matrix{Int8}, shift::Int = NEIGHBOURS_DIST)::Matrix{Int8}
	kernel = get_kernel(shift)
	res = conv(mat, kernel)
	return res[(1+shift):(end-shift), (1+shift):(end-shift)] .* mat
end

function im_filter_convolution(mat::Matrix, shift::Int = NEIGHBOURS_DIST)::Matrix{Int8}
	kernel = get_kernel(shift)

	res_float = imfilter(Float32.(mat), kernel, Fill(0.0f0))

	return Int8.(round.(res_float)) .* mat
end

function compare_speed()
	input_matrix = read_input()

    println("The performance of custom, DSP and IMG convolution:")
    @btime custom_convolution($input_matrix, $NEIGHBOURS_DIST)
    @btime dsp_convolution($input_matrix, $NEIGHBOURS_DIST)
    @btime im_filter_convolution($input_matrix, $NEIGHBOURS_DIST)
end

############################################
if abspath(PROGRAM_FILE) == @__FILE__
	compare_speed()
    # The performance of custom, DSP and IMG convolution:
    # 96.612 μs (78 allocations: 481.98 KiB)
    # 17.753 μs (11 allocations: 56.79 KiB)
    # 200.586 μs (32 allocations: 247.12 KiB)
end