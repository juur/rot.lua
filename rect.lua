require "object"

Rect = Class:newClass("Rect", Object)

function Rect:new(context)
	local o = Object.new(self)
	o._spacingX = 0
	o._spacingY = 0
	o._canvasCache = {}
	o._options = {}
	o.cache = false
	o._context = context
	return o
end

function Rect:compute(options)
	self._canvasCache = {}
	self._options = options
	
	local charWidth = math.ceil(self._context.font:getWidth('@'))
	
	self._spacingX = math.ceil(options.spacing * charWidth)
	self._spacingY = math.ceil(options.spacing * self._context.font:getHeight())
	
	local canvas = love.graphics.newCanvas(
		options.width * self._spacingX,
		options.height * self._spacingY
	)
	
	self._context.canvas = canvas
	
	love.window.setMode(canvas:getWidth(), canvas:getHeight())
end

function Rect:draw(data, clearBefore)
	if Rect.cache then
		self:_drawWithCache(data, clearBefore)
	else
		self:_drawNoCache(data, clearBefore)
	end
end

function Rect:_drawNoCache(data, clearBefore)
	local x,y,ch,_fg,_bg = data[1],data[2],data[3],data[4],data[5]
	
	if(x<0 or y<0 or x>80 or y>25) then return end
	
	local fg = (type(_fg)=='table') and _fg or toRGB(_fg)
	local bg = (type(_bg)=='table') and _bg or toRGB(_bg)
	
	if clearBefore then
		local b = self._options.border
		
		love.graphics.setColor(bg[1],bg[2],bg[3],bg[4])
		love.graphics.rectangle(
			'fill',
			x * (self._spacingX + b),
			y * (self._spacingY + b),
			self._spacingX - b,
			self._spacingY - b
		)
	end
	
	if not ch then 
		return 
	end
	
	love.graphics.setColor(fg[1],fg[2],fg[3],fg[4])
	
	for c in ch:gmatch(".") do
		love.graphics.printf(
			c,
			x * self._spacingX,
			y * self._spacingY,
			self._spacingX,
			'center'
		)
	end
end
