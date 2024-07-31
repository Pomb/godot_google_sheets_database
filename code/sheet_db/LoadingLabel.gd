extends Label

var timer
var tick_count = 0

func _ready():
	timer = Timer.new()
	timer.wait_time = 0.2
	add_child(timer)
	timer.timeout.connect(tick)


func tick():
	tick_count += 1
	tick_count = tick_count % 4
	text = "loading"
	for _i in range(tick_count):
		text += '.'


func start():
	visible = true
	timer.start(0)


func stop():
	text = ""
	visible = false
	timer.stop()
