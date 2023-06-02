-- menu.lua

local gfx = love.graphics

local buttonWidth = 128
local buttonHeight = 48

local tutorial

local fE, wE, elE, eE, hG, title, watermark


function LoadMenu()
    fE = gfx.newImage("res/UI/fireEssence.png")
    wE = gfx.newImage("res/UI/waterEssence.png")
    elE = gfx.newImage("res/UI/elecEssence.png")
    eE = gfx.newImage("res/UI/earthEssence.png")
    hG = gfx.newImage("res/sprites/healthGenerator.png")
    title = gfx.newImage("res/title.png")
    watermark = gfx.newImage("res/watermark.png")
end

function ClickedPlay(x, y)
    if x > 640 - (buttonWidth / 2)
        and x < 640 + (buttonWidth / 2)
        and y > 360
        and y < 360 + buttonHeight then
        return true
    else
        return false
    end
end

function ClickedTut(x, y)
    if x > 640 - (buttonWidth*1.5/2)
        and x < 640 + (buttonWidth*1.5/2)
        and y > 360 + 25
        and y < 360 + 25 + buttonHeight*2 then
        tutorial = true
        return true
    else
        return false
    end
end

function ClickedBack(x, y)
    if x > 25
        and x < 25 + (buttonWidth)
        and y > 25
        and y < 25 + buttonHeight then
        tutorial = false
        return true
    else
        return false
    end
end

function DrawTutorial()
    gfx.setColor(0, 0, 0.25, 1)
    gfx.rectangle("fill", 25, 25, buttonWidth-15, buttonHeight)
    gfx.setColor(1, 1, 1, 1)
    local font = gfx.newFont(24)
    local textWidth = font:getWidth("Back")
    local textHeight = font:getHeight()
    gfx.print("Back", font, 25 + (textWidth/2), 25 + (textHeight / 3))
    font = gfx.newFont(18)
    local start = 100
    local text = "Oh no! You're trapped on this island with no way off."
    textWidth = font:getWidth(text)
    gfx.print(text, font, 640-textWidth/2, start)
    text = "This place is crawling with curious and dangerous spirits."
    textWidth = font:getWidth(text)
    gfx.print(text, font, 640-textWidth/2, start + (textHeight+10)*1)
    text = "Defeating them will allow you to collect their essence."
    textWidth = font:getWidth(text)
    gfx.print(text, font, 640-textWidth/2, start + (textHeight+10)*2)
    text = "To harm them, you need to fuse with their aspect."
    textWidth = font:getWidth(text)
    gfx.print(text, font, 640-textWidth/2, start + (textHeight+10)*3)
    gfx.draw(fE,640-64,start + (textHeight+10)*3 + 32,0,2,2)
    gfx.draw(wE,640-32,start + (textHeight+10)*3 + 32,0,2,2)
    gfx.draw(elE,640,start + (textHeight+10)*3 + 32,0,2,2)
    gfx.draw(eE,640+32,start + (textHeight+10)*3 + 32,0,2,2)
    text = "Press 'space' to leap forward and take on their power."
    textWidth = font:getWidth(text)
    gfx.print(text, font, 640-textWidth/2, start + (textHeight+10)*5)
    text = "Some aspects are weak to others." 
    textWidth = font:getWidth(text)
    gfx.print(text, font, 640-textWidth/2, start + (textHeight+10)*6)
    text = "After fusing with water, for example, fire spirits will die on contact."
    textWidth = font:getWidth(text)
    gfx.print(text, font, 640-textWidth/2, start + (textHeight+10)*7)
    text = "Somewhere on the island there are 4 Heart Generators, where you can heal."
    textWidth = font:getWidth(text)
    gfx.print(text, font, 640-textWidth/2, start + (textHeight+10)*8)

    gfx.draw(hG, gfx.newQuad(0, 0, 32, 37, 160, 37), 640-16, start - 5 + (textHeight+10)*9)

    text = "You can give 5 of one kind of essence to heal and give an aspect to the machine."
    textWidth = font:getWidth(text)
    gfx.print(text, font, 640-textWidth/2, start + (textHeight+10)*10)
    text = "With an aspect, it will prevent spirits of that type from spawning nearby."
    textWidth = font:getWidth(text)
    gfx.print(text, font, 640-textWidth/2, start + (textHeight+10)*11)
    text = "You'll also be able to heal with only 3 of that essence."
    textWidth = font:getWidth(text)
    gfx.print(text, font, 640-textWidth/2, start + (textHeight+10)*12)
    text = "Hold out for as long as you can. Good luck!"
    textWidth = font:getWidth(text)
    gfx.print(text, font, 640-textWidth/2, start + (textHeight+10)*13)
end

function DrawMenu(state, paused)
    if state == 0 then
        if tutorial then
            DrawTutorial()
        else
            gfx.draw(title,640-title:getWidth()/2, 120-title:getHeight()/2)
            gfx.draw(watermark,10,710-watermark:getHeight()/4,0,0.25,0.25)
            gfx.setColor(0, 0, 0.25, 1)
            gfx.rectangle("fill", 640 - (buttonWidth / 2), 360, buttonWidth, buttonHeight)
            gfx.rectangle("fill", 640 - (buttonWidth*1.5/2), 360 + 25 + buttonHeight, buttonWidth*1.5, buttonHeight)
            gfx.setColor(1, 1, 1, 1)
            local font = gfx.newFont(24)
            local textWidth = font:getWidth("Play")
            local textHeight = font:getHeight()
            gfx.print("Play", font, 640 - (textWidth / 2), 360 + (textHeight / 3))
            textWidth = font:getWidth("How To Play")
            gfx.print("How To Play", font, 640 - (textWidth / 2), 360 + 25 + buttonHeight + (textHeight / 3))
        end 
    else
        if paused then
            if tutorial then
                DrawTutorial()
            else
                local font = gfx.newFont(24)
                local textHeight = font:getHeight()
                local textWidth = font:getWidth("Paused")
                gfx.print("Paused", font,640 - (textWidth / 2), 360 - textHeight)
                gfx.setColor(0, 0, 0.25, 1)
                gfx.rectangle("fill", 640 - (buttonWidth*1.5/2), 360 + 25 + buttonHeight, buttonWidth*1.5, buttonHeight)
                gfx.setColor(1, 1, 1, 1)
                textWidth = font:getWidth("How To Play")
                gfx.print("How To Play", font, 640 - (textWidth / 2), 360 + 25 + buttonHeight + (textHeight / 3))
            end
        end
        
    end
end
