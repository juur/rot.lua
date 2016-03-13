require "object"
require "eventqueue"

Scheduler = Class:newClass("Scheduler",Object)

function Scheduler:new()
	local o = Object.new(self)
	
	o._queue = EventQueue:new()
	o._repeat = {}
	o._current = nil;
	
	return o
end

function Scheduler:getTime()
	return self._queue.getTime()
end

function Scheduler:add(item, doRepeat)
	if doRepeat then self._repeat[item] = true end
	return item
end

function Scheduler:clear()
	self._queue:clear()
	self._repeat = {}
	self._current = nil
	return self
end

function Scheduler:remove(item)
	local result = self._queue:remove(item)
	
	self._repeat[item] = nil
		
	if self._current == item then self._current = nil end
	
	return result
end

function Scheduler:Next()
	self._current = self._queue:get()
	return self._current
end
