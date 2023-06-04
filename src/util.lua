-- util.lua

function Distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

function Clamp(val, min, max)
	if val <= min then
		val = min
	elseif max <= val then
		val = max
	end
	return val
end