require "fov"

PreciseShadowcasting = Class:newClass("PreciseShadowcasting",FOV)

function PreciseShadowcasting:new(lightPassesCallback, options)
	return FOV.new(self,lightPassesCallback, options)
end

function PreciseShadowcasting:compute(x,y,R,callback)
	callback(x,y,0,1)
	
	if not self._lightPasses(x,y) then return end
	
	local SHADOWS = {}
	local cx,cy,blocks,A1,A2,visibility
	
	for r=1,R do
		local neighbors = self:_getCircle(x,y,r)
		local neighborCount = #neighbors
		
		-- should this be ipairs?
		for key,neighbor in ipairs(neighbors) do
			local i = key - 1
			
			cx = neighbor[1]
			cy = neighbor[2]
			
			A1 = { (i ~= 0) and (2*i-1) or (2*neighborCount-1), 2*neighborCount}
			A2 = { 2*i+1, 2*neighborCount}
			
			blocks = not self._lightPasses(cx,cy)
			visibility = self:_checkVisibility(A1,A2,blocks,SHADOWS)
			
			if visibility > 0 then
				callback(cx,cy,r,visibility)
			end
			
			if #SHADOWS == 2 and SHADOWS[1][1] == 0 
				and SHADOWS[2][1] == SHADOWS[2][2] then
				return
			end
		end
	end
end

function PreciseShadowcasting:_checkVisibility(A1,A2,blocks,SHADOWS)
	if A1[1] > A2[1] then
		local v1 = self:_checkVisibility(A1, 	{A1[2], A1[2]}, blocks, SHADOWS)
		local v2 = self:_checkVisibility({0,1}, A2, 			blocks, SHADOWS)
		return (v1+v2)/2
	end
	
	local index1 = 0
	local edge1	= false
	
	while index1 < #SHADOWS do
		local old = SHADOWS[index1+1]
		local diff = (old[1]*A1[2]) - (A1[1]*old[2])
		if diff >= 0 then
			if diff == 0 and (index1%2 == 0) then
				edge1 = true
			end
			break
		end
		index1 = index1 + 1
	end
	
	local index2 = #SHADOWS
	local edge2 = false
	
	while index2 > 0 do
		index2 = index2 - 1
		
		local old = SHADOWS[index2+1]
		local diff = A2[1]*old[2] - old[1]*A2[2]
		if diff >= 0 then
			if diff == 0 and (index2%2 ~= 0) then
				edge2 = true
			end
			index2 = index2 + 1
			break
		end
	end
	index2 = index2 - 1

	local visible = true
	
	if index1 == index2 and (edge1 or edge2) then
		visible = false
	elseif edge1 and edge2 and index1+1 == index2 and (index2%2 ~= 0) then
		visible = false
	elseif index1 > index2 and (index1%2 ~= 0) then
		visible = false
	end
	
	if not visible then return 0 end
	
	local visibleLength
	local remove = index2 - index1 + 1
	
	if (remove % 2 ~= 0) then
		if (index1 % 2 ~= 0) then
			local P = SHADOWS[index1+1]
			visibleLength = (A2[1]*P[2] - P[1]*A2[2]) / (P[2] * A2[2])
			if blocks then
				Splice(SHADOWS, index1, remove, A2);
			end
		else
			local P = SHADOWS[index2+1]
			visibleLength = (P[1]*A1[2] - A1[1]*P[2]) / (A1[2] * P[2])
			if blocks then
				Splice(SHADOWS, index1, remove, A1);
			end
		end
	else
		if (index1 % 2 ~= 0) then
			local P1 = SHADOWS[index1+1]
			local P2 = SHADOWS[index2+1]
			visibleLength = (P2[1]*P1[2] - P1[1]*P2[2]) / (P1[2] * P2[2])
			if blocks then 
				Splice(SHADOWS, index1, remove)
			end
		else
			if blocks then
				Splice(SHADOWS, index1, remove, A1, A2)
			end
			return 1
		end
	end
	
	local arcLength = (A2[1]*A1[2] - A1[1]*A2[2]) / (A1[2] * A2[2])
	
	return visibleLength/arcLength
end
