-- Project Sunlight
-- The best damn tower defence since the birth of mankind.
-- Created By Larry Chew
--			  Kevin Otoshi
--			  Stewart Bracken

display.setStatusBar( display.HiddenStatusBar )

--Initialize screen orienation stuff
local screen = require("screen")
--create our grid
local grid = require("grid")




--print FPS info
local prevTime = system.getTimer()
local fps = display.newText( "30", 30, 47, nil, 24 )
fps:setTextColor( 255 )
fps.prevTime = prevTime

local function enterFrame( event )
	local curTime = event.time
	local dt = curTime - prevTime
	prevTime = curTime
	if ( (curTime - fps.prevTime ) > 100 ) then
		-- limit how often fps updates
		fps.text = string.format( '%.2f', 1000 / dt )
	end
end
Runtime:addEventListener( "enterFrame", enterFrame )
--end print FPS info