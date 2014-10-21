--- ************************************************************************************************************************************************************************
---
---				Name : 		background.lua
---				Purpose :	Game Background
---				Updated:	12 October 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

require("utils.controllable")

--- ************************************************************************************************************************************************************************
--																			Background Object
--- ************************************************************************************************************************************************************************

local Background = Framework:createClass("game.background","system.controllable")

--//	Create a Background object,  given the colour descriptor, colour table and level descriptor
--//	@info 	[table]	constructor information

function Background:constructor(info)
	self.m_group = display.newGroup() 												-- create a group for the Background object
	self.m_timeAllowed = info.time 													-- time to complete
	local r = display.newRect(self.m_group,0,0,display.contentWidth,display.contentHeight)
	r.anchorX,r.anchorY = 0,0 
	r.anchorX,r.anchorY = 0,0 														-- tile it.
	display.setDefault("textureWrapX","repeat")
	display.setDefault("textureWrapY","repeat")
	r.fill = { type = "image", filename = "images/tile.jpg" }
	r.fill.scaleX,r.fill.scaleY = 0.2,0.15


	self.m_timerRectangle = display.newRoundedRect(self.m_group,display.contentWidth/2,display.contentHeight/2,300,300,display.contentWidth/30)
	self.m_timerRectangle:setFillColor(1,0,0) self.m_timerRectangle.alpha = 0
	self.m_timerPercent = 1
	self:tag("enterFrame")
end 

--//	Delete the object

function Background:destructor()
	self.m_group:removeSelf() self.m_group = nil 									-- tidy up.
end 

function Background:getDisplayObjects() 
	return { self.m_group }
end

function Background:onEnterFrame(dt)
	if not self:isEnabled() then return end 										-- must be enabled.
	self.m_time = (self.m_time or 0) + dt 											-- track time.
	self.m_timerPercent = self.m_time / self.m_timeAllowed * 100 					-- calculate percentage
	if self.m_timerPercent > 10 then 
		local timeScalar = self.m_timerPercent / 10 + 1
		local percent = self.m_timerPercent + math.sin(self.m_time*timeScalar) * 3 / 2
		percent = math.min(100,math.max(0,percent))
		self.m_timerRectangle.width = display.contentWidth * percent / 100
		self.m_timerRectangle.height = display.contentHeight * percent / 100
		self.m_timerRectangle.alpha = 0.6
	else 
		self.m_timerRectangle.alpha = 0
	end
	if self.m_timerPercent >= 100 then 												-- time up 
		transition.to(self.m_timerRectangle,{ alpha = 0, time = 500 })
		self:sendMessage("gamecontroller","lose")									-- tell the controller we have lost.
	end
end 

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		12-Oct-14	0.1 		Initial version of file
		21-Oct-14 	1.0 		Release One

--]]
--- ************************************************************************************************************************************************************************
