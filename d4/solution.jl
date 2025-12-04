using Pkg
Pkg.activate("..")

using Printf
using DSP: conv
using ImageFiltering: imfilter, Fill

const INPUT_PATH = "input.txt"
const NEIGHBOURS_DIST = 1
const NEIGHBOUR_THR = 4

function read_input(path::String = INPUT_PATH)::Matrix{Int8}
	lines = readlines(path)
	m = length(lines)
	n = length(lines[1])
	mat = Matrix{Int8}(undef, m, n)
	@inbounds for i in 1:m, j in 1:n
		mat[i, j] = lines[i][j] == '@'
	end
	return mat
end

function print_rolls_map_aligned(mat::Matrix, thr::Int = NEIGHBOUR_THR)
	mat_chars = map(x -> x == 0 ? '.' : x >= thr ? '@' : 'x', mat)
	for row in eachrow(mat_chars)
		println(@sprintf("%-*s", size(mat, 2), join(row)))
	end
end

function show_step(mat, step)
	print("\033[2J\033[H")   # clear screen + move cursor home
	println("Step $step")
	print_rolls_map_aligned(mat)
	sleep(0.1)              # adjust animation speed
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
	return res_m
end

function dsp_convolution(mat::Matrix{Int8}, shift::Int = NEIGHBOURS_DIST)::Matrix{Int8}
	kernel = get_kernel(shift)
	res = conv(mat, kernel)
	return res[(1+shift):(end-shift), (1+shift):(end-shift)]
end

function im_filter_convolution(mat::Matrix, shift::Int = NEIGHBOURS_DIST)::Matrix{Int8}
	kernel = get_kernel(shift)

	res_float = imfilter(Float32.(mat), kernel, Fill(0.0f0))

	return Int8.(round.(res_float))
end

function find_n_rolls_removed(mat::Matrix{Int8}, shift::Int = NEIGHBOURS_DIST, thr::Int = NEIGHBOUR_THR)::Tuple{Matrix, Int}
	res_matrix = dsp_convolution(mat, NEIGHBOURS_DIST) # the quickest of three
	# order matters: if multiplied first, we don't tell "no neighbours" and "empty" apart!
	res_matrix_thr_bool = (res_matrix .< NEIGHBOUR_THR)
	n_rolls = sum(res_matrix_thr_bool .* mat)
	return res_matrix, n_rolls
end

function main()
	input_matrix = read_input()
	res_matrix, res_n = find_n_rolls_removed(input_matrix)

	println("The number of rolls removed at the first step:
		# of rolls with < $NEIGHBOUR_THR neighbours: $res_n")
	# println("Resulting map:")
	# print_rolls_map_aligned(res_matrix, NEIGHBOUR_THR)
	total_rolls_removed = 0
	removed_this_step = -1
	temp_matrix = copy(input_matrix)

	n_steps = 0
	while removed_this_step != 0
		res_matrix, removed_this_step = find_n_rolls_removed(temp_matrix)

		show_step(temp_matrix, n_steps)   # <<< animation frame

		total_rolls_removed += removed_this_step
		temp_matrix[res_matrix .< NEIGHBOUR_THR] .= 0
		n_steps += 1
		println("Rolls removed at this step: $removed_this_step.")
	end
	println("Total rolls removed: $total_rolls_removed after $n_steps steps.")
	println("Resulting map:")
	print_rolls_map_aligned(temp_matrix, NEIGHBOUR_THR)

	return res_n
end

if abspath(PROGRAM_FILE) == @__FILE__
	main()
end
