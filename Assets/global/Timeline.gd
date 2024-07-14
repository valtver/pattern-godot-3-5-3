extends Node

var speedValue = 1

func Delay(obj, methodName, delayTime):
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = delayTime
	timer.one_shot = true
	timer.connect("timeout", obj, methodName)
	timer.connect("timeout", self, "CleanTimer", [timer])
	timer.start()

func TweenSpeed(startSpeedValue):
	var tween = get_node_or_null("SpeedTween")
	if tween == null:
		tween = Tween.new()
		add_child(tween)
	tween.interpolate_property(self, "speedValue",
		startSpeedValue, 1, 5,
		Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()

func CleanTimer(timerInstance):
	timerInstance.queue_free()
