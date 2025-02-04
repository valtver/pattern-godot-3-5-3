extends HudScreen

func Init():
	var hudButtons = get_tree().get_nodes_in_group("HudButton")
	for button in hudButtons:
		button.visible = false

func ShowButtons():
	pass
			
func ShowSpecial():
	var animationPlayer = get_node("AnimationPlayer")
	animationPlayer.play("show")
	yield(animationPlayer, "animation_finished")
	var hudButtons = get_tree().get_nodes_in_group("HudButton")
	for button in hudButtons:
		if button.has_method("AnimateShow"):
			button.visible = true
			button.AnimateShow("alpha")
	AppInput.EnableUi()

