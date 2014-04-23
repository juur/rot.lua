require "object"
require "color"

Lighting = Class:newClass("Lighting",Object)

function Lighting:new(cb, options)
	local o = Object.new(self)
	options = options or {}
	
	o._options = {
		passes = 1,
		emissionThreshold = 100,
		range = 10,
	}
	o._fov = nil
	o._refCallback = cb
	o._lights = {}
	o._reflectivityCache = {}
	o._fovCache = {}
	
	o:setOptions(options)
	
	return o
end

function Lighting:setOptions(options)
	for i,v in pairs(options) do
		self._options[i] = v
	end
	if options.range then self:reset() end
	return self
end

function Lighting:setFOV(fov)
	self._fov = fov
	self._fovCache = {}
	return self
end

function Lighting:setLight(x,y,col)
	local key = x..','..y
	if(col) then
		self._lights[key] = (type(col) == 'string') 
		and Color:fromString(col) or col
	else
		self._lights[key] = nil
	end
	return self
end

function Lighting:reset()
	self._reflectivityCache = {}
	self._fovCache = {}
	return self
end

function Lighting:compute(callback)
	local doneCells = {}
	local emittingCells = {}
	local litCells = {}
	
	for key,light in pairs(self._lights) do
		if not emittingCells[key] then
			emittingCells[key] = {0,0,0,255}
		end
		Color.add_(emittingCells[key], light)
	end
	
	for i=1,self._options.passes do
		self:_emitLight(emittingCells, litCells, doneCells)
		if not i == self._options.passes then
			emittingCells = self:_computeEmitters(litCells, doneCells)
		end
	end
	
	for litKey in pairs(litCells) do
		local x,y = getXY(litKey)
		callback(x,y,litCells[litKey])
	end
	
	return self
end

function Lighting:_emitLight(emittingCells, litCells, doneCells)
	for key in pairs(emittingCells) do
		local x,y = getXY(key)
		self:_emitLightFromCell(x, y, emittingCells[key], litCells)
		doneCells[key] = true
	end
	return self
end

function Lighting:_computeEmitters(litCells, doneCells)
	local result = {}
	
	for key,color in litCells do
		if not doneCells[key] then 			
			local reflectivity
			
			if self._reflectivityCache[key] then
				reflectivity = self._reflectivityCache[key]
			else
				local x,y = getXY(key)
				reflectivity = self._refCallback(x,y)
				self._reflectivityCache[key] = reflectivity
			end
			
			if reflectivity ~= 0 then 			
				local emission = {}
				local intensity = 0
				
				for i=1,3 do
					local part = (color[i] * reflectivity)
					emission[i] = part
					intensity = intensity + part
				end
				
				if intensity > self._options.emissionThreshold then 
					result[key] = emission
				end
			end
		end
	end
	
	return result
end

function Lighting:_emitLightFromCell(x,y,color,litCells)
	local key = x..','..y
	local fov
	
	if self._fovCache[key] then
		fov = self._fovCache[key]
	else
		fov = self:_updateFOV(x,y)
	end
	
	for fovKey,formFactor in pairs(fov) do
		local result
		
		if litCells[fovKey] then
			result = litCells[fovKey]
		else
			result = {0,0,0,255}
			litCells[fovKey] = result
		end
		
		for i=1,3 do
			result[i] = math.min(255,result[i] + Round(color[i] * formFactor))
		end
	end
	
	return self
end

function Lighting:_updateFOV(x,y)	
	local key1 = x..','..y
	local cache = {}
	self._fovCache[key1] = cache
	local range = self._options.range
	local cb = function(x,y,r,vis)
		local key2 = x..','..y
		local formFactor = vis * (1-r/range)
		if (formFactor == 0) then return end
		cache[key2] = formFactor
	end
	self._fov:compute(x,y,range,cb)
	return cache
end
