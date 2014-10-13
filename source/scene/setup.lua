--- ************************************************************************************************************************************************************************
---
---				Name : 		setup.lua
---				Purpose :	Set up Page
---				Updated:	13 October 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************


--- ************************************************************************************************************************************************************************
--																	Setup Scene
--- ************************************************************************************************************************************************************************

local SetupScene = Framework:createClass("scene.setup","game.scenemanager")

function SetupScene:preOpen(manager,data,resources)
	local scene = Framework:new("game.scene")
	return scene 
end

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		13-Oct-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
