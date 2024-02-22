local consts = require("consts")
local assets = require("assets")

local loadMap = require("modules.load-map")

return function()
	local state = {}

	state.stateType = "game"
	state.outputCanvas = love.graphics.newCanvas(consts.gameOutputCanvasWidth, consts.gameOutputCanvasHeight)

	state.camera = {
		x = 0,
		y = 0
	}

	state.player = {
		x = 0,
		y = 0,
		direction = "down",
		moveDirection = nil,
		moveProgress = nil,
		moveSpeed = 2,
		entitySkinName = "ancientKnight",
		animation = "standing",
		animationFrame = 0,
		secondHalfWalkAnimation = false
	}
	state.nonPlayerEntities = {} -- Use of table.remove is fine for this game

	loadMap(state, "starterMap")

	return state
end
