-- ui.lua

local gfx = love.graphics

local heartCase
local heart

local fE, wE, elE, eE

Difficulty = 1

function LoadUI()
    heartCase = gfx.newImage("res/UI/heartslot.png")
    heart = gfx.newImage("res/UI/heart.png")
    fE = gfx.newImage("res/UI/fireEssence.png")
    wE = gfx.newImage("res/UI/waterEssence.png")
    elE = gfx.newImage("res/UI/elecEssence.png")
    eE = gfx.newImage("res/UI/earthEssence.png")
end

function DrawUI(gd, player, showGenUI)
    local font = gfx.newFont(21)
    local pos = 0
    local width = gfx.getWidth()
    local height = gfx.getHeight()

    -- draws heart cases
    for i = 1, 3 do
        pos = pos + 25
        gfx.draw(heartCase, pos, 25, 0, 2, 2)
        pos = pos + heartCase:getWidth()
    end

    local minutes = math.floor(math.fmod(gd.time,3600)/60)
    local seconds = math.floor(math.fmod(gd.time,60))
    local timer = string.format("%02d:%02d",minutes,seconds)
    gfx.push()
    gfx.setColor(1,math.max(0,1+0.1-gd.diff/10),math.max(0,1+0.1-gd.diff/10))
    gfx.print(timer, font, 25, 25 + 32 + 10)
    gfx.setColor(1,1,1)
    gfx.pop()
    

    if player.dead then
        -- respawn prompt
        local r_text = "Press 'r' to restart"
        gfx.print(r_text, font, width / 2 - font:getWidth(r_text) / 2,
            height / 2 - font:getHeight())
    else
        -- draws player health and essence
        local h_pos = 0
        for i = 1, player.health do
            h_pos = h_pos + 25
            gfx.draw(heart, h_pos, 25, 0, 2, 2)
            h_pos = h_pos + heart:getWidth()
        end
        gfx.draw(fE, 25, height - 100 - 64, 0, 1, 1)
        gfx.print(tostring(player.fireEssence), font, 50, height - 100 - 64 - font:getHeight() / 4)
        gfx.draw(wE, 25, height - 75 - 48, 0, 1, 1)
        gfx.print(tostring(player.waterEssence), font, 50, height - 75 - 48 - font:getHeight() / 4)
        gfx.draw(elE, 25, height - 50 - 32, 0, 1, 1)
        gfx.print(tostring(player.elecEssence), font, 50, height - 50 - 32 - font:getHeight() / 4)
        gfx.draw(eE, 25, height - 25 - 16, 0, 1, 1)
        gfx.print(tostring(player.earthEssence), font, 50, height - 25 - 16 - font:getHeight() / 4)

        if showGenUI then
            gfx.print("Press '1'", font, 80, height - 100 - 64 - font:getHeight() / 4)
            gfx.print("Press '2'", font, 80, height - 75 - 48 - font:getHeight() / 4)
            gfx.print("Press '3'", font, 80, height - 50 - 32 - font:getHeight() / 4)
            gfx.print("Press '4'", font, 80, height - 25 - 16 - font:getHeight() / 4)
        end
        
    end

    gfx.print("FPS: " .. tostring(love.timer.getFPS()), 10, height / 2)
end
