require "object"
require "display"
require "arena"
require "simple"
require "engine"
require "player"
require "lighting"
require "preciseshadowcasting"

Game = Class:newClass("Game", Object) 

function Game:new()
	local o = Class.new(self)
	o.display = {}
	o.map = {}
	o.engine = {}
	o.scheduler = {}
	o.player = {}
	return o
end	

function Game:init()
	self.display = Display:new()
	self:generateMap();

	self.scheduler = Simple:new()
	self.scheduler:add(self.player, true)
	
	self.engine = Engine:new(self.scheduler)
	self.engine:start()
	
	self:redraw()
end

function Game:generateMap()
	local digger = Arena:new()

	digCallback = function(x, y, value) 
		local key = x..","..y
		if value == 1 then
			self.map[key] = "#"
		else
			self.map[key] = "."
		end
	end

	digger:create(digCallback)
	self.map["10"..",".."5"] = "#"
	self.map["10"..",".."6"] = "#"
	self.map["10"..",".."7"] = "#"

	self:createPlayer()	
end

function Game:createPlayer()
	self.player = Player:new(10,10)
end

function Game:draw(xy,lightData,tile)
	tile = tile or false
	local key = xy[1]..","..xy[2]
	
	if not self.map[key] then return end
	
	self.display:draw(xy[1], xy[2], self.map[key], lightData, {10,20,50,155} )
end


function Game:redraw()
	self.display:clear()
	
	if not self.player then return end
	
	local lightData = {}
	
	local lightPasses = function(x,y)
		x = tonumber(x)
		y = tonumber(y)
		if x < 0 or y < 0 or x > 80 or y > 25 then return true end
		local key = x..","..y
		if self.map[key] and self.map[key] == "#" then return false end
		return true
	end
	
	local reflectFunc = function(x,y)
		local key = x..","..y
		if not self.map[key] then 
			return 0
		elseif self.map[key] == "#" then 
			return 1
		else 
			return 0 
		end
	end
	
	local lightCallBack = function(x,y,color)
		table.insert(lightData, {{tonumber(x),tonumber(y)},color})
	end
	
	local lighting = Lighting:new(reflectFunc, {range=10,passes=1})
	local fov = PreciseShadowcasting:new(lightPasses, {topology=8})
	
	lighting:setFOV(fov)
	lighting:setLight(self.player._x, self.player._y, {255,255,255,255})
	lighting:compute(lightCallBack)
	
	for _,v in ipairs(lightData) do
		self:draw(v[1], v[2])
	end	
end

function love.keypressed(key, isrepeat)
	game.player:handleEvent(key)
end

function love.update(dt)
end

function love.draw()
	love.graphics.setCanvas(game.display.canvas)
	love.graphics.setColor(255,255,255,255)
	love.graphics.setFont(game.display.font)

	game.display:_tick()

	love.graphics.setCanvas()
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(game.display.canvas,0,0)
end

function love.load(arg)
	if arg[#arg] == "-debug" then 
		require("mobdebug").start() 
	end
	game = Game:new()
	game:init()
end
