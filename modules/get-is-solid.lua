local function getIsSolid(state, tileX, tileY)
	if state.map.metatileFlags[tileX] then
		if state.map.metatileFlags[tileX][tileY] then
			return state.map.metatileFlags[tileX][tileY].solid
		end
	end
	return true -- Out of bounds is solid
end

return getIsSolid
