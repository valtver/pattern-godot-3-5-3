extends Node

signal LoadComplete

const SIMULATED_DELAY_SEC = 0.1
var thread = null
#onready var progress = $Progress

var cache = {}
var isBusy = false

func GetResource(res):
	var cachedHandler = cache[res.get_path()]
	if cachedHandler!= null:
		var cachedRes = cachedHandler.get_resource()
		if cachedRes != null:
			print(res, " is in cache")
			return cachedRes
		else:
			print(res, " is in cache but not loaded")
			return null
	else:
		print(res, " is not in cache. SYNC load triggered!")
		var syncRes = load(res.get_path())
		return syncRes

func QueueResource(res):
	cache[res.get_path()] = null
	
func Load():
	if cache.size() == 0:
		print("Nothing to Load. Queue is empty")
		return
	for cacheKey in cache:
		if cache[cacheKey] == null:
			cache[cacheKey] = ResourceLoader.load_interactive(cacheKey)
			print(cacheKey, " loading started...")
	
	thread = Thread.new()
	thread.start( self, "_queue_loading_thread", cache)
	
func Unload():
	cache.clear()
	
func _queue_loading_thread(cache):
	assert(cache)
	var error = false
	while true:
		var completeCounter = 0
		for cacheKey in cache:
			OS.delay_msec(int(SIMULATED_DELAY_SEC * 1000.0))
			var err = cache[cacheKey].poll()
			if err == ERR_FILE_EOF:
				completeCounter += 1
			elif err != OK:
				# Not OK, there was an error.
				error = true
				print("There was an error loading")
				break
		if completeCounter == cache.size() || error:
			break
			
	call_deferred("_queue_loading_thread_complete", true)
	
func _queue_loading_thread_complete(status):
	assert(status)
	print("Queue load complete with status: ", status)
	emit_signal("LoadComplete")
	thread.wait_to_finish()











func _thread_load(path):
	var ril = ResourceLoader.load_interactive(path)
	assert(ril)
	var total = ril.get_stage_count()
	# Call deferred to configure max load steps.
#	progress.call_deferred("set_max", total)

	var res = null

	while true: #iterate until we have a resource
		# Update progress bar, use call deferred, which routes to main thread.
#		progress.call_deferred("set_value", ril.get_stage())
		# Simulate a delay.
		OS.delay_msec(int(SIMULATED_DELAY_SEC * 1000.0))
		# Poll (does a load step).
		var err = ril.poll()
		# If OK, then load another one. If EOF, it' s done. Otherwise there was an error.
		if err == ERR_FILE_EOF:
			# Loading done, fetch resource.
			res = ril.get_resource()
			break
		elif err != OK:
			# Not OK, there was an error.
			print("There was an error loading")
			break

	# Send whathever we did (or did not) get.
	call_deferred("_thread_done", res)


func _thread_done(resource):
	assert(resource)
	# Always wait for threads to finish, this is required on Windows.
	thread.wait_to_finish()
	

	# Hide the progress bar.
#	progress.hide()

	# Instantiate new scene.
	var new_scene = resource.instance()
	# Free current scene.
#	get_tree().current_scene.free()
#	get_tree().current_scene = null
	# Add new one to root.
#	get_tree().root.add_child(new_scene)
	# Set as current scene.
#	get_tree().current_scene = new_scene

#	progress.visible = false


func load_scene(path):
	thread = Thread.new()
	thread.start( self, "_thread_load", path)
#	raise() # Show on top.
#	progress.visible = true
