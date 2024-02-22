local assets = {}

function assets.load()
	assets.displayTiles = {}
	local items = love.filesystem.getDirectoryItems("assets/display-tiles/") -- kebab-case directory name, camelCase filenames
	for _, itemName in ipairs(items) do
		local info = love.filesystem.getInfo("assets/display-tiles/" .. itemName, "file")
		if info and itemName:sub(-4, -1) == ".png" then
			assets.displayTiles[itemName:sub(1, -5)] = love.graphics.newImage("assets/display-tiles/" .. itemName)
		end
	end

	-- Just making it work
	assets.entitySkins = {}
	local items = love.filesystem.getDirectoryItems("assets/entity-skins/") -- kebab-case directory name, camelCase subdirectories
	for _, itemName in ipairs(items) do
		local path = "assets/entity-skins/" .. itemName
		local info = love.filesystem.getInfo(path, "directory")
		if info then
			local entitySkinTable = {}
			assets.entitySkins[itemName] = entitySkinTable
			local items = love.filesystem.getDirectoryItems(path)
			for _, itemName in pairs(items) do
				local path = path .. "/" .. itemName
				local info = love.filesystem.getInfo(path, "file")
				if info and itemName:sub(-4, -1) == ".png" then
					entitySkinTable[itemName:sub(1, -5)] = love.graphics.newImage(path)
				end
			end
		end
	end
end

return assets
