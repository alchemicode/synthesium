--main.lua

require "src/player"
require "src/enemy"
require "src/healthgenerator"
require "src/camera"
require "src/map"
require "src/menu"
require "src/ui"

local gfx = love.graphics

local state = 0
local paused = false

MapW = 256
MapH = 256
local player
local cam

local deathTiles = {}

local healthGenerators = {}

local enemies = {}

GameData = {}

-- Loads necessary visual elements for map and UI
function love.load()
    gfx.setDefaultFilter("nearest")
    LoadTileset("res/tilemap-grassy.png")
    LoadTileset("res/tilemap-desert.png")
    LoadTileset("res/tilemap-volcano.png")
    LoadMenu()
    LoadUI()
end

-- Initializes or resets GameData
function InitGameData()
    GameData.time = 0
    GameData.fireKills = 0
    GameData.waterKills = 0
    GameData.elecKills = 0
    GameData.earthKills = 0
    GameData.fireFusions = 0
    GameData.waterFusions = 0
    GameData.elecFusions = 0
    GameData.earthFusions = 0
    GameData.diff = 1
    GameData.spawnTime = 10
    GameData.spawnTimer = 0
end

-- (Re)Generates the map, resets and spawns the player in a new spot
function NewGame()
    InitGameData()
    if state == 1 then
        for k in pairs(deathTiles) do
            deathTiles[k] = nil
        end
        for k in pairs(enemies) do
            enemies[k] = nil
        end
    end

    GenerateMap(MapW, MapH, deathTiles, state)
    local spawn_x, spawn_y
    repeat
        spawn_x = math.random(0, MapW-1)
        spawn_y = math.random(0, MapH-1)
    until (GetMapTile(spawn_x, spawn_y) > 2)
    if state == 0 then
        player = Player()
    end
    player:translate(spawn_x * 32 + 16, spawn_y * 32 + 16)
    SpawnHealthGenerators()
    cam = Camera(player)
    for i = 1, 64 do
        SpawnEnemy()
    end
end

function Distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

function BoolToInt(bool)
    return bool and 1 or 0
end

function SpawnHealthGenerators()
    for k in pairs(healthGenerators) do
        healthGenerators[k] = nil
    end
    for i=1,2 do
        for j=1,2 do
            local spawn_x
            local spawn_y
            repeat
                spawn_x = math.random(0, math.min(i*(MapW/2), MapW-1))
                spawn_y = math.random(0, math.min(j*(MapW/2), MapH-1))
                local md = 999
                for i=1,#healthGenerators do
                    md = math.min(md, Distance(spawn_x,spawn_y,healthGenerators[i].x,healthGenerators[i].y))
                end
            until (GetMapTile(spawn_x, spawn_y) > 2 and md > 512)
            local g = HealthGenerator(spawn_x*32, spawn_y*32, player, GameData,0)
            table.insert(healthGenerators,g)
        end
    end
end

-- Spawns an enemy at a random spot, and decides its aspect based on the biome
function SpawnEnemy()
    local spawn_x, spawn_y
    repeat
        spawn_x = math.random(1, MapW - 1)
        spawn_y = math.random(1, MapH - 1)
    until (GetMapTile(spawn_x, spawn_y) > 2 and Distance(player.x, player.y, spawn_x * 32 + 16, spawn_y * 32 + 16) > 384)
    local sheet = GetMapSheet(spawn_x, spawn_y)
    local aspRand = math.random(0, 100)
    local asp = 1
    if sheet == 1 then
        if aspRand < 67 then
            asp = 2
        else
            asp = 4
        end
    elseif sheet == 2 then
        if aspRand < 67 then
            asp = 1
        else
            asp = 4
        end
    elseif sheet == 3 then
        if aspRand < 67 then
            asp = 1
        else
            asp = 3
        end
    end
    local enemy = Enemy(player, asp)
    enemy:translate(spawn_x * 32 + 16, spawn_y * 32 + 16)
    table.insert(enemies, enemy)
end

function love.mousepressed(x, y, button, istouch)
    if state == 0 then
        if button == 1 then
            if MouseClick(x, y) == 1 then
                NewGame()
                state = 1
            end
        end
    end
end

function love.keypressed(key)
    for i=1,#healthGenerators do
        if healthGenerators[i].showUI then
            if key == "1" then
                healthGenerators[i]:interact(player, 1)
            elseif key == "2" then
                healthGenerators[i]:interact(player, 2)
            elseif key == "3" then
                healthGenerators[i]:interact(player, 3)
            elseif key == "4" then
                healthGenerators[i]:interact(player, 4)
            end
        end
        
    end
    if key == "space" then
        player:onSpace()
        cam:shake(0.5, 15)
    end
    if key == "r" and player.dead then
        NewGame()
        player:reset()
    end
end

function HandleEnemySpawns(dt)
    GameData.time = GameData.time + dt
    local minutes = math.fmod(GameData.time,3600)/60.0
    GameData.diff = 1 + minutes * 0.5
    GameData.spawnTime = math.max(0.5, -math.sqrt(48*minutes/GameData.diff)+10)
    
    if GameData.spawnTimer > math.ceil(GameData.spawnTime) then
        SpawnEnemy()
        GameData.spawnTimer = 0
    else
        GameData.spawnTimer = GameData.spawnTimer + dt
    end
end

function love.update(dt)
    if state == 0 then
        --updateMenu(dt)
    else
        cam:update(dt)
        player:update(dt)
        for i, v in pairs(enemies) do
            if v ~= nil then
                v:update(GameData, player, dt)
                if v.state == 2 then
                    v = nil
                end
            else
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
        for i = 1, #healthGenerators do
            healthGenerators[i]:checkCollision(player)
            healthGenerators[i]:update(dt)
        end
        if player.dead == false then
            HandleEnemySpawns(dt)
        end
        
    end
end

function love.draw()
    if state == 0 then
        DrawMenu()
    else
        gfx.push()
        cam:draw()
        DrawMap(cam.x, cam.y)
        local showGenUI = false
        for i = 1, #healthGenerators do
            healthGenerators[i]:draw(cam.x, cam.y)
            if healthGenerators[i].showUI == true then 
                showGenUI = true
            end
        end
        player:draw()
        for i = 1, #enemies do
            enemies[i]:draw(cam.x, cam.y)
        end
        gfx.pop()
        DrawUI(GameData, player,showGenUI)
    end
end
