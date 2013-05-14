-- Touch Events!!

local Touch = {}
local Vector2 = require "src.vector2"

----------------------------------
-- Touch Template
----------------------------------
function Touch:touchTemplate()
    local event = self
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
        --local parent = t.parent
        --parent:insert( t ) --not
		display.getCurrentStage():setFocus( t )
        t.isFocus = true
    elseif event.phase == "moved" then
        local touchPos = a.grid:unproject(event.x , event.y) -- get in world touch position
		local energyPos = a:pos() --get center position of energy tower
        local target = touchPos + -energyPos --get the direction vector from energy
        local dist2 = target:length2() -- use squared dist for optimization
        if (dist2>=a.pipeLength2) then
            target = target:normalized()*a.pipeLength + energyPos
			--Create a pipe here!
			local pipe = a.grid:spawnPipe(energyPos, target, a)
			display.getCurrentStage():setFocus(nil)
			t.isFocus = false
			display.getCurrentStage():setFocus(pipe.sprite)
			pipe.sprite.isFocus = true
			
			--a.Out = pipe
			pipe.In = a
			
			return false
        end
    elseif event.phase == "ended" or event.phase == "cancelled" then
        display.getCurrentStage():setFocus( nil )
		t.isFocus = false
    end
    return true --important
end

----------------------------------
-- Pipe touch event
----------------------------------
function Touch:pipeTouchEvent (  )
    local event = self
	local t = event.target -- the sprite involved
    local pipe = t.actor --the pipe involved in touch
    local selectedPipeOverlay = pipe.selectedPipeOverlay
    if event.phase == "began" then
		if pipe:canContinuePipe() then
			display.getCurrentStage():setFocus( t )
			t.isFocus = true
		else
			return false
		end
    elseif event.phase == "moved" then
        -- get in world touch position
        local touchPos = pipe.grid:unproject(event.x , event.y) 
		
		--Calculate distance to remove this pipe segment
		local inPos = pipe.inPos
		local targetIn = touchPos + -inPos
		local distIn2 = targetIn:length2()
		if (distIn2 <= pipe.pipeLength2/16) then
			--erase the pipe
			t.isFocus = false
			display.getCurrentStage():setFocus( pipe.In.sprite )
			if pipe.In.sprite then pipe.In.sprite.isFocus = true end
			if pipe.startConnection then
				--The start connection is the source of this pipe's energy here
			end
			pipe:dispose()
		else
			--Calculate dist to start a new pipe segment
			local outPos = pipe.outPos
			local targetOut = touchPos + -outPos
			local distOut2 = targetOut:length2() 
			if (distOut2>=pipe.pipeLength2) then
				--Create a pipe here!
				targetOut = targetOut:normalized()
				targetOut = targetOut * pipe.pipeLength
				targetOut = targetOut + outPos
				local newPipe = pipe.grid:spawnPipe(outPos, targetOut, pipe)
				display.getCurrentStage():setFocus(nil)
				t.isFocus = false
				display.getCurrentStage():setFocus(newPipe.sprite)
				newPipe.sprite.isFocus = true
				
				newPipe.In = pipe
				pipe.Out = newPipe
				
				return false
			end
		end
    elseif event.phase == "ended" or event.phase == "cancelled" then
        display.getCurrentStage():setFocus( nil )
		pipe.isFocus = false
    end
    return true --important
end


return Touch