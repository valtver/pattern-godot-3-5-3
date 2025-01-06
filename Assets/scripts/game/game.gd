extends Spatial

enum GameState {
	START = 0,
	PLAY = 1,
	CHECK = 2,
	OVER = 3,
	NEXT = 4,
	COMPLETE = 5,
	PAUSE = 6,
	CONTINUE = 7,
	PREPLAY = 8,
	FIRSTSTART = 9
}

var state = GameState.FIRSTSTART
var gameSteps = []
var gameStepsTotal
var MapCamera
var Map

func _ready():
	AppInput.DisableScene()
	Events.connect("HudButtonPlayClick", self, "OnPREPLAY")
	Events.connect("HudButtonSymbolClick", self, "OnSymbolButtonClick")
	Events.connect("HudButtonMenuClick", self, "OnMenuButtonClick")
	Events.connect("HudButtonReplayClick", self, "OnReplayButtonClick")
	Events.connect("HudButtonHomeClick", self, "OnHudButtonHomeClick")
	Events.connect("HudButtonNextClick", self, "OnHudButtonNextClick")
	Events.connect("GameBonusCollected", self, "OnBonusCollect")
	InitScene()
	InitData()
	GameLoop()

func InitScene():
	MapCamera = get_parent().get_node_or_null("MapCamera")
	Map = get_node_or_null("Map")
	if Map == null:
		Map = Loader.GetResource(Data.gameData.mapScene).instance()
		add_child(Map)
	Map.Init()
	pass

func InitData():
	var lvl = Data.playerData.selectedLevelIndex
	var subLvl = Data.playerData.selectedSubLevelIndex
	Data.playerData.sessionFails = 0
	gameSteps = []
	gameSteps = Data.GetGeneratedRuntimeGameData(Data.gameData.levels[lvl].subLevels[subLvl])
	gameStepsTotal = gameSteps.size()
	state = GameState.FIRSTSTART
	
func GameLoop():	
	if state == GameState.FIRSTSTART:
		Data.playerData.gameStep = gameSteps[0]		
		SetFirstStep(Data.playerData.gameStep)
		CheckTutorialCall()
		
	if state == GameState.NEXT:
		if gameSteps.size() > 0:
			Data.playerData.gameStep = gameSteps.pick_random()
			state = GameState.START
		else:
			state = GameState.COMPLETE
			
	if state == GameState.START:
		SetNextStep(Data.playerData.gameStep)
		Call.Delay(self, "OnPREPLAY", Data.gameData.nextGameStepDelay)

	if state == GameState.PREPLAY:
		Data.playerData.selectedButton = null
		if "bonus" in Data.playerData.gameStep:
			Call.Delay(Map, "SpawnBonus", Data.playerData.gameStep["bonusDelay"])
		Call.Delay(self, "GameStepCheck", Data.gameData.gameStepDelay, "EmitGameStepCheckTime")
		AppInput.EnableScene()
		ShowStepStart()
		state = GameState.PLAY
		
	if state == GameState.CONTINUE:
		if Call.IsTimer(self, "GameStepCheck"):
			AppInput.EnableScene()
			Call.ResumeDelay(Map, "SpawnBonus")
			Call.ResumeDelay(self, "GameStepCheck")
			MapCamera.Resume()
			state = GameState.PLAY


	if state == GameState.PLAY:
#		Events.emit_signal("TutorialState1")
		Events.emit_signal("ShowHudGameScreen")
		Events.emit_signal("ShowHudSymbolButtons", Data.playerData.gameStep)
		Events.emit_signal("ShowHudMenuButton")

	if state == GameState.PAUSE:
		Call.PauseDelay(self, "GameStepCheck")
		Call.PauseDelay(Map, "SpawnBonus")
		MapCamera.Pause()
		
	if state == GameState.CHECK:
		AppInput.DisableUi()
		AppInput.DisableScene()
		var reservedScore = Call.GetTimer(self, "GameStepCheck").get_total_elapsed_time() * 1000
		Call.StopDelay(self, "GameStepCheck")
		Call.StopDelay(Map, "SpawnBonus")
		Events.emit_signal("HideHudMenuButton")
			
		if Data.playerData.selectedButton != null:
			if Data.playerData.selectedButton.GetSymbolAngles() == Data.playerData.gameStep["angles"]:
				Data.playerData.selectedButton.AnimateSuccessClick()
				Data.playerData.sessionTimeScoreLastStep = int(reservedScore)
				Data.playerData.sessionTimeScore += Data.playerData.sessionTimeScoreLastStep
				Data.playerData.sessionStars = clamp( (Data.gameData.gameStepDelay * 1000) / (Data.playerData.sessionTimeScore / gameStepsTotal), 1, 3 )
				Events.emit_signal("HudTimeScoreAnimation", Data.playerData.sessionTimeScoreLastStep)
				ShowStepComplete()
				Events.emit_signal("ShowHudStepSuccess")
				#Dirty hack here for nicer delay on last success + avoid double-complete state
				if gameSteps.size() > 1:
					OnNextStep()
				else:
					Call.Delay(self, "OnNextStep", 0.5)
					
			elif Data.playerData.sessionFails <= 2:
				Data.playerData.sessionFails += 1
				Data.playerData.selectedButton.AnimateFailClick()
				Events.emit_signal("HudTimeScoreAnimation", 0)
				Events.emit_signal("ShowHudStepFail")
				Events.emit_signal("HudSetFails", Data.playerData.sessionFails)
				Call.Delay(self, "OnNextStep", 1.3)
		else:
			if Data.playerData.sessionFails <= 2:
				Data.playerData.sessionFails += 1
				Events.emit_signal("HudTimeScoreAnimation", 0)
				Events.emit_signal("HideHudSymbolButtons")
				Events.emit_signal("ShowHudStepFail")
				Events.emit_signal("HudTimeUp")
				Call.Delay(self, "OnNextStep", 1.3)

	if state == GameState.OVER:
		Events.emit_signal("ShowHudLostScreen")
		print("GAME OVER")

	if state == GameState.COMPLETE:
		print("LEVEL END")
		Map.AddLastIsland()
		RegisterWin()
		Events.emit_signal("ShowHudWinScreen", Data.playerData.sessionStars)
		Events.emit_signal("ShowHudWinScreenScore", 1.5, true, 1.5)
		MapCamera.MoveToInTime(Map.cIsland.get_node("CameraPosition").global_position, Data.gameData.nextGameStepDelay)
		Call.Delay(self, "TryPlayEndIslandAnimation", Data.gameData.nextGameStepDelay + 0.25)
		return
		
		
func SetFirstStep(sData):
	Map.AddFirstIsland()
	MapCamera.position = Map.cIsland.get_node("CameraPosition").global_position
	for tile in Map.cTiles:
		tile.symbol.UpdateSymbol(sData["angles"], sData["sprites"])
	Data.playerData.sessionTimeScore = 0
	Data.playerData.sessionTimeScoreLastStep = 0
	Events.emit_signal("ShowHudStartScreen")
	
func SetNextStep(sData):
	Map.AddNextIsland(sData)
	MapCamera.MoveToInTime(Map.cIsland.get_node("CameraPosition").global_position, Data.gameData.nextGameStepDelay)
	for tile in Map.cTiles:
		tile.symbol.UpdateSymbol(sData["angles"], sData["sprites"])
		
func ShowStepStart():
	MapCamera.MoveToInTime(MapCamera.position + Vector3.FORWARD, Data.gameData.gameStepDelay)
	#Prepare Bonus Spawn
	var tileRevealPoint = Map.cIsland.get_node("CameraPosition").global_position
	for tile in Map.cTiles:
		Call.Delay(tile, "SymbolFadeIn", tile.global_position.distance_to(tileRevealPoint - Vector3.FORWARD * 2) * 0.05)
		
