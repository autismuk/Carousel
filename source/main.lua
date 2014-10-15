--- ************************************************************************************************************************************************************************
---
---				Name : 		main.lua
---				Purpose :	Top level code "Carousel"
---				Updated:	12 October 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

ApplicationDescription = { 																		-- application description.
	appName = 		"Carousel",
	version = 		"1.0",
	developers = 	{ "Paul Robson" },
	email = 		"paul@robsons.org.uk",
	fqdn = 			"uk.org.robsons.brainwash", 												-- must be unique for each application.
    admobIDs = 		{ 																			-- admob Identifiers.
    					ios = "ca-app-pub-8354094658055499/1749592813", 						-- TODO: Must be interstitial ones !
						android = "ca-app-pub-8354094658055499/1609992011"
					},
	advertType = 	"banner",																	-- show banners. -- TODO: Change to interstitial
	showDebug = 	true 																		-- show debug info and adverts.
}

display.setStatusBar(display.HiddenStatusBar)													-- hide status bar.
require("strict")																				-- install strict.lua to track globals etc.
require("framework.framework")																	-- framework.
require("utils.sound")																			-- sfx singleton
require("utils.simplescene")																	-- simple scenes.
local fm = require("utils.fontmanager")															-- bitmap font manager
require("utils.stubscene")																		-- stub scenes for development.
require("scene.game")																			-- main game scene
require("scene.setup")																			-- setup scene
require("game.levelmanager")																	-- level manager.

--- ************************************************************************************************************************************************************************
--																				Start Up
--- ************************************************************************************************************************************************************************

math.randomseed(system.getTimer())

Framework:new("audio.sound",																	-- create sounds object, not much in this game.
					{ sounds = { "correct","wrong","win" } })


local manager = Framework:new("game.manager") 													-- Create a new game manager and then add states.

manager:addManagedState("title",
						Framework:new("scene.simple.touch",{
							constructor = function(storage,group,scene,manager)					-- just create some animated bitmap headings.
								local r = display.newRect(group,0,0,display.contentWidth,display.contentHeight)
								r.anchorX,r.anchorY = 0,0 r.alpha = 1 r:setFillColor(0,0,0.5)
								local ver = display.newText(group,"v"..ApplicationDescription.version,0,0,system.nativeFont,14)
								ver.anchorX,ver.anchorY = 0,0 ver:setFillColor(0,1,0)
								storage.t1 = display.newBitmapText(group,"Carousel",display.contentWidth/2,display.contentHeight * 0.2,"jandles",display.contentWidth*0.4):setTintColor(1,1,0)
								storage.t2 = display.newBitmapText(group,"A Matching Puzzle Game",display.contentWidth/2,display.contentHeight * 0.55,"jandles",display.contentWidth/7):setTintColor(1,0.5,0)
								storage.t3 = display.newBitmapText(group,"Written by Paul Robson (C) 2014",display.contentWidth/2,display.contentHeight * 0.9,"jandles",display.contentWidth/10):setTintColor(0,1,1)
								storage.t1:setModifier(fm.Modifiers.SimpleCurveModifier:new(0,180,0.3,3)):animate(3)
								storage.t3:setModifier("wobble")
							end,
							destructor = function(storage,group,scene,manager)
								storage.t1:removeSelf()
								storage.t2:removeSelf()
								storage.t3:removeSelf()
							end
						}),
						{ next = "level"})

manager:addManagedState("level",																-- level selector scene
						Framework:new("scene.setup",{ }),
						{ next = "game" })

manager:addManagedState("game",																	-- game scene
						Framework:new("scene.game.manager",{}),
						{ next = "level" })

manager:start("level",{ level = 3 }) 															-- and start.

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		12-Oct-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************

-- TODO: Add in adverts (timing issue)
-- TODO: proper levels and testing.
