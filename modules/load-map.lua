local json = require("lib.json")

local consts = require("consts")

local decodeMetatileFlags = require("modules.metatile-flags-format").decodeMetatileFlags

local function loadMap(state, mapName)
	local path = "assets/maps/" .. mapName
	local map = json.decode(love.filesystem.read(path .. "/info.json"))
	map.displayTiles = {}
	map.metatileFlags = {}
	map.tileset = {}

	local i = 0
	for line in love.filesystem.lines(path .. "/tileset.txt") do
		map.tileset[i] = line
		i = i + 1
	end

	local metatileFlagsBin = love.filesystem.read(path .. "/metatile-flags.bin")
	for x = 0, map.widthMetatiles - 1 do
		map.metatileFlags[x] = {}
		for y = 0, map.heightMetatiles - 1 do
			local i = x + y * map.widthMetatiles + 1
			map.metatileFlags[x][y] = decodeMetatileFlags(metatileFlagsBin:byte(i, i))
		end
	end

	local displayTiles = love.filesystem.read(path .. "/display-tiles.bin")
	for x = 0, map.widthMetatiles * consts.metatileDivisions - 1 do
		map.displayTiles[x] = {}
		for y = 0, map.heightMetatiles * consts.metatileDivisions - 1 do
			local i = x + y * map.widthMetatiles * consts.metatileDivisions + 1
			map.displayTiles[x][y] = map.tileset[displayTiles:byte(i, i)]
		end
	end

	state.map = map

	state.player.x, state.player.y = map.playerSpawnX, map.playerSpawnY
	state.player.direction = map.playerSpawnDirection
end

return loadMap
