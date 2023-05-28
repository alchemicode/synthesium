-- map.lua

require "src/deathtile"

local mapW = 64
local mapH = 64
local map = {}

TileW = 32
TileH = 32

Tileset = {}
Tiles = {}

function LoadTileset(tileset)
    local image = love.graphics.newImage(tileset)
    local tilesetW, tilesetH = image:getWidth(), image:getHeight()
    table.insert(Tileset, image)
    local sheet = {
        love.graphics.newQuad(0, 0, TileW, TileH, tilesetW, tilesetH),
        love.graphics.newQuad(32, 0, TileW, TileH, tilesetW, tilesetH),
        love.graphics.newQuad(0, 32, TileW, TileH, tilesetW, tilesetH),
        love.graphics.newQuad(32, 32, TileW, TileH, tilesetW, tilesetH)
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
    Seed = love.math.random(75, 150)
    for i = 1, mapW do
        map[i] = {}
        for j = 1, mapH do
            map[i][j] = {}
            local noise1 = love.math.noise(Seed * i / 1200, Seed * j / 1200)
            local noise2 = love.math.noise(Seed * i / 25000, Seed * j / 25000)
            local tile = 0
            local sheet = 0
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

            if noise2 < 0.5 then
                sheet = 1
            else
                sheet = 2
            end
            map[i][j].tile = tile
            map[i][j].sheet = sheet
        end
    end
end

function DrawMap()
    for i = 1, mapW do
        for j = 1, mapH do
            local t = map[i][j].tile
            local s = map[i][j].sheet
            if t ~= 0 then
                love.graphics.draw(Tileset[s], Tiles[s][t], math.floor((i - 1) * TileW), math.floor((j - 1) * TileH))
            end
        end
    end
end
