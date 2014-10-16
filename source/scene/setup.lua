--- ************************************************************************************************************************************************************************
---
---				Name : 		setup.lua
---				Purpose :	Set up Page
---				Updated:	13 October 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

require("utils.pageselector")
require("utils.swipable")
require("utils.gui")
require("game.leveldescriptor")
require("utils.admob")

tracker = Framework:new("admob.tracker", { rate = 0.5,start = 0.2 })				-- used to control whether to show interstitial or not.

--- ************************************************************************************************************************************************************************
--//	This is an object which handles swipable pages - it is abstract, having methods to create/delete the swipable bit and so should be subclassed. It wraps it in 
--//	a group with a top layer which detects swipes and scrolls the page left/right accordingly, sending messages to pageselector objects to show which page it is.
--- ************************************************************************************************************************************************************************

local SetupDisplay = Framework:createClass("control.swipe.level","control.swipe.base")


--//	Dummy function - creates page
--//	@group 	[display group]		should go in here, beginning from 0,0 and don't change the anchors !
--//	@data 	[table]				anything you need to keep for this page
--//	@info 	[table]				info from constructor

function SetupDisplay:pageConstructor(group,data,info)
	local ld = Framework:new("game.levelDescriptor")								-- create a level descriptor
	data.m_totalLevels = ld:getCount()												-- so we can get the total number of levels.
	ld:delete() 																	-- remove the level descriptor.
	data.m_buttons = {} 															-- array of button selector objects.
	data.m_completed = Framework.fw.levelManager:getCompletedLevel() 				-- get the completed levels.
	local bgr = display.newRect(group,0,0,display.contentWidth * math.floor((data.m_totalLevels+1)/12),display.contentHeight)
	bgr.anchorX,bgr.anchorY = 0,0
	display.setDefault("textureWrapX","repeat")
	display.setDefault("textureWrapY","repeat")
	bgr.fill = { type = "image", filename = "images/tile2.gif" }
	bgr.fill.scaleX,bgr.fill.scaleY = 0.04,0.04
	for n = 1,data.m_totalLevels do 												-- for each level.
		local i = n - 1 															-- works better for 0-3.
		local x = (i % 3+1) * display.contentWidth / 4 								-- work out x,y
		local y = (math.floor(i / 3) % 4 + 1.5) * display.contentHeight / 6
		x = x + math.floor(i / 12) * display.contentWidth
		local canAccess = (n <= data.m_completed + 1)								-- can this button be clicked.
		data.m_buttons[n] = self:createButton(x,y,n,canAccess) 						-- create it
		if canAccess then 															-- if can be used
			data.m_buttons[n]:addEventListener("tap",data.owner)					-- add event listener sending message here
		end
		group:insert(data.m_buttons[n])												-- add to group
	end 
	data.m_headings = {}															-- create level headings.
	local difficulty = { "Wimpish","Meh...","Insane" }
	for i = 1,math.floor((data.m_totalLevels+11)/12) do 
		data.m_headings[i] = display.newBitmapText(group,difficulty[i] .. " levels",display.contentWidth * (i-0.5), display.contentHeight * 0.1,"jandles",display.contentWidth/4)
		data.m_headings[i]:setTintColor(1,0.5,0)
	end
end 

--//	Create a button
--//	@x 	[number]	position
--//	@y 	[number]	position
--//	@n 	[number]	level number
--//	@isAllowed [boolean] can this one be played.

function SetupDisplay:createButton(x,y,n,isAllowed)
	local group = display.newGroup()												-- each button has a group
	local button = display.newImage(group,"images/button.png",x,y) 					-- draw the button
	button.width,button.height = display.contentWidth/5,display.contentWidth/5
	local obj = display.newText(group,""..n,x,y,native.systemFont,display.contentWidth/12) 	-- add the text
	obj:setFillColor(0,0,0) 
	if not isAllowed then 
		local s = display.contentWidth/20
		local l
		l = display.newLine(group,x-s,y-s,x+s,y+s) l.strokeWidth = display.contentWidth/80 l:setStrokeColor(1,0,0)
		l = display.newLine(group,x+s,y-s,x-s,y+s) l.strokeWidth = display.contentWidth/80 l:setStrokeColor(1,0,0)
	end
	return group 
end 

--//	Handle taps

function SetupDisplay:tap(event)
	local data = self:accessPageData()												-- access the setup data
	for i = 1,#data.m_buttons do 													-- look for the tapped button
		if data.m_buttons[i] == event.target then 									-- if it is found ...
			local skill = Framework.fw.skillLevel:getSelected() 					-- get gui skill level
			skill = (skill - 2) * 0.25 + 1 											-- make it 0.75,1,1.25
			local target = "skipAdvert"
			self:performGameEvent(tracker:select("next","skipAdvert"), { level = i, skill = skill })
			--print(i)
		end 
	end
end 

--//	Dummy function - destroys page
--//	@group 	[display group]		should go in here, beginning from 0,0 and don't change the anchors !
--//	@data 	[table]				anything you need to keep for this page

function SetupDisplay:pageDestructor(group,data)
	for i = 1,#data.m_headings do data.m_headings[i]:removeSelf() end 
	for i = 1,#data.m_buttons do 
		if i <= data.m_completed + 1 then
			data.m_buttons[i]:removeEventListener("tap",data.owner)
		end 
		data.m_buttons[i]:removeSelf()
	end
	data.m_headings = nil data.m_buttons = nil
end

--]]

--- ************************************************************************************************************************************************************************
--																	Setup Scene
--- ************************************************************************************************************************************************************************

local SetupScene = Framework:createClass("scene.setup","game.scenemanager")

function SetupScene:preOpen(manager,data,resources)
	local scene = Framework:new("game.scene")
	--Framework:dump()
	scene:new("control.swipe.level",{})
	scene:new("control.audio", { x = 17,r = 1,g = 1, b = 0 })											-- add an audio control
	scene:new("control.selector.diamond",{})													-- and a page selector, these aren't moving with the swipe obviously.
	scene:new("gui.text.list", { items = { "Easy","Moderate","Hard"}, x = 83,y = 92, tint = { 1,1,0}, key = "difficulty",
								 font = { name = "jandles", size = display.contentWidth/8}}):name("skillLevel")
	return scene 
end

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		13-Oct-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
