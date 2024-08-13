extends Node

onready var fillTexture = $fill
onready var safeColor = Color(0.43, 0.73, 0.31)
onready var critColor = Color(0.69, 0.21, 0.36)
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	fillTexture.region_rect.size = Vector2(fillTexture.texture.get_width() ,fillTexture.texture.get_height())
	Events.connect("GameOverNormalTime", self, "UpdateFill")
	pass # Replace with function body.

func UpdateFill(normalValue):
	var newWidth = fillTexture.texture.get_width() * normalValue
	fillTexture.region_rect.size = Vector2(newWidth, fillTexture.texture.get_height())
	fillTexture.modulate = safeColor.linear_interpolate(critColor, 1 - normalValue)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
