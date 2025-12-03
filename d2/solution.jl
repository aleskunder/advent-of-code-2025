const INPUT_PATH = "input.txt"


function read_input(path::String=INPUT_PATH)::Vector{Tuple{Int,Int}}
    line = readline(path)
    parts = split(line, ",")
    res = Vector{Tuple{Int,Int}}()
    for part in parts
        segment = Tuple(parse.(Int, split(part, "-")))
        push!(res, segment)
    end
    return res
end

function get_decimal_length(num::Int)::Int
    floor(Int, log10(num)) + 1
end

function check_number(input_num::Int, check_all::Bool=true)::Bool
    num_len = get_decimal_length(input_num)
    if check_all
        if num_len > 1 # don't check single digits
            for part_len in 1:div(num_len, 2) # min token size is 1, max is a half of number length
                if (rem(num_len, part_len) == 0) # if the number can be divided into chunks by 'part_len'
                    parts_set = Set(Int[])
                    num_left, num_right = input_num, 0
                    while num_left != 0 # keep slicing the right part until the left one is zero
                        num_left, num_right = div(num_left, 10^part_len), rem(num_left, 10^part_len)
                        push!(parts_set, num_right)
                    end
                    if length(parts_set) == 1 # if all the slices are identical
                        return true
                    end
                end
            end
        end
    else
        if (rem(num_len, 2) == 0)
            part_len = div(num_len, 2)
            if div(input_num, 10^part_len) == rem(input_num, 10^part_len)
                return true
            end
        end
    end
    return false
end

# TO DO: finish a proper way, not iterating all numbers
# function check_interval(input_segment::Tuple{Int, Int})::Int
#     sum_invalid = 0
#     seg_start, seg_end = input_segment
#     min_len = max(div(log10(seg_start)+1, 2), 1) # finding the min length of repeated part; it can't be 0
#     max_len = div(log10(seg_end) + 1, 2)
#     if max_len != 0
#         for rep_len in min_len:max_len
#             start_left, start_right = div(seg_start, 10^rep_len), rem(seg_start, 10^rep_len)
#             max_end = 
#         end
#     end
#     return sum_invalid
# end


function check_interval_dumb(input_segment::Tuple{Int,Int}, check_all::Bool=true)::Int
    sum_invalid = 0
    seg_start, seg_end = input_segment
    for num in seg_start:seg_end
        if check_number(num, check_all)
            sum_invalid += num
        end
    end
    return sum_invalid
end

# Main function
function main()
    input_v = read_input()
    total_sum = 0
    total_sum_halves = 0

    for seg in input_v
        total_sum += check_interval_dumb(seg, true)
        total_sum_halves += check_interval_dumb(seg, false)
    end
    println("Final answer:
    only halves:    $total_sum_halves
    total:          $total_sum")
    return total_sum
end


if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
