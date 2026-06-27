extends Control

@onready var button = $Button
@onready var label = $Label
@onready var timer = $Timer
@onready var labeltime: Timer = $labeltime

var spin_time = 5.0
var spinning = false
var spin_speed = 99999999999999999 # degrees per second

func _ready():
	pass
	
func _process(delta):
	if button.disabled:
		button.text = str(ceil(timer.time_left))

	if spinning:
		label.offset_transform_rotation += spin_speed * delta
		
	



var wheel_items = [
	{"name": "Nothing", "weight": 10},
	{"name": "Speed Boost", "weight": 25},
	{"name": "Speed Decrease", "weight": 25},
	{"name": "Low Gravity", "weight": 15},
	{"name": "high gravity", "weight": 10},
	{"name": "Instant Death", "weight": 1},
	{"name": "Jackpot", "weight": 5}
]

func _on_button_pressed():
	var result = pick_random_item()
	label.text = result

	button.disabled = true
	timer.wait_time = 10
	
	timer.start()
	labeltime.wait_time=2
	labeltime.start()
	spinning = true
	



func _on_timer_timeout():
	print("Timer finished!")
	button.disabled = false
	button.text = "Spin"

func pick_random_item():
	var total_weight = 0

	for item in wheel_items:
		total_weight += item.weight

	var rand = randi_range(1, total_weight)

	var current = 0
	for item in wheel_items:
		current += item.weight
		if rand <= current:
			return item.name

	return null


func _on_label_timeout() -> void:
	print("labeltimedone")
	spinning = false
	var result = pick_random_item()
	label.offset_transform_rotation=0
	label.text = result
	if result=="Nothing":
		pass
	elif result=="Speed Boost":
		Global.sped=Global.sped+2
		Global.acc=Global.acc+1
	elif result=="Speed Decrease":
		Global.sped=Global.sped-2
		Global.acc=Global.acc-1
	elif result=="Low Gravity":
		Global.grav=Global.grav+20
	elif result=="high gravity":
		Global.grav=Global.grav-20
