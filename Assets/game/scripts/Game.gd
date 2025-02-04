extends Spatial

var level
var mapCamera

var activeTask = -1
var activeStep = -1

func _ready():
	AppInput.DisableScene()
	mapCamera = get_parent().get_node_or_null("MapCamera")
	Events.connect("HudButtonPlayClick", self, "NextTask")
	Events.connect("HudButtonSymbolClick", self, "TaskCheck")
	Events.connect("HudButtonReplayClick", self, "RestartLevel")
	Events.connect("TimerTimeout", self, "TaskCheck")

func Init():
	InitSessionData()
	if level == null:
		level = Loader.GetResource(Data.levels[Data.playerData.selectedLevelIndex].subLevels[Data.playerData.selectedSubLevelIndex].scene).instance()
		add_child(level)
	level.Init()
	yield(get_tree(), "idle_frame")
	mapCamera.position = level.tasks[0].get_node("StartPosition").global_position
	var animationPlayer = level.tasks[0].get_node_or_null("AnimationPlayer")
	if animationPlayer != null:
		animationPlayer.play("Idle")
	level.UpdateVisibility(0)
	activeTask = -1
	activeStep = -1
	Events.emit_signal("GameLevelStart")
		
func RestartLevel():
	Events.emit_signal("GameRestart", self)
	pass
		
func OnButtonClick(button):
	pass
	
func NextTask():
	activeTask += 1
	activeStep = -1	
	if activeTask >= level.tasks.size():
		LevelWin()
		return
	var nextCameraPos = level.tasks[activeTask].get_node("StartPosition").global_position
	var animationPlayer = level.tasks[activeTask].get_node_or_null("AnimationPlayer")
	if animationPlayer != null:
		animationPlayer.play("Start")
	level.UpdateVisibility(activeTask)
	if mapCamera.position != nextCameraPos:
		mapCamera.MoveToInTime(nextCameraPos, float(Data.nextTaskDelay))
		level.UpdateVisibility(activeTask)
		yield(get_tree().create_timer(float(Data.nextTaskDelay)), "timeout")
	level.UpdateVisibility()
	NextStep()
		
func NextStep():
	activeStep += 1
	if activeStep >= level.tasks[activeTask].steps.size():
		if activeStep > 0:
			Events.emit_signal("GameTaskEnd", true, Timers.Get(self.name).time_left)
		NextTask()
		return
	var step = level.tasks[activeTask].steps[activeStep]
	step.visible = true
	step.Start()
	Events.emit_signal("GameStepStart", step.pattern)
	if activeStep == 0:
		Timers.Set(self.name, Data.taskTimerDelay)
		Events.emit_signal("GameTaskStart")

func TaskCheck(button = null):
	Timers.Pause(self.name)
	var step = level.tasks[activeTask].steps[activeStep]
	
	if Timers.Get(self.name).time_left <= 0:
		FailOrEnd(step)
	
	if button != null:
		var validSymbol = step.ValidButtonSymbol(button)
		if validSymbol:
			Win(step)
			NextStep()
		else:
			FailOrEnd(step)
			
func LevelWin():
	print("Level Complete")
	var animationPlayer = level.tasks[activeTask-1].get_node_or_null("AnimationPlayer")
	if animationPlayer != null:
		animationPlayer.play("End")
	Events.emit_signal("GameLevelEnd", true)
		
func LevelFail():
	print("Level Fail")
	Events.emit_signal("GameLevelEnd", false)	
	
func InitSessionData():
	Data.playerData.sessionFails = 0
	Data.playerData.sessionTimeScore = 0
	Data.playerData.sessionStars = 0
	Data.playerData.sessionTimeScoreLastStep = 0
	
func Win(step):
	Data.playerData.sessionTimeScore += Timers.Get(self.name).time_left
	step.Complete()
	
func FailOrEnd(step):
	Data.playerData.sessionFails += 1
	step.Fail()
	if Data.playerData.sessionFails >= Data.sessionFailsLimit:	
		LevelFail()
	else:
		Events.emit_signal("GameTaskEnd", false, Timers.Get(self.name).time_left)
		NextTask()
	
