const INITIAL_VAL = 50

function read_input(path::String="input.txt")::Vector{Int}
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

function count_zeros(input::Vector{Int}, initial_val::Int=INITIAL_VAL)::Int
    counter = 0
    if initial_val == 0
        counter += 1
    end

    for value in input
        initial_val += value
        if initial_val % 100 == 0
            counter += 1
        end
    end

    return counter
end

# Main function
function main()
    input_list = read_input()
    ans = count_zeros(input_list)
    println(ans)
end


# Run main if script is executed directly
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
