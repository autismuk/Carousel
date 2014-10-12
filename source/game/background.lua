--- ************************************************************************************************************************************************************************
---
---				Name : 		background.lua
---				Purpose :	Game Background
---				Updated:	12 October 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************


--- ************************************************************************************************************************************************************************
--																			Background Object
--- ************************************************************************************************************************************************************************

local Background = Framework:createClass("game.background")

--//	Create a Background object,  given the colour descriptor, colour table and level descriptor
--//	@info 	[table]	constructor information

function Background:constructor(info)
	self.m_group = display.newGroup() 												-- create a group for the Background object
	local r = display.newRect(self.m_group,0,0,display.contentWidth,display.contentHeight)
	r.anchorX,r.anchorY = 0,0 
	r.anchorX,r.anchorY = 0,0 												-- tile it.
	display.setDefault("textureWrapX","repeat")
	display.setDefault("textureWrapY","repeat")
	r.fill = { type = "image", filename = "images/tile.jpg" }
	r.fill.scaleX,r.fill.scaleY = 0.2,0.15


	self.m_timerRectangle = display.newRoundedRect(self.m_group,display.contentWidth/2,display.contentHeight/2,300,300,display.contentWidth/30)
	self.m_timerRectangle:setFillColor(1,0,0) self.m_timerRectangle.alpha = 0
	self.m_timerPercent = 81
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
	self.m_time = (self.m_time or 0) + dt 											-- track time.
	if self.m_timerPercent > 10 then 
		local timeScalar = self.m_timerPercent / 10 + 1
		local percent = self.m_timerPercent + math.sin(self.m_time*timeScalar) * 2
		percent = math.min(100,math.max(0,percent))
		self.m_timerRectangle.width = display.contentWidth * percent / 100
		self.m_timerRectangle.height = display.contentHeight * percent / 100
		self.m_timerRectangle.alpha = 0.6
	else 
		self.m_timerRectangle.alpha = 0
	end
end 

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		12-Oct-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
