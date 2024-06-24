extends Spatial

export (int) var activeLevel = 0
export (Array, PackedScene) var levels

var activeCameraTransform
var gameStarted : bool = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Init()
	LoadActiveLevel()
	StartGame()
	pass # Replace with function body.

func Init():
	activeCameraTransform = get_viewport().get_camera().get_parent()

func LoadActiveLevel():
	if levels[activeLevel] == null:
		print("Level ", activeLevel, " not found")
		return
	
	var levelIsLoaded = (get_node_or_null("Level%s" % activeLevel) != null)
	if levelIsLoaded:
		print("Level ", activeLevel, " is loaded already")
	else:	
		var level = levels[activeLevel].instance()
		add_child(level)
	
func StartGame():
	gameStarted = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !gameStarted:
		return
	activeCameraTransform.position -= Vector3(0, 0, delta/2)
#	pass
