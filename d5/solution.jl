using Base.Iterators

const INPUT_PATH = "input.txt"

function read_input(path::String = INPUT_PATH)::Tuple{Vector{Tuple{Int, Int}}, Set}
	txt = read(path, String)

	parts = split(txt, "\n\n"; limit = 2)

	part1_str_list = filter(!isempty, split(parts[1], '\n'))
	prod_int_set = Set(parse.(Int, filter(!isempty, split(parts[2], '\n'))))

	tuple_list = Vector{Tuple{Int, Int}}()
	for part in part1_str_list
		segment = Tuple(parse.(Int, split(part, "-")))
		push!(tuple_list, segment)
	end

	return (tuple_list, prod_int_set)
end

# memory-heavy way of storing all fresh IDs in a set:
function bad_way(fresh_ranges_list::Vector{Tuple{Int, Int}}, avail_set::Set{Int})::Int
	function get_set_of_fresh_idx(ranges_list::Vector{Tuple{Int, Int}})::Set{Int}
		return Set(flatten(a:b for (a, b) in ranges_list))
	end

	function find_len_fresh(fresh_set::Set{Int}, avail_set::Set{Int})::Int
		return length(intersect(fresh_set, avail_set))
	end

	return find_len_fresh(get_set_of_fresh_idx(fresh_ranges_list), avail_set)
end

# this causes OutOfMemoryError()
function simple_iterative_way(fresh_ranges_list::Vector{Tuple{Int, Int}}, avail_set::Set{Int})::Int
	given_set = copy(avail_set)
	n_ranges = length(fresh_ranges_list)
	found_len = 0
	i = 1
	while length(given_set) != 0 && i <= n_ranges # we don't have to check all if we found an element already
		curr_range = fresh_ranges_list[i][1]:fresh_ranges_list[i][2]
		found_len += length(intersect(curr_range, given_set))
		setdiff!(given_set, curr_range)
		i += 1
	end
	return found_len
end

function merge_and_find_way(fresh_ranges_list::Vector{Tuple{Int, Int}}, avail_set::Set{Int})::Tuple{Int, Int}
	sorted_ranges = sort_and_merge_ranges(fresh_ranges_list)
	avail = sort!(collect(avail_set))
	return count_in_ranges(sorted_ranges, avail), total_length(sorted_ranges)
end

function sort_and_merge_ranges(fresh_ranges_list::Vector{Tuple{Int, Int}})::Vector{Tuple{Int, Int}}
	sorted_ranges = sort(fresh_ranges_list, by = x -> x[1])
	S = Tuple{Int, Int}[]
	push!(S, sorted_ranges[1])   # start with first

	for (lo, hi) in sorted_ranges[2:end]
		last_lo, last_hi = S[end]

		if lo <= last_hi + 1      # overlap or touch
			# merge into the last interval
			S[end] = (last_lo, max(last_hi, hi))
		else
			# disjoint → push new interval
			push!(S, (lo, hi))
		end
	end
	return S
end

function count_in_ranges(ranges, avail_sorted)
	total = 0
	for (lo, hi) in ranges
		# first index ≥ lo
		l = searchsortedfirst(avail_sorted, lo)
		# last index ≤ hi
		r = searchsortedlast(avail_sorted, hi)
		total += max(r - l + 1, 0)
	end
	return total
end

function total_length(ranges::Vector{Tuple{Int, Int}})::Int
	total_len = 0
	for (lo, hi) in ranges
		total_len += hi - lo + 1
	end
	return total_len
end

function main()
	fresh_ranges, avail_products_set = read_input()
	fresh_n, fresh_total_len = merge_and_find_way(fresh_ranges, avail_products_set)
	println("
	# of products available:		$(length(avail_products_set))
	# Of fresh products in the given set:	$fresh_n
	# of all fresh IDs:			$fresh_total_len")
end

if abspath(PROGRAM_FILE) == @__FILE__
	main()
end
