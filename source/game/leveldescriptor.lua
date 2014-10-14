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

function LevelDescriptor:constructor(info) 
	self.m_rawData = {}
	local sourceText = self.rawTextData:gsub("\n","|").."|"											-- replace carriage returns with vertical bar, make sure there is a beginning one.
	while sourceText ~= "" do 
		local pos = sourceText:find("|")															-- find split
		local line = sourceText:sub(1,pos-1)														-- first bit.
		sourceText = sourceText:sub(pos+1)
		local id  id,line = line:match("^(%d+),(.*)")												-- look for number,<data>
		if id ~= nil then 																			-- found something
			local data = {}
			self.m_rawData[id*1] = data 															-- start a new line.
			line = line .. ","																		-- append a comma.
			while line ~= "" do 																	-- now split that up
				local pos = line:find(",")															-- around commas
				data[#data+1] = self:process(line:sub(1,pos-1)) line = line:sub(pos+1)				-- copy it in to the array structure
				print(#data,data[#data])
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

--//	Get the descriptor for the given level number.
--//	@levelNumber 	[number]	level number
--//	@return 		[table]		description of the level

function LevelDescriptor:get(levelNumber)
	local descriptor = {}																			-- default empty descriptor.
	descriptor.rotation = { start = 120, min = 120,max = 360, acc = 0 }
	descriptor.velocity = { start = 100,min = 100,max = 1974, collide = 105 }
	descriptor.wrappable = false
	descriptor.collidable = true
	descriptor.reversable = true
	return { descriptor = descriptor, count = 2, segments = 4, time = 22 }
end 

--//	Get the number of levels.
--//	@return 	[number]	count of levels.

function LevelDescriptor:getCount()
	return #self.m_rawData
end 


--
--	Cut and Pasted from CSV exports.
--

LevelDescriptor.rawTextData = [===[																	
Level,Pieces,Segments,Rotating,Moving,Wrap?,Alpha?,Size?,Reverse?,Velocity,Rotate,Base time,Special,Difficulty,Actual time
1,2,3,,,,,,,,,30,,150%,45
2,4,3,,,,,,,,,60,,100%,60
3,6,3,,,,,,,,,90,,100%,90
4,4,2,y,,,,,,,Slow,60,,120%,72
5,6,3,y,,,,,,,Slow,90,,100%,90
6,8,3,y,,,,,,,Slow,120,,100%,120
7,8,4,y,,,,,,,Slow,120,,120%,144
8,8,4,y,,,,Gentle,,,Medium,120,,120%,144
9,4,3,,y,,,,,Slow,,60,,120%,72
10,6,3,,y,y,,,,Slow,,90,,110%,99
11,6,3,,y,y,,,,Slow,,90,,100%,90
12,8,4,,y,,,,,Slow,,120,,100%,120
13,8,4,,,y,,,y,,,120,,110%,132
14,8,4,,y,,Gentle,,y,,,120,,100%,120
15,10,4,,y, ,,,,,,150,,100%,150
16,10,4,,y,,Gentle,Gentle,y,,,150,,100%,150
17,6,3,y,y,,,,,Slow,Slow,90,,100%,90
18,8,3,y,y,,,,,Slow,Slow,120,,100%,120
19,10,4,y,y,,,,,Slow,Medium,150,,100%,150
20,12,4,y,y,,,,,Medium,Medium,180,,100%,180
21,12,5,y,y,,,,,Medium,Medium,180,,100%,180
22,10,4,y,y,y,Gentle,Gentle,y,Medium,Medium,150,,100%,150
23,12,4,y,y,,Medium,,,Medium,Medium,180,,100%,180
24,12,4, ,y,,Medium,Medium,y,Fast, ,180,,100%,180
25,12,4,y,y,,Medium,Medium,y,Fast,Slow,180,,100%,180
26,14,6, ,y,,Medium,Medium,y,Fast, ,210,,100%,210
27,14,6,y,y,,Medium,Medium,y,Fast,Slow,210,,100%,210
28,12,8, ,y,y,Medium,Medium,y,Fast, ,180,,100%,180
29,12,8,y,y,y,Medium,Medium,y,Fast,Slow,180,,100%,180
30,12,8, ,y,y,Medium,Medium,y,Fast, ,180,,100%,180
31,16,6,y,y,,Medium,Medium,y,Medium,Medium,240,,100%,240
32,20,6,y,y,,Medium,Medium,y,Fast,Medium,300,,100%,300
33,16,8,y,y,,Heavy,,y,Fast,Medium,240,,100%,240
34,20,8,y,y,,,Heavy,y,Fast,Fast,300,,100%,300
35,24,8,y,y,,Heavy,,y,Fast,Fast,360,,100%,360
36,32,8,y,y,,,Heavy,y,Fast,Fast,480,,100%,480
,,,,,,,,,,,,,,
,Seconds/Segment,,,,,,,,,,,,,
,15,,,,,,,,,,,,,
]===]


--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		13-Oct-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
