require "object"

Color = Class:newClass("Color",Object)
Color._cache = {}

function Color:fromString(str)
	--assert(type(str) == 'string')

	local cached, r
	if type(str) == 'table' then
		return str
	elseif self._cache[str] then
		cached = self._cache[str]
	else
		if str:sub(1,1) == "#" then
			cached = self:toRGB(str)
			if #cached == 3 then cached[4] = 255 end
		else
			error("cannot process string '"..str.."' sub 1 is "..str:sub(1))
		end
		self._cache[str] = cached
	end
	
	return cached
end

function Color:toRGB(string)
	local bg = {}
	
	for i in string:gmatch('[0-9a-fA-F][0-9a-fA-F]') do
		bg[#bg+1] = tonumber(i,16)
	end
	
	if #bg == 3 then bg[4] = 255 end
	
	return bg
end

function Color.add_(col1,col2)
	for k=1,3 do
		col1[k] = math.min(255, col1[k] + col2[k])
	end

	return col1
end

function Color.add(col1,col2)
	local ret = {}

	for k=1,3 do
		ret[k] = math.min(255, col1[k] + col2[k])
	end

	return ret
end

function Color.interpolate(col1,col2,factor)
	factor = factor or 0.5
	local result = {}
	
	for i=1,3 do
		result[i] = Round(col1[i] + factor*(col2[i] - col1[i]))
	end
	
	return result
end


function Color.multiply_(col1,col2)
		
	for i=1,3 do
		col1[i] = col1[i] * (col2[i]/255)
		col1[i] = Round(col1[i])
	end
	
	return col1
end

function Color.multiply(col1,col2)
	local ret = {}
		
	for i=1,3 do
		ret[i] = col1[i] * (col2[i]/255)
		ret[i] = Round(ret[i])
	end
	
	return ret
end