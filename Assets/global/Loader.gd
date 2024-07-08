extends Node

signal LoadComplete

const SIMULATED_DELAY_SEC = 0.1
var thread = null
#onready var progress = $Progress

var cache = {}
var isBusy = false

func GetResource(res):
	if cache.has(res):
		var cachedHandler = cache[res]
		var cachedRes = cachedHandler.get_resource()
		if cachedRes != null:
			print(res, " is in cache")
			return cachedRes
		else:
			print(res, " is in cache but not loaded")
			return null
	else:
		print(res, " is not in cache. SYNC load triggered!")
		var syncRes = load(res)
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
