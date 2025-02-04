extends UiScreen

func ShowUiContent():
	var scrollerPivot = get_node("Pivot/Pivot")
	var subLevelButtonReference = get_node("Pivot/Pivot/SubLevelButton")
	get_node("Top/MenuLabel").text = tr("LVL_%d_NAME" % (Data.playerData.selectedLevelIndex + 1))
	
	var lvlData = Data.levels[Data.playerData.selectedLevelIndex]
	var numberOfPages = ceil(float(lvlData.subLevels.size()) / 9)
	for subLvlData in lvlData.subLevels:
		var pageNum = (subLvlData.index / (SUB_LEVELS_X * SUB_LEVELS_Y))
		var pagePosition = Vector3(pageNum * SCROLLER_PAGE_WIDTH / 100.0, 0, 0)
		var gridPositionY = -(subLvlData.index / SUB_LEVELS_Y) * 1.1
		var gridPositionX = subLvlData.index % SUB_LEVELS_X
		var gridPosition = Vector3(gridPositionX, gridPositionY, 0) - Vector3(SUB_LEVELS_X/2, -SUB_LEVELS_Y/2, 0)
		
		var subLevelButton = subLevelButtonReference.duplicate()
		subLevelButton.index = subLvlData.index
		subLevelButton.name += String(subLvlData.index)
		subLevelButton.get_node("Pivot/SubLevelName").text = String(subLvlData.index+1)
		subLevelButton.get_node("Pivot/SubLevelNameShadow").text = String(subLvlData.index+1)
		scrollerPivot.add_child(subLevelButton)
		subLevelButton.position = gridPosition + pagePosition
		subLevelButton.active = subLvlData.unlock
		subLevelButton.SetStars(subLvlData.stars)
		subLevelButton.get_node("AnimationPlayer").play("UiButtonAlphaShow")
		subLevelButton.get_node("StarsAnimationPlayer").play("StarsShow")
	subLevelButtonReference.free()
	
