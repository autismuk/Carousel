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
	descriptor.collidable = def.isReversable 
	descriptor.isReversable = def.isColliding

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
1,2,3,,,,,,,,,,30,,150%,45
2,4,3,,,,,,,,,,60,,100%,60
3,6,3,,,,,,,,,,90,,100%,90
4,4,2,y,,,,,,,,Slow,60,,120%,72
5,6,3,y,,,,,,,,Slow,90,,100%,90
6,8,3,y,,,,,,,,Slow,120,,100%,120
7,8,4,y,,,,,,,,Slow,120,,120%,144
8,8,4,y,,,,Gentle,,,,Medium,120,,120%,144
9,4,3,,y,,,,,,Slow,,60,,120%,72
10,6,3,,y,y,,,,,Slow,,90,,110%,99
11,6,3,,y,y,,,,y,Slow,,90,,100%,90
12,8,4,,y,,,,,,Slow,,120,,100%,120
13,8,4,,y,y,,,y,y,Medium,,120,,110%,132
14,8,4,,y,,Gentle,,y,,,,120,,100%,120
15,10,4,,y, ,,,,,,,150,,100%,150
16,10,4,,y,,Gentle,Gentle,y,,,,150,,100%,150
17,6,3,y,y,,,,,y,Slow,Slow,90,,100%,90
18,8,3,y,y,,,,,y,Slow,Slow,120,,100%,120
19,10,4,y,y,,,,,y,Slow,Medium,150,,100%,150
20,12,4,y,y,,,,,y,Medium,Medium,180,,100%,180
21,12,5,y,y,,,,,y,Medium,Medium,180,,100%,180
22,10,4,y,y,y,Gentle,Gentle,y,y,Medium,Medium,150,,100%,150
23,12,4,y,y,,Medium,,,y,Medium,Medium,180,,100%,180
24,12,4, ,y,,Medium,Medium,y,y,Fast, ,180,,100%,180
25,12,4,y,y,,Medium,Medium,y,y,Fast,Slow,180,,100%,180
26,14,6, ,y,,Medium,Medium,y,y,Fast, ,210,,100%,210
27,14,6,y,y,,Medium,Medium,y,y,Fast,Slow,210,,100%,210
28,12,8, ,y,y,Medium,Medium,y,y,Fast, ,180,,100%,180
29,12,8,y,y,y,Medium,Medium,y,y,Fast,Slow,180,,100%,180
30,12,8, ,y,y,Medium,Medium,y,y,Fast, ,180,,100%,180
31,16,6,y,y,,Medium,Medium,y,y,Medium,Medium,240,,100%,240
32,20,6,y,y,,Medium,Medium,y,y,Fast,Medium,300,,100%,300
33,16,8,y,y,,Heavy,,y,y,Fast,Medium,240,,100%,240
34,20,8,y,y,,,Heavy,y,y,Fast,Fast,300,,100%,300
35,24,8,y,y,,Heavy,,y,y,Fast,Fast,360,,100%,360
36,32,8,y,y,,,Heavy,y,y,Fast,Fast,480,,100%,480
,,,,,,,,,,,,,,,
,Seconds/Segment,,,,,,,,,,,,,,
,15,,,,,,,,,,,,,,

]===]


--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		13-Oct-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
