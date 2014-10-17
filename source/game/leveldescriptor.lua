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

--//	The constructor parses the raw text data below, exported from the google docs spreadsheet, and converts it into a series of tables, one for each level.
--//	afterwards each level has a table with members defined which define that level.

 function LevelDescriptor:constructor(info) 
	self.m_rawData = {}
	local sourceText = self.rawTextData:gsub("\n","|").."|"											-- replace carriage returns with vertical bar, make sure there is a beginning one.
	local members
	while sourceText ~= "" do 
		local pos = sourceText:find("|")															-- find split
		local line = sourceText:sub(1,pos-1)														-- first bit.
		sourceText = sourceText:sub(pos+1) 															-- and the rest
		local items = self:split(line) 																-- split up into items
		if items[1]:lower() == "level" then members = items end 									-- have we found the list of headings ?
		if items[1]:match("^%d+$") ~= nil then 														-- found a level (first is a number)
			local n= items[1] * 1 																	-- convert level to a number
			self.m_rawData[n] = {} 																	-- create an empty table.
			for j = 2,#items do 																	-- copy all elements into the table
				self.m_rawData[n][members[j]] = self:process(items[j])								-- using headings as members
			end
		end
	end	
end 

--//	Process text - y and "" become boolean, % converted to multiplier, numbers to number type, strings first character only l/c
--//	@item 	[string]	item to process
--//	@return [assorted]	appropriately typed object.

function LevelDescriptor:process(item)
	if item == "" then return false end 															-- handle booleans.
	if item == "y" then return true end 
	if item:sub(-1,-1) == "%" then return (item:sub(1,-2)*1)/100 end 								-- percentages.
	if item:match("^%d+$") then return item*1 end 													-- numbers
	return item:lower():sub(1,1)																	-- text first character only.
end

--//	Tidy up

function LevelDescriptor:destructor() 
	self.m_rawData = nil 
end

--//	Split a comma seperated string into an array, spaces removed.
--//	@line 	[string]	line to split
--//	@return [array]		array of strings.

