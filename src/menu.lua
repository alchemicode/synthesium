-- menu.lua

local gfx = love.graphics

local buttonWidth = 128
local buttonHeight = 48

function LoadMenu()

end

function MouseClick(x, y)
    if x > 640 - (buttonWidth / 2)
        and x < 640 + (buttonWidth / 2)
        and y > 360
        and y < 360 + buttonHeight then
        return 1
    else
        return 0
    end
end

function DrawMenu()
    gfx.setColor(0, 0, 0.25, 1)
    gfx.rectangle("fill", 640 - (buttonWidth / 2), 360, buttonWidth, buttonHeight)
    gfx.rectangle("fill", 640 - (buttonWidth/2), 360 + 25 + buttonHeight)
    gfx.setColor(1, 1, 1, 1)
    local font = gfx.newFont(24)
    local textWidth = font:getWidth("Play")
    local textHeight = font:getHeight()
    gfx.print("Play", font, 640 - (textWidth / 2), 360 + (textHeight / 3))
    textWidth = Font:getWidth("How To Play")
    gfx.print("How To Play", font, 640 - (textWidth / 2), 360 + 25 + buttonHeight + (textHeight / 3))
end
