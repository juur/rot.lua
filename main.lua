require "game"

function love.keypressed(key, isrepeat)
	game.player:handleEvent(key)
end

local last = 0

function love.update(dt)
	last = last + dt
	while last > 1/60 do
		game:redraw()
		last = last - 1/60
		game:tick()
	end
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
