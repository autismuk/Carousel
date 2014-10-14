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

--- ************************************************************************************************************************************************************************
--//	This is an object which handles swipable pages - it is abstract, having methods to create/delete the swipable bit and so should be subclassed. It wraps it in 
--//	a group with a top layer which detects swipes and scrolls the page left/right accordingly, sending messages to pageselector objects to show which page it is.
--- ************************************************************************************************************************************************************************

local AbstractSwipable = Framework:createClass("control.swipe.base")

--//	Create the swipable page
--//	@info 	[table]		constructor info

function AbstractSwipable:constructor(info)
	self.m_overGroup = display.newGroup() 														-- this is the group that holds everything.
	self.m_contentGroup = display.newGroup() 													-- this group holds the content
	self.m_data = {} 																			-- members for the thing being swiped
	self:pageConstructor(self.m_contentGroup,self.m_data,info)									-- create the actual content.
	self.m_overGroup:insert(self.m_contentGroup)												-- put the content in the overall group
	self.m_pageCount = math.floor((self.m_contentGroup.width + display.contentWidth - 2)/		-- calculate how many pages there are.
																				display.contentWidth)
	self:sendMessage("swipepagetracker","count", { count = self.m_pageCount })					-- tell the page tracker there are that many pages.
	self.m_swipeTracker = display.newRect(self.m_overGroup,0,0, 								-- this tracks touches
													display.contentWidth,display.contentHeight)		
	self.m_swipeTracker.anchorX,self.m_swipeTracker.anchorY = 0,0 								-- position and alpha
	self.m_swipeTracker.alpha = 0.02 self.m_swipeTracker:setFillColor(1,0,1)
	self.m_swipeTracker:addEventListener("touch",self)											-- and pick up touches.
	self.m_currentPage = 1
	self.m_canSwipe = false 																	-- set to true when we can swipe
end 

--//	Tidy up

function AbstractSwipable:destructor()
	self.m_swipeTracker:removeEventListener("touch",self) 										-- remove event listener.
	self:pageDestructor(self.m_contentGroup,self.m_data)										-- tidy up content if needed (listeners, timers etc.)
	self.m_overGroup:removeSelf() self.m_overGroup = nil self.m_contentGroup = nil 				-- and tidy everything else up.
	self.m_swipeTracker = nil
end 

--//	Get display objects for scene
--//	@return [array]	list of display objects

function AbstractSwipable:getDisplayObjects()
	return { self.m_overGroup }
end 

--//	Handle touches. Start and End of a touch enable/disable the possibility of swiping - moved is used to actually detect it.
--//	@event 	[table]	event data

function AbstractSwipable:touch(event)
	local passThrough = false 																	-- true if not passed through	
	if event.phase == "began" then 																-- beginning a touch, therefore we may be swiping.
		self.m_canSwipe = true
	end
	if event.phase == "moved" and self.m_canSwipe then  										-- if swipe allowed and moving.
		local dx,dy = event.x-event.xStart,event.y-event.yStart 								-- work out swipe movement
		if math.abs(dy) < display.contentHeight / 32 and 										-- not moved too far vertically 
		   math.abs(dx) > display.contentWidth / 8 then 										-- and far enough horizontally 
		   	passThrough = true 																	-- swipe detected - don't pass through
		   	self.m_canSwipe = false 															-- can't swipe any more on this touch.
		   	if dx < 0 then self:changePage(1) else self:changePage(-1) end 						-- go to new page.
		end
	end
	if event.phase == "ended" or event.phase == "cancelled" then 								-- disable swipe at end of touch
		self.m_canSwipe = false 																-- should not be strictly necessary.
	end
	return passThrough 
end 

--//	Change to a new page and update everything.
--//	@offset [number]	offset from current page

function AbstractSwipable:changePage(offset)
	local newPage = math.max(1,math.min(self.m_currentPage+offset,self.m_pageCount))			-- work out new page
	if newPage ~= self.m_currentPage then 														-- page changed ?
		self.m_currentPage = newPage 															-- update page.
		transition.to(self.m_contentGroup,														-- transition the position to display that bit
								{ x = -display.contentWidth * (self.m_currentPage-1), time = 400 })
		self:sendMessage("swipepagetracker","select",{ page = self.m_currentPage})				-- update page tracker.
	end
end 

--//	Dummy function - creates page
--//	@group 	[display group]		should go in here, beginning from 0,0 and don't change the anchors !
--//	@data 	[table]				anything you need to keep for this page
--//	@info 	[table]				info from constructor

function AbstractSwipable:pageConstructor(group,data,info)
	local t = display.newText(group,"This is the swiping page mark number one",0,120,native.systemFont,160)
	t.anchorX,t.anchorY = 0,0 
end 

--//	Dummy function - destroys page
--//	@group 	[display group]		should go in here, beginning from 0,0 and don't change the anchors !
--//	@data 	[table]				anything you need to keep for this page

function AbstractSwipable:pageDestructor(group,data)
end

--- ************************************************************************************************************************************************************************
--																	Setup Scene
--- ************************************************************************************************************************************************************************

local SetupScene = Framework:createClass("scene.setup","game.scenemanager")

function SetupScene:preOpen(manager,data,resources)
	local scene = Framework:new("game.scene")
	scene:new("control.audio", { r = 1,g = 1, b = 0 })											-- add an audio control
	scene:new("control.selector.diamond",{})													-- and a page selector, these aren't moving with the swipe obviously.
	scene:new("control.swipe.base",{})
	return scene 
end

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		13-Oct-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
