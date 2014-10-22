--[[

Apple
-----
App Icon 1024x1024
3.5 in Retina 640x960
4 in Retina 640x1136
iPad 768x1024

Android
-------
App Icon 512x512
General 640x960
Feature 1024x500

--]]

local formats = { 

	apple_icon = {"apple","icon",1024,1024 },
	apple_35_retina = { "apple","3.5 retina",640,960 },
	apple_4_retina = { "apple","4 retina",640,1136 },
	apple_iPad = { "apple","ipad",768,1024 },

	android_icon = { "android","icon",512,512 },
	android_image = { "android","image", 640,960 },
	android_feature = { "android","feature", 1024,500 }
}

function process(s)
	return s:lower():gsub("%s+","_"):gsub("\\.","")
end

function convert(from,to,width,height)
	local s = 'convert "'..from..'" -background white -alpha off -resize '..width.."x"..height..'! "'..to..'"'
	io.popen(s)
end


 for file in io.popen([[ls *.png]]):lines() do 
 	local stub = file:sub(1,-5)
 	if stub:sub(-4) ~= "temp" then
 		print("Processing "..file)
 		for name,descr in pairs(formats) do 
 			local to = process(stub.."_"..descr[1].."_"..descr[2].."_"..descr[3].."x"..descr[4].."_temp.png")
 			convert(file,to,descr[3],descr[4])
 		end
 	end
 end