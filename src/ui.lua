-- ui.lua

local heartCase
local heart

local fE, wE, elE, eE

Difficulty = 1

function LoadUI()
    heartCase = love.graphics.newImage("res/heartslot.png")
    heart = love.graphics.newImage("res/heart.png")
    fE = love.graphics.newImage("res/fireEssence.png")
    wE = love.graphics.newImage("res/waterEssence.png")
    elE = love.graphics.newImage("res/elecEssence.png")
    eE = love.graphics.newImage("res/earthEssence.png")
end

function DrawUI(player)
    local font = love.graphics.newFont(21)
    local pos = 0
    -- draws heart cases
    for i = 1, 3 do
        pos = pos + 25
        love.graphics.draw(heartCase, pos, 25, 0, 2, 2)
        pos = pos + heartCase:getWidth()
    end

    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()

    if player.dead then
        -- respawn prompt
        local r_text = "Press 'r' to restart"
        love.graphics.print(r_text, font, width / 2 - font:getWidth(r_text) / 2,
            height / 2 - font:getHeight())
    else
        -- draws player health and essence
        local h_pos = 0
        for i = 1, player.health do
            h_pos = h_pos + 25
            love.graphics.draw(heart, h_pos, 25, 0, 2, 2)
            h_pos = h_pos + heart:getWidth()
        end
        -- love.graphics.draw(fE, 25, love.graphics:getHeight() - 100 - 64)
        -- love.graphics.draw(wE, 25, love.graphics:getHeight() - 75 - 48)
        -- love.graphics.draw(elE, 25, love.graphics:getHeight() - 50 - 32)
        -- love.graphics.draw(eE, 25, love.graphics:getHeight() - 25 - 16)
    end

    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, height / 2)
end
