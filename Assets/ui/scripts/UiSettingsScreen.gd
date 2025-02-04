extends UiScreen

func ShowUiContent():
	var uiContents = get_tree().get_nodes_in_group("UiContent")
	for content in uiContents:
		if content.is_in_group("UiContent"):
			if content.is_in_group("Sound"):
				content.active = Data.playerData.sound
			if content.is_in_group("Music"):
				content.active = Data.playerData.music
			content.visible = true
		content.get_node("AnimationPlayer").play("UiButtonAlphaShow")
	get_node("Top/MenuLabel").text = tr("UI_SETTINGS_TOP_TEXT")
	
