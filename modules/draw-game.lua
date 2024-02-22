local quadreasonable = require("lib.quadreasonable")

local assets = require("assets")
local consts = require("consts")
local animations = require("animations")

local getEntityDisplayPos = require("modules.get-entity-display-pos")
local directionToAtlasX = require("modules.direction-to-atlas-x")

local function drawEntity(entity)
	local x, y = getEntityDisplayPos(entity)
	love.graphics.draw(
 		assets.entitySkins[entity.entitySkinName][entity.animation],
		quadreasonable.getQuad(
			directionToAtlasX(entity.direction),
			entity.animationFrame,
			4,
			animations[entity.animation].frames,
			consts.displayTileSize * consts.metatileDivisions,
			consts.displayTileSize * consts.metatileDivisions
		),
		x, y
	)
end

local function drawGame(state)
	love.graphics.setCanvas(state.outputCanvas)
	love.graphics.clear()
	love.graphics.translate(-state.camera.x, -state.camera.y)
	love.graphics.translate(consts.gameOutputCanvasWidth / 2, consts.gameOutputCanvasHeight / 2)
	for x = 0, state.map.widthMetatiles * consts.metatileDivisions - 1 do
		for y = 0, state.map.heightMetatiles * consts.metatileDivisions - 1 do
			love.graphics.draw(
				assets.displayTiles[state.map.displayTiles[x][y]],
				consts.displayTileSize * x,
				consts.displayTileSize * y
			)
		end
	end
	drawEntity(state.player)
	love.graphics.origin()
	love.graphics.setCanvas()
end

return drawGame
