Class = {
	classes = {},
	
	newClass = function (self,name,super)
		assert(self and name and type(self) == 'table' and type(name) == 'string', 
			"Invalid arguments to Class.newClass(self,name[,super])")
		
		if Class.classes[name] then
			return Class.classes[name]
		end
		
		if super then 
			assert(type(super) == 'table' and super.__className, 
				"Invalid superclass passed to newClass(self,name,[,super])")
		end
		
		local o = {
			__className 	= name,
			__superClass 	= super or nil,
		}
		
		-- The __index field is used where we (the class object) is a metatable
		o.__index = o
		-- Obtain our __index via our parent class
		setmetatable(o, super)
	
		Class.classes[name] = o
	
		return o
	end,
	
	new = function (self)
		assert(self and type(self) == 'table',
			"Invalid arguments to Class.new(self)")
		assert(self.__className and type(self.__className) == 'string',
			"Invalid class passed to Class.new(self)")
		
		local o = {
			__class			= self
		}
		-- Link this new object to its class
		setmetatable(o,self)
		return o
	end
}