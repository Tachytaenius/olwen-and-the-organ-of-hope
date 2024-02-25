local json = require("lib.json")

local assets = require("assets")
local consts = require("consts")

local metatileFlagsFormat = require("modules.metatile-flags-format")
local decodeMetatileFlags = metatileFlagsFormat.decodeMetatileFlags
local encodeMetatileFlags = metatileFlagsFormat.encodeMetatileFlags

local mapEditor = {}

local viewportWidth, viewportHeight = 256, 256
local tilesetViewerWidth = 128
local viewportMoveSpeed = 128
-- local selectedTileTypeFlashTimerLength = 0.25
-- local selectedTileTypeFlashTimerBlinkLength = 0.025
local outputCanvas, viewportCanvas

local viewportX, viewportY
local mapInfo
local displayTiles, metatileFlags
local tileNamesById, tileIdsByName
local currentDisplayTileTypeId
local mapAddress
local filesOpen -- boolean

local infoJsonFile, displayTilesBinFile, tilesetTxtFile, metatileFlagsBinFile

local function mousePosToDisplayTileMapPosDisplayTiles(mx, my)
	local x, y =
		mx / consts.windowScale + viewportX,
		my / consts.windowScale + viewportY
	return
		math.floor(x / consts.displayTileSize),
		math.floor(y / consts.displayTileSize)
end

local function mousePosToDisplayTileMapPosMetatiles(mx, my)
	local x, y =
		mx / consts.windowScale + viewportX,
		my / consts.windowScale + viewportY
	return
		math.floor(x / (consts.displayTileSize * consts.metatileDivisions)),
		math.floor(y / (consts.displayTileSize * consts.metatileDivisions))
end

local function readWhole(file)
	file:seek("set")
	return file:read("*a")
end

local function closeFiles()
	infoJsonFile:close()
	displayTilesBinFile:close()
	tilesetTxtFile:close()
	metatileFlagsBinFile:close()
	filesOpen = false
end

local function openFiles(mode)
	infoJsonFile = io.open(mapAddress .. "info.json", mode)
	displayTilesBinFile = io.open(mapAddress .. "display-tiles.bin", mode .. "b")
	tilesetTxtFile = io.open(mapAddress .. "tileset.txt", mode)
	metatileFlagsBinFile = io.open(mapAddress .. "metatile-flags.bin", mode .. "b")
	filesOpen = true
end

local function save()
	if filesOpen then
		closeFiles()
	end
	openFiles("w")

	infoJsonFile:write(json.encode(mapInfo))

	local displayTilesByteTable = {}
	for x = 0, mapInfo.widthMetatiles * consts.metatileDivisions - 1 do
		for y = 0, mapInfo.heightMetatiles * consts.metatileDivisions - 1 do
			local i = x + y * mapInfo.widthMetatiles * consts.metatileDivisions + 1
			displayTilesByteTable[i] = string.char(tileIdsByName[displayTiles[x][y]])
		end
	end
	local displayTilesBinary = table.concat(displayTilesByteTable)
	displayTilesBinFile:write(displayTilesBinary)

	-- Start with 0
	local tilesetText = tileNamesById[0] .. "\n"
	-- Then do 1+, if present
	for _, tileName in ipairs(tileNamesById) do
		tilesetText = tilesetText .. tileName .. "\n"
	end
	tilesetTxtFile:write(tilesetText)

	local metatileFlagsByteTable = {}
	for x = 0, mapInfo.widthMetatiles - 1 do
		for y = 0, mapInfo.heightMetatiles - 1 do
			local i = x + y * mapInfo.widthMetatiles + 1
			metatileFlagsByteTable[i] = string.char(encodeMetatileFlags(metatileFlags[x][y]))
		end
	end
	local metatileFlagsBinary = table.concat(metatileFlagsByteTable)
	metatileFlagsBinFile:write(metatileFlagsBinary)

	closeFiles()
	openFiles("r")
end

