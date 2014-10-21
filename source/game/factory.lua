--- ************************************************************************************************************************************************************************
---
---				Name : 		factory.lua
---				Purpose :	Carousel colour sequence factory object
---				Updated:	12 October 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

--- ************************************************************************************************************************************************************************
--															Factory object that creates unique sequences
--- ************************************************************************************************************************************************************************

local Factory,SuperClass = Framework:createClass("game.segment.factory")

--//	Create a new sequence factory
--//	@info 	[table] 	constructor information

function Factory:constructor(info)
	self.m_size = info.size 														-- how long is the sequence required
	self.m_colours = info.colours 													-- how many colours are available
	self.m_used = {} 																-- hash of already used sequences
end 

--//	Tidy up

function Factory:destructor()
	self.m_used = nil 																-- tidy up
end 

--//	Create a unique sequence
--//	@return [string] sequence

function Factory:create()
	local sequence 
	repeat 																			-- keep
		sequence = self:createRaw() 												-- getting a new sequence
	until self.m_used[sequence] == nil 												-- until that sequence has not been used
	self.m_used[sequence] = true  													-- add it to the table so we don't get it again.
	return sequence 
end 

--//	Create a raw character sequence of the required length, the sequence being rotated so the lowest ASCII value is
--//	first, this is how we create uniqueness.
--//	@return [string]	sequence.

function Factory:createRaw()
	local s = "" 																	-- empty string
	local lowest = "z" 																-- smallest character
	for i = 1,self.m_size do 														-- do for the required number of characters
		local newC
		repeat 																		-- keep getting a character
		 	newC = string.char(math.random(97,97+self.m_colours-1))
		until s:find(newC) == nil 													-- until it has not been used before.
		s = s .. newC 																-- append it.
		if newC < lowest then lowest = newC end 									-- keep the lowest character 
	end 
	while s:sub(1,1) ~= lowest do 													-- keep rotating it until the lowest character is first.
		s = s:sub(2) .. s:sub(1,1)
	end
	return s
end 

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		12-Oct-14	0.1 		Initial version of file
		21-Oct-14 	1.0 		Release One

--]]
--- ************************************************************************************************************************************************************************
