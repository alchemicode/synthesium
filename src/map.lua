-- map.lua

require "src/deathtile"

local gfx = love.graphics
local l_math = love.math


local route = {}

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

function GetLevel(l)
    return route[l]
end

function GetMapTile(l,x,y)
    return route[l].map[x][y].tile
end

function GetMapSheet(l,x, y)
    return route[l].map[x][y].sheet
end

function GenerateRoute(player)
    for i=1,#route do
        local l = route[i]
        for j=1,l.w do
            for k=1,l.h do
                l.map[j][k] = nil
            end
        end
        for j=1,#l.deathtiles do
            l.deathtiles[j] = nil
        end
        l.deathtiles = nil
        route[i] = nil
        for k in pairs(l.generators) do
            l.generators[k] = nil
        end
    end
    local lw = 64
    local lh = 64
    for i=1, 11 do
        route[i] = {}
        GenerateLevel(i,lw,lh)
        lw = lw + (i-1) * 8
        lh = lh + (i-1) * 8
    end
    GenerateBossLevel()
end

function GenerateLevel(l, w, h)
    route[l].w = w
    route[l].h = h
    route[l].map = {}
    route[l].deathtiles = {}
    route[l].generators = {}
    local Seed = l_math.random(75, 150)
    local t = l_math.random(100)
    local theme = 0
    if t < 30 then theme = 3
    elseif t < 67 then theme = 1
    else theme = 2 end
    for i = 1, w do
        route[l].map[i] = {}
        for j = 1, h do
            route[l].map[i][j] = {}
            local tile = 0
            local sheet = 0
            -- First layer of noise is for the layout (holes and tiles)
            local noise1 = l_math.noise(Seed * i / 1350, Seed * j / 1350)
            if noise1 < 0.125 then
                table.insert(
                    route[l].deathtiles,
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
            if i == 1 or j == 1 or i == w or j == h then
                if tile > 0 then
                    tile = 1
                else
                    tile = 0
                end
            end
            -- Second layer of noise determines the biome
            local noise2 = l_math.noise(Seed * i / 25000, Seed * j / 25000)
            if noise2 < 0.2 then
                if theme == 3 then
                    sheet = 1
                else
                    sheet = 3
                end
            elseif noise2 < 0.8 then
                sheet = theme
            else
                if theme == 2 then
                    sheet = 1
                else
                    sheet = 2
                end
            end
            route[l].map[i][j].tile = tile
            route[l].map[i][j].sheet = sheet
        end
    end
    for i = 1, 2 do
        for j = 1, 2 do
            local spawn_x
            local spawn_y
            local md = 999
            repeat
                spawn_x = math.random((i - 1) * (w / 2) + 2, math.min(i * (w / 2), w - 2))
                spawn_y = math.random((j - 1) * (h / 2) + 2, math.min(j * (h / 2), h - 2))
                for k = 1, #route[l].generators do
                    md = math.min(md, Distance(spawn_x, spawn_y, route[l].generators[k].x, route[l].generators[k].y))
                end
            until (GetMapTile(l, spawn_x, spawn_y) > 2 and md > (w/4))
            local g = HealthGenerator(spawn_x * 32, spawn_y * 32, 0)
            table.insert(route[l].generators, g)
        end
    end
end

function GenerateBossLevel()
    local shrunk = {
        {0,0,0,1,1,1,1,1,1,0,0,0},
        {0,0,1,1,2,2,2,2,1,1,0,0},
        {0,1,1,2,2,2,2,2,2,1,1,0},
        {1,1,2,2,2,2,2,2,2,2,1,1},
        {1,2,2,2,3,3,3,3,2,2,2,1},
        {1,2,2,2,3,3,3,3,2,2,2,1},
        {1,2,2,2,3,3,3,3,2,2,2,1},
        {1,2,2,2,3,3,3,3,2,2,2,1},
        {1,2,2,2,2,2,2,2,2,2,2,1},
        {0,1,1,2,2,2,2,2,2,1,1,0},
        {0,0,1,1,2,2,2,2,1,1,0,0},
        {0,0,0,1,1,1,1,1,1,0,0,0},
    }
    route[12] = {}
    route[12].w = 24
    route[12].h = 24
    route[12].map = {}
    route[12].deathtiles = {}
    route[12].generators = {}
    local t = l_math.random(100)
    local theme = 0
    if t < 30 then theme = 3
    elseif t < 67 then theme = 1
    else theme = 2 end
    for i=1,12 do
        route[12].map[1+((i-1)*2)] = {}
        route[12].map[2+((i-1)*2)] = {}
        for j=1,12 do 
            if shrunk[i][j] == 0 then
                for m=1,2 do
                    for n=1,2 do
                        route[12].map[m+((i-1)*2)][n+((j-1)*2)] = {}
                        route[12].map[m+((i-1)*2)][n+((j-1)*2)].tile = 0
                        route[12].map[m+((i-1)*2)][n+((j-1)*2)].sheet = theme
                        table.insert(
                            route[12].deathtiles,
                            DeathTile(
                                TileW,
                                TileH,
                                math.floor((m+((i-1)*2)) * TileW),
                                math.floor((n+((j-1)*2)) * TileH)
                            )
                        )
                    end
                end
            else
                route[12].map[1+((i-1)*2)][1+((j-1)*2)] = {}
                route[12].map[1+((i-1)*2)][1+((j-1)*2)].tile = shrunk[i][j]
                route[12].map[1+((i-1)*2)][1+((j-1)*2)].sheet = theme
                route[12].map[1+((i-1)*2)][2+((j-1)*2)] = {}
                route[12].map[1+((i-1)*2)][2+((j-1)*2)].tile = shrunk[i][j]
                route[12].map[1+((i-1)*2)][2+((j-1)*2)].sheet = theme

                route[12].map[2+((i-1)*2)][1+((j-1)*2)] = {}
                route[12].map[2+((i-1)*2)][1+((j-1)*2)].sheet = theme
                route[12].map[2+((i-1)*2)][2+((j-1)*2)] = {}
                route[12].map[2+((i-1)*2)][2+((j-1)*2)].sheet = theme
                if shrunk[i][j] == 1 then 
                    route[12].map[2+((i-1)*2)][1+((j-1)*2)].tile = 2
                    route[12].map[2+((i-1)*2)][2+((j-1)*2)].tile = 2
                else
                    route[12].map[2+((i-1)*2)][1+((j-1)*2)].tile = shrunk[i][j]
                    route[12].map[2+((i-1)*2)][2+((j-1)*2)].tile = shrunk[i][j]
                end
            end
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

function DrawLevel(l, cam_x, cam_y)
    local level = route[l]
    for i = 1, level.w do
        for j = 1, level.h do
            local t = level.map[i][j].tile
            local s = level.map[i][j].sheet
            if t ~= 0 then
                if TileInView(i, j, cam_x, cam_y) then
                    gfx.draw(Tileset[s], Tiles[s][t], math.floor((i - 1) * TileW), math.floor((j - 1) * TileH))
                end
            end
        end
    end
end
