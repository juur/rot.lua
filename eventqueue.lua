require "object"

EventQueue = Class:newClass("EventQueue",Object)

function EventQueue:new()
	local o = Object.new(self)
	o._time = 0
	o._events = {}
	o._eventTimes = {}
	return o
end

function EventQueue:getTime()
	return self._time
end

function EventQueue:clear()
	self._events = {}
	self._eventTimes = {}
	return self
end

function EventQueue:add(event, time)
	local index = #self._events
	for i in ipairs(self._eventTimes) do
		if self._eventTimes(i) > time then
			index = i
			break
		end
	end
	
	table.insert(self._events, index, event)
	table.insert(self._eventTimes, index, time)
end

function EventQueue:get()
	if #self._events == 0 then return nil end
	
	local time = table.remove(self._eventTimes,0)
	if time > 0 then
		self._time = self._time + time
		for i in ipairs(self._eventTimes) do
			self._eventTimes[i] = self._eventTimes[i] - time
		end
	end
	
	return table.remove(self._events,0)
end

function EventQueue:remove(event)
	local found = false
	for idx in pairs(self._events) do
		if self._events[idx] == event then found = idx break end
	end
	if not found then return false end
	self:_remove(found)
	return true
end

function EventQueue:_remove(index)
	table.remove(self._events, index)
end
