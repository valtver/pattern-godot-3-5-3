extends Node

var timers = {}

func Clear():
	timers = {}

func Set(callerName, duration):
	var timer = Get(callerName)
	if timer != null:
		timer.paused = true
		timer.start(duration)
		timer.paused = false
		return
	timers[callerName] = Timer.new()
	add_child(timers[callerName])
	timers[callerName].one_shot = true
	timers[callerName].connect("timeout", self, "OnTimeout")
	timers[callerName].start(duration)
	
func Get(callerName):
	if !callerName in timers:
		print("Timer ", callerName, " doesn't exist")
		return null
	return timers[callerName]
		
func Pause(callerName):
	var timer = Get(callerName)
	if timer != null:
		timer.paused = true
		
func Resume(callerName):
	var timer = Get(callerName)
	if timer != null:
		timer.paused = false
		
func Stop(callerName):
	var timer = Get(callerName)
	if timer != null:
		timer.stop()
	
func OnTimeout():
	Events.emit_signal("TimerTimeout")
