const INPUT_PATH = "input.txt"


function read_input(path::String=INPUT_PATH)::Vector{String}
    return readlines(path)
end

function max_n_digit_list_search(num_str::String, res_len::Int=2)::Int
    num_digits = [c - '0' for c in num_str]   # array of Ints from Chars; works only for digits!
    input_len = length(num_digits)
    res_digits = fill(-1, res_len)
    # find the largest left n candidate, while checking for the right on
    for (index, value) in enumerate(num_digits)
        # find the min result index we can work with:
        checked_index = max(res_len + index - input_len, 1)
        while  checked_index <= res_len
            if res_digits[checked_index] >= value
                # println("checked_index: $checked_index and skipped forward bc digit at i=$checked_index = $(res_digits[checked_index]) >= $value")
                checked_index += 1
                
            else
                # println("checked_index: $checked_index and changed digit at i=$checked_index from $(res_digits[checked_index]) to $value")
                res_digits[checked_index] = value
                res_digits[checked_index+1:end] .= -1
                break
            end
        end
    end
    return reduce((acc, d) -> acc*10 + d, res_digits)
end

function max_n_digit_stack_search(num_str::String, res_len::Int)::Int
    num_digits = [c - '0' for c in num_str]   # array of Ints from Chars; works only for digits!
    n = length(num_str)
    stack = Vector{Int}()
    max_drop = n - res_len  # how many digits we can drop

    for d in num_digits
        while !isempty(stack) && stack[end] < d && max_drop > 0
            pop!(stack)
            max_drop -= 1
        end
        push!(stack, d)
    end

    # Keep only the first res_len digits
    return reduce((acc, x) -> acc*10 + x, stack[1:res_len])
end


function main()
    input_v = read_input()
    total_sum_two_digits = sum(max_n_digit_list_search.(input_v, 2))
    total_sum_twelve_digits = sum(max_n_digit_list_search.(input_v, 12))

    println("Final answer:
        two digits sum:     $total_sum_two_digits
        twelve digits sum:  $total_sum_twelve_digits")
    return total_sum_two_digits, total_sum_twelve_digits
end


if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
