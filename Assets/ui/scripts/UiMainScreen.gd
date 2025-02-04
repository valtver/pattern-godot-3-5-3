extends UiScreen

func ShowUiContent():
	var scrollerPivot = get_node("Pivot/Pivot")
	var levelButtonReference = get_node("Pivot/Pivot/LevelButton")

	for lvlData in Data.levels:
		var levelButton = levelButtonReference.duplicate()
		scrollerPivot.add_child(levelButton)
		levelButton.index = lvlData.index
		levelButton.name += String(levelButton.index) 
		levelButton.active = Data.gameData.levels[lvlData.index].unlock
		levelButton.get_node("Pivot/Sprite").texture = Loader.GetResource(lvlData.uiTexture)
		levelButton.position = Vector3((SCROLLER_PAGE_WIDTH / 100.0) * (scrollerPivot.get_child_count()-2), 0, 0)
	levelButtonReference.free()
	
	var uiContents = get_tree().get_nodes_in_group("UiContent")
	for content in uiContents:
		if content.is_in_group("UiButton"):
			content.active = true
			content.visible = true
		content.get_node("AnimationPlayer").play("UiButtonAlphaShow")
		
	get_node("Top/MenuLabel").text = tr("UI_MAIN_TOP_TEXT")
	
