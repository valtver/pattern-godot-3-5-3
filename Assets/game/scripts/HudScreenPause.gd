extends HudScreen

export (NodePath) var animationPlayerNodePath

onready var animationPlayer = get_node(animationPlayerNodePath)

func Init():
	var hudButtons = get_tree().get_nodes_in_group("HudButton")
	for button in hudButtons:
		button.visible = false

func ShowSpecial():
	animationPlayer.play("show")
	yield(animationPlayer, "animation_finished")
	var hudButtons = get_tree().get_nodes_in_group("HudButton")
	for button in hudButtons:
		if button.is_in_group("Next"):
			var level = Data.levels[Data.playerData.selectedLevelIndex]
			var nextSubLevelIndex = Data.playerData.selectedSubLevelIndex + 1
			button.active = (nextSubLevelIndex in level.subLevels) and level.subLevels[nextSubLevelIndex].unlocked
		if button.has_method("AnimateShow"):
			button.visible = true
			button.AnimateShow("alpha")
	AppInput.EnableUi()
	
