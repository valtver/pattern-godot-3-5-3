extends Spatial

const ASPECT_RATIO = 9.0/21.0
const MAX_ASPECT_RATIO = 4.0/3.0

onready var bottom = $Bottom
onready var top = $Top

func _ready():
	position = Vector3(0, 0, -1)
	resize()
	get_tree().get_root().connect("size_changed", self, "resize")

func resize():
	var ref_width = 450 / get_viewport().get_camera().size
	var ref_height = 1050
	var view_scale = 100/ref_width
	scale = Vector3.ONE * view_scale
	var aspectDiff = (OS.get_window_size().x / OS.get_window_size().y)/ASPECT_RATIO
	var top_height = ref_height/2/100
	var bottom_height = -ref_height/2/100
			
	if aspectDiff < 1:
		top_height /= 1
		bottom_height /= 1
	elif aspectDiff > MAX_ASPECT_RATIO:
		top_height /= MAX_ASPECT_RATIO
		bottom_height /= MAX_ASPECT_RATIO
	else:
		top_height /= aspectDiff
		bottom_height /= aspectDiff
	
	top.position = Vector3(0, top_height, 0)
	bottom.position = Vector3(0, bottom_height, 0)

