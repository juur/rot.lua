require "entity"
require "rot"

Player = Class:newClass("Player",Entity)

function Player:new()
	local o = Entity.new(self)
	o.ch = "@"
	return o
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
	
	local x,y = XY(self._key)
	local newX = x + dir[1]
	local newY = y + dir[2]
	
	local newKey = newX .. ',' .. newY
	
	if self:canMoveTo(newKey) then	
		self._level:setEntity(self, newKey)
	end
	
	game.engine:unlock()
end

