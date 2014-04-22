Color = Class:newClass("Color",Object)
Color._cache = {}

function Color:fromString(str)
	--assert(type(str) == 'string')
	
	local cached, r
	if self._cache[str] then
		cached = self._cache[str]
	else
		if str:sub(1) == "#" then
			cached = toRGB(str)
			if #cached == 3 then cached[4] = 255 end
		else
			error("cannot process string '"..str.."'")
		end
		self._cache[str] = cached
	end
	
	return cached
end

function Color.add_(col1,col2)
	--assert(type(col1)=='table' and type(col2)=='table')
	--assert(#col1 >= 3 and #col2 >= 3)

	for k=1,3 do
		col1[k] = math.min(255, col1[k] + col2[k])
	end

	return col1
end

		