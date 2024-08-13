extends Node

var speedValue = 1

var timers = {}

func Delay(obj, methodName, delayTime, updateMethod: String = ""):
	var timer = create_tween()
	if obj in timers:
		if methodName in timers[obj]:
			print("Timer key ", methodName, " already exists!")
		else:
			timers[obj][methodName] = timer
	else:
		timers[obj] = {}
		timers[obj][methodName] = timer
		
	if updateMethod != "":
		timer.tween_method(obj, updateMethod, delayTime, 0.0, delayTime)
		timer.chain().tween_callback(obj, methodName)
	else:
		timer.tween_callback(obj, methodName).set_delay(delayTime)
		
	timer.chain().tween_callback(self, "CleanUp", [obj, methodName])
	timer.play()
	return timer
		
func CleanUp(obj, methodName):
	if obj in timers:
		if methodName in timers[obj]:
			timers[obj].erase(methodName)
			if timers[obj].size() == 0:
				timers.erase(obj)
			
	
func StopDelay(obj, methodName):
	if obj in timers:
		if methodName in timers[obj]:
			timers[obj][methodName].kill()
			CleanUp(obj, methodName)

func PauseDelay(obj, methodName):
	if obj in timers:
		if methodName in timers[obj]:
			timers[obj][methodName].pause()
			print("Timer ", methodName, " is paused at ", timers[obj][methodName].get_total_elapsed_time())
			
func ResumeDelay(obj, methodName):
	if obj in timers:
		if methodName in timers[obj]:
			timers[obj][methodName].play()
			print("Timer ", methodName, " is resumed at ", timers[obj][methodName].get_total_elapsed_time())
			
func GetTimer(obj, methodName):
	if obj in timers:
		if methodName in timers[obj]:
			return timers[obj][methodName]
			
func IsTimer(obj, methodName):
	if obj in timers:
		if methodName in timers[obj]:
			return true
	return false
