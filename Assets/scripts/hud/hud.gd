extends Spatial

var DISABLED_TYPES = [
	Types.HudElementId.HudButtonSymbol,
	Types.HudElementId.HudButtonHome,
	Types.HudElementId.HudButtonReplay,
	Types.HudElementId.HudButtonNext
]
var FADE_ANIMATION_TYPES = [Types.HudElementId.HudButtonMenu]

export (String, FILE) var startHudScreen
export (String, FILE) var gameHudScreen
export (String, FILE) var pauseHudScreen
export (String, FILE) var winHudScreen
export (String, FILE) var lostHudScreen

var lastHudScreen = null

var cHudScreen = null
var isPauseScreen = false

func _ready():
	Events.connect("Click", self, "OnButtonClick")
	Events.connect("ShowHudStartScreen", self, "OnShowHudStartScreen")
	Events.connect("ShowHudGameScreen", self, "OnShowHudGameScreen")
	Events.connect("ShowHudMenuScreen", self, "OnShowHudMenuScreen")
	Events.connect("ShowHudWinScreen", self, "OnShowHudWinScreen")
	Events.connect("ShowHudLostScreen", self, "OnShowHudLostScreen")
	
	Events.connect("ShowHudSymbolButtons", self, "OnShowSymbolButtons")
	Events.connect("HideHudSymbolButtons", self, "OnHideSymbolButtons")
	Events.connect("HideHudMenuButton", self, "OnHideMenuButton")
	Events.connect("ShowHudMenuButton", self, "OnShowMenuButton")
	pass
		
func GetScreenChildren(screenName):
	var children = []
	children.append_array(screenName.top.get_children())
	children.append_array(screenName.bottom.get_children())
	children.append_array(screenName.pivot.get_children())
	return children
	
func OnButtonClick(button):
	AppInput.DisableUi()
	if button.hudElementId == Types.HudElementId.HudButtonStart:
		Events.emit_signal("HudButtonPlayClick")
	if button.hudElementId == Types.HudElementId.HudButtonSymbol:
		Events.emit_signal("HudButtonSymbolClick", button)
	if button.hudElementId == Types.HudElementId.HudButtonMenu:
		if not isPauseScreen:
			ShowHudScreen(Loader.GetResource(pauseHudScreen).instance())
			Timeline.Delay(self, "ShowControlScreenButtons", 0.25)
			isPauseScreen = true
		else:
			ShowHudScreen(Loader.GetResource(lastHudScreen).instance())
			isPauseScreen = false
		Events.emit_signal("HudButtonMenuClick")
	if button.hudElementId == Types.HudElementId.HudButtonReplay:
		isPauseScreen = false
		Events.emit_signal("HudButtonReplayClick")
	if button.hudElementId == Types.HudElementId.HudButtonHome:
		Events.emit_signal("HudButtonHomeClick")
	if button.hudElementId == Types.HudElementId.HudButtonNext:
		Data.playerData.selectedSubLevelIndex += 1
		Events.emit_signal("HudButtonNextClick")
	
func OnShowHudStartScreen():
	lastHudScreen = startHudScreen
	var screen = Loader.GetResource(startHudScreen).instance()
	ShowHudScreen(screen)
	screen.get_node_or_null("Pivot/levelIcon").texture = Loader.GetResource(Data.gameData.levels[Data.playerData.selectedLevelIndex].uiTexture)
	screen.get_node_or_null("Pivot/levelLabel").text = "%s %d" % [tr("SUB_LVL_NAME"), (Data.playerData.selectedSubLevelIndex + 1)]
	screen.get_node_or_null("Pivot/hud-play-button/Pivot/TapLabel").text = tr("HUD_START_TEXT")

	
func OnShowHudGameScreen():
	if lastHudScreen != gameHudScreen:
		lastHudScreen = gameHudScreen
		ShowHudScreen(Loader.GetResource(gameHudScreen).instance())
		
func OnShowHudMenuScreen():
	ShowHudScreen(Loader.GetResource(pauseHudScreen).instance())
	
