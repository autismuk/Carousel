--- ************************************************************************************************************************************************************************
---
---				Name : 		game.lua
---				Purpose :	Main Game Scene
---				Updated:	12 October 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

require("game.background")															-- background/timer
require("game.carousel")															-- carousel object
require("utils.buttons")															-- buttons
require("game.collisions")															-- collision manager
require("game.controller")															-- game controller
require("utils.music")																-- music player
require("utils.text")																-- bitmap text object
require("game.factory")																-- carousel object factory
require("game.leveldescriptor")														-- level factory

--- ************************************************************************************************************************************************************************
--																			Create the Scene
--- ************************************************************************************************************************************************************************

local GameScene,SuperClass = Framework:createClass("scene.game.manager","game.sceneManager")

GameScene.levelDescriptor = Framework:new("game.levelDescriptor")					-- all instances share a level descriptor.

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
	local setup = GameScene.levelDescriptor:get(data.level,data.skill) 				-- get information pertaining to this.
	Framework.fw.levelManager:setLevel(data.level) 									-- let level tracking manager know which level.
	scene:new("game.background",{ time = setup.time or 60 }) 						-- create background with timer
	scene:new("audio.music") 														-- start the background music.
	scene:new("control.leftarrow", { x = 5,y = 96,									-- add a 'give up' button
									 r = 139/255, g = 69/255, b = 19/255,	 		
									 listener = self, message = "abandon" })

	assert(setup.count % 2 == 0,"Must be an even number of carousel objects !") 	-- they are paired off.

	local factory = Framework:new("game.segment.factory",							-- create a factory.
												{ size = setup.segments, colours = 8 })	
	for i = 1,setup.count / 2 do 													-- n/2 pairs
		local sequence = factory:create() 											-- get the new sequence.
		for j = 1,2 do 																-- create two of them.
			scene:new("game.carousel", { identifier = i,colourDescriptor = sequence, descriptor = setup.descriptor })
		end
	end
	factory:delete() 																-- no longer need the factory

	self.m_usesCollisions = setup.descriptor.collidable 							-- save the collision flag
	local timeEnd = system.getTimer() + 1500 										-- allow at most 1.5 seconds for this bit
	repeat
		local list = self.m_collisionChecker:getCollisions(10) 						-- look for collisions, trying to maximise space
		if #list > 0 then 															-- if collisions found, move one of each collided pair randomly.
			for _,pair in ipairs(list) do pair[math.random(1,2)]:randomPosition() end 
		end
	until #list == 0 or system.getTimer() > timeEnd 								-- until either no collisions, or time up.

	scene:new("control.text", { text = "Match Up!", font = "jandles", alpha = 1, 	-- add the 'get ready' text
								tint = { r = 0,g = 1,b = 1} ,
								fontSize = display.contentWidth / 20,
								transition = { time = 1500, alpha = 1 ,
									onComplete = function(item) 					-- transition it visible
									timer.performWithDelay(1000,function() 			-- hold it briefly.
											self:setControllableEnabled(true) 		-- everything on
											transition.to(item, { time = 750, y = -80, 
																  alpha = 0.1, 
																  onComplete = function() item:removeSelf() end })
											end)
									 end }
	})		
	return scene
end

function GameScene:postOpen(manager,data,resources)
	self.m_gameController = Framework:new("game.controller", 						-- start the game controller
									{ testForCollision = self.m_usesCollisions })
end

function GameScene:preClose(manager,data,resources)
	self.m_gameController:delete() self.m_gameController = nil 						-- remove the game controller.
end 

function GameScene:onMessage(sender,name,body) 
	self:performGameEvent("next")
end

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		12-Oct-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
