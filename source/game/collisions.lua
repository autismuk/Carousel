--- ************************************************************************************************************************************************************************
---
---				Name : 		collisions.lua
---				Purpose :	Carousel object.
---				Updated:	12 October 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

--- ************************************************************************************************************************************************************************
--																	Collisions Manager Object
--- ************************************************************************************************************************************************************************

local CollisionManager = Framework:createClass("game.collision.checker")

function CollisionManager:constructor(info) end 
function CollisionManager:destructor() end

--//	Get all the colliding carousel objects
--//	@gap 	[number]	Minimum gap between them, besides the radii (defaults to 0)
--//	@return [array]		Array of reference pairs indicating collisions.

function CollisionManager:getCollisions(gap)
	gap = gap or 0 																	-- default gap value
	local carouselCount,carouselTable = self:query("carousel")						-- get the number of carousels and the table of them
	local collisionList = {} 														-- list of collisions.
	if carouselCount <= 1 then return collisionList end 							-- if less than 2 there can't possibly be any collisions !
	local objectArray = {}
	local objectData = {}
	for _,obj in pairs(carouselTable) do 											-- convert from a hash to an array as it is quicker.
		objectArray[#objectArray+1] = obj 
		objectData[#objectData+1] = obj:getStatus() 								-- pick up the object data at the same time.
	end 		
	for testIndex = 1,#objectArray-1 do 											-- for each in the table, except the last one
		local obj1 = objectArray[testIndex]
		local obd1 = objectData[testIndex]
		for altIndex = testIndex+1,#objectArray do  								-- compare against every other one.
			local obj2 = objectArray[altIndex]
			local obd2 = objectData[altIndex]
			local minDist = obd1.radius + obd2.radius + gap							-- the minimum distance between centres for a collision
			if math.abs(obd1.x-obd2.x) <= minDist then 								-- check if they *might* collide, intersecting boxes first as its quicker.
				if math.abs(obd1.y-obd2.y) <= minDist then 
					local dx = obd1.x - obd2.x 										-- now do the proper calculation. 
					local dy = obd1.y - obd2.y
					if dx * dx + dy * dy < minDist * minDist then 					-- if it is actually in range.
						collisionList[#collisionList+1] = { obj1, obj2 } 			-- add to the collision list.
						--print(#collisionList,obj1.m_identifier,obj2.m_identifier)
					end
				end 
			end
		end 
	end
	return collisionList
end 

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		12-Oct-14	0.1 		Initial version of file
		21-Oct-14 	1.0 		Release One

--]]
--- ************************************************************************************************************************************************************************
