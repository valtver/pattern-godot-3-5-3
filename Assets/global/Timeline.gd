extends Node

var speedValue = 1

var timers = []

func Delay(obj, methodName, delayTime):
	var timer := Timer.new()
	add_child(timer)
	timers.append(timer)
	timer.wait_time = delayTime
	timer.one_shot = true
	timer.connect("timeout", obj, methodName)
	timer.connect("timeout", self, "StopAndCleanTimer", [timer])
	timer.start()

func StopAndCleanTimer(timerInstance):
	timerInstance.stop()
	timerInstance.queue_free()
	timers.erase(timerInstance)
	
func StopTimer(obj, methodName):
	for timer in timers:
		if timer.is_connected("timeout", obj, methodName):
			timers.erase(timer)
			StopAndCleanTimer(timer)
			print("Timer ", methodName, " for ", obj, " has stopped!")
			return
