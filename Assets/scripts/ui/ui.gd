extends Spatial

var MANUAL_VIS_CONTROL_TYPES = [
	Types.UiElementId.UiButtonScrollerLeft,
	Types.UiElementId.UiButtonScrollerRight,
	Types.UiElementId.UiButtonSound,
	Types.UiElementId.UiButtonMusic,
	Types.UiElementId.UiButtonLevel,
	Types.UiElementId.UiButtonSubLevel
]

const SCROLLER_PAGE_WIDTH = 450
const SUB_LEVELS_X = 3
const SUB_LEVELS_Y = 3

export (String, FILE) var mainUiScreenPath
export (String, FILE) var settingsUiScreenPath
export (String, FILE) var aboutUiScreenPath
export (String, FILE) var subLevelUiScreenPath
export (String, FILE) var subLevelConfirmUiScreenPath

var lastUiScreenPath = null
var currentUiScreen = null
var scrollerTween = null

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("Click", self, "OnButtonClick")
	Events.connect("InactiveClick", self, "OnInactiveButtonClick")
	Events.connect("ShowUiMainScreen", self, "OnShowUiMainScreen")
	
	pass # Replace with function body.

func GetScreenChildren(screenName):
	var children = []
	children.append_array(screenName.top.get_children())
	children.append_array(screenName.bottom.get_children())
	children.append_array(screenName.pivot.get_children())
	return children
		
func OnShowUiScreenBack():
	match lastUiScreenPath:
		mainUiScreenPath:
			OnShowUiMainScreen()
		subLevelUiScreenPath:
			OnShowUiSubLevelScreen()
			
func OnShowUiMainScreen():
	lastUiScreenPath = mainUiScreenPath
	var screen = Loader.GetResource(mainUiScreenPath).instance()
	ShowUiScreen(screen)
	screen.get_node("Top/MenuLabel").text = tr("UI_MAIN_TOP_TEXT")
	ShowUiLevelButtons(screen)
	UpdateUiScreenScrollerIndex(screen, 0)

func OnShowUiSettingsScreen():
	var screen = Loader.GetResource(settingsUiScreenPath).instance()
	ShowUiScreen(screen)
	ShowUiSettingsButtons(screen)

func OnShowUiSubLevelScreen():
	lastUiScreenPath = mainUiScreenPath
	var screen = Loader.GetResource(subLevelUiScreenPath).instance()
	ShowUiScreen(screen)
	ShowUiSubLevelButtons(screen)
	
func OnShowUiSubLevelConfirmScreen():
	lastUiScreenPath = subLevelUiScreenPath
	var screen = Loader.GetResource(subLevelConfirmUiScreenPath).instance()
	ShowUiScreen(screen)
	UpdateUiSubLevelConfirmScreen(screen)
	
func UpdateUiSubLevelConfirmScreen(screenInstance):
	var lvlData = Data.gameData.levels[Data.playerData.selectedLevelIndex]
	screenInstance.get_node("Pivot/LevelImage").texture = Loader.GetResource(lvlData.uiTexture)
	screenInstance.get_node("Pivot/ConfirmLabel").text = "%s" % tr("UI_SUBLEVEL_CONFIRM_TEXT")
	screenInstance.get_node("Pivot/SubLevelLabel").text = "%s %d" % [tr("SUB_LVL_NAME"), (Data.playerData.selectedSubLevelIndex + 1)]
	pass

