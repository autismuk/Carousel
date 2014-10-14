--- ************************************************************************************************************************************************************************
---
---				Name : 		leveldescriptor.lua
---				Purpose :	Level Descriptor Object
---				Updated:	13 October 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************


--- ************************************************************************************************************************************************************************
--																	Level Descriptor Object
--- ************************************************************************************************************************************************************************

local LevelDescriptor = Framework:createClass("game.leveldescriptor")

function LevelDescriptor:constructor(info) end 
function LevelDescriptor:destructor() end

function LevelDescriptor:get(levelNumber)
	local descriptor = {}																			-- default empty descriptor.
	descriptor.rotation = { start = 120, min = 120,max = 360, acc = 0 }
	descriptor.velocity = { start = 100,min = 100,max = 1974, collide = 105 }
	descriptor.wrappable = false
	descriptor.collidable = true
	descriptor.reversable = true
	return { descriptor = descriptor, count = 2, segments = 4, time = 22 }
end 

function LevelDescriptor:getCount()
	return 36 
end 

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		13-Oct-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
