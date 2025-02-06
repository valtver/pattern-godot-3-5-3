extends HudScreen

export (NodePath) var gameBarNodePath
export (NodePath) var failBarNodePath

onready var gameBar = get_node(gameBarNodePath)
onready var failBar = get_node(failBarNodePath)

var tween

func Init():
	gameBar.SetCounter(Data.playerData.sessionTimeScore)
	gameBar.SetLevelLabel(Data.playerData.selectedSubLevelIndex)
	var hudButtons = get_tree().get_nodes_in_group("HudButtonCustom")
	for button in hudButtons:
		if button.is_in_group("Symbol") or button.is_in_group("Menu"):
			button.visible = false
	var hudObjects = get_tree().get_nodes_in_group("HudObject")
	for object in hudObjects:
		if object.is_in_group("Task"):
			object.visible = false
	
func ShowMenuButton():
	var hudButtons = get_tree().get_nodes_in_group("HudButtonCustom")
	for button in hudButtons:
		if button.has_method("AnimateShow"):
			if button.is_in_group("Menu"):
				button.visible = true
				button.AnimateShow("alpha")
				
func HideMenuButton():
	var hudButtons = get_tree().get_nodes_in_group("HudButtonCustom")
	for button in hudButtons:
		if button.has_method("AnimateHide"):
			if button.is_in_group("Menu"):
				button.AnimateHide("alpha")

func ShowSymbolButtons(pattern):
	var hudButtons = get_tree().get_nodes_in_group("HudButtonCustom")
	var idx = -1
	for button in hudButtons:
		if button.is_in_group("Symbol"):
			idx +=1
			button.UpdateSymbol(pattern.buttons[idx].angles, pattern.sprites)
			button.AnimateShow()
			button.visible = true
			yield(get_tree().create_timer(0.1), "timeout")
			
func HideSymbolButtons():
	var hudButtons = get_tree().get_nodes_in_group("HudButtonCustom")
	for hudButton in hudButtons:
		if hudButton.is_in_group("Symbol"):
			hudButton.AnimateHide()
			yield(get_tree().create_timer(0.1), "timeout")
			
func ShowTaskResult(isWin):
	var hudObjects = get_tree().get_nodes_in_group("HudObject")
	for object in hudObjects:
		if object.is_in_group("Task"):
			object.visible = true
			if isWin:
				object.get_node("AnimationPlayer").play("Win")
			else:
				object.get_node("AnimationPlayer").play("Fail")
				failBar.SetFails(Data.playerData.sessionFails)
			
			yield(get_tree().create_timer(object.get_node("AnimationPlayer").current_animation_length), "timeout")
			object.visible = false
			
func StartTimerBar(timer):
	if tween != null:
		tween.kill()
	tween = create_tween()
	tween.tween_method(gameBar, "UpdateFill", timer.time_left/Data.taskTimerDelay, 0.0, timer.time_left)
	tween.play()

func RefillTimerBar():
	if tween != null:
		tween.kill()
	tween = create_tween()
	tween.tween_method(gameBar, "RestoreUpdateFill", 0.0, 1.0, Data.nextTaskDelay)
	
func AnimateBarScore(stepTimeScore):
	tween.kill()
	gameBar.TimeScoreAnimation(stepTimeScore)
	
func AnimateFailBarScore(stepTimeScore):
	tween.kill()
	if stepTimeScore <= 0:
		gameBar.TimeUp()
	else:
		gameBar.TimeEnd()
	
	