func ShowStepComplete():
	var tileRevealPoint = Map.cIsland.get_node("CameraPosition").global_position
	var rnd = RandomNumberGenerator.new()
	for mapCompleter in Map.cCompleters:
		rnd.randomize()
		var randVal = rnd.randf_range(1.0, 1.2)
		Call.Delay(mapCompleter, "PlayComplete", mapCompleter.global_position.distance_to(tileRevealPoint - Vector3.FORWARD * 2) * randVal * 0.07)

func CheckTutorialCall():
	if Data.appData.tutorial:
		Data.appData.tutorial = false
		Events.emit_signal("ShowHudTutorialScreen")
		
func OnHudButtonHomeClick():
	Events.emit_signal("AppMainMenu")
	
func OnHudButtonNextClick():
	Events.emit_signal("StartGame")

func OnReplayButtonClick():
	Events.emit_signal("ShowFastBlocker")
	Call.Delay(self, "ContinueReplayButtonClick", 0.35)

func ContinueReplayButtonClick():
	Call.StopDelay(self, "GameStepCheck")
	MapCamera.Stop()
	InitScene()
	InitData()
	GameLoop()

func OnPREPLAY():
	TryPlayStartIslandAnimation()
	state = GameState.PREPLAY
	GameLoop()
	
func OnNextStep():
	gameSteps.erase(Data.playerData.gameStep)
	print("Step removed. ", gameSteps.size(), " left")
	if Data.playerData.sessionFails > 2:
		GameOver()
	else:
		state = GameState.NEXT
		GameLoop()
		
func TryPlayStartIslandAnimation():
	var startAnimation = Map.cIsland.get_node_or_null("AnimationPlayer")
	if startAnimation != null:
		startAnimation.play("Start")
		
func TryPlayEndIslandAnimation():
	var startAnimation = Map.cIsland.get_node_or_null("AnimationPlayer")
	if startAnimation != null:
		startAnimation.play("End")
		startAnimation.queue("Idle")
	
func GameOver():
	state = GameState.OVER
	GameLoop()
	
func OnMenuButtonClick():
	if state != GameState.PAUSE:
		AppInput.DisableScene()
		state = GameState.PAUSE
		GameLoop()
	else:
		state = GameState.CONTINUE
		GameLoop()
	
func OnSymbolButtonClick(button):
	Events.emit_signal("HideHudSymbolButtons", button)
	Data.playerData.selectedButton = button
	GameStepCheck()
	
func OnBonusCollect(bonus):
	match bonus.bonusType:
		Types.Bonus.GetTime:
			Call.StopDelay(self, "GameStepCheck")
			Call.Delay(self, "GameStepCheck", Data.gameData.gameStepDelay, "EmitGameStepCheckTime")
			MapCamera.MoveToInTime(MapCamera.position + Vector3.FORWARD, Data.gameData.gameStepDelay)
	
func GameStepCheck():
	state = GameState.CHECK
	GameLoop()
		
func EmitGameStepCheckTime(timeLeft):
	Events.emit_signal("HudTimerUpdate", timeLeft / Data.gameData.gameStepDelay)
	
func RegisterWin():
	var lvlData = Data.gameData.levels[Data.playerData.selectedLevelIndex]
	var subLvlData = lvlData.subLevels[Data.playerData.selectedSubLevelIndex]
	
	subLvlData.timeScore = Data.playerData.sessionTimeScore
	subLvlData.stars = Data.playerData.sessionStars
	
	var subLevelScore = lvlData.subLevels[Data.playerData.selectedSubLevelIndex].timeScore
	if subLevelScore < Data.playerData.sessionTimeScore:
		subLevelScore = Data.playerData.sessionTimeScore
		
	var nextLevelIndex = Data.playerData.selectedLevelIndex + 1
	var nextSubLevelIndex = Data.playerData.selectedSubLevelIndex + 1
	if nextSubLevelIndex < lvlData.subLevels.size():
		lvlData.subLevels[nextSubLevelIndex].unlock = true
	elif nextLevelIndex < Data.gameData.levels.size():
		Data.gameData.levels[nextLevelIndex].unlock = true
		Data.gameData.levels[nextLevelIndex].subLevels[0].unlock = true
		
		


