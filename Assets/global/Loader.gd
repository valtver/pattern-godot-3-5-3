extends Node

signal LoadComplete

const SIMULATED_DELAY_SEC = 0.1
var thread = null
#onready var progress = $Progress

var cache = {}
var isBusy = false

func GetResource(res):
	if cache.has(res):
		var cachedRes = cache[res]
		if cachedRes != null:
#			print(res, " is in cache")
			return cachedRes
		else:
#			print(res, " is in cache but not loaded")
			return null
	else:
		print(res, " is not in cache. SYNC load triggered!")
		cache[res] = ResourceLoader.load(res)
		return cache[res] 

func QueueResource(res):
	cache[res] = null
	
func Load():
	if cache.size() == 0:
		print("Nothing to Load. Queue is empty")
		call_deferred("_queue_loading_thread_complete", true)
		return
	
	thread = Thread.new()
	thread.start( self, "_queue_loading_thread")
	
func Unload():
	cache.clear()
	
func _queue_loading_thread():

	for cacheKey in cache:
		OS.delay_msec(int(SIMULATED_DELAY_SEC * 1000.0))
		print(cacheKey, " loading...")
		cache[cacheKey] = ResourceLoader.load(cacheKey)
				
	call_deferred("_queue_loading_thread_complete", true)
	
func _queue_loading_thread_complete(status):
	assert(status)
	print("Queue load complete with status: ", status)
	emit_signal("LoadComplete")
	thread.wait_to_finish()
