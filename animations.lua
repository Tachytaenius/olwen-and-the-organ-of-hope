local animations = {}

local function new(name, frames)
	animations[name] = {
		frames = frames
	}
end

new("standing", 1)
new("walking", 4)

return animations
