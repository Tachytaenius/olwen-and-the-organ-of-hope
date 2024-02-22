local consts = require("consts")

local iconImageData = love.image.newImageData("icon.png")

local function getCurrentWindowDisplay()
	local _, _, flags = love.window.getMode()
	return flags.display
end

return function(runType)
	local w, h
	if runType == "playing" then
		w, h = consts.gameOutputCanvasWidth, consts.gameOutputCanvasHeight
	elseif runType == "mapEditing" then
		w, h = consts.editorOutputCanvasWidth, consts.editorOutputCanvasHeight
	end
	love.window.setMode(w * consts.windowScale, h * consts.windowScale, {
		fullscreen = consts.fullscreen,
		borderless = consts.fullscreen,
		display = getCurrentWindowDisplay()
	})
	love.window.setIcon(iconImageData)
	love.window.setTitle(runType == "mapEditing" and consts.editorWindowTitle or runType == "playing" and consts.windowTitle)
end
