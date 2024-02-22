local consts = {}

consts.windowScale = 3 -- TEMP
consts.windowTitle = "Olwen and the Organ of Hope"
consts.editorWindowTitle = "Olwen and the Organ of Hope (Map Editing Mode)"

consts.gameOutputCanvasWidth = 160
consts.gameOutputCanvasHeight = 144
consts.editorOutputCanvasWidth = 384
consts.editorOutputCanvasHeight = 256

consts.displayTileSize = 8
consts.metatileDivisions = 2 -- 2x2 display tiles in a metatile
consts.metatileSize = consts.displayTileSize * consts.metatileDivisions

return consts
