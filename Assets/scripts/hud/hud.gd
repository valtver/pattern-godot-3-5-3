extends Spatial

const ASPECT_RATIO = 9.0/21.0
const MAX_ASPECT_RATIO = 4.0/3.0

enum GameState {
	BUSY = 0,
	WAITING_INPUT = 1
}

var gameState = GameState.BUSY
var currentScreen = null

onready var bottom = $Bottom
onready var top = $Top

func _ready():
	resize()
	get_tree().get_root().connect("size_changed", self, "resize")
	Events.connect("Click", self, "OnButtonClick")
	Events.connect("ShowHudStartScreen", self, "OnShowHudStartScreen")
	Events.connect("ShowHudPlayScreen", self, "OnShowHudPlayScreen")
	Events.connect("ShowHudSymbolButtons", self, "OnShowHudSymbolButtons")

func CleanHudScreen():
	for child in bottom.get_children():
		child.queue_free()

func InitCurrentScreen():
	CleanHudScreen()
	for screen in Data.hudData.screens:
		if screen.hudScreenId == currentScreen:
			if currentScreen == Types.HudScreenId.Start:
				for hudButton in screen.hudButtons:
					var bInstance = Loader.GetResource(hudButton.button).instance()
					if hudButton.buttonUiAnchor == Types.UiAnchor.Bottom:
						bottom.add_child(bInstance)
					bInstance.position = hudButton.buttonPosition
					bInstance.AnimateShow()
			if currentScreen == Types.HudScreenId.Play:
				for hudButton in screen.hudButtons:
					if hudButton.hudButtonId != Types.HudButtonId.Symbol:
						var bInstance = Loader.GetResource(hudButton.button).instance()
						if hudButton.buttonUiAnchor == Types.UiAnchor.Bottom:
							bottom.add_child(bInstance)
						bInstance.position = hudButton.buttonPosition
						bInstance.AnimateShow()
						
func ShowSymbolButtons():
	for screen in Data.hudData.screens:
		if screen.hudScreenId == currentScreen:
			var btnIndex = -1
			var indexDelay = 0
			for hudButton in screen.hudButtons:
				if hudButton.hudButtonId == Types.HudButtonId.Symbol:
					var bInstance = Loader.GetResource(hudButton.button).instance()
					btnIndex += 1
					bInstance.index = btnIndex
					if hudButton.buttonUiAnchor == Types.UiAnchor.Bottom:
						bottom.add_child(bInstance)
						print("Added")
					bInstance.position = hudButton.buttonPosition
					bInstance.AnimateShow()
					
func HideSymbolButtons():
	for screen in Data.hudData.screens:
		if screen.hudScreenId == currentScreen:
			for hudButton in screen.hudButtons:
				if hudButton.hudButtonId == Types.HudButtonId.Symbol:
					if hudButton.buttonUiAnchor == Types.UiAnchor.Bottom:
						var indexDelay = 0
						for child in bottom.get_children():
							if child.hudButtonId == Types.HudButtonId.Symbol:
								Timeline.Delay(child, "AnimateHide", indexDelay)
								Timeline.Delay(child, queue_free(), 0.3 + indexDelay)
								indexDelay += 0.1
			
func OnShowHudStartScreen():
	currentScreen = Types.HudScreenId.Start
	InitCurrentScreen()

func OnShowHudPlayScreen():
	currentScreen = Types.HudScreenId.Play
	InitCurrentScreen()

func OnShowHudSymbolButtons():
	ShowSymbolButtons()

func OnButtonClick(button):
	if button.buttonId == Types.HudButtonId.Play:
		Events.emit_signal("HudButtonPlayClick")

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

