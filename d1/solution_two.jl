const INITIAL_VAL = 50
const CIRCLE_SIZE = 100
const INPUT_PATH = "input.txt"

function read_input(path::String = INPUT_PATH)::Vector{Int}
	lines = Int[]
	open(path, "r") do file
		for line in eachline(file)
			if line[1] == 'R' # always single quotation for char
				push!(lines, parse(Int, line[2:end]))
			else
				push!(lines, -parse(Int, line[2:end]))
			end
		end
	end

	return lines
end

function count_passing_zeros(
	input::Vector{Int},
	initial_val::Int = INITIAL_VAL,
	circle_size::Int = CIRCLE_SIZE)::Int
	counter = 0
	if initial_val == 0
		counter += 1
	end

	for value in input
		initial_val += value
		if initial_val < 0
			if initial_val == value
				counter -= 1
			end
			counter -= fld(initial_val, circle_size)
			initial_val = mod(initial_val, circle_size)
		end

		if initial_val == 0
			counter += 1
		end

		if initial_val >= circle_size
			counter += fld(initial_val, circle_size)
			initial_val = mod(initial_val, circle_size)
		end
	end

	return counter
end

# Main function
function main()
	input_list = read_input()
	ans = count_passing_zeros(input_list)
	println(ans)
end

# Run main if script is executed directly
if abspath(PROGRAM_FILE) == @__FILE__
	main()
end
