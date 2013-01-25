-- 
-- Abstract: SpriteTilesComplex
-- By "complex", we mean it's more work; you specify the data for each frame manually.
--
-- Version: 1.0
-- 
-- Sample code is MIT licensed, see http://developer.anscamobile.com/code/license
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.

--display.setDefault( "background", 255 )
display.setStatusBar( display.HiddenStatusBar )

--[[
local options = 
{
	-- Required params
	width = 32,
	height = 32,
	numFrames = 256,

	-- content scaling
	sheetContentWidth = 1024,
	sheetContentHeight = 1024,
}
--]]

-- The following is a manual duplication of the above:

-- (1) Generate the first 16 out of 256 frames
local options = { frames = {},
	-- content scaling
	sheetContentWidth = 1024,
	sheetContentHeight = 1024, 
}
local sequences
local sprites
local tileWidth = 32
local tileHeight = 32
local columns = 2
local rows	  = 3
for iY=0,rows do
	for jX=0,columns do
		table.insert(options.frames,{ x = jX*tileWidth,
									  y = iY*tileHeight,
									  width = tileWidth,
									  height = tileHeight
									 })
	end
end
-- for i=0,32 do
-- 	table.insert(options.frames,{x=32*i,y=0,width=tileWidth,height=tileHeight})
-- end

-- (2) Generate the remaining 256 frames programatically:
-- Instead of typing them all out, we just duplicate the first row 15 more times,
-- adjusting the y value as necessary.
--local frames = options.frames
-- for j=1,30 do
-- 	for i=1,32 do
-- 		local src = frames[i]
-- 		local element = {
-- 			x = src.x,
-- 			y = 32 * j,
-- 			width = src.width,
-- 			height = src.height,
-- 		}
-- 		table.insert( frames, element )
-- 	end
-- end

local sheet = graphics.newImageSheet( "tiles.png", options )

--local sequenceData = {}

local w = 32
local h = 32
local halfW = w*0.5
local halfH = h*0.5

local function createTiles( x, y, xMax, yMax, group )
	local xStart = x
	local j = 0
	
	sequences = {}
	sequences["wood"] = {name="wood", start=1, count = 1}
	sequences["grass"] = {name="grass", start=2, count = 1}
	sequences["horz"] = {name="horz", start=3, count = 1}
	sequences["leftdown"] = {name="leftdown", start=4, count = 1}
	sequences["rightdown"] = {name="rightdown", start=5, count = 1}
	sequences["stone"] = {name="stone", start=6, count = 1}
	sequences["leftup"] = {name="leftup", start=7, count = 1}
	sequences["rightup"] = {name="rightup", start=8, count = 1}
	sequences["vert"] = {name="vert", start=9, count = 1}
	sequences["water"] = {name="water", start=10, count = 1}
	
	for iX = 1,tileWidth do
		for jY = 1, tileHeight do
			local sprite = display.newSprite(sheet, sequences.water )
			group:insert(sprite)
			sprite:translate(iX*tileWidth,jY*tileHeight)
			sprite:play()
		end
	end
	
	-- for k,v in pairs(sequences) do
	-- 	local sprite = display.newSprite( sheet, v )
	-- 	if ( group ) then
	-- 		group:insert( sprite )
	-- 	end
	-- 	sprite:translate( options.frames[i].x, options.frames[1].y )
	-- 	sprite:play()
	-- 	table.insert(sprites,sprite)
	-- end

	-- while ( true ) do
	-- 		local i = 1+math.fmod( j, 32 )
	-- 		j = j + 1
	-- 		
	-- 		local dancer = "dancer" .. i
	-- 		local numFrames = 32
	-- 		local start = (i % 32)*numFrames + 1
	-- 		local sequence = { name=dancer, start=start, count=numFrames, loopDirection="bounce" }
	-- 
	-- 		local sprite
	-- 
	-- 		if ( group ) then
	-- 			sprite = display.newSprite( sheet, sequence )
	-- 			group:insert( sprite )
	-- 		else
	-- 			sprite = display.newSprite( sheet, sequence )
	-- 		end
	-- 
	-- 		sprite:translate( x, y )
	-- 		sprite:play()
	-- 
	-- 		x = x + w
	-- 		if ( x > xMax ) then
	-- 			x = xStart
	-- 			y = y + h
	-- 		end
	-- 
	-- 		if ( y > yMax ) then
	-- 			break
	-- 		end
	-- 	end

end

local function createTileGroup( nx, ny )
	local group = display.newImageGroup( sheet )
	group.xMin = -(nx-1)*display.contentWidth - halfW
	group.yMin = -(ny-1)*display.contentHeight - halfH
	group.xMax = halfW
	group.yMax = halfH
	function group:touch( event )
		if ( "began" == event.phase ) then
			self.xStart = self.x
			self.yStart = self.y
			self.xBegan = event.x
			self.yBegan = event.y
		elseif ( "moved" == event.phase ) then
			local dx = event.x - self.xBegan
			local dy = event.y - self.yBegan
			local x = dx + self.xStart
			local y = dy + self.yStart
			if ( x < self.xMin ) then x = self.xMin end
			if ( x > self.xMax ) then x = self.xMax end
			if ( y < self.yMin ) then y = self.yMin end
			if ( y > self.yMax ) then y = self.yMax end
			self.x = x
			self.y = y
		end
		return true
	end
	group:addEventListener( "touch", group )
	
	
	local x = halfW
	local y = halfH
	
	local xMax = nx * display.contentWidth
	local yMax = ny * display.contentHeight
	
	createTiles( x, y, xMax, yMax, group )

	return group
end

local nx = 2
local ny = 2
local group = createTileGroup( nx, ny )

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
