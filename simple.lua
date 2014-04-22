require "scheduler"

Simple = Class:newClass("Simple",Scheduler)

function Simple:new()
	local o = Scheduler.new(self)
	return o
end

function Simple:add(item, doRepeat)
	self._queue:add(item, 0)
	return Scheduler.add(self, item, doRepeat)
end

function Simple:Next()
	if self._current and findTable(self._repeat, self._current) then
		self._queue:add(self._current, 0)
	end
	
	return Scheduler.Next(self)
end

	