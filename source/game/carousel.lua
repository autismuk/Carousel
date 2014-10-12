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
	self.m_identifier = info.identifier 											-- save the unique identifier number.
	self.m_colourDescriptor = info.colourDescriptor 								-- save the physical descriptor
	self.m_colourTable = info.colourTable or Carousel.colourTable					-- save reference to the colour table, using default here if needed.
	self.m_descriptor = info.descriptor 											-- save the descriptor
	self:applyDefaults() 															-- apply the default values.
	self.m_group = display.newGroup() 												-- create a group for the carousel object
	self:createCarousel() 															-- create the physical carousel graphic.
	self.m_group.x,self.m_group.y = math.random(640),math.random(960)
	self:tag("enterFrame,carousel")													-- is updated on enterFrame and is a carousel object
	self.m_isSelected = false 														-- initially not selected
	self.m_isKilled = false 														-- has not been killed (used when disappearing but object exists)
	self:setRadius(self.m_descriptor.radius)										-- set the initial radius to the default value.
	self:randomPosition() 															-- randomly position
	self.m_group:addEventListener("tap",self) 										-- listen for taps.
	self.m_velocity = self.m_descriptor.velocity.start or 
									self:randomValue(self.m_descriptor.velocity.min,self.m_descriptor.velocity.max)
	self.m_direction = math.random(360)												-- a randomly chosen direction initially.

	self.m_rotationalVelocity = self.m_descriptor.rotation.start or 				-- randomly chosen rotational velocity
									self:randomValue(self.m_descriptor.rotation.min,self.m_descriptor.rotation.max)
	self.m_rotationalDirection = 1 													-- forward by default.
	self:setRotation(math.random(360))												-- initial random rotation.

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

--//	Get the carousel's status record.
--//	@return 	[table]		table containing required values.

function Carousel:getStatus()
	return { x = self.m_x, y = self.m_y, radius = self.m_radius, velocity = self.m_velocity, direction = self.m_direction }
end 

--//	Set the Carousel's motion (velocity and direction)
--//	@velocity 	[number]	velocity
--//	@direction 	[number]	direction

function Carousel:setMotion(velocity,direction)
	local v = self.m_descriptor.velocity
	self.m_velocity = math.max(v.min,math.min(v.max,velocity))
	self.m_direction = (direction + 3600) % 360 
end 

--//	Set the radius in logical units.
--//	@logicalUnits 	[number]		logical units (1024x1536 scale)

function Carousel:setRadius(logicalUnits)
	local pUnits = logicalUnits * display.contentWidth / 1024 						-- scale into physical units
	pUnits = math.max(pUnits,4)
	self.m_group.xScale = pUnits / 100 												-- calculate the actual scale as the object as drawn is 100 pixels radius.
	self.m_group.yScale = self.m_group.xScale 										-- set both scales the same - it's a circle.
	self.m_radius = logicalUnits 													-- save the radius
end 

--//	Set the rotation in degrees
--//	@rotation 	[number]	rotation

function Carousel:setRotation(rotation)
	self.m_group.rotation = rotation 												-- set the rotation
	self.m_rotation = (rotation + 36000) % 360 										-- record it, but force into range 0-360.
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

	local v = self.m_descriptor.velocity 											-- access velocity structure.
	if v.acc ~= 0 then 																-- is there acceleration supplied ?
		self.m_velocity = self.m_velocity + v.acc * dt 								-- v = u + at 
		self.m_velocity = math.min(v.max,math.max(v.min,self.m_velocity))			-- force into range.
	end
	
	if self.m_velocity ~= 0 then 													-- is it moving ?
																					-- work out new position
		local x = self.m_x + self.m_velocity * math.cos(math.rad(self.m_direction)) * dt 
		local y = self.m_y - self.m_velocity * math.sin(math.rad(self.m_direction)) * dt
		self:moveTo(x,y)

		local r = self.m_radius 													-- short for radius
		if self.m_descriptor.wrappable then 										-- is it wrapping round, or bouncing ?
			if self.m_x > 1024 + r then self:moveTo(self.m_x - 1024 - r * 2,self.m_y) end
			if self.m_y > 1536 + r then self:moveTo(self.m_x,self.m_y - 1536 - r * 2) end
			if self.m_x < -r then self:moveTo(self.m_x + 1024 + r * 2,self.m_y) end
			if self.m_y < -r then self:moveTo(self.m_x,self.m_y + 1536 + r * 2) end
		else  																		-- bounces
			if self.m_x < r or self.m_x > 1024 - r then 							-- left/right walls.
				if self.m_direction > 90 and self.m_direction < 270 then 			-- if moving left to right.
					self.m_direction = (540 - self.m_direction) % 360 				-- now it will be 270..90
				end 
				if self.m_x > r then 
					self.m_direction = (540 - self.m_direction) % 360 				-- equivalent to bouncing off l/r wall.
				end
			end 
			if self.m_y < r or self.m_y > 1536 -r then 								-- top/bottom walls.
				if self.m_direction > 180 then 										-- force into range 0..180
					self.m_direction = 360-self.m_direction
				end
				if self.m_y < r then 
					self.m_direction = 360-self.m_direction 
				end
			end
		end
	end
	
	if self.m_rotationalVelocity ~= 0 then 											-- rotating 
		local newR = self.m_rotationalVelocity * dt * self.m_rotationalDirection + 	-- work out new rotation
																			self.m_rotation 				
		self:setRotation(newR) 														-- set it, direction done by this method.
		local r = self.m_descriptor.rotation 										-- access rotation structure
		if r.acc ~= 0 then 															-- rotational acceleration
			self.m_rotationalVelocity = self.m_rotationalVelocity + r.acc * dt 		-- update with rotational acceleration and force into range
			self.m_rotationalVelocity = math.min(r.max,math.max(r.min,self.m_rotationalVelocity))
		end
	end

	if self.m_descriptor.radiusFunction ~= nil then 								-- radius function provided ?
		local v = self.m_descriptor.radiusFunction(self.m_time,self.m_identifier) 	-- call it
		v = math.max(0,math.min(v,1))												-- force in range 0-1
		self:setRadius(v * self.m_descriptor.radius)								-- and set the radius accordingly.
	end

	if self.m_descriptor.alphaFunction ~= nil then 									-- alpha function provided ?
		local v = self.m_descriptor.alphaFunction(self.m_time,self.m_identifier) 	-- call it
		v = math.max(0,math.min(v,1))												-- force in range 0-1
		self.m_group.alpha = v	 													-- and set the alpha accordingly.
	end

