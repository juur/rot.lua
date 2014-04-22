require "object"
require "rot"

Player = Class:newClass("Player",Object)

function Player:new(x,y)
	local o = Object.new(self)
	o._x = x
	o._y = y
	o:_draw()
	return o
end

function Player:_draw()
	game.display:draw(
		self._x, self._y, 
		"@", 
		"#ff0000"
	)
end

function Player:act()
	game.engine:lock()
end

function Player:handleEvent(e)
	local d
	
	if e == 'up' then d = 0
	elseif e == 'right' then d = 1
	elseif e == 'down' then d = 2
	elseif e == 'left' then d = 3
	else return end
	
	local dir = ROT.DIRS[4][d]
	
	local newX = self._x + dir[1]
	local newY = self._y + dir[2]
	local newKey = newX .. ',' .. newY
	
	if canMoveTo(self, newKey) then		
		game.display:draw(
			self._x, self._y,
			game.map[self._x..','..self._y]
		)
		self._x = newX
		self._y = newY
		self:_draw()
		game:redraw()
	end
	
	game.engine:unlock()
end

function canMoveTo(e, k)
	d = game.map[k]
	if d == "#" then 
		return false
	end
	return true
end