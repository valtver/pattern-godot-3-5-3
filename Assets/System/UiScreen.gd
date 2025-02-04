extends Spatial
class_name UiScreen

const SCROLLER_PAGE_WIDTH = 450
const ASPECT_RATIO = 9.0/21.0
const MAX_ASPECT_RATIO = 4.0/3.0
const SUB_LEVELS_X = 3
const SUB_LEVELS_Y = 3

var bottom
var top
var pivot

var scrollerTween = null

func _ready():
	bottom = $Bottom
	top = $Top
	pivot = $Pivot
	
	position = Vector3(0, 0, -1)
	resize()
	get_tree().get_root().connect("size_changed", self, "resize")
	
func ShowUiContent():
	pass

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
	
func ShowPreviousPage():
	var scrollerPivot = get_node("Pivot/Pivot")
	var scrollerIndex = (scrollerPivot.position.x / (SCROLLER_PAGE_WIDTH / 100.0)) - 1
	if scrollerIndex > 0:
		scrollerIndex -= 1
		UpdateUiScreenScrollerIndex(scrollerIndex)
		
func ShowNextPage():
	var scrollerPivot = get_node("Pivot/Pivot")
	var scrollerIndex = (scrollerPivot.position.x / (SCROLLER_PAGE_WIDTH / 100.0)) - 1
	if scrollerIndex > 0:
		scrollerIndex += 1
		UpdateUiScreenScrollerIndex(scrollerIndex)
		
func UpdateUiScreenScrollerIndex(index):
	var scrollerPivot = get_node("Pivot/Pivot")
	var scrollerButtonLeft = get_node("Pivot/ScrollerButtonLeft")
	var scrollerButtonRight = get_node("Pivot/ScrollerButtonRight")
	var levelName = get_node_or_null("Pivot/LevelName")
	var levelStats = get_node_or_null("Pivot/LevelStats")
	
	if index <= 0:
		scrollerButtonLeft.visible = false
	if index >= (scrollerPivot.get_child_count()-1):
		scrollerButtonRight.visible = false
	if index > 0 and index < (scrollerPivot.get_child_count()-1):
		scrollerButtonLeft.visible = true
		scrollerButtonRight.visible = true

	if index >= scrollerPivot.get_child_count():
		return
	var nextPosition = Vector3(index * (SCROLLER_PAGE_WIDTH / 100.0), 0, 0)
	if scrollerPivot.position == nextPosition:
		return

	if scrollerTween != null:
		scrollerTween.kill()
	scrollerTween = create_tween()
	scrollerTween.set_trans(Tween.TRANS_CUBIC)
	scrollerTween.set_ease(Tween.EASE_OUT)
	scrollerTween.parallel().tween_property(scrollerPivot, "position", nextPosition, 0.5)
	if levelName != null:
		levelName.text.modulate.a = 0
		scrollerTween.parallel().tween_property(levelName.text.modulate, "a", 1, 0.5)
	if levelStats != null:
		levelStats.text.modulate.a = 0
		scrollerTween.parallel().tween_property(levelStats.text.modulate, "a", 1, 0.5)
	scrollerTween.play()
