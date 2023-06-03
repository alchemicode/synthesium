-- map.lua

require "src/deathtile"

local gfx = love.graphics
local l_math = love.math

local mapW = 32
local mapH = 32
local map = {}

TileW = 32
TileH = 32

Tileset = {}
Tiles = {}

function LoadTileset(tileset)
    local image = gfx.newImage(tileset)
    local tilesetW, tilesetH = image:getWidth(), image:getHeight()
    table.insert(Tileset, image)
    local sheet = {
        gfx.newQuad(0, 0, TileW, TileH, tilesetW, tilesetH),
        gfx.newQuad(32, 0, TileW, TileH, tilesetW, tilesetH),
        gfx.newQuad(0, 32, TileW, TileH, tilesetW, tilesetH),
        gfx.newQuad(32, 32, TileW, TileH, tilesetW, tilesetH)
    }
    table.insert(Tiles, sheet)
end

function GetMapTile(x, y)
    return map[x][y].tile
end

function GetMapSheet(x, y)
    return map[x][y].sheet
end

function GenerateMap(w, h, deathtiles, state)
    mapW = w
    mapH = h
    Seed = l_math.random(75, 150)
    for i = 1, mapW do
        map[i] = {}
        for j = 1, mapH do
            map[i][j] = {}
            local tile = 0
            local sheet = 0
            -- First layer of noise is for the layout (holes and tiles)
            local noise1 = l_math.noise(Seed * i / 1350, Seed * j / 1350)
            if noise1 < 0.15 then
                table.insert(
                    deathtiles,
                    DeathTile(
                        TileW,
                        TileH,
                        math.floor((i - 1) * TileW),
                        math.floor((j - 1) * TileH)
                    )
                )
            elseif noise1 < 0.25 then
                tile = 1
            elseif noise1 < 0.5 then
                tile = 2
            elseif noise1 < 0.95 then
                tile = 3
            else
                tile = 4
            end
            if i == 1 or j == 1 or i == mapW or j == mapH then
                if tile > 0 then
                    tile = 1
                else
                    tile = 0
                end
            end
            -- Second layer of noise determines the biome
            local noise2 = l_math.noise(Seed * i / 25000, Seed * j / 25000)
            if noise2 < 0.45 then
                sheet = 1
            elseif noise2 < 0.85 then
                sheet = 2
            else
                sheet = 3
            end
            map[i][j].tile = tile
            map[i][j].sheet = sheet
        end
    end
end

function TileInView(x, y, cam_x, cam_y)
    local width = gfx.getWidth()
    local height = gfx.getHeight()
    local p_x = x * 32
    local p_y = y * 32
    return p_x >= cam_x - width / 2
        and p_x - 32 <= cam_x + width / 2
        and p_y >= cam_y - height / 2
        and p_y - 32 <= cam_y + height / 2
end

function DrawMap(cam_x, cam_y)
    for i = 1, mapW do
        for j = 1, mapH do
            local t = map[i][j].tile
            local s = map[i][j].sheet
            if t ~= 0 then
                if TileInView(i, j, cam_x, cam_y) then
                    gfx.draw(Tileset[s], Tiles[s][t], math.floor((i - 1) * TileW), math.floor((j - 1) * TileH))
                end
            end
        end
    end
end
