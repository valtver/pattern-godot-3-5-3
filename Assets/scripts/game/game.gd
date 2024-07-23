extends Spatial

enum GameState {
	START = 0,
	PLAY = 1,
	CHECK = 2,
	OVER = 3
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
	Events.connect("HudButtonSymbolClick", self, "OnSymbolButtonClick")
	cameraTransform = get_viewport().get_camera().get_parent()
	scroller = get_node_or_null("Scroller")
	if scroller == null:
		scroller = Loader.GetResource(Data.gameData.scrollerScene).instance()
		add_child(scroller)

func InitData():
	Data.playerData.gameStep = 0
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
	scroller.cIsland.get_node("AnimationPlayer").play("Start")
	state = GameState.PLAY
	GameLoop()
	
func GameOver():
	state = GameState.OVER
	GameLoop()
	
func OnSymbolButtonClick(button):
	Timeline.StopTimer(self, "GameOver")
	Data.playerData.selectedAngles = button.GetSymbolAngles()
	state = GameState.CHECK
	GameLoop()

func FinishGameStep(gameStepData):
	scroller.InitNext(gameStepData)
	AnimateTilesComplete()
	pass

func AnimateTilesComplete():
	pass
	
func AnimateTilesStart():
	var cameraGPos = scroller.cIsland.get_node("CameraPosition").global_position
	for tile in scroller.currentTiles:			
		Timeline.Delay(tile, "SymbolFadeIn", tile.global_position.distance_to(cameraGPos) * 0.05)

func MoveCameraTo(nextPos):
	var tween = get_node_or_null("CameraTween")
	if tween == null:
		tween = Tween.new()
		tween.name = "CameraTween"
		add_child(tween)
	tween.interpolate_property(cameraTransform, "position",
		cameraTransform.position, nextPos, Data.gameData.gameStepDelay,
		Tween.TRANS_CUBIC, Tween.EASE_IN)
	tween.start()

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
	var stepData = gameSteps[Data.playerData.gameStep]
	if state == GameState.START:		
		FirstGameStep(stepData)
		return
	if state == GameState.PLAY:
		Events.emit_signal("ShowHudPlayScreen")
		AnimateTilesStart()
		Events.emit_signal("ShowHudSymbolButtons", stepData)
		MoveCameraTo(cameraTransform.position + Vector3.FORWARD)
		Timeline.Delay(self, "GameOver", Data.gameData.gameStepDelay)
	if state == GameState.CHECK:
		if Data.playerData.selectedAngles == stepData["angles"]:
			print("CORRECT ", Data.playerData.selectedAngles, " ", stepData["angles"])
		else:
			print("INCORRECT ", Data.playerData.selectedAngles, " ", stepData["angles"])
	if state == GameState.OVER:
		print("GAME OVER")


