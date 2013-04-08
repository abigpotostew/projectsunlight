-- Project Sunlight
-- The best damn tower defence since the birth of mankind.
-- Created By Larry Chew
--			  Kevin Otoshi
--			  Stewart Bracken

-- Disable undeclared globals
setmetatable(_G, {
	__newindex = function(_ENV, var, val)
		if var ~= 'tableDict' then
			error(("attempt to set undeclared global \"%s\""):format(tostring(var)), 2)
		else
			rawset(_ENV, var, val)
		end
	end,
	__index = function(_ENV, var)
		if var ~= 'tableDict' then
			error(("attempt to read undeclared global \"%s\""):format(tostring(var)), 2)
		end
	end,
})

local util = require("src.util")

-- Some globals set by various corona modules
-- Widget adds some globals
util.DeclareGlobal("sprite")
util.DeclareGlobal("physics")

io.output():setvbuf('no') -- Allows print statements to appear on iOS console output
display.setStatusBar(display.HiddenStatusBar) -- hide the status bar


--Initialize screen orienation stuff
local screen = require("screen")

local gamestate = require "src.gamestate"

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

io.output():setvbuf('no') -- Allows print statements to appear on iOS console output

