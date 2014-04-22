require "object"

Engine = Class:newClass("Engine",Object)

function Engine:new(scheduler)
	local o = Object.new(self)
	o._scheduler = scheduler
	o._lock = 1
	return o
end

function Engine:start()
	return self:unlock()
end

function Engine:lock()
	self._lock = self._lock + 1
	return self
end

function Engine:unlock()
	assert(self._lock ~= 0)
	self._lock = self._lock - 1
	
	while self._lock == 0 do
		local actor = self._scheduler:Next()
		if not actor then return self:lock() end
		
		local result = actor:act()
		
		--[[if result and result.then then
			error("not implemented")
			self:lock()
			result.then(self.unlock())
		end]]
	end
	
	return self
end
