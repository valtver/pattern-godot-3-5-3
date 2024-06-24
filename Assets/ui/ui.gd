extends Spatial

export (PackedScene) var content


const ASPECT_RATIO = 9.0/21.0
const MAX_ASPECT_RATIO = 4.0/3.0

onready var uiBottom = $Bottom
onready var uiTop = $Top
onready var uiMenuTitle = $Top/MenuLabel
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
	for screenConfig in Data.uiData.screens:
		if screenConfig.uiContentId == uiContentId:
			var locId = Types.LocId.keys()[Data.appData.locId]
			uiMenuTitle.text = screenConfig.uiLocLabel[locId]
			var cont = content.instance()
			add_child(cont)
			cont.Init(screenConfig)
			cont.Show()
			break

func InitButtons(uiContentId):
	RemoveDynamicButtons()
	for screenConfig in Data.uiData.screens:
		if screenConfig.uiContentId == uiContentId:					
			for btnConfig in screenConfig.buttons:
				var button = btnConfig.button.instance()
				if btnConfig.buttonUiAnchor == Types.UiAnchor.Top:
					uiTop.add_child(button)
				if btnConfig.buttonUiAnchor == Types.UiAnchor.Bottom:
					uiBottom.add_child(button)
				button.position = btnConfig.buttonPos
				button.scale = btnConfig.buttonScale
				button.Show()
	ConnectUiButtons()
	
func ConnectUiButtons():
	for button in get_tree().get_nodes_in_group("uiButtons"):
		if !button.is_connected("Click", self, "OnButtonClick"):
			button.connect("Click", self, "OnButtonClick")
			
func RemoveContent():
	var contentNode = get_node_or_null("Content")
	if contentNode != null:
		contentNode.free()
		
func RemoveDynamicButtons():
	for child in get_tree().get_nodes_in_group("dynamicUiButtons"):
		child.queue_free()
						
func OnButtonClick(buttonId):
	if buttonId == Types.UiButtonId.Settings:
		InitScreen(Types.UiContentId.Settings)
		InitButtons(Types.UiContentId.Settings)
		return
	if buttonId == Types.UiButtonId.Back:
		InitScreen(Types.UiContentId.Main)
		InitButtons(Types.UiContentId.Main)
		return
	if buttonId == Types.UiButtonId.Sound:
		Data.appData.sound = !Data.appData.sound
		get_tree().get_first_node_in_group("uiSoundButton").active = Data.appData.sound
		return
	if buttonId == Types.UiButtonId.Music:
		Data.appData.music = !Data.appData.music
		get_tree().get_first_node_in_group("uiMusicButton").active = Data.appData.music
		return


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
	
	uiTop.position = Vector3(0, top_height, 0)
	uiBottom.position = Vector3(0, bottom_height, 0)
# Called every frame. 'delta' is the elapsed time since the previous frame.
