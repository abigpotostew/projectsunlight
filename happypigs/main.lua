
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

-- include the Corona "storyboard" module
local gamestate = require "src.gamestate"
local assetManager = require "src.assetManager"
local spSprite = require "src.libs.swiftping.sp_sprite"
local audio = require "audio"

--spSprite.setDebug(true) --Comment this out to turn off debug drawing
spSprite.setDebugColor{r = 64, g = 192, b = 64, a =192} --Change this to alter the debug line color (0 to 255 for each component)

assetManager.pushAssets()

--load menu screen
gamestate.ChangeState("Menu")

-- Debugging jumps
gamestate.DebugSetLevel(1)
gamestate.ChangeState("LevelPlaying")

--audio.play = function(name) end --Uncomment this line to disable sound
