require "class"

Object = Class:newClass("Object")

function Object:new()
	return Class.new(self)
end

function findTable(table, item)
	for i,v in pairs(table) do
		if v == item then return i end
	end
	
	return false
end


function getXY(key)
	assert(key and type(key) == 'string')
	
	local r = {}

	for i in key:gmatch("%d+") do
		r[#r+1] = i
	end

	return r[1],r[2]
end

function Splice(t, index, howMany, ...)
	assert(t and index and howMany)
	local arg = {...}
    local removed = {}
    local tableSize = #t--table.getn(t) -- Table size
    local argNb = #arg -- Number of elements to insert
    -- Check parameter validity
    if index < 1 then index = 1 end
    if howMany < 0 then howMany = 0 end
    if index > tableSize then
        index = tableSize + 1 -- At end
        howMany = 0 -- Nothing to delete
    end
    if index + howMany - 1 > tableSize then
        howMany = tableSize - index + 1 -- Adjust to number of elements at index
    end

    local argIdx = 1 -- Index in arg
    -- Replace min(howMany, argNb) entries
    for pos = index, index + math.min(howMany, argNb) - 1 do
        -- Copy removed entry
        table.insert(removed, t[pos])
        -- Overwrite entry
        t[pos] = arg[argIdx]
        argIdx = argIdx + 1
    end
    argIdx = argIdx - 1
    -- If howMany > argNb, remove extra entries
    for i = 1, howMany - argNb do
        table.insert(removed, table.remove(t, index + argIdx))
    end
    -- If howMany < argNb, insert remaining new entries
    for i = argNb - howMany, 1, -1 do
        table.insert(t, index + howMany, arg[argIdx + i])
    end
    return removed
end

function Round(val, decimal)
  local exp = decimal and 10^decimal or 1
  return math.ceil(val * exp - 0.5) / exp
end