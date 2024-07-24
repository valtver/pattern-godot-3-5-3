extends Spatial

enum GameState {
	START = 0,
	PLAY = 1,
	CHECK = 2,
	OVER = 3,
	NEXT = 4,
	END = 5
}

var state = GameState.START

var gameSteps = []
var tiles
var cameraTransform
var scroller

func Init():
	Events.connect("HudButtonPlayClick", self, "OnPlay")
	Events.connect("HudButtonSymbolClick", self, "OnSymbolButtonClick")
	cameraTransform = get_viewport().get_camera().get_parent()
	scroller = get_node_or_null("Scroller")
	if scroller == null:
		scroller = Loader.GetResource(Data.gameData.scrollerScene).instance()
		add_child(scroller)
	InitData()
	GameLoop()

func InitData():
	Data.playerData.gameStep = 0
	var lvl = Data.playerData.selectedLevelIndex
	var subLvl = Data.playerData.selectedSubLevelIndex
	gameSteps = GenerateGameData(Data.gameData.levels[lvl].subLevels[subLvl])

func FirstGameStep(gameStepData):
	scroller.AddFirstIsland()
	for tile in scroller.cTiles:
		tile.symbol.UpdateSymbol(gameStepData["angles"], gameStepData["sprites"])
	Events.emit_signal("ShowHudStartScreen")
		
func NextGameStep(gameStepData):
	scroller.AddNextIsland(gameStepData)
	MoveCameraTo(scroller.cIsland.get_node("CameraPosition").global_position, Data.gameData.nextGameStepDelay)
	for tile in scroller.cTiles:
		tile.symbol.UpdateSymbol(gameStepData["angles"], gameStepData["sprites"])
	Timeline.Delay(self, "OnPlay", Data.gameData.nextGameStepDelay)

func EndLevelStep():
	scroller.AddLastIsland()
	TryPlayStartIslandAnimation()
	MoveCameraTo(scroller.cIsland.get_node("CameraPosition").global_position, Data.gameData.nextGameStepDelay)
	Timeline.Delay(self, "TryPlayEndIslandAnimation", Data.gameData.nextGameStepDelay + 0.25)

func OnPlay():
	TryPlayStartIslandAnimation()
	state = GameState.PLAY
	GameLoop()
	
func PlayGameStep(gameStepData):
	Events.emit_signal("ShowHudPlayScreen")
	AnimateTilesStart()
	Events.emit_signal("ShowHudSymbolButtons", gameStepData)
	MoveCameraTo(cameraTransform.position + Vector3.FORWARD, Data.gameData.gameStepDelay)
	Timeline.Delay(self, "GameOver", Data.gameData.gameStepDelay)
	
func TryPlayStartIslandAnimation():
	var startAnimation = scroller.cIsland.get_node_or_null("AnimationPlayer")
	if startAnimation != null:
		startAnimation.play("Start")
		
func TryPlayEndIslandAnimation():
	var startAnimation = scroller.cIsland.get_node_or_null("AnimationPlayer")
	if startAnimation != null:
		startAnimation.play("Idle")
	
func GameOver():
	Events.emit_signal("HideHudSymbolButtons", null)
	state = GameState.OVER
	GameLoop()
	
func OnSymbolButtonClick(button):
	Timeline.StopTimer(self, "GameOver")
	Events.emit_signal("HideHudSymbolButtons", button)
	Data.playerData.selectedAngles = button.GetSymbolAngles()
	state = GameState.CHECK
	GameLoop()
	
func AnimateTilesStart():
	var cameraGPos = scroller.cIsland.get_node("CameraPosition").global_position
	for tile in scroller.cTiles:			
		Timeline.Delay(tile, "SymbolFadeIn", tile.global_position.distance_to(cameraGPos) * 0.05)
		
func AnimateTilesComplete():
	var cameraGPos = scroller.cIsland.get_node("CameraPosition").global_position
	for tile in scroller.cTiles:
		Timeline.Delay(tile, "PathAppear", tile.global_position.distance_to(cameraGPos) * 0.1)
	Data.playerData.gameStep += 1
	state = GameState.NEXT
	GameLoop()

func MoveCameraTo(nextPos, delay):
	var tween = get_node_or_null("CameraTween")
	if tween == null:
		tween = Tween.new()
		tween.name = "CameraTween"
		add_child(tween)
	if tween != null:
		tween.remove_all()
	tween.interpolate_property(cameraTransform, "position",
		cameraTransform.position, nextPos, delay,
		Tween.TRANS_CUBIC, Tween.EASE_IN)
	tween.start()

func GenerateGameData(subLevel):
	var gUniqueSingle = []
	var gUniqueDouble = []
	var spriteCompares = []
	
	spriteCompares.append_array(subLevel.sprites)
	gUniqueSingle.append_array(spriteCompares)
	for sprite in subLevel.sprites:
		spriteCompares.erase(spriteCompares[0])
		for cSprite in spriteCompares:
			gUniqueDouble.push_back([sprite, cSprite])
#	print("Singles: ", gUniqueSingle.size(), "\nDoubles: ", gUniqueDouble.size())
	#Pick an island
	var step = {}	
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
				#island
				step["island"] = []
				
				gameSteps.push_back(step.duplicate())
	
	randomize()
	gameSteps.shuffle()
	#AFTER SHUFFLE
	for i in gameSteps.size():
		if i == 0:
			gameSteps[i]["island"] = subLevel.startIsland
		else:
			gameSteps[i]["island"] = subLevel.islands.pick_random()
			
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
	var stepData = null
	
	if Data.playerData.gameStep < gameSteps.size():
		stepData = gameSteps[Data.playerData.gameStep]
	else:
		state = GameState.END

	if state == GameState.START:
		FirstGameStep(stepData)
		return
	if state == GameState.NEXT:
		NextGameStep(stepData)
		return
	if state == GameState.PLAY:
		PlayGameStep(stepData)
		return
	if state == GameState.CHECK:
		if Data.playerData.selectedAngles == stepData["angles"]:
			AnimateTilesComplete()
		return
	if state == GameState.OVER:
		print("GAME OVER")
		return
	if state == GameState.END:
		print("LEVEL END")
		EndLevelStep()


