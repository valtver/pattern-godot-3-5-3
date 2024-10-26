extends Node

export (Types.Bonus) var bonusType

onready var animationPlayer = $AnimationPlayer
onready var collider = $StaticBody/CollisionShape

func PlayBonus():
	self.visible = true
	collider.disabled = false
	animationPlayer.play("start")
	animationPlayer.queue("loop")
	
func OnClick():
	collider.disabled = true
	animationPlayer.stop()
	animationPlayer.play("collect")
	Events.emit_signal("GameBonusCollected", self)

	