function LevelDescriptor:split(line)
	local data = {}																					-- empty table
	line = line .. ","																				-- append a comma so we know it ends in one.
	line = line:gsub("%s+","")																		-- remove spaces.
	while line ~= "" do 																			-- now split that up
		local pos = line:find(",")																	-- around commas
		data[#data+1] = line:sub(1,pos-1)															-- add to array
		line = line:sub(pos+1)
	end 
	return data 																					-- return array.
end

function LevelDescriptor.heavyRadius(time,identifier)
	local sin = math.sin(math.rad((time*20+identifier * 37) % 180))														
	local level = 1 - sin + 0.2
	return math.min(1,math.max(0,level))
end 

function LevelDescriptor.mediumRadius(time,identifier)
	local sin = math.sin(math.rad((time*15+identifier * 37) % 180))														
	local level = 1 - sin + 0.3
	return math.min(1,math.max(0,level))
end 

function LevelDescriptor.gentleRadius(time,identifier)
	local sin = math.sin(math.rad((time*10+identifier * 37) % 180))														
	local level = 1 - sin + 0.4
	return math.min(1,math.max(0,level))
end 

function LevelDescriptor.heavyAlpha(time,identifier)
	local sin = math.sin(math.rad((time*33+identifier * 45) % 180))														
	local level = 1.2 - sin*1.4
	return math.min(1,math.max(0,level))
end 

function LevelDescriptor.mediumAlpha(time,identifier)
	local sin = math.sin(math.rad((time*28+identifier * 45) % 180))														
	local level = 1.5 - sin*1.5
	return math.min(1,math.max(0,level))
end 

function LevelDescriptor.gentleAlpha(time,identifier)
	local sin = math.sin(math.rad((time*23+identifier * 45) % 180))														
	local level = 1.7 - sin*1.7
	return math.min(1,math.max(0,level))
end 

--//	Get the descriptor for the given level number.
--//	@levelNumber 	[number]	level number
--//	@skillMultiplier [number]	skill scalar - < 1 is easier - more time, slower etc.
--//	@return 		[table]		description of the level

function LevelDescriptor:get(levelNumber,skillMultiplier)
	-- print("Obtaining",levelNumber,skillMultiplier)

	skillMultiplier = skillMultiplier or 1 															-- default skill
	assert(levelNumber ~= nil and self.m_rawData[levelNumber] ~= nil)								-- check exists
	local descriptor = {}																			-- default empty descriptor.
	local level = {}																				-- and level (contains count, segments, time)
	local def = self.m_rawData[levelNumber]															-- raw data

	descriptor.rotation = { min = 0,max = 0, acc = 0 } 												-- initialise carousel descriptor.
	descriptor.velocity = { min = 0,max = 0, collide = 0 }
	descriptor.wrappable = false
	descriptor.collidable = false
	descriptor.reversable = false

	local n = 0																						-- calculate rotation for s/m/f (slow,medium,fast)
	if def.rotation == "s" then n = 20 end
	if def.rotation == "m" then n = 50 end
	if def.rotation == "f" then n = 90 end
	descriptor.rotation.min = n/2 
	descriptor.rotation.max = n * 2
	descriptor.rotation.collide = 110

	local n = 0  																					-- calculate velocity for s/m/f (slow,medium,fast)
	if def.velocity == "s" then n = 40 end 	
	if def.velocity == "m" then n = 80 end 
	if def.velocity == "f" then n = 140 end 
	descriptor.velocity.min = n/2 
	descriptor.velocity.max = n * 2
	descriptor.velocity.collide = 110

	if def.alphaFunc == "g" then descriptor.alphaFunction = LevelDescriptor.gentleAlpha end 		-- Functions.
	if def.alphaFunc == "m" then descriptor.alphaFunction = LevelDescriptor.mediumAlpha end 
	if def.alphaFunc == "h" then descriptor.alphaFunction = LevelDescriptor.heavyAlpha end 

	if def.radiusFunc == "g" then descriptor.radiusFunction = LevelDescriptor.gentleRadius end 
	if def.radiusFunc == "m" then descriptor.radiusFunction = LevelDescriptor.mediumRadius end 
	if def.radiusFunc == "h" then descriptor.radiusFunction = LevelDescriptor.heavyRadius end 


	descriptor.wrappable = def.isWrapping 															-- boolean values
	descriptor.collidable = def.isColliding
	descriptor.reversable = def.isReversable

	level.count = def.pieces 																		-- setup stuff.
	level.segments = def.segments
	level.time = def.actualTime

	level.descriptor = descriptor

	descriptor.radius = 90 																			-- calculate radius
	if level.count > 12 then descriptor.radius = descriptor.radius - (level.count-12)*3/2 end

	level.time = level.time / skillMultiplier 														-- adjust for skill level.
	descriptor.velocity.min = descriptor.velocity.min * skillMultiplier
	descriptor.velocity.max = descriptor.velocity.max * skillMultiplier
	descriptor.rotation.min = descriptor.rotation.min * skillMultiplier
	descriptor.rotation.max = descriptor.rotation.max * skillMultiplier

	return level
end 

--//	Get the number of levels.
--//	@return 	[number]	count of levels.

function LevelDescriptor:getCount()
	return #self.m_rawData
end 


--- ************************************************************************************************************************************************************************
--																	Cut and Pasted from CSV export.
--- ************************************************************************************************************************************************************************
							 																		-- whereas these lines are a direct copy.
LevelDescriptor.rawTextData = [===[
Level,pieces,segments,isRotating,isMoving,isWrapping,alphaFunc,radiusFunc,isReversable,isColliding,velocity,rotation,baseTime,special,difficulty,actualTime
1,4,3,,,,,,,,,,32,,150%,48
2,8,3,,,,,,,,,,64,,100%,64
3,10,3,,,,,,,,,,80,,100%,80
4,4,2,y,,,,,,,,Slow,32,,120%,38.4
5,8,3,y,,,,,,,,Slow,64,,100%,64
6,12,3,y,,,,,,,,Slow,96,,100%,96
7,12,4,y,,,,,,,,Slow,96,,120%,115.2
8,8,4,y,,,,Gentle,,,,Medium,64,,120%,76.8
9,6,3,,y,,,,,,Slow,,48,,120%,57.6
10,8,3,,y,y,,,,,Slow,,64,,110%,70.4
11,10,3,,y,y,,,,y,Slow,,80,,100%,80
12,12,4,,y,,,,,,Slow,,96,,100%,96
13,12,4,,y,y,,, ,y,Medium,,96,,110%,105.6
14,10,4,,y,,Gentle,Gentle,y,,,,80,,100%,80
15,6,3,y,y,,,,,y,Slow,Slow,48,,100%,48
16,10,3,y,y,,,,,y,Slow,Slow,80,,100%,80
17,12,4,y,y,,,,,y,Slow,Medium,96,,100%,96
18,10,5,y,y,,,,,y,Medium,Medium,80,,100%,80
19,12,6,y,y,,,,,y,Medium,Medium,96,,100%,96
20,10,4,y,y,y,Gentle,Gentle,y,y,Medium,Medium,80,,100%,80
21,12,4,y,y,,Medium,,,y,Medium,Medium,96,,100%,96
22,12,4, ,y,, ,Medium,y,y,Fast, ,96,,100%,96
23,14,4,y,y,,Gentle,Medium,y,y,Fast,Slow,112,,100%,112
24,14,6, ,y,,Medium,Gentle,y,y,Fast, ,112,,100%,112
25,16,5,y,y,,Gentle,Medium,y,y,Fast,Slow,128,,100%,128
26,18,3,y,y,,Medium,,y,y,Medium,Medium,144,,100%,144
27,12,7, ,y,y, ,Gentle,y,y,Fast, ,96,,100%,96
28,14,7,y,y,y,Medium,Medium,y,y,Fast,Slow,112,,100%,112
29,14,8, ,y,y,Gentle, ,y,y,Fast, ,112,,100%,112
30,16,6,y,y,, ,Medium,y,y,Medium,Medium,128,,100%,128
31,20,6,y,y,,Medium,Medium,y,y,Fast,Medium,160,,100%,160
32,16,8,y,y,,Heavy,,y,y,Fast,Medium,128,,100%,128
33,20,8,y,y,,,Heavy,y,y,Fast,Fast,160,,110%,176
34,24,8,y,y,,Heavy,,y,y,Fast,Fast,192,,120%,230.4
35,28,8,y,y,,,Heavy,y,y,Fast,Fast,224,,120%,268.8
36,32,8,y,y,,Heavy,Heavy,y,y,Fast,Fast,256,,130%,332.8
,,,,,,,,,,,,,,,
,Seconds/Segment,,,,,,,,,,,,,,
,8,,,,,,,,,,,,,,
]===]


--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		13-Oct-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
