extends Node

func OnCompleteTimer(obj, methodName, delayTime):
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = delayTime
	timer.one_shot = true
	timer.connect("timeout", obj, methodName)
	timer.connect("timeout", self, "CleanTimer", [timer])
	timer.start()

func CleanTimer(timerInstance):
	timerInstance.queue_free()
