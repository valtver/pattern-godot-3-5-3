extends Spatial

export (PackedScene) var hudScreenStartScene
export (PackedScene) var hudScreenGameScene
export (PackedScene) var hudScreenPauseScene
export (PackedScene) var hudScreenWinScene
export (PackedScene) var hudScreenLostScene
export (PackedScene) var hudScreenTutorialScene

var currentScreenSceneInstance
var previousScreenSceneName

func _ready():
	Events.connect("Click", self, "OnButtonClick")
	Events.connect("InactiveClick", self, "OnInactiveClick")
	Events.connect("GameStepStart", self, "OnGameStepStart")
	Events.connect("GameStepEnd", self, "OnGameStepEnd")
	Events.connect("GameTaskEnd", self, "OnGameTaskEnd")
	Events.connect("GameTaskStart", self, "OnGameTaskStart")
	Events.connect("GameLevelEnd", self, "OnGameLevelEnd")
	Events.connect("GameLevelStart", self, "OnGameLevelStart")

func ShowScreen(screenName):
	AppInput.DisableUi()
	var screenSceneInstance
	var removeScreen
	
	match screenName:
		"HudScreenStart":
			screenSceneInstance = hudScreenStartScene.instance()
		"HudScreenGame":
			screenSceneInstance = hudScreenGameScene.instance()
		"HudScreenLost":
			screenSceneInstance = hudScreenLostScene.instance()
			
	if currentScreenSceneInstance:
		removeScreen = currentScreenSceneInstance
		remove_child(removeScreen)
		removeScreen.queue_free()
		
	currentScreenSceneInstance = screenSceneInstance
	add_child(screenSceneInstance)
	screenSceneInstance.Init()
	screenSceneInstance.ShowButtons()
	screenSceneInstance.ShowSpecial()
	
func OnButtonClick(button):
	AppInput.DisableUi()
	
	if button.is_in_group("HudButton"):
		if button.is_in_group("Play"):
			ShowScreen("HudScreenGame")
			Events.emit_signal("HudButtonPlayClick")
		if button.is_in_group("Replay"):
			Events.emit_signal("HudButtonReplayClick")
	if button.is_in_group("HudButtonCustom"):
		if button.is_in_group("Symbol"):
			Events.emit_signal("HudButtonSymbolClick", button)
				
func OnGameStepStart(pattern):
	currentScreenSceneInstance.ShowSymbolButtons(pattern)
	currentScreenSceneInstance.ShowMenuButton()
	AppInput.EnableUi()
	
func OnGameStepEnd():
	pass
	
func OnGameTaskEnd(isWin, timeScore):
	AppInput.DisableUi()
	currentScreenSceneInstance.HideMenuButton()
	currentScreenSceneInstance.HideSymbolButtons()
	currentScreenSceneInstance.ShowTaskResult(isWin)
	if isWin:
		currentScreenSceneInstance.AnimateBarScore(timeScore)
	else:
		currentScreenSceneInstance.AnimateFailBarScore(timeScore)
	
func OnGameTaskStart():
	currentScreenSceneInstance.StartTimerBar()
	
func OnGameLevelEnd(isWin):
	AppInput.DisableUi()
	if !isWin:
		ShowScreen("HudScreenLost")
		
func OnGameLevelStart():
	ShowScreen("HudScreenStart")
	AppInput.EnableUi()
	
func OnInactiveButtonClick(button):
	pass
