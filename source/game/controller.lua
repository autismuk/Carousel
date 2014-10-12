--- ************************************************************************************************************************************************************************
---
---				Name : 		controller.lua
---				Purpose :	Responsible for actually controlling the game play.
---				Updated:	12 October 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

--- ************************************************************************************************************************************************************************
--																	Collisions Manager Object
--- ************************************************************************************************************************************************************************

local Controller = Framework:createClass("game.controller")

Controller.CHECK_RATE = 20 															-- how many times a second do we do collision checks.

--//	Create a game controller
--//	@info 	[table]	constructor information

function Controller:constructor(info) 
	self:tag("enterFrame,gamecontroller")											-- handle enterFrame and self identify
	self.m_collisionTest = info.testForCollision 									-- remember if we do collisions on this level.
	self.m_collisionChecker = Framework:new("game.collision.checker") 				-- helper for collision checking
end 

--//	Delete a game controller.

function Controller:destructor() 	
	self:setControllableEnabled(false)												-- stop everything
	self.m_collisionChecker:delete() self.m_collisionChecker = nil 					-- delete the checker helper.
end

--//	Handle enterFrame
--//	@dt 	[number]	elapsed time

function Controller:onEnterFrame(dt)
	self.m_timer = (self.m_timer or 0) + dt 										-- track time.
	if self.m_timer > 1/Controller.CHECK_RATE and self.m_collisionTest then 		-- if time for test, and we are checking collisions
		self.m_timer = 0 															-- reset timer
		local collides = self.m_collisionChecker:getCollisions() 					-- get collides
		if #collides > 0 then  														-- process them.
			for i = 1,#collides do self:handleCollision(collides[i][1],collides[i][2]) end
		end
	end
end

--//	Handle messages
--//	@sender 	[object]	who sent it
--//	@name 		[string]	message (select, win, lose)
--//	@body 		[table]		other data

function Controller:onMessage(sender,name,body)
	print(name,body.object)
end 

--//	Handle collision between two objects
--//	@obj1 	[object]		first object
--//	@obj2 	[object] 		second object

function Controller:handleCollision(obj1,obj2)
	local s1,s2 = obj1:getStatus(), obj2:getStatus() 								-- get object statuses.
	local angle = math.deg(math.atan2(s2.y-s1.y,s1.x-s2.x))							-- angle from 2 to 1.
	local velocity = (s1.velocity + s2.velocity) / 2 								-- distribute velocity equally
	obj1:setMotion(velocity,(angle+3600) % 360)										-- send off in opposite directions
	obj1:collision() 																-- and tell both they've collided.
	obj2:setMotion(velocity,(angle+3600+180) % 360)	
	obj2:collision()
end

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		12-Oct-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
