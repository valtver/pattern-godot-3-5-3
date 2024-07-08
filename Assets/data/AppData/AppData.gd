extends Resource

export (Types.LocId) var locId

export (String, FILE, "*.tscn") var hecticPlayLogoScene
export (String, FILE, "*.tscn") var gameLogoScene
export (String, FILE, "*.tscn") var gameScene
export (String, FILE, "*.tscn") var uiScene

export (bool) var sound = true
export (bool) var music = true

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
