extends Node

var camTween = null

func MoveToInTime(nextPos, posTime):
	if camTween != null:
		camTween.kill()
		
	camTween = create_tween()
	camTween.set_ease(Tween.EASE_IN)
	camTween.set_trans(Tween.TRANS_QUART)
	camTween.tween_property(self, "position", nextPos, posTime)
	camTween.play()

func Pause():
	if camTween != null:
		camTween.pause()
		
func Resume():
	if camTween != null:
		camTween.play()
		
func Stop():
	if camTween != null:
		camTween.kill()
