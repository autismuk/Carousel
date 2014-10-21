--- ************************************************************************************************************************************************************************
---
---				Name : 		levelmanager.lua
---				Purpose :	Manages levels currently achieved.
---				Updated:	13 October 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

--- ************************************************************************************************************************************************************************
--																		Manages level completion
--- ************************************************************************************************************************************************************************

require("utils.document")																								-- access the document store.

local LevelManager = Framework:createClass("game.levelmanager")

function LevelManager:constructor(info)
	self:name("levelManager")																							-- label it
	local docStore = Framework.fw.documentStore:access() 																-- access document store
	docStore.completedLevel = docStore.completedLevel or 0 																-- default to zero.
	self.m_currentLevel = nil 																							-- current level.
end 


function LevelManager:destructor()
end 

function LevelManager:getCompletedLevel()
	local docStore = Framework.fw.documentStore:access() 																-- access document store
	return docStore.completedLevel 
end 

function LevelManager:setLevel(level)
	self.m_currentLevel = level 
end 

function LevelManager:completed()
	assert(self.m_currentLevel ~= nil)
	local docStore = Framework.fw.documentStore:access() 																-- access document store
	--print("Completed ",self.m_currentLevel," of ",Framework.fw.levelManager:getCompletedLevel())
	if self.m_currentLevel > docStore.completedLevel then 																-- beaten previously best level.
		docStore.completedLevel = self.m_currentLevel 																	-- write it back into the docStore.
		Framework.fw.documentStore:update() 																			-- and update it
	end 
end

Framework:new("game.levelmanager") 																						-- it's a singleton.
LevelManager.constructor = nil


--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		13-Oct-14	0.1 		Initial version of file
		21-Oct-14 	1.0 		Release One

--]]
--- ************************************************************************************************************************************************************************

