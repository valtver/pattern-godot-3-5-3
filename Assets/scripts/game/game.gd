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
	PREPLAY = 8
}

var camTween = null

var state = GameState.START

var runtimeData
var gameSteps = []
var tiles
var cameraTransform
var scroller

func _ready():
	AppInput.DisableUi()
	Events.connect("HudButtonPlayClick", self, "OnPREPLAY")
	Events.connect("HudButtonSymbolClick", self, "OnSymbolButtonClick")
	Events.connect("HudButtonMenuClick", self, "OnMenuButtonClick")
	Events.connect("HudButtonReplayClick", self, "OnReplayButtonClick")
	Events.connect("HudButtonHomeClick", self, "OnHudButtonHomeClick")
	Events.connect("HudButtonNextClick", self, "OnHudButtonNextClick")
	InitScene()
	InitData()
	GameLoop()

func InitScene():
	cameraTransform = get_tree().get_root().get_camera().get_parent()
	scroller = get_node_or_null("Scroller")
	if scroller == null:
		scroller = Loader.GetResource(Data.gameData.scrollerScene).instance()
		add_child(scroller)
	scroller.Init()
	pass

func InitData():
	Data.playerData.gameStep = -1
	var lvl = Data.playerData.selectedLevelIndex
	var subLvl = Data.playerData.selectedSubLevelIndex
	gameSteps = []
	gameSteps = Data.GetGeneratedRuntimeGameData(Data.gameData.levels[lvl].subLevels[subLvl])
	state = GameState.NEXT

func OnHudButtonHomeClick():
	Events.emit_signal("AppMainMenu")
	
func OnHudButtonNextClick():
	Events.emit_signal("StartGame")

func OnReplayButtonClick():
	Timeline.StopDelay(self, "GameOver")
	StopCameraMove()
	InitScene()
	InitData()
	GameLoop()

func OnPREPLAY():
	TryPlayStartIslandAnimation()
	state = GameState.PREPLAY
	GameLoop()
		
func TryPlayStartIslandAnimation():
	var startAnimation = scroller.cIsland.get_node_or_null("AnimationPlayer")
	if startAnimation != null:
		startAnimation.play("Start")
		
func TryPlayEndIslandAnimation():
	var startAnimation = scroller.cIsland.get_node_or_null("AnimationPlayer")
	if startAnimation != null:
		startAnimation.play("End")
		startAnimation.queue("Idle")
	
func GameOver():
	Events.emit_signal("HideHudSymbolButtons", null)
	state = GameState.OVER
	GameLoop()
	
func OnMenuButtonClick():
	if state != GameState.PAUSE:
		state = GameState.PAUSE
		GameLoop()
	else:
		state = GameState.CONTINUE
		GameLoop()
	
func OnSymbolButtonClick(button):
	Events.emit_signal("HideHudSymbolButtons", button)
	Data.playerData.selectedAngles = button.GetSymbolAngles()
	state = GameState.CHECK
	GameLoop()
	
func AnimateTilesStart():
	var cameraGPos = scroller.cIsland.get_node("CameraPosition").global_position
	for tile in scroller.cTiles:
		Timeline.Delay(tile, "SymbolFadeIn", tile.global_position.distance_to(cameraGPos - Vector3.FORWARD * 2) * 0.05)
		
func AnimateTilesComplete():
	pass

func MoveCameraTo(nextPos, delay):
	if camTween != null:
		camTween.kill()
		
	camTween = create_tween()
	camTween.set_ease(Tween.EASE_IN)
	camTween.set_trans(Tween.TRANS_CUBIC)
	camTween.tween_property(cameraTransform, "position", nextPos, delay)
	camTween.play()
	
func PauseCameraMove():
	if camTween != null:
		camTween.pause()
		
func ResumeCameraMove():
	if camTween != null:
		camTween.play()
		
func StopCameraMove():
	if camTween != null:
		camTween.kill()
		
func EmitGameOverTime(timeLeft):
	Events.emit_signal("HudTimerUpdate", timeLeft / Data.gameData.gameStepDelay)
			
