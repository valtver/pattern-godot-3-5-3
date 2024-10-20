extends Node

export (Types.HudElementId) var hudElementId

func _ready():
	self.visible = false

func AnimateFail():
	self.visible = true
	$AnimationPlayer.play("fail")	
	pass
	
func AnimateSuccess():
	self.visible = true
	$AnimationPlayer.play("success")	
	pass
