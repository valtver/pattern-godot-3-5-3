extends Spatial

enum GameState {
	START = 0
}

var state = GameState.START

var gameSteps = []
var tiles
var cameraTransform
var scroller

func _ready():
	Init()
	InitData()
	GameLoop()
	pass # Replace with function body.

func Init():
	Events.connect("HudButtonPlayClick", self, "OnPlayButtonClick")
	cameraTransform = get_viewport().get_camera().get_parent()
	scroller = get_node_or_null("Scroller")
	if scroller == null:
		scroller = Loader.GetResource(Data.gameData.scrollerScene).instance()
		add_child(scroller)

func InitData():
	Data.playerData.gameStep = -1
	var lvl = Data.playerData.selectedLevelIndex
	var subLvl = Data.playerData.selectedSubLevelIndex
	gameSteps = GenerateGameData(Data.gameData.levels[lvl].subLevels[subLvl])

func FirstGameStep(gameStepData):
	scroller.AddFirstIsland(gameStepData)
	for tile in scroller.currentTiles:
		tile.symbol.UpdateSymbol(gameStepData["angles"], gameStepData["sprites"])
	Events.emit_signal("ShowHudStartScreen")
		
func NextGameStep(gameStepData):
	scroller.AddNext(gameStepData)
	for tile in scroller.currentTiles:
		tile.symbol.UpdateSymbol(gameStepData["angles"], gameStepData["sprites"])
		
func OnPlayButtonClick():
	Events.emit_signal("ShowHudPlayScreen")
	AnimateTilesStart()
	Events.emit_signal("ShowHudSymbolButtons")

func FinishGameStep(gameStepData):
	scroller.InitNext(gameStepData)
	AnimateTilesComplete()
	MoveCameraToNext()
	pass

func AnimateTilesComplete():
	pass
	
func AnimateTilesStart():
	for tile in scroller.currentTiles:
		tile.symbol.visible = true
		if tile.symbolBg != null:
			tile.symbolBg.visible = true
		tile.symbol.PlayJump()
	pass
	
func MoveCameraToNext():
	pass

func GenerateGameData(subLevel):
	var gUniqueSingle = []
	var gUniqueDouble = []
	var spriteCompares = []
	var islandsArray = []
	
	spriteCompares.append_array(subLevel.sprites)
	gUniqueSingle.append_array(spriteCompares)
	for sprite in subLevel.sprites:
		spriteCompares.erase(spriteCompares[0])
		for cSprite in spriteCompares:
			gUniqueDouble.push_back([sprite, cSprite])
	islandsArray.append_array(subLevel.islands)
#	print("Singles: ", gUniqueSingle.size(), "\nDoubles: ", gUniqueDouble.size())
	#Pick an island
	var step = {}
	step["island"] = []
	if gameSteps.size() == 0:
		step["island"] = subLevel.startIsland
	else:
		islandsArray.pick_random()
	
	#Singles and offsets
	for singleSprite in gUniqueSingle:
		for symbolType in subLevel.symbolTypes:
			var symbolData = Data.gameData.symbolData.SymbolTypes[symbolType]
			for map in symbolData["maps"]:
				if map == Types.SubSymbolMap.Single:
					step["sprites"] = []
					for n in Data.gameData.symbolData.SubSymbolMap[map].size():
						step["sprites"].push_back(singleSprite)
			for offset in symbolData["offsets"]:
				var offsetData = Data.gameData.symbolData.SubSymbolOffset[offset] 
				step["angles"] = []
				for i in symbolData["angles"].size():
					step["angles"].push_back( symbolData["angles"][offsetData[i]] )
				#generate buttons options ahead
				step["buttons"] = []
				step["buttons"].append_array(GenerateButtons(symbolType, offset))
				gameSteps.push_back(step.duplicate())
	
	gameSteps.shuffle()
	return gameSteps

func GenerateButtons(symbolType, correctOffset):
	var symbolData = Data.gameData.symbolData.SymbolTypes[symbolType]
	var buttons = []
	
	var button = {
		"angles": []
	}
	var offsetData = Data.gameData.symbolData.SubSymbolOffset[correctOffset]
	for i in symbolData["angles"].size():
		button["angles"].push_back( symbolData["angles"][offsetData[i]] )
	buttons.push_back(button.duplicate())
		
	if symbolType == Types.SymbolType.DiagonalLeft:
		button = {
			"angles": []
		}
		var newSymbolData = Data.gameData.symbolData.SymbolTypes[Types.SymbolType.DiagonalRight]
		for i in newSymbolData["angles"].size():
			button["angles"].push_back( newSymbolData["angles"][i] )
		buttons.push_back(button.duplicate())

		
		button = {
			"angles": []
		}
		offsetData = Data.gameData.symbolData.SubSymbolOffset[Types.SubSymbolOffset.X]
		for i in newSymbolData["angles"].size():
			button["angles"].push_back( newSymbolData["angles"][offsetData[i]] )
		buttons.push_back(button.duplicate())

	elif symbolType == Types.SymbolType.DiagonalRight:
		button = {
			"angles": []
		}
		offsetData = Data.gameData.symbolData.SubSymbolOffset[Types.SubSymbolOffset.None]
		var newSymbolData = Data.gameData.symbolData.SymbolTypes[Types.SymbolType.DiagonalLeft]
		for i in newSymbolData["angles"].size():
			button["angles"].push_back( newSymbolData["angles"][i] )
		buttons.push_back(button.duplicate())
		
		button = {
			"angles": []
		}
		offsetData = Data.gameData.symbolData.SubSymbolOffset[Types.SubSymbolOffset.X]
		for i in newSymbolData["angles"].size():
			button["angles"].push_back( newSymbolData["angles"][offsetData[i]] )
		buttons.push_back(button.duplicate())
		
	else:
		var keys = Data.gameData.symbolData.SubSymbolOffset.keys()
		keys.erase(correctOffset)
		var randomRemove = keys.pick_random()
		keys.erase(randomRemove)
	
		for offset in keys:
			button = {
				"angles": []
			}
			offsetData = Data.gameData.symbolData.SubSymbolOffset[offset] 
			for i in symbolData["angles"].size():
				button["angles"].push_back( symbolData["angles"][offsetData[i]] )
			buttons.push_back(button.duplicate())
		#
#	print("Buttons: ", symbolType, " ", buttons, "\n")
	buttons.shuffle()
	return buttons

func GameLoop():
	if state == GameState.START:
		Data.playerData.gameStep += 1
		var stepData = gameSteps[Data.playerData.gameStep]
		FirstGameStep(stepData)
		return


