local consts = require("consts")
local settings = require("settings")
local animations = require("animations")

local getEntityDisplayPos = require("modules.get-entity-display-pos")
local translateByDirection = require("modules.translate-by-direction")
local getIsSolid = require("modules.get-is-solid")

local function updateGame(state, dt)
	-- Move player if moving
	if state.player.moveProgress then
		state.player.moveProgress = state.player.moveProgress + state.player.moveSpeed * dt
		if state.player.moveProgress >= 1 then
			state.player.x, state.player.y = translateByDirection(state.player.x, state.player.y, state.player.moveDirection, 1)
			state.player.moveProgress = nil
			state.player.moveDirection = nil
			state.player.animation = "standing"
			state.player.animationFrame = 0
			state.player.secondHalfWalkAnimation = not state.player.secondHalfWalkAnimation
		end
	end
	-- Start player movement if not moving
	if not state.player.moveProgress then
		local startedMoving = false
		-- TODO: Prioritise currently held direction
		-- moveiDirection gets set to direction if startedMoving is set to true
		if love.keyboard.isDown(settings.controls.moveRight) then
			state.player.direction = "right"
			startedMoving = not getIsSolid(state, state.player.x + 1, state.player.y)
		elseif love.keyboard.isDown(settings.controls.moveDown) then
			state.player.direction = "down"
			startedMoving = not getIsSolid(state, state.player.x, state.player.y + 1)
		elseif love.keyboard.isDown(settings.controls.moveLeft) then
			state.player.direction = "left"
			startedMoving = not getIsSolid(state, state.player.x - 1, state.player.y)
		elseif love.keyboard.isDown(settings.controls.moveUp) then
			state.player.direction = "up"
			startedMoving = not getIsSolid(state, state.player.x, state.player.y - 1)
		end
		if startedMoving then
			state.player.animation = "walking"
			state.player.moveDirection = state.player.direction
			state.player.moveProgress = 0
		end
	end
	-- Now set animation (moving it here fixed single frame incorrect drawing)
	if state.player.moveProgress then
		assert(state.player.animation == "walking")
		assert(animations.walking.frames % 2 == 0) -- Number of frames is to be divisible by two
		local visualMoveProgress = state.player.moveProgress
		if state.player.secondHalfWalkAnimation then
			visualMoveProgress = visualMoveProgress + 1
		end
		state.player.animationFrame = math.floor(visualMoveProgress * animations.walking.frames / 2)
	end

	local x, y = getEntityDisplayPos(state.player)
	state.camera.x, state.camera.y = x + consts.displayTileSize * consts.metatileDivisions / 2, y + consts.displayTileSize * consts.metatileDivisions / 2
end

return updateGame
