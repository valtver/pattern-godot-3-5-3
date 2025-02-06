extends Spatial

export (PackedScene) var hudScreenStartScene
export (PackedScene) var hudScreenGameScene
export (PackedScene) var hudScreenPauseScene
export (PackedScene) var hudScreenWinScene
export (PackedScene) var hudScreenLostScene
export (PackedScene) var hudScreenTutorialScene

var currentScreenSceneInstance = null
var previousScreenSceneName = null

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
	AppInput.DisableScene()
	var screenSceneInstance
	var removeScreen
	
	match screenName:
		"HudScreenStart":
			screenSceneInstance = hudScreenStartScene.instance()
		"HudScreenGame":
			screenSceneInstance = hudScreenGameScene.instance()
		"HudScreenLost":
			screenSceneInstance = hudScreenLostScene.instance()
		"HudScreenWin":
			screenSceneInstance = hudScreenWinScene.instance()
		"HudScreenPause":
			screenSceneInstance = hudScreenPauseScene.instance()
			
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
	AppInput.DisableScene()
	if button.is_in_group("HudButton"):
		if button.is_in_group("Play"):
			ShowScreen("HudScreenGame")
			Events.emit_signal("HudButtonPlayClick")
		if button.is_in_group("Replay"):
			previousScreenSceneName = null
			Events.emit_signal("HudButtonReplayClick")
		if button.is_in_group("Tutorial"):
			pass
		if button.is_in_group("Home"):
			Events.emit_signal("HudButtonHomeClick")
			pass
	if button.is_in_group("HudButtonCustom"):
		if button.is_in_group("Symbol"):
			Events.emit_signal("HudButtonSymbolClick", button)
		if button.is_in_group("Menu"):
			if previousScreenSceneName == null:
				print(currentScreenSceneInstance.name)
				previousScreenSceneName = currentScreenSceneInstance.name
				Events.emit_signal("HudButtonMenuClick")
				ShowScreen("HudScreenPause")
			else:
				ShowScreen(previousScreenSceneName)
				previousScreenSceneName = null
				Events.emit_signal("HudButtonMenuUnClick")
				
func OnInactiveClick(button):
	pass
				
func OnGameStepStart(pattern):
	currentScreenSceneInstance.ShowSymbolButtons(pattern)
	currentScreenSceneInstance.ShowMenuButton()
	AppInput.EnableUi()
	AppInput.EnableScene()
	
func OnGameStepEnd():
	pass
	
func OnGameTaskEnd(isWin, timeScore):
	AppInput.DisableScene()
	AppInput.DisableUi()
	currentScreenSceneInstance.HideMenuButton()
	currentScreenSceneInstance.HideSymbolButtons()
	currentScreenSceneInstance.ShowTaskResult(isWin)
	if isWin:
		currentScreenSceneInstance.AnimateBarScore(timeScore)
	else:
		currentScreenSceneInstance.AnimateFailBarScore(timeScore)
	
func OnGameTaskStart(timer):
	currentScreenSceneInstance.StartTimerBar(timer)
	
func OnGameLevelEnd(isWin):
	AppInput.DisableUi()
	AppInput.DisableScene()
	if isWin:
		ShowScreen("HudScreenWin")
	else:
		ShowScreen("HudScreenLost")
		
func OnGameLevelStart():
	ShowScreen("HudScreenStart")
	AppInput.EnableUi()
	
func OnInactiveButtonClick(button):
	pass
