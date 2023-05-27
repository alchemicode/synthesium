-- menu.lua


local buttonWidth = 128
local buttonHeight = 48

function loadMenu()

end

function mouseClick(x,y)
    if x > 640-(buttonWidth/2) 
    and x < 640+(buttonWidth/2) 
    and y > 360
    and y < 360 + buttonHeight then
        return 1
    else
        return 0
    end
end


function drawMenu()
    love.graphics.setColor(0,0,0.25,1)
    love.graphics.rectangle("fill", 640-(buttonWidth/2), 360, buttonWidth, buttonHeight)
    love.graphics.setColor(1,1,1,1)
    font = love.graphics.newFont(24)
    local textWidth = font:getWidth("Play")
    local textHeight = font:getHeight()
    love.graphics.print("Play", font, 640-(textWidth/2), 360+(textHeight/3))

end