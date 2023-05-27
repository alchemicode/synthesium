--main.lua
require "src/player"
require "src/enemy"
require "src/camera"
require "src/map"
require "src/menu"

local state = 0
local paused = false

local map
local mapW = 256
local mapH = 256
local player
local cam

local deathTiles = {}

local enemies = {}

function NewGame()
    for i = 1, #deathTiles do
        table.remove(deathTiles, i)
    end
    for i = 1, #enemies do
        table.remove(enemies, i)
    end
    GenerateMap(mapW, mapH, deathTiles)
    local spawn_x, spawn_y
    repeat
        spawn_x = math.random(0, mapW)
        spawn_y = math.random(0, mapH)
    until (GetMapTile(spawn_x, spawn_y) > 2)
    player = Player()
    player:translate(spawn_x * 32, spawn_y * 32)
    cam = Camera(player)
    for i = 1, 32 do
        SpawnEnemy(math.random(1, 2))
    end
end

function Distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

function SpawnEnemy(asp)
    local spawn_x, spawn_y
    repeat
        spawn_x = math.random(0, mapW)
        spawn_y = math.random(0, mapH)
    until (GetMapTile(spawn_x, spawn_y) > 2 and Distance(player.x, spawn_x, player.y, spawn_y) > 384)
    local enemy = Enemy(player, asp)
    enemy:translate(spawn_x * 32, spawn_y * 32)
    table.insert(enemies, enemy)
end

function love.load()
    LoadTileset("res/tilemap-grassy.png")
    LoadTileset("res/tilemap-desert.png")
    loadMenu()
end

function love.mousepressed(x, y, button, istouch)
    if state == 0 then
        if button == 1 then
            if mouseClick(x, y) == 1 then
                NewGame()
                state = 1
            end
        end
    end
end

function love.keypressed(key)
    if key == "1" then
        player.aspect = 0
    end
    if key == "2" then
        player.aspect = 1
    end
    if key == "3" then
        player.aspect = 2
    end
    if key == "space" then
        player:onSpace()
        cam:shake(0.5, 15)
    end
    if key == "r" and player.dead then
        NewGame()
    end
end

function love.update(dt)
    if state == 0 then
        --updateMenu(dt)
    else
        cam:update(dt)
        player:update(dt)
        for i = 1, #enemies do
            enemies[i]:update(player, dt)
            if enemies[i].state == 2 then
                table.remove(enemies, i)
            end
        end
        for i = 1, #deathTiles do
            if deathTiles[i]:checkOverlap(player) then
                if player.canWalk then
                    player:die()
                end
            end
        end
    end
end

function love.draw()
    if state == 0 then
        drawMenu()
    else
        love.graphics.push()
        cam:draw()
        drawMap()
        player:draw()
        for i = 1, #enemies do
            enemies[i]:draw()
        end
        love.graphics.pop()
        if player.dead then
            love.graphics.print("Press 'r' to restart", 600, 300)
        end
        love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
    end
end