func UpdateUiScreenScrollerIndex(screenInstance, index):
	var scrollerPivot = screenInstance.get_node("Pivot/Pivot")
	var scrollerButtonLeft = screenInstance.get_node("Pivot/ScrollerButtonLeft")
	var scrollerButtonRight = screenInstance.get_node("Pivot/ScrollerButtonRight")
	var levelName = screenInstance.get_node_or_null("Pivot/LevelName")
	var levelStats = screenInstance.get_node_or_null("Pivot/LevelStats")
	
	if index == 0:
		scrollerButtonLeft.visible = false
	if index >= (scrollerPivot.get_child_count()-1):
		scrollerButtonRight.visible = false
	if index > 0 and index < (scrollerPivot.get_child_count()-1):
		scrollerButtonLeft.visible = true
		scrollerButtonRight.visible = true

	if index >= scrollerPivot.get_child_count():
		return
	var nextPosition = Vector3(index * (SCROLLER_PAGE_WIDTH / 100.0), 0, 0)
	if scrollerPivot.position == nextPosition:
		return

	if scrollerTween != null:
		scrollerTween.kill()
	scrollerTween = create_tween()
	scrollerTween.set_trans(Tween.TRANS_CUBIC)
	scrollerTween.set_ease(Tween.EASE_OUT)
	scrollerTween.parallel().tween_property(scrollerPivot, "position", nextPosition, 0.5)
	if levelName != null:
		levelName.text.modulate.a = 0
		scrollerTween.parallel().tween_property(levelName.text.modulate, "a", 1, 0.5)
	if levelStats != null:
		levelStats.text.modulate.a = 0
		scrollerTween.parallel().tween_property(levelStats.text.modulate, "a", 1, 0.5)
	scrollerTween.play()

func ShowUiSettingsButtons(screenInstance):
	var soundButton = screenInstance.get_node("Pivot/SoundButton")
	var musicButton = screenInstance.get_node("Pivot/MusicButton")
	screenInstance.get_node("Top/MenuLabel").text = tr("UI_SETTINGS_TOP_TEXT")
	soundButton.active = Data.appData.sound
	soundButton.AnimateShow("alpha")
	musicButton.active = Data.appData.music
	musicButton.AnimateShow("alpha")
	
func ShowUiSubLevelButtons(screenInstance):
	var scrollerPivot = screenInstance.get_node("Pivot/Pivot")
	var subLevelButtonReference = screenInstance.get_node("Pivot/Pivot/SubLevelButton")
	
	var lvlData = Data.gameData.levels[Data.playerData.selectedLevelIndex]
	var numberOfPages = ceil(float(lvlData.subLevels.size()) / 9)
	for subLvlData in lvlData.subLevels:
		var pageNum = (subLvlData.index / (SUB_LEVELS_X * SUB_LEVELS_Y))
		var pagePosition = Vector3(pageNum * SCROLLER_PAGE_WIDTH / 100.0, 0, 0)
		var gridPositionY = ((subLvlData.index - (pageNum * 9)) / SUB_LEVELS_Y)
		var gridPositionX = ((subLvlData.index - (pageNum * 9)) % (SUB_LEVELS_X-1))
		var gridPosition = Vector3(gridPositionX, gridPositionY, 0) - Vector3(SUB_LEVELS_X/2, -SUB_LEVELS_Y/2, 0)
		
		var subLevelButton = subLevelButtonReference.duplicate()
		subLevelButton.index = subLvlData.index
		subLevelButton.name += String(subLvlData.index)
		subLevelButton.get_node("Pivot/SubLevelName").text = String(subLvlData.index+1)
		subLevelButton.get_node("Pivot/SubLevelNameShadow").text = String(subLvlData.index+1)
		scrollerPivot.add_child(subLevelButton)
		subLevelButton.position = gridPosition + pagePosition
		subLevelButton.active = subLvlData.unlock
		subLevelButton.AnimateShow("alpha")
	subLevelButtonReference.free()

func ShowUiLevelButtons(screenInstance):
	var scrollerPivot = screenInstance.get_node("Pivot/Pivot")
	var levelButtonReference = screenInstance.get_node("Pivot/Pivot/LevelButton")

	for lvlData in Data.gameData.levels:
		var levelButton = levelButtonReference.duplicate()
		scrollerPivot.add_child(levelButton)
		levelButton.index = lvlData.index
		levelButton.name += String(levelButton.index) 
		levelButton.active = Data.gameData.levels[lvlData.index].unlock
		levelButton.get_node("Pivot/Sprite").texture = Loader.GetResource(lvlData.uiTexture)
		levelButton.position = Vector3((SCROLLER_PAGE_WIDTH / 100.0) * (scrollerPivot.get_child_count()-2), 0, 0)
		levelButton.AnimateShow("alpha")
	levelButtonReference.free()

