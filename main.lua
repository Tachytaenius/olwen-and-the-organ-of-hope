local newGame = require("modules.new-game")
local updateGame = require("modules.update-game")
local drawGame = require("modules.draw-game")
local remakeWindow = require("modules.remake-window")

local consts = require("consts")
local assets = require("assets")
local mapEditor = require("map-editor")

local runType
local state

function love.load(args)
	if args[1] == "map-edit" then
		runType = "mapEditing"
	else
		runType = "playing"
	end

	remakeWindow(runType)

	love.graphics.setDefaultFilter("nearest", "nearest")

	assets.load()

	if runType == "playing" then
		state = newGame()
	elseif runType == "mapEditing" then
		mapEditor.load(args)
	end
end

function love.update(dt)
	if runType == "playing" then
		updateGame(state, dt)
	elseif runType == "mapEditing" then
		mapEditor.update(dt)
	end
end

function love.draw()
	if runType == "playing" then
		drawGame(state)
		love.graphics.draw(state.outputCanvas, 0, 0, 0, consts.windowScale)
	elseif runType == "mapEditing" then
		mapEditor.draw()
	end
end

function love.keypressed(key)
	if runType == "mapEditing" then
		mapEditor.keypressed(key)
	end
end

function love.wheelmoved(x, y)
	if runType == "mapEditing" then
		mapEditor.wheelmoved(x, y)
	end
end