end 

--//	Handle collisions.

function Carousel:collision()
	if self.m_descriptor.reversable then 											-- do we reverse on collision
		self.m_rotationalDirection = -self.m_rotationalDirection 					-- if so, do it.
	end 
	self.m_velocity = self:adjust(self.m_velocity,self.m_descriptor.velocity)
	self.m_rotationalVelocity = self:adjust(self.m_rotationalVelocity,self.m_descriptor.rotation)
end 

--//	A collision has occurred - given a value (with min, max, and collision) adjust it appropriately.
--//	@value 	[number]	value to adjust
--//	@modifier [table]	table containing min, max and collision percentage
--//	@return [number]	new value

function Carousel:adjust(value,modifier)
	value = value * modifier.collide / 100 											-- calculate new value
	value = math.max(modifier.min,math.min(modifier.max,value))						-- force into min/max range
	return value 
end

--//	Check to see if the carousel object is active - not been matched up.
--//	@return 	[true]			true if object is active.

function Carousel:isInPlay()
	return self:isAlive() and (not self.m_isKilled) 
end 

--//	Randomly position the carousel, making sure that the back arrow is visible.

function Carousel:randomPosition()
	local r = self.m_descriptor.radius 
	repeat 
		self:moveTo(math.random(r,1023-r),math.random(r,1535-r)) 					-- position it randomly
	until self.m_x > 100+r or self.m_y < 1440-r 									-- make sure the back arrow is visible, in case nothing moves.
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
	frame.strokeWidth = 12 frame:setStrokeColor(160/255,69/255,13/255)
	local r1 = display.newCircle(g,0,0,100-frame.strokeWidth/2) r1:setFillColor(0,0,0,0)
	r1.strokeWidth = 3 r1:setStrokeColor(0,0,0)										-- black lines framing the brown frame.
	r1 = display.newCircle(g,0,0,100+frame.strokeWidth/2) r1:setFillColor(0,0,0,0)
	r1.strokeWidth = 3 r1:setStrokeColor(0,0,0)
	self.m_selector = display.newCircle(g,0,0,100+frame.strokeWidth*0.75+12) 		-- and the pulsing selector.
	self.m_selector:setFillColor(0,0,0,0) self.m_selector.strokeWidth = 14
	self.m_selector:setStrokeColor(1,1,0) 
	self.m_selector.alpha = 0 														-- which initially you can't see

	display.newText(self.m_group,"#"..self.m_identifier,0,0,native.systemFont,48)
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
	d.min = d.min or 0 d.max = d.max or 0 d.acc = d.acc or 0 d.collide = d.collide or 100
	d = self.m_descriptor.rotation
	d.min = d.min or 0 d.max = d.max or 0 d.acc = d.acc or 0 d.collide = d.collide or 100
end 

--//	Reliable version of math.random - works for any range of numbers, including non integers
--//	@min 	[number]		lowest value 
--//	@max 	[number]		highest value 

function Carousel:randomValue(min,max)
	if min == max then return min end 												-- if the same, there is no difference.
	return min + math.random() * (max - min) 										-- otherwise a random value between them.
end 

--//	Default colour table

Carousel.colourTable = {
	{ 1,0,0 }, { 0,1,0 }, { 0,0,1 }, { 1,1,0 }, { 1,0,1 }, { 0,1,1 }, { 1,0.5,0 }, { 0,0,0}
}

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		12-Oct-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