function mapEditor.load(args)
	print("Check map-editor-readme.txt for usage")

	filesOpen = false

	love.graphics.setLineStyle("rough")
	outputCanvas = love.graphics.newCanvas(consts.editorOutputCanvasWidth, consts.editorOutputCanvasHeight)
	viewportCanvas = love.graphics.newCanvas(viewportWidth, viewportHeight)

	viewportX, viewportY = 0, 0

	currentDisplayTileTypeId = 0

	assert(args[2], "Specify location of map directory")
	mapAddress = args[2] .. "/"

	local displayTilesBinary, metatileFlagsBinary
	if args[3] == "new" then
		mapInfo = {
			widthMetatiles = tonumber(args[4]),
			heightMetatiles = tonumber(args[5])
		}

		displayTilesBinary = string.char(0):rep(mapInfo.widthMetatiles * consts.metatileDivisions * mapInfo.heightMetatiles * consts.metatileDivisions)

		tileNamesById = {
			[0] = args[6]
		}
		tileIdsByName = {
			[args[6]] = 0
		}

		metatileFlagsBinary = string.char(0):rep(mapInfo.widthMetatiles * mapInfo.heightMetatiles)
	else
		openFiles("r") -- b is appended when appropriate
		assert(infoJsonFile, "Couldn't open info.json")
		assert(displayTilesBinFile, "Couldn't open display-tiles.bin")
		assert(tilesetTxtFile, "Couldn't open tileset.txt")
		assert(metatileFlagsBinFile, "Could not open metatile-flags.bin")

		mapInfo = json.decode(readWhole(infoJsonFile))

		local i = 0
		tileNamesById, tileIdsByName = {}, {}
		while true do
			local line = tilesetTxtFile:read()
			if not line then
				break
			end
			tileNamesById[i] = line
			tileIdsByName[line] = i
			i = i + 1
		end

		displayTilesBinary = readWhole(displayTilesBinFile)

		metatileFlagsBinary = readWhole(metatileFlagsBinFile)
	end

	displayTiles = {}
	for x = 0, mapInfo.widthMetatiles * consts.metatileDivisions - 1 do
		displayTiles[x] = {}
		for y = 0, mapInfo.heightMetatiles * consts.metatileDivisions - 1 do
			local i = x + y * mapInfo.widthMetatiles * consts.metatileDivisions + 1
			local newDisplayTile = tileNamesById[displayTilesBinary:byte(i, i)]
			displayTiles[x][y] = newDisplayTile
		end
	end

	metatileFlags = {}
	for x = 0, mapInfo.widthMetatiles - 1 do
		metatileFlags[x] = {}
		for y = 0, mapInfo.heightMetatiles - 1 do
			local i = x + y * mapInfo.widthMetatiles + 1
			metatileFlags[x][y] = decodeMetatileFlags(metatileFlagsBinary:byte(i, i))
		end
	end
end

function mapEditor.keypressed(key)
	if love.keyboard.isDown("lctrl") then
		if key == "s" then
			-- TODO: Message
			save()
		end
	end
	if key == "p" then
		local x, y = love.mouse.getPosition()
		if x < viewportWidth * consts.windowScale and y < viewportHeight * consts.windowScale then
			local x, y = mousePosToDisplayTileMapPosMetatiles(x, y)
			if x >= 0 and x < mapInfo.widthMetatiles and y >= 0 and y < mapInfo.heightMetatiles then
				if mapInfo.playerSpawnX == x and mapInfo.playerSpawnY == y then
					-- Rotate
					local dir = mapInfo.playerSpawnDirection
					mapInfo.playerSpawnDirection = dir == "right" and "down" or dir == "down" and "left" or dir == "left" and "up" or dir == "up" and "right"
				else
					-- New place
					mapInfo.playerSpawnX = x
					mapInfo.playerSpawnY = y
				end
			end
		end
	end
end

function mapEditor.wheelmoved(x, y)
	currentDisplayTileTypeId = (currentDisplayTileTypeId - y) % (#tileNamesById + 1)
end

function mapEditor.update(dt)
	if not love.keyboard.isDown("lctrl") then
		if love.keyboard.isDown("w") then
			viewportY = viewportY - viewportMoveSpeed * dt
		end
		if love.keyboard.isDown("s") then
			viewportY = viewportY + viewportMoveSpeed * dt
		end
		if love.keyboard.isDown("a") then
			viewportX = viewportX - viewportMoveSpeed * dt
		end
		if love.keyboard.isDown("d") then
			viewportX = viewportX + viewportMoveSpeed * dt
		end
	end

	if love.mouse.isDown({1, 2}) then
		local x, y = love.mouse.getPosition()
		if x < viewportWidth * consts.windowScale and y < viewportHeight * consts.windowScale then
			if love.keyboard.isDown("lshift") then
				local x, y = mousePosToDisplayTileMapPosMetatiles(x, y)
				if metatileFlags[x] then
					if metatileFlags[x][y] then
						metatileFlags[x][y].solid = love.mouse.isDown(1) -- Else 2
					end
				end
			else
				local x, y = mousePosToDisplayTileMapPosDisplayTiles(x, y)
				if displayTiles[x] then
					if displayTiles[x][y] then
						displayTiles[x][y] = tileNamesById[currentDisplayTileTypeId]
					end
				end
			end
		end
	end
end

function mapEditor.draw()
	love.graphics.setCanvas(viewportCanvas)
	love.graphics.clear(0, 0, 0)
	love.graphics.translate(-viewportX, -viewportY)
	for x = 0, mapInfo.widthMetatiles * consts.metatileDivisions - 1 do
		for y = 0, mapInfo.heightMetatiles * consts.metatileDivisions - 1 do
			if
				metatileFlags[
					math.floor(x / consts.metatileDivisions)
				][
					math.floor(y / consts.metatileDivisions)
				].solid
			then
				love.graphics.setColor(0.75, 0.75, 0.75)
			end
			love.graphics.draw(
				assets.displayTiles[displayTiles[x][y]],
				consts.displayTileSize * x,
				consts.displayTileSize * y
			)
			-- Draw metatile grid
			love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
			if x % 2 == 0 then
				love.graphics.line(
					consts.displayTileSize * x,
					consts.displayTileSize * y,
					consts.displayTileSize * x,
					consts.displayTileSize * (y + 1)
				)
			end
			if y % 2 == 0 then
				love.graphics.line(
					consts.displayTileSize * x,
					consts.displayTileSize * y,
					consts.displayTileSize * (x + 1),
					consts.displayTileSize * y
				)
			end
			love.graphics.setColor(1, 1, 1)
		end
	end
	love.graphics.print("S (" .. (mapInfo.playerSpawnDirection == "up" and "^" or mapInfo.playerSpawnDirection == "right" and ">" or mapInfo.playerSpawnDirection == "down" and "v" or mapInfo.playerSpawnDirection == "left" and "<") .. ")", mapInfo.playerSpawnX * consts.metatileDivisions * consts.displayTileSize, mapInfo.playerSpawnY * consts.metatileDivisions * consts.displayTileSize)
	love.graphics.rectangle("line", -1, -1, mapInfo.widthMetatiles * consts.metatileDivisions * consts.displayTileSize + 2, mapInfo.heightMetatiles * consts.metatileDivisions * consts.displayTileSize + 2)
	love.graphics.origin()
	love.graphics.setCanvas()

	love.graphics.setCanvas(outputCanvas)
	love.graphics.clear(0.2, 0.2, 0.2)
	love.graphics.draw(viewportCanvas)
	love.graphics.translate(viewportWidth, 0)
	local viewerWidthTiles = math.floor(tilesetViewerWidth / consts.displayTileSize)
	local i = 0
	while tileNamesById[i] do
		-- if i ~= currentDisplayTileTypeId or love.timer.getTime() % selectedTileTypeFlashTimerLength > selectedTileTypeFlashTimerBlinkLength then
		local xTiles = i % viewerWidthTiles
		local yTiles = math.floor(i / viewerWidthTiles)
		love.graphics.draw(assets.displayTiles[tileNamesById[i]], xTiles * consts.displayTileSize, yTiles * consts.displayTileSize)
		-- end
		i = i + 1
	end
	love.graphics.rectangle("line", currentDisplayTileTypeId % viewerWidthTiles * consts.displayTileSize, math.floor(currentDisplayTileTypeId / viewerWidthTiles) * consts.displayTileSize, consts.displayTileSize + 1, consts.displayTileSize + 1)
	love.graphics.origin()
	love.graphics.setCanvas()

	love.graphics.draw(outputCanvas, 0, 0, 0, consts.windowScale)
end

return mapEditor
