-- Touch Events!!

local Touch = {}
local Vector2 = require "src.vector2"

----------------------------------
-- Touch Template
----------------------------------
function Touch:touchTemplate ( event )
    --local group = event.target
    if event.phase == "began" then
       
    elseif event.phase == "moved" then
        
    elseif event.phase == "ended" or event.phase == "cancelled" then
        
    end
    return true --important
end

----------------------------------
-- Energy Src touch event!
----------------------------------
function Touch:energyTouchEvent( )
    local event = self
    local t = event.target -- the sprite involved
    local a = t.actor --the energy involved in touch
    if event.phase == "began" then
        local parent = t.parent
        parent:insert( t )
		display.getCurrentStage():setFocus( t )
        t.isFocus = true
    elseif event.phase == "moved" then
        local touchPos = a.grid:unproject(event.x , event.y)
		local energyPos = Vector2:init(a:x(),a:y())
        local target = touchPos + -energyPos
        local dist = target:length()
        if(dist>=a.pipeLength)then
            --print(dist)
			--Create a pipe here!
			a.grid:spawnPipe(Vector2:init(a:x(),a:y()),target,a)
			display.getCurrentStage():setFocus(nil)
			t.isFocus = false
			return false
        end
    elseif event.phase == "ended" or event.phase == "cancelled" then
        --print("end energy touch")
        display.getCurrentStage():setFocus( nil )
		t.isFocus = false
    end
    return true --important
end



return Touch