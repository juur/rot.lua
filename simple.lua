require "scheduler"

Simple = Class:newClass("Simple",Scheduler)

function Simple:new()
	return Scheduler.new(self)
end

function Simple:add(item, doRepeat)
	self._queue:add(item, 0)
	return Scheduler.add(self, item, doRepeat)
end

function Simple:Next()
	if self._current and self._repeat[self._current] then
		self._queue:add(self._current, 0)
	end
	
	return Scheduler.Next(self)
end
