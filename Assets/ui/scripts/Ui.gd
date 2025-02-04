extends Spatial

export (PackedScene) var uiMainScreenScene
export (PackedScene) var uiSettingsScreenScene
export (PackedScene) var uiSubLevelScreenScene
export (PackedScene) var uiSubLevelConfirmScreenScene

var currentScreenSceneInstance
var previousScreenSceneName

func _ready():
	Events.connect("Click", self, "OnActiveButtonClick")
	Events.connect("InactiveClick", self, "OnInactiveButtonClick")
	
func OnActiveButtonClick(button):
	if button.is_in_group("UiButton"):
		if button.is_in_group("Settings"):
			ShowScreen("UiSettingsScreen")
		if button.is_in_group("Back"):
			ShowScreen(previousScreenSceneName);
		if button.is_in_group("Decline"):
			ShowScreen(previousScreenSceneName);
		if button.is_in_group("Accept"):
			Events.emit_signal(
				"AppStart",
				Data.gameSceneResources,
				Data.levels[Data.playerData.selectedLevelIndex].subLevels[Data.playerData.selectedSubLevelIndex].scene)
			pass
	if button.is_in_group("UiContent"):
		if button.is_in_group("Sound"):
			Data.playerData.sound = !button.active
			button.active = Data.playerData.sound
		if button.is_in_group("Music"):
			Data.playerData.music = !button.active
			button.active = Data.playerData.music
		if button.is_in_group("Level"):
			Data.playerData.selectedLevelIndex = button.index;
			ShowScreen("UiSubLevelScreen")
		if button.is_in_group("SubLevel"):
			Data.playerData.selectedSubLevelIndex = button.index;
			ShowScreen("UiSubLevelConfirmScreen")
			currentScreenSceneInstance.UpdateUiSubLevelConfirmScreen()
		if button.is_in_group("UiScreenButtonLeft"):
			currentScreenSceneInstance.ShowPreviousPage()
		if button.is_in_group("UiScreenButtonRight"):
			currentScreenSceneInstance.ShowNextPage()
				
func OnInactiveButtonClick(button):
	if button.is_in_group("UiContent"):
		if button.is_in_group("Sound"):
			Data.playerData.sound = !button.active
			button.active = Data.playerData.sound
		if button.is_in_group("Music"):
			Data.playerData.music = !button.active
			button.active = Data.playerData.music

func ShowScreen(screenName):
	AppInput.DisableUi()
	var screenSceneInstance
	var removeScreen
	
	match screenName:
		"UiMainScreen":
			screenSceneInstance = uiMainScreenScene.instance()
			screenSceneInstance.UpdateUiScreenScrollerIndex(Data.playerData.selectedLevelIndex)
		"UiSettingsScreen":
			screenSceneInstance = uiSettingsScreenScene.instance()
			previousScreenSceneName = currentScreenSceneInstance.name
		"UiSubLevelScreen":
			screenSceneInstance = uiSubLevelScreenScene.instance()
			screenSceneInstance.UpdateUiScreenScrollerIndex(ceil(float(Data.playerData.selectedSubLevelIndex/9)))
			previousScreenSceneName = "UiMainScreen"
		"UiSubLevelConfirmScreen":
			screenSceneInstance = uiSubLevelConfirmScreenScene.instance()
			previousScreenSceneName = currentScreenSceneInstance.name
			
	if currentScreenSceneInstance:
		removeScreen = currentScreenSceneInstance
		remove_child(removeScreen)
		removeScreen.queue_free()
		
	currentScreenSceneInstance = screenSceneInstance
	add_child(screenSceneInstance)
	ShowUiButtons()
	screenSceneInstance.ShowUiContent()
	AppInput.EnableUi()

func ShowUiButtons():
	var uiButtons = get_tree().get_nodes_in_group("UiButton")
	for button in uiButtons:
		button.visible = false
	for button in uiButtons:
			button.visible = true
			button.active = true
			button.get_node("AnimationPlayer").play("UiButtonShow")
			yield(get_tree().create_timer(0.1), "timeout")


