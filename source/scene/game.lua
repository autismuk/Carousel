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

--- ************************************************************************************************************************************************************************
--																			Create the Scene
--- ************************************************************************************************************************************************************************

local GameScene = Framework:createClass("scene.game.manager","game.sceneManager")

function GameScene:preOpen(manager,data,resources)
	local scene = Framework:new("game.scene")
	scene:new("game.background",{})
	self.m_objectList = {}
	math.randomseed(42)
	for i = 1,12 do
		local obj = scene:new("game.carousel", { colourDescriptor = "abcdefgh", colourTable = GameScene.colourTable, descriptor = data.descriptor })
		self.m_objectList[#self.m_objectList+1] = obj
	end


	return scene
end

function GameScene:postOpen(manager,data,resources)
	self:setControllableEnabled(true)
end

GameScene.colourTable = {
	{ 1,0,0 }, { 0,1,0 }, { 0,0,1 }, { 1,1,0 }, { 1,0,1 }, { 0,1,1 }, { 1,0.5,0 }, { 0,0,0}
}
--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		12-Oct-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
