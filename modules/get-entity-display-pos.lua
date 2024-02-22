local consts = require("consts")

local translateByDirection = require("modules.translate-by-direction")

local function getEntityDisplayPos(entity)
	local x, y =
		entity.x * consts.metatileSize,
		entity.y * consts.metatileSize
	if entity.moveProgress then
		return translateByDirection(x, y, entity.moveDirection, entity.moveProgress * consts.metatileSize)
	end
	return x, y
end

return getEntityDisplayPos
