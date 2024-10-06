extends Node

# need to define the bonus type

func PlayBonus():
	self.visible = true
	var animationPlayer = get_node("AnimationPlayer")
	animationPlayer.play("start")
	animationPlayer.queue("loop")
	
