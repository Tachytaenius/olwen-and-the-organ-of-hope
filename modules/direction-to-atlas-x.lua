local function directionToAtlasX(directionName)
	if directionName == "right" then return 0
	elseif directionName == "down" then return 1
	elseif directionName == "left" then return 2
	elseif directionName == "up" then return 3
	else
		error("Invalid direction " .. directionName)
	end
end

return directionToAtlasX
