-- Touch Events!!

local Touch = {}

--Event listener for each tile!
Touch:tileTouchEvent ( event )
    local group = event.target
    if event.phase == "began" then
       
    elseif event.phase == "moved" then
        
    elseif event.phase == "ended" or event.phase == "cancelled" then
        
    return true --important
end


return Touch