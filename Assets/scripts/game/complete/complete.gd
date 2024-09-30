extends Node


func PlayComplete():
	self.visible = true
	get_node("AnimationPlayer").play("complete")
