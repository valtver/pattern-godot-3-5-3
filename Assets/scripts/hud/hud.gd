extends Spatial

var DISABLED_TYPES = [Types.HudElementId.HudButtonSymbol]
var FADE_ANIMATION_TYPES = [Types.HudElementId.HudButtonMenu]

export (String, FILE) var startHudScreen
export (String, FILE) var gameHudScreen

var cHudScreen = null

func _ready():
	Events.connect("Click", self, "OnButtonClick")
	Events.connect("ShowHudStartScreen", self, "OnShowHudStartScreen")
	Events.connect("ShowHudGameScreen", self, "OnShowHudGameScreen")
	Events.connect("ShowHudSymbolButtons", self, "OnShowSymbolButtons")
	Events.connect("HideHudSymbolButtons", self, "OnHideSymbolButtons")
	Events.connect("HideHudMenuButton", self, "OnHideMenuButton")
	Events.connect("ShowHudMenuButton", self, "OnShowMenuButton")
	pass
	
func GetScreenChildren(screenName):
	var children = []
	children.append_array(screenName.top.get_children())
	children.append_array(screenName.bottom.get_children())
	return children
	
func OnButtonClick(button):
	if button.hudElementId == Types.HudElementId.HudButtonStart:
		Events.emit_signal("HudButtonPlayClick")
	if button.hudElementId == Types.HudElementId.HudButtonSymbol:
		Events.emit_signal("HudButtonSymbolClick", button)
	
func OnShowHudStartScreen():
	ShowHudScreen(Loader.GetResource(startHudScreen).instance())
func OnShowHudGameScreen():
	ShowHudScreen(Loader.GetResource(gameHudScreen).instance())
	
func OnShowMenuButton():
	var currentChildren = GetScreenChildren(cHudScreen)
	for child in currentChildren:
		if child.hudElementId == Types.HudElementId.HudButtonMenu:
			child.AnimateShow("alpha")
			
func OnHideMenuButton():
	var currentChildren = GetScreenChildren(cHudScreen)
	for child in currentChildren:
		if child.hudElementId == Types.HudElementId.HudButtonMenu:
			child.AnimateHide("alpha")
	
func OnShowSymbolButtons(gameStepData):
	var currentChildren = GetScreenChildren(cHudScreen)
	for child in currentChildren:
		if child.hudElementId == Types.HudElementId.HudButtonSymbol:
			child.UpdateSymbol(gameStepData["buttons"][child.index]["angles"], gameStepData["sprites"])
			child.AnimateShow()
			
func OnHideSymbolButtons(button: Node = null):
	var currentChildren = GetScreenChildren(cHudScreen)
	for child in currentChildren:
		if child.hudElementId == Types.HudElementId.HudButtonSymbol:
			if button != null and button.index == child.index:
				Timeline.Delay(button, "AnimateHide", 0.5)
			else:
				child.AnimateHide()
				
func ShowHudScreen(nextHudScreen):
	if nextHudScreen == null:
		print("No transition screen defined.")
		return
	
	add_child(nextHudScreen)
	
	var nextChildren = GetScreenChildren(nextHudScreen)
	
	if cHudScreen == null:
		for nextChild in nextChildren:
			if nextChild.has_method("AnimateShow"):
				if nextChild.hudElementId in FADE_ANIMATION_TYPES:
					print("Animating...")
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
						if currentChild.hudElementId == nextChild.hudElementId:
							animate = false
							break
					if animate:
						if nextChild.hudElementId in FADE_ANIMATION_TYPES:
							print("Animating...")
							nextChild.AnimateShow("alpha")
						else:
							nextChild.AnimateShow()
				
		var removeScreen = cHudScreen
		cHudScreen = nextHudScreen
		removeScreen.queue_free()
