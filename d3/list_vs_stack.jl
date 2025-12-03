################################################
# testing speed part: is numerical or string way better?
################################################
using BenchmarkTools

INPUT_NUMBER_LEN = 100


function random_digit_strings(n::Int, len::Int)
    return [join(rand('0':'9', len)) for _ in 1:n]
end

function max_n_digit_list_search(num_str::String, res_len::Int=2)::Int
    num_digits = [c - '0' for c in num_str]   # array of Ints from Chars; works only for digits!
    input_len = length(num_digits)
    res_digits = fill(-1, res_len)
    # find the largest left n candidate, while checking for the right on
    for (index, value) in enumerate(num_digits)
        # find the min result index we can work with:
        checked_index = max(res_len + index - input_len, 1)
        while checked_index <= res_len
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
    return reduce((acc, d) -> acc * 10 + d, res_digits)
end

function max_n_digit_stack_search(num_str::String, res_len::Int)::Int
    # a quicker implementation
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
    return reduce((acc, x) -> acc * 10 + x, stack[1:res_len])
end


function max_n_digit_stack_prealloc(num_str::String, res_len::Int, stack::Vector{Int})::Int
    n = length(num_str)
    empty!(stack)                   # reuse buffer
    max_drop = n - res_len          # how many digits we can drop

    for c in num_str
        d = c - '0'
        while !isempty(stack) && stack[end] < d && max_drop > 0
            pop!(stack)
            max_drop -= 1
        end
        push!(stack, d)
    end

    # Combine first res_len digits into number
    return reduce((acc, x) -> acc * 10 + x, stack[1:res_len])
end

function compare_speed()
    n_samples = 1000
    input_v = random_digit_strings(n_samples, INPUT_NUMBER_LEN)

    for compared_val in [2, 12, 52]
        stack_buf = Vector{Int}(undef, compared_val)  # preallocate maximum needed
        println("For len of $compared_val, the performance of list, stack and allocated stack:")
        @btime sum(sum(max_n_digit_list_search.($input_v, $compared_val)))
        @btime sum(sum(max_n_digit_stack_search.($input_v, $compared_val)))
        @btime sum(sum(max_n_digit_stack_prealloc.($input_v, $compared_val, Ref($stack_buf))))
    end


end


############################################
if abspath(PROGRAM_FILE) == @__FILE__
    compare_speed()


# For len of 2, the performance of list, stack and allocated stack:
#   343.129 μs (4003 allocations: 992.26 KiB)
#   886.378 μs (7995 allocations: 1.42 MiB)
#   737.997 μs (2003 allocations: 86.01 KiB)
# For len of 12, the performance of list, stack and allocated stack:
#   964.187 μs (4003 allocations: 1.05 MiB)
#   968.606 μs (8003 allocations: 1.50 MiB)
#   756.559 μs (2003 allocations: 164.13 KiB)
# For len of 52, the performance of list, stack and allocated stack:
#   831.287 μs (4003 allocations: 1.35 MiB)
#   894.852 μs (9003 allocations: 2.92 MiB)
#   668.215 μs (2003 allocations: 476.63 KiB)


end
