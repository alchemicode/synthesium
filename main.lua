--main.lua

require "src/player"
require "src/enemy"
require "src/healthgenerator"
require "src/camera"
require "src/map"
require "src/menu"
require "src/sound"
require "src/ui"
require "src/util"

local gfx = love.graphics
local fs = love.filesystem
local kb = love.keyboard

local state = 0
local paused = false

local bg

MapW = 64
MapH = 64
local player
local cam

local level

local healthGenerators = {}

local enemies = {}

local screenScale = 1

GameData = {}
BestGame = {}

-- Loads necessary visual elements for map and UI
function love.load()
    InitGameData()
    local f = fs.newFile("best.snth")
    f:open("w")
    f:write("poopy!")
    f:close()
    gfx.setDefaultFilter("nearest")
    LoadTileset("res/tiles/tilemap-grassy.png")
    LoadTileset("res/tiles/tilemap-desert.png")
    LoadTileset("res/tiles/tilemap-volcano.png")
    LoadSound()
    LoadMenu()
    LoadUI()
    bg = gfx.newImage("res/bg.png")
    Canvas = gfx.newCanvas()
end

-- Initializes or resets GameData
function InitGameData()
    GameData.level = 0
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
    state = 2
    InitGameData()
    GenerateRoute()
    NextLevel()
end


function NextLevel()
    if state ~= 2 then state = 2 end
    for k in pairs(enemies) do
        enemies[k] = nil
    end
    if player ~= nil then
        player:reset()
    end
    GameData.level = GameData.level + 1
    level = GetLevel(GameData.level)
    MapW = level.w
    MapH = level.h
    local spawn_x, spawn_y
    repeat
        spawn_x = math.random(1, MapW - 1)
        spawn_y = math.random(1, MapH - 1)
    until (GetMapTile(GameData.level, spawn_x, spawn_y) > 2)
    if player == nil then
        player = Player()
    end

    player:translate(spawn_x * 32 + 16, spawn_y * 32 + 16)
    cam = Camera(player)
    local initAmount = MapW / 2
    for i = 1, initAmount do
        SpawnEnemy()
    end
    state = 1
end


function SpawnHealthGenerators()
    for k in pairs(healthGenerators) do
        healthGenerators[k] = nil
    end
    for i = 1, 2 do
        for j = 1, 2 do
            local spawn_x
            local spawn_y
            local md = 999
            repeat
                spawn_x = math.random((i - 1) * (MapW / 2) + 2, math.min(i * (MapW / 2), MapW - 2))
                spawn_y = math.random((j - 1) * (MapH / 2) + 2, math.min(j * (MapH / 2), MapH - 2))
                for k = 1, #healthGenerators do
                    md = math.min(md, Distance(spawn_x, spawn_y, healthGenerators[k].x, healthGenerators[k].y))
                end
            until (GetMapTile(GameData.level, spawn_x, spawn_y) > 2 and md > 16 * 32)
            local g = HealthGenerator(spawn_x * 32, spawn_y * 32, player, GameData, 0)
            table.insert(healthGenerators, g)
        end
    end
end

-- Spawns an enemy at a random spot, and decides its aspect based on the biome
function SpawnEnemy()
    local spawn_x, spawn_y
    local tile
    repeat
        spawn_x = math.random(1, MapW - 1)
        spawn_y = math.random(1, MapH - 1)
        tile = GetMapTile(GameData.level, spawn_x, spawn_y)
    until (tile > 2 and Distance(player.x, player.y, spawn_x * 32 + 16, spawn_y * 32 + 16) > 340 - GameData.diff * 20)
    local asp = GetRandomAspect(GameData.level, tile, spawn_x, spawn_y)
    local blocked = false
    for i = 1, #healthGenerators do
        local h = healthGenerators[i]
        if h.aspect == asp then
            if Distance(spawn_x * 32 + 16, spawn_y * 32 + 16, h.x, h.y) > 512 then
                blocked = true
                break
            end
        end
    end
    if not blocked then
        local enemy = Enemy(player, asp)
        enemy:translate(spawn_x * 32 + 16, spawn_y * 32 + 16)
        table.insert(enemies, enemy)
    end
end

function love.mousepressed(x, y, button, istouch)
    if state == 0 then
        if button == 1 then
            if ClickedPlay(x, y) then
                SFX_PlayConfirm()
                NewGame()
            end
            if ClickedTut(x, y) then
                SFX_PlayConfirm()
            end
            if ClickedBack(x, y) then
                SFX_PlayConfirm()
            end
        end
    else
        if paused then
            if ClickedTut(x, y) then
                SFX_PlayConfirm()
            end
            if ClickedBack(x, y) then
                SFX_PlayConfirm()
            end
        end
    end
end

function love.keypressed(key)
    for i = 1, #healthGenerators do
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
    end
    if key == "escape" and state == 1 then
        paused = not paused
        SFX_PlayConfirm()
    end
    --DEBUG
    if key == "p" and state == 1 then
        NextLevel()
    end
end

function HandleEnemySpawns(dt)
    if GameData.spawnTimer > GameData.spawnTime/2 then
        SpawnEnemy()
        GameData.spawnTimer = 0
    else
        GameData.spawnTimer = GameData.spawnTimer + dt
    end
end

function love.update(dt)
    if state == 1 then
        if not paused then
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
            for i = 1, #level.deathtiles do
                if level.deathtiles[i]:checkOverlap(player) then
                    if player.canWalk then
                        player:die()
                    end
                end
            end
            for i = 1, #healthGenerators do
                healthGenerators[i]:checkCollision(player)
                healthGenerators[i]:update(dt)
            end
            if not player.dead then
                GameData.time = GameData.time + dt
                local minutes = math.fmod(GameData.time, 3600) / 60.0
                GameData.diff = 1 + minutes * 0.5
                GameData.spawnTime = math.max(0.25, -math.sqrt(48 * minutes / GameData.diff) + 9)
                HandleEnemySpawns(dt)
                Music_PlaySynthesium()
            end
            if player.dead then
                Music_StopSynthesium()
            end
        end
    end
end

function love.draw()
    gfx.setCanvas(Canvas)
    gfx.draw(bg, 0, 0)
    DrawMenu(state, paused)
    if state == 1 then
        if not paused then
            local gscale = 1
            gfx.push()
            gfx.scale(gscale)
            cam:draw(gscale)
            DrawLevel(GameData.level, cam.x, cam.y)
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
            DrawUI(GameData, player, showGenUI)
        end
    elseif state == 2 then
        gfx.print("Loading...", 16,16)
    end
    gfx.setCanvas()
    gfx.draw(Canvas, 0, 0, 0, screenScale)
end
