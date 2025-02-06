extends HudScreen

func ShowButtons():
	var hudButtons = get_tree().get_nodes_in_group("HudButton")
	for button in hudButtons:
		if button.has_method("AnimateShow"):
			button.visible = true
			button.AnimateShow()

func ShowSpecial():
	var hudButtons = get_tree().get_nodes_in_group("HudButtonCustom")
	for button in hudButtons:
		if button.has_method("AnimateShow"):
			if button.is_in_group("Menu"):
				button.AnimateShow("alpha")

	get_node_or_null("Pivot/levelIcon").texture = Loader.GetResource(Data.levels[Data.playerData.selectedLevelIndex].uiTexture)
	get_node_or_null("Pivot/levelLabel").text = "%s %d" % [tr("SUB_LVL_NAME"), (Data.playerData.selectedSubLevelIndex + 1)]
	get_node_or_null("Pivot/HudButtonPlay/Pivot/TapLabel").text = tr("HUD_START_TEXT")
	
	AppInput.EnableUi()

