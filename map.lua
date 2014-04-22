require "object"

Map = Class:newClass("Map",Object)

function Map:new(width, height)
	local o = Object.new(self)
	o._width = width or 60
	o._height = height or 20
	return o
end

function Map:_fillmap(value)
	local map = {}
	for i=1,this._width do
		map[i] = {}
		for j=1,this._height do
			map[i][j] = value
		end
	end
	return map
end