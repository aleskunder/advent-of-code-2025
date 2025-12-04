################################################
# testing speed part: is numerical or string way better?
################################################
using BenchmarkTools

function check_number_str(n)
	s = string(n)
	L = length(s)
	if L > 1 && L % 2 == 0
		k = div(L, 2)
		return s[1:k] == s[(k+1):end]
	end
	return false
end

function get_decimal_length(num::Int)::Int
	floor(Int, log10(num)) + 1
end

function check_number_math(n)
	L = get_decimal_length(n)
	if L > 1 && L % 2 == 0
		k = div(L, 2)
		pow_ten = 10^k
		return div(n, pow_ten) == rem(n, 1pow_ten)
	end
	return false
end

function compare_speed()
	nums = rand((10^2):(10^6), 10000)
	@btime sum(check_number_str.($nums))
	@btime sum(check_number_math.($nums))
end

############################################
if abspath(PROGRAM_FILE) == @__FILE__
	compare_speed()
	#  450.645 μs (38189 allocations: 1.17 MiB)
	#  174.107 μs (3 allocations: 1.39 KiB)
end
