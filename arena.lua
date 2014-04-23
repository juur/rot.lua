require "map"

Arena = Class:newClass("Arena",Map)

function Arena:new(width, height)
	return Map.new(self, width, height)
end

function Arena:create(callback)
	local w = self._width - 1
	local h = self._height - 1
	
	for i=0,w do
		for j=0,h do
			local empty = (i>0 and j>0 and i<w and j<h)
			callback(i,j,empty and 0 or 1)
		end
	end
end