func OnShowHudWinScreen(stars):
	var screen = Loader.GetResource(winHudScreen).instance()
	ShowHudScreen(screen)
	var animationName = "show-%d" % stars
	var screenPlayer = screen.get_node_or_null("ScreenAnimationPlayer")
	screenPlayer.play(animationName)
	screen.get_node_or_null("Pivot/winLabel").text = "%s %d %s" % [tr("SUB_LVL_NAME"), (Data.playerData.selectedSubLevelIndex + 1), tr("HUD_WIN_TEXT")]
	Timeline.Delay(self, "ShowControlScreenButtons", screenPlayer.current_animation_length)
	pass
	
func OnShowHudLostScreen():
	var screen = Loader.GetResource(lostHudScreen).instance()
	ShowHudScreen(screen)
	var screenPlayer = screen.get_node_or_null("ScreenAnimationPlayer")
	screenPlayer.play("show")
	Timeline.Delay(self, "ShowControlScreenButtons", screenPlayer.current_animation_length)
	pass
	
func ShowControlScreenButtons():
	var currentChildren = GetScreenChildren(cHudScreen)
	for child in currentChildren:
		if "hudElementId" in child:
			if child.hudElementId == Types.HudElementId.HudButtonHome:
				child.AnimateShow("alpha")
			if child.hudElementId == Types.HudElementId.HudButtonReplay:
				child.AnimateShow("alpha")
			if child.hudElementId == Types.HudElementId.HudButtonNext:
				if (Data.playerData.selectedSubLevelIndex + 1) < Data.gameData.levels[Data.playerData.selectedLevelIndex].subLevels.size():
					child.AnimateShow("alpha")
					
func OnShowMenuButton():
	var currentChildren = GetScreenChildren(cHudScreen)
	for child in currentChildren:
		if "hudElementId" in child:
			if child.hudElementId == Types.HudElementId.HudButtonMenu:
				child.AnimateShow("alpha")
			
func OnHideMenuButton():
	var currentChildren = GetScreenChildren(cHudScreen)
	for child in currentChildren:
		if "hudElementId" in child:
			if child.hudElementId == Types.HudElementId.HudButtonMenu:
				child.AnimateHide("alpha")
	
func OnShowSymbolButtons(gameStepData):
	AppInput.EnableUi() #No delay for gameplay
	var currentChildren = GetScreenChildren(cHudScreen)
	for child in currentChildren:
		if "hudElementId" in child:
			if child.hudElementId == Types.HudElementId.HudButtonSymbol:
				child.UpdateSymbol(gameStepData["buttons"][child.index]["angles"], gameStepData["sprites"])
				child.AnimateShow()
	
func OnHideSymbolButtons(button: Node = null):
	var currentChildren = GetScreenChildren(cHudScreen)
	for child in currentChildren:
		if "hudElementId" in child:
			if child.hudElementId == Types.HudElementId.HudButtonSymbol:
				if button != null and button.index == child.index:
					Timeline.Delay(button, "AnimateHide", 0.5)
				else:
					child.AnimateHide()
				
func ShowHudScreen(nextHudScreen):
	Timeline.Delay(AppInput, "EnableUi", 0.25) #Longer delay for menu
	if nextHudScreen == null:
		print("No transition screen defined.")
		return
		
	add_child(nextHudScreen)
	
	var nextChildren = GetScreenChildren(nextHudScreen)
	
	if cHudScreen == null:
		for nextChild in nextChildren:
			if nextChild.has_method("AnimateShow"):
				if nextChild.hudElementId in FADE_ANIMATION_TYPES:
					nextChild.AnimateShow("alpha")
				else:
					nextChild.AnimateShow()
		cHudScreen = nextHudScreen
	else:
		var currentChildren = GetScreenChildren(cHudScreen)
	
		for nextChild in nextChildren:
			if "hudElementId" in nextChild:
				if nextChild.hudElementId in DISABLED_TYPES:
					nextChild.visible = false
				else:
					var animate = true
					for currentChild in currentChildren:
						if "hudElementId" in currentChild:
							if currentChild.hudElementId == nextChild.hudElementId:
								animate = false
								break
					if animate:
						if nextChild.has_method("AnimateShow"):
							if nextChild.hudElementId in FADE_ANIMATION_TYPES:
								nextChild.AnimateShow("alpha")
							else:
								nextChild.AnimateShow()
				
		var removeScreen = cHudScreen
		cHudScreen = nextHudScreen
		var animationPlayer = cHudScreen.get_node_or_null("AnimationPlayer")
		if animationPlayer != null:
			animationPlayer.play("show")
		removeScreen.queue_free()

