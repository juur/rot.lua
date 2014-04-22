require "object"

Display = Class:newClass("Display",Object)

function Display:new(options)
	local o = Object.new(self)
	o._options = {}
	o._data = {}
	o._backend = nil
	o._dirty = false
	o.canvas = {}
	
	options = options or {}
	
	local defaultOptions = {
		width 		= options.width 		or 80,
		height 		= options.height 		or 25,
		layout 		= options.layout 		or 'rect',
		spacing		= options.spacing 		or 1,
		border 		= options.border 		or 0,
		fontSize 	= options.fontSize 		or 18,
		fontFamily	= options.fontFamily 	or 'lucon',
		fontStyle	= options.fontStyle 	or 'Regular',
		fg			= options.fg 			or '#ccccccff',
		bg			= options.bg 			or '#302010ff',
		tileWidth	= options.tileWidth 	or 32,
		tileHeight	= options.tileHeight 	or 32,
		tileMap		= options.tileMap 		or {},
		tileSet		= options.tileSet 		or nil
	}
		
	o:setOptions(defaultOptions)
	
	love.keyboard.setKeyRepeat(true)
	
	return o
end

function Display:clear()
	self.canvas:clear()
	self._data = {}
	self._dirty = true
end

function Display:setOptions(options)
	for key in pairs(options) do
		self._options[key] = options[key]
	end
	
	if options.width or options.height or options.fontSize or
		options.fontFamily or options.spacing or options.layout then
		
		self.font = love.graphics.newFont(
			options.fontFamily..'-'..options.fontStyle..'.ttf', 
			options.fontSize
		)
				
		if options.layout then
			if options.layout == 'rect' then
				require "rect"
				self._backend = Rect:new(self)
			else
				error('unsupported backend')
			end
		end
		
		self._backend:compute(self._options)
		self._dirty = true
	end
end

function Display:computeSize(availWidth, availHeight)
	return self._backend.computeSize(
		availWidth, availHeight, 
		self._options
	)
end

function Display:computeFontSize(availWidth, availHeight)
	return self._backend.computeFontSize(
		availWidth, availHeight,
		self._options
	)
end

function Display:draw(x,y,ch,fg,bg)
	fg = fg or self._options.fg
	bg = bg or self._options.bg
	
	self._data[x..','..y] = {x,y,ch,fg,bg}
	
	if self._dirty == true then return end
	if self._dirty == false then self._dirty = {} end
	self._dirty[x..','..y] = true
end

function Display:_tick()	
	if self._dirty == false then return end
	
	local bg = toRGB(self._options.bg)
	
	if self._dirty == true then
		for id in pairs(self._data) do
			self:_draw(id, false)
		end
	else
		for key in pairs(self._dirty) do
			self:_draw(key, true)
		end
	end
	
	self._dirty = false
end

function Display:_draw(key, clearBefore)
	local data = self._data[key]
	if data[4] ~= self._options.bg then clearBefore = true end
	
	self._backend:draw(data, clearBefore)
end


function toRGB(string)
	--assert(string)
	--assert(type(string) == 'string',"fail on"..tostring(string))
	
	local bg = {}
	
	for i in string:gmatch('[0-9a-fA-F][0-9a-fA-F]') do
		bg[#bg+1] = tonumber(i,16)
	end
	
	if #bg == 3 then bg[4] = 255 end
	
	return bg
end