func GameLoop():
	var stepData = null
	
	if state == GameState.NEXT:
		Data.playerData.gameStep += 1
		state = GameState.START
		
	if Data.playerData.gameStep < gameSteps.size():
		stepData = gameSteps[Data.playerData.gameStep]
	else:
		state = GameState.COMPLETE

	if state == GameState.START:
		if Data.playerData.gameStep == 0:
			scroller.AddFirstIsland()
			cameraTransform.position = scroller.cIsland.get_node("CameraPosition").global_position
			for tile in scroller.cTiles:
				tile.symbol.UpdateSymbol(stepData["angles"], stepData["sprites"])
			Data.playerData.sessionScore = 0
			Data.playerData.sessionScoreLastStep = 0
			Events.emit_signal("ShowHudStartScreen")
		elif Data.playerData.gameStep > 0:
			scroller.AddNextIsland(stepData)
			MoveCameraTo(scroller.cIsland.get_node("CameraPosition").global_position, Data.gameData.nextGameStepDelay)
			for tile in scroller.cTiles:
				tile.symbol.UpdateSymbol(stepData["angles"], stepData["sprites"])
			Timeline.Delay(self, "OnPREPLAY", Data.gameData.nextGameStepDelay)

	if state == GameState.PREPLAY:
		Timeline.Delay(self, "GameOver", Data.gameData.gameStepDelay, "EmitGameOverTime")
		MoveCameraTo(cameraTransform.position + Vector3.FORWARD, Data.gameData.gameStepDelay)
		AnimateTilesStart()
		state = GameState.PLAY
		
	if state == GameState.CONTINUE:
		if Timeline.IsTimer(self, "GameOver"):
			Timeline.ResumeDelay(self, "GameOver")
			ResumeCameraMove()
			state = GameState.PLAY

	if state == GameState.PLAY:
		Events.emit_signal("ShowHudGameScreen")
		Events.emit_signal("ShowHudSymbolButtons", stepData)
		Events.emit_signal("ShowHudMenuButton")
		
	if state == GameState.PAUSE:
		Timeline.PauseDelay(self, "GameOver")
		PauseCameraMove()
		
	if state == GameState.CHECK:
		var reservedScore = (Data.gameData.gameStepDelay - Timeline.GetTimer(self, "GameOver").get_total_elapsed_time()) * Data.gameData.gameScoreMultiplier
		Timeline.StopDelay(self, "GameOver")
		Events.emit_signal("HideHudMenuButton")
			
		if Data.playerData.selectedAngles == stepData["angles"]:
			Data.playerData.sessionScoreLastStep = int(reservedScore)
			Data.playerData.sessionScore += Data.playerData.sessionScoreLastStep
			Events.emit_signal("HudWinScore")
			var cameraGPos = scroller.cIsland.get_node("CameraPosition").global_position
			var rnd = RandomNumberGenerator.new()
			for tile in scroller.cTiles:
				rnd.randomize()
				Timeline.Delay(tile, "PathAppear", tile.global_position.distance_to(cameraGPos - Vector3.FORWARD * 2) * rnd.randf_range(1.0, 1.2) * 0.1)
			state = GameState.NEXT
			GameLoop()
			return
		else:
			state = GameState.OVER

	if state == GameState.OVER:
		Events.emit_signal("ShowHudLostScreen")
		print("GAME OVER")

	if state == GameState.COMPLETE:
		print("LEVEL END")
		scroller.AddLastIsland()
		var starsNumber = Data.playerData.sessionScore / ((gameSteps.size() * (Data.gameData.gameStepDelay / 2) * Data.gameData.gameScoreMultiplier) / 3) #CONST FOR NOW
		Events.emit_signal("ShowHudWinScreen", clamp(floor(starsNumber), 1, 3))
		Events.emit_signal("HudWinScore", 2.5, true, 0.0)
		MoveCameraTo(scroller.cIsland.get_node("CameraPosition").global_position, Data.gameData.nextGameStepDelay)
		Timeline.Delay(self, "TryPlayEndIslandAnimation", Data.gameData.nextGameStepDelay + 0.25)
		return


