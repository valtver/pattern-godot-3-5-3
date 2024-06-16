extends Spatial

export (PackedScene) var content
export (Array, Resource) var uiScreens

var aspectRatio = 9.0/21.0

onready var bottom = $Bottom
onready var top = $Top
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	resize()
	get_tree().get_root().connect("size_changed", self, "resize")
	InitScreen(Types.UiContentId.Main)
	InitButtons(Types.UiContentId.Main)
	pass # Replace with function body.

func InitScreen(uiContentId):
	RemoveContent()
	for screenConfig in uiScreens:
		if screenConfig.uiContentId == uiContentId:
			var cont = content.instance()
			add_child(cont)
			cont.Init(uiContentId)
			cont.Show()
			break

func InitButtons(uiContentId):
	RemoveButtons()
	for screenConfig in uiScreens:
		if screenConfig.uiContentId == uiContentId:
			for btnConfig in screenConfig.buttons:
				var button = btnConfig.button.instance()
				if btnConfig.buttonUiAnchor == Types.UiAnchor.Top:
					top.add_child(button)
				if btnConfig.buttonUiAnchor == Types.UiAnchor.Bottom:
					bottom.add_child(button)
				button.position = btnConfig.buttonPos
				button.scale = btnConfig.buttonScale
				button.connect("Click", self, "OnButtonClick")
				button.Show()
			
func RemoveContent():
	var contentNode = get_node_or_null("Content")
	if contentNode != null:
		contentNode.free()
			
func RemoveButtons():
	for key in Types.UiAnchor.keys():
		var node = get_node_or_null(key)
		if node != null:
			for child in node.get_children():
				if child.has_signal("Click"):
					print(child.name)
					child.queue_free()
			
func OnButtonClick(buttonId):
	if buttonId == Types.UiButtonId.Settings:
		InitScreen(Types.UiContentId.Settings)
		InitButtons(Types.UiContentId.Settings)
	elif buttonId == Types.UiButtonId.Back:
		InitScreen(Types.UiContentId.Main)
		InitButtons(Types.UiContentId.Main)

func resize():
	var ref_width = 450 / get_viewport().get_camera().size
	var ref_height = 1050
	var view_scale = 100/ref_width
	
	scale = Vector3.ONE * view_scale
	
	var aspectDiff = (OS.get_window_size().x / OS.get_window_size().y)/aspectRatio
	
	var top_height = ref_height/2/100
	var bottom_height = -ref_height/2/100
			
	if aspectDiff < 1:
		top_height /= 1
		bottom_height /= 1
	elif aspectDiff > 1.5:
		top_height /= 1.5
		bottom_height /= 1.5
	else:
		top_height /= aspectDiff
		bottom_height /= aspectDiff
	
	$Top.position = Vector3(0, top_height, 0)
#	print((OS.get_window_size().x / OS.get_window_size().y)/aspectRatio, " ", aspectRatio)
#	print($Top.position)
	$Bottom.position = Vector3(0, bottom_height, 0)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
