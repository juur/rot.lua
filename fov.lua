require "object"
require "rot"
table.inspect = require "inspect"

FOV = Class:newClass("FOV",Object)

function FOV:new(cb, options)
	local o = Object.new(self)
	
	options = options or {}
	
	o._lightPasses = cb	
	o._options = {
		topology = 8
	}
	
	for key,val in pairs(options) do
		o._options[key] = val
	end
	
	return o
end

function FOV:_getCircle(cx,cy,r)
	local result = {}
	local dirs, countFactor
	local startOffset = {}
	
	if self._options.topology == 4 then
		dirs = {
			[0] = ROT.DIRS[8][7],
			ROT.DIRS[8][1],
			ROT.DIRS[8][3],
			ROT.DIRS[8][5]
		}
		countFactor = 1
		startOffset = {0,1}
	elseif self._options.topology == 6 then
		dirs = ROT.DIRS[6]
		countFactor = 1
		startOffset = {-1,1}
	elseif self._options.topology == 8 then
		dirs = ROT.DIRS[4]
		countFactor = 2
		startOffset = {-1,1}
	else
		error("Unknown topology of "..self._options.topology)
	end

	local x = cx + (startOffset[1] * r)
	local y = cy + (startOffset[2] * r)
	
	for i=0,#dirs do
		for _=1,r*countFactor do
			table.insert(result,{x,y})
			x = x + dirs[i][1]
			y = y + dirs[i][2]
		end
	end
	
	return result
end