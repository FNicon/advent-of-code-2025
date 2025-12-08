local extend = {}

--- get index from min max
---@param index number
---@param min number
---@param max number
---@param loop? boolean
function extend.get(index, min, max, loop)
    if (min <= index and index <= max) then
		return index
    else
		if (loop) then
	        return index % (max + 1)
		else
			if (min >= index) then
				return min
			elseif (index >= max) then
				return max
			end
		end
    end
end

function extend.lpush(index, push, min, max)
	local new_index = index - push
	local new_max = max + 1
	local ldiv = math.floor(new_index/ new_max)
	return ((new_index - min) % new_max), ldiv
end

function extend.rpush(index, push, min, max)
	local new_index = index + push
	local new_max = max + 1
	local ldiv = math.floor(new_index/ new_max)
	return ((new_index + min) % new_max), ldiv
end

function extend.test_div(a, b)
	local ffi = require("ffi")
	ffi.cdef([[
	int div(int a, int b);
	]])
	local c = math.floor(a/ b) 
	local d = ffi.C.div(a, b)
	return math.floor(a/ b) ~= ffi.C.div(a, b)
end

return extend