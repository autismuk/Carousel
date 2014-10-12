--- ************************************************************************************************************************************************************************
---
---				Name : 		carousel.lua
---				Purpose :	Carousel object.
---				Updated:	12 October 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

require("utils.controllable")

--- ************************************************************************************************************************************************************************
--																			Carousel Object
--- ************************************************************************************************************************************************************************

local Carousel,SuperClass = Framework:createClass("game.carousel","system.controllable")

--//	Create a carousel object,  given the colour descriptor, colour table and level descriptor
--//	@info 	[table]	constructor information

function Carousel:constructor(info)
	self.m_colourDescriptor = info.colourDescriptor 								-- save the physical descriptor
	self.m_colourTable = info.colourTable 											-- save reference to the colour table
	self.m_descriptor = info.descriptor 											-- save the descriptor
	self:applyDefaults() 															-- apply the default values.
	self.m_group = display.newGroup() 												-- create a group for the carousel object
	self:createCarousel() 															-- create the physical carousel graphic.
	self.m_group.x,self.m_group.y = math.random(640),math.random(960)
	self:tag("enterFrame,carousel")													-- is updated on enterFrame and is a carousel object
	self.m_isSelected = false 														-- initially not selected
	self.m_isKilled = false 														-- has not been killed (used when disappearing but object exists)
	self:setRadius(self.m_descriptor.radius)										-- set the initial radius to the default value.
	local r = self.m_descriptor.radius 
	self:moveTo(math.random(r,1023-r),math.random(r,1535-r)) 						-- position it randomly
	self.m_group:addEventListener("tap",self) 										-- listen for taps.
	
	--self.m_group.width,self.m_group.height = 64,64
end 

--//	Delete the object

function Carousel:destructor()
	self.m_group:removeEventListener("tap",self)									-- remove event listener.
	self.m_group:removeSelf() self.m_group = nil 									-- tidy up.
	self.m_descriptor = nil self.m_colourTable = nil self.m_selector = nil
end 

function Carousel:getDisplayObjects() 
	return { self.m_group }
end

--//	Move the carousel to a specific location
--//	@x 	[number]	x position (0-1023)
--//	@y 	[number]	y position (0-1535)

function Carousel:moveTo(x,y)
	self.m_group.x = x * display.contentWidth / 1024 								-- convert logical to physical positions and apply them.
	self.m_group.y = y * display.contentWidth / 1024
	self.m_x, self.m_y = x,y 														-- save logical positions
end 

--//	Set the radius in logical units.
--//	@logicalUnits 	[number]		logical units (1024x1536 scale)

function Carousel:setRadius(logicalUnits)
	local pUnits = logicalUnits * display.contentWidth / 1024 						-- scale into physical units
	self.m_group.xScale = pUnits / 100 												-- calculate the actual scale as the object as drawn is 100 pixels radius.
	self.m_group.yScale = self.m_group.xScale 										-- set both scales the same - it's a circle.
end 

--//	Handle the enter frame event
--//	@dt 	[number]		elapsed time.

function Carousel:onEnterFrame(dt)
	if not self:isEnabled() and not self.m_isKilled then return end 				-- only do this when the object is enabled and it isn't dead.
	self.m_time = (self.m_time or 0) + dt 											-- keep track of elapsed time for animations.
	self.m_selector.alpha = 0 														-- hide selector
	if self.m_isSelected then 														-- is it selected.
		self.m_selector.alpha = math.abs(math.sin(self.m_time*2.5))					-- then flash it on and off
	end 

	self.m_group.rotation = self.m_time * 100

end 

--//	Create the actual physical carousel object.

function Carousel:createCarousel()
	local g = self.m_group 															-- this is where the group goes.
	local segAngle = 360 / #self.m_colourDescriptor 								-- each segment size in degrees
	for segment = 1,#self.m_colourDescriptor do 									-- first draw the segments.
		local rad = math.rad(segAngle/2)											-- angle above and below centre line, hence / 2
		local rad2 = math.rad(segAngle/4)											-- the mid points in those lines
		local poly = display.newPolygon(g,0,0,{ 0,0, 								-- now build a five sided polygon resembling an arc.
												100*math.cos(rad),-100*math.sin(rad), 
												100*math.cos(rad2),-100*math.sin(rad2), 
												100,0, 
												100*math.cos(rad2),100*math.sin(rad2), 
												100*math.cos(rad),100*math.sin(rad) })
		local ascii = string.byte(self.m_colourDescriptor:sub(segment,segment))-96 	-- convert a,b,c to 1,2,3 number
		local c = self.m_colourTable[ascii] 										-- look up in colour table
		poly:setFillColor(c[1],c[2],c[3]) 											-- colour the polygon.
		poly.anchorX,poly.anchorY = 0,0.5 											-- anchor point at the 'sharp end'
		poly.rotation = (segment - 1) * segAngle 									-- rotate into position
	end
	local frame = display.newCircle(g,0,0,100) frame:setFillColor(0,0,0,0) 			-- this is the brown frame.
	frame.strokeWidth = 10 frame:setStrokeColor(160/255,69/255,13/255)
	local r1 = display.newCircle(g,0,0,100-frame.strokeWidth/2) r1:setFillColor(0,0,0,0)
	r1.strokeWidth = 3 r1:setStrokeColor(0,0,0)										-- black lines framing the brown frame.
	r1 = display.newCircle(g,0,0,100+frame.strokeWidth/2) r1:setFillColor(0,0,0,0)
	r1.strokeWidth = 3 r1:setStrokeColor(0,0,0)
	self.m_selector = display.newCircle(g,0,0,100+frame.strokeWidth*0.75+12) 		-- and the pulsing selector.
	self.m_selector:setFillColor(0,0,0,0) self.m_selector.strokeWidth = 14
	self.m_selector:setStrokeColor(1,1,0) 
	self.m_selector.alpha = 0 														-- which initially you can't see
end 

--//	Apply the object defaults - these are defined in the documentation.

function Carousel:applyDefaults()
	local d = self.m_descriptor 													-- shortcut to descriptor
	d.collidable = d.collidable or false 											-- first the standard values
	d.reversable = d.reversable or false 
	d.wrappable = d.wrappable or false 
	d.radius = d.radius or 100
	d.velocity = d.velocity or {}													-- velocity/rotation info are tables
	d.rotation = d.rotation or {}
	d = self.m_descriptor.velocity 													-- initialise the tables 
	d.min = d.min or 0 d.max = d.max or 0 d.acc = d.acc or 0 d.collide = d.collide or 0
	d = self.m_descriptor.rotation
	d.min = d.min or 0 d.max = d.max or 0 d.acc = d.acc or 0 d.collide = d.collide or 0
end 

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		12-Oct-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
