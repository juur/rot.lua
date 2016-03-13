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
	local index = #self._events + 1
	for i,v in ipairs(self._eventTimes) do
		if v > time then
			index = i
			break
		end
	end
	
	table.insert(self._events, index, event)
	table.insert(self._eventTimes, index, time)
end

function EventQueue:get()
	if #self._events == 0 then return nil end
	
	local time = table.remove(self._eventTimes,1)
	if time > 0 then
		self._time = self._time + time
		for i,v in ipairs(self._eventTimes) do
			self._eventTimes[i] = v - time
		end
	end
	
	return table.remove(self._events,1)
end

function EventQueue:remove(event)
	local found = false
	for idx,v in ipairs(self._events) do
		if v == event then found = idx break end
	end
	if not found then return false end
	self:_remove(found)
	return true
end

function EventQueue:_remove(index)
	return table.remove(self._events, index)
end
