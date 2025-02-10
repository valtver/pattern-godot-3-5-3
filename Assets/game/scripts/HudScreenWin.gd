extends HudScreen

export (NodePath) var animationPlayerNodePath
export (NodePath) var winLabelNodePath
export (NodePath) var scoreLabelNodePath

onready var animationPlayer = get_node(animationPlayerNodePath)
onready var winLabel = get_node(winLabelNodePath)
onready var scoreLabel = get_node(scoreLabelNodePath)

func Init():
	var hudButtons = get_tree().get_nodes_in_group("HudButton")
	for button in hudButtons:
		button.visible = false

func SetScoreLabel(value):
	scoreLabel.text = "%d" % value

func ShowSpecial():
	var maxScore = ((Data.taskTimerDelay - 1) * Data.playerData.sessionTasks)
	var stars = clamp(ceil((Data.playerData.sessionTimeScore / maxScore) * 3), 1, 3)
	var animationName = "show-%d" % stars
	winLabel.text = "%s %d %s" % [tr("SUB_LVL_NAME"), (Data.playerData.selectedSubLevelIndex + 1), tr("HUD_WIN_TEXT")]
	animationPlayer.play(animationName)
	var tween = create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_method(self, "SetScoreLabel", 0, int(Data.playerData.sessionTimeScore * Data.constScoreMultiplier), animationPlayer.current_animation_length)
	yield(animationPlayer, "animation_finished")
	
	var hudButtons = get_tree().get_nodes_in_group("HudButton")
	for button in hudButtons:
		if button.is_in_group("Next"):
			var level = Data.levels[Data.playerData.selectedLevelIndex]
			var nextSubLevelIndex = Data.playerData.selectedSubLevelIndex + 1
			button.active = (nextSubLevelIndex < level.subLevels.size()) && level.subLevels[nextSubLevelIndex].unlock
		if button.has_method("AnimateShow"):
			button.visible = true
			button.AnimateShow("alpha")
	animationPlayer.queue("%s-loop" % animationName)

	AppInput.EnableUi()
	