func OnButtonClick(button):
	match button.uiElementId:
		Types.UiElementId.UiButtonBack:
			OnShowUiScreenBack()
		Types.UiElementId.UiButtonDecline:
			OnShowUiScreenBack()
		Types.UiElementId.UiButtonAccept:
			Events.emit_signal("StartGame")
		Types.UiElementId.UiButtonSettings:
			OnShowUiSettingsScreen()
		Types.UiElementId.UiButtonLevel:
			Data.playerData.selectedLevelIndex = button.index
			OnShowUiSubLevelScreen()
		Types.UiElementId.UiButtonSubLevel:
			Data.playerData.selectedSubLevelIndex = button.index
			OnShowUiSubLevelConfirmScreen()
		Types.UiElementId.UiButtonSound:
			Data.appData.sound = !button.active
			button.active = Data.appData.sound
		Types.UiElementId.UiButtonMusic:
			Data.appData.music = !button.active
			button.active = Data.appData.music
		Types.UiElementId.UiButtonScrollerLeft:
			var scrollerPivot = currentUiScreen.get_node("Pivot/Pivot")
			var scrollerIndex = (scrollerPivot.position.x / (SCROLLER_PAGE_WIDTH / 100.0)) - 1
			if scrollerIndex > 0:
				scrollerIndex -= 1
				UpdateUiScreenScrollerIndex(currentUiScreen, scrollerIndex)
		Types.UiElementId.UiButtonScrollerRight:
			var scrollerPivot = currentUiScreen.get_node("Pivot/Pivot")
			var scrollerIndex = (scrollerPivot.position.x / (SCROLLER_PAGE_WIDTH / 100.0)) - 1
			if scrollerIndex > 0:
				scrollerIndex += 1
				UpdateUiScreenScrollerIndex(currentUiScreen, scrollerIndex)

func OnInactiveButtonClick(button):
	match button.uiElementId:
		Types.UiElementId.UiButtonSound:
			Data.appData.sound = !button.active
			button.active = Data.appData.sound
		Types.UiElementId.UiButtonMusic:
			Data.appData.music = !button.active
			button.active = Data.appData.music

func ShowUiScreen(nextScreenInstance):
	add_child(nextScreenInstance)
	var nextScreenChildren = GetScreenChildren(nextScreenInstance)

	if currentUiScreen == null:
		for nextChild in nextScreenChildren:
			if nextChild.has_method("AnimateShow"):
				nextChild.AnimateShow()
			if "active" in nextChild:
				nextChild.active = true
		currentUiScreen = nextScreenInstance
	else:
		var currentScreenChildren = GetScreenChildren(currentUiScreen)
	
		for nextChild in nextScreenChildren:
			if "uiElementId" in nextChild:
				if nextChild.uiElementId in MANUAL_VIS_CONTROL_TYPES:
					nextChild.visible = false
				else:
					var animate = true
					for currentChild in currentScreenChildren:
						if "uiElementId" in currentChild:
							if currentChild.uiElementId == nextChild.uiElementId:
								animate = false
								break
					if animate:
						if nextChild.has_method("AnimateShow"):
							nextChild.AnimateShow()
							
				if "active" in nextChild:
					nextChild.active = true
				
		var removeScreen = currentUiScreen
		currentUiScreen = nextScreenInstance
		var animationPlayer = currentUiScreen.get_node_or_null("AnimationPlayer")
		if animationPlayer != null:
			animationPlayer.play("show")
		removeScreen.queue_free()
		


