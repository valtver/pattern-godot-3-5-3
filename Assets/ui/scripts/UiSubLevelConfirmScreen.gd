extends UiScreen

func UpdateUiSubLevelConfirmScreen():
	var lvlData = Data.gameData.levels[Data.playerData.selectedLevelIndex]
	get_node("Pivot/LevelImage").texture = Loader.GetResource(lvlData.uiTexture)
	get_node("Pivot/ConfirmLabel").text = "%s" % tr("UI_SUBLEVEL_CONFIRM_TEXT")
	get_node("Pivot/SubLevelLabel").text = "%s %d" % [tr("SUB_LVL_NAME"), (Data.playerData.selectedSubLevelIndex + 1)]
