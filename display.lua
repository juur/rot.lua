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
		width 		= options.width 		or 20,
		height 		= options.height 		or 16,
		layout 		= options.layout 		or 'rect',
		spacing		= options.spacing 		or 1,
		border 		= options.border 		or 0,
		fontSize 	= options.fontSize 		or 32,
		fontFamily	= options.fontFamily 	or 'slkscr',
		fontStyle	= options.fontStyle 	or nil,
		fg			= options.fg 			or '#ccccccff',
		bg			= options.bg 			or '#000000ff',
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
	if not self.canvas == nil then self.canvas:clear() end
	self._data = {}
	self._dirty = true
end

function Display:setOptions(options)
	for key in pairs(options) do
		self._options[key] = options[key]
	end
	
	if options.width or options.height or options.fontSize or
		options.fontFamily or options.spacing or options.layout then
		
		local fontName = options.fontStyle 
			and options.fontFamily..'-'..options.fontStyle 
			or options.fontFamily
		
		self.font = love.graphics.newFont(
			fontName..'.ttf', 
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

function Display:draw(x,y,ch,fg,bg)
	fg = fg or self._options.fg
	bg = bg or self._options.bg
	
	local key = x..','..y
	
	self._data[key] = {x,y,ch,fg,bg}
	self:invalidate(key)
end

function Display:invalidate(xy)
	if self._dirty == true then return end
	if self._dirty == false then self._dirty = {} end
	self._dirty[xy] = true
end

function Display:_tick()	
	if self._dirty == false then 
		return
	elseif self._dirty == true then
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