extends Resource

export (int) var index
export (Array, Resource) var patterns
export (String, FILE) var startIsland
export (Array, String, FILE) var islands
export (String, FILE) var endIsland
export (float, 0, 3) var bonusDelay
export (Array, Resource) var bonuses
export (bool) var unlock = false
export (int) var score
export (int) var stars
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
