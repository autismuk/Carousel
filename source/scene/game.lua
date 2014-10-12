--- ************************************************************************************************************************************************************************
---
---				Name : 		game.lua
---				Purpose :	Main Game Scene
---				Updated:	12 October 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

require("game.background")
require("game.carousel")
require("utils.buttons")
require("game.collisions")

--- ************************************************************************************************************************************************************************
--																			Create the Scene
--- ************************************************************************************************************************************************************************

local GameScene,SuperClass = Framework:createClass("scene.game.manager","game.sceneManager")

function GameScene:constructor(info)
	SuperClass.constructor(self,info)
	self.m_collisionChecker = Framework:new("game.collision.checker")
end 

function GameScene:destructor()
	self.m_collisionChecker:delete() self.m_collisionChecker = nil
	SuperClass.destructor()
end 

function GameScene:preOpen(manager,data,resources)
	local scene = Framework:new("game.scene")										-- create a new scene
	scene:new("game.background",{})
	scene:new("control.leftarrow", { x = 5,y = 96,r = 1, g = 0.5, b = 0, 			-- add a 'give up' button
												listener = self, message = "abandon" })
	for i = 1,4 do
		local obj = scene:new("game.carousel", { identifier = i,colourDescriptor = "abcdefgh", descriptor = data.descriptor })
	end

	local timeEnd = system.getTimer() + 1500 										-- allow at most 1.5 seconds for this bit
	repeat
		local list = self.m_collisionChecker:getCollisions(10) 						-- look for collisions, trying to maximise space
		if #list > 0 then 															-- if collisions found, move one of each collided pair randomly.
			for _,pair in ipairs(list) do pair[math.random(1,2)]:randomPosition() end 
		end
	until #list == 0 or system.getTimer() > timeEnd 								-- until either no collisions, or time up.
	return scene
end

function GameScene:postOpen(manager,data,resources)
	self:setControllableEnabled(true)
end

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		12-Oct-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
