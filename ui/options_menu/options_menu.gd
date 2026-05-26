extends CanvasLayer

@onready var sfx_down_button: Button = %SfxDownButton
@onready var sfx_progress_bar: ProgressBar = %SfxProgressBar
@onready var sfx_up_button: Button = %SfxUpButton
@onready var bgm_down_button: Button = %BgmDownButton
@onready var bgm_progress_bar: ProgressBar = %BgmProgressBar
@onready var bgm_up_button: Button = %BgmUpButton
@onready var done_button: Button = $MarginContainer/VBoxContainer/DoneButton

func _ready() -> void:
	update_display()
	
	sfx_down_button.pressed.connect(_on_down_pressed.bind("sfx"))
	sfx_up_button.pressed.connect(_on_up_pressed.bind("sfx"))
	bgm_down_button.pressed.connect(_on_down_pressed.bind("bgm"))
	bgm_up_button.pressed.connect(_on_up_pressed.bind("bgm"))
	done_button.pressed.connect(_on_done_pressed)
	
	UIAudioManager.register_buttons([
		sfx_down_button,
		sfx_up_button,
		bgm_down_button,
		bgm_up_button,
		done_button
	])
	
func update_display():
	sfx_progress_bar.value = get_bus_volume("sfx")
	bgm_progress_bar.value = get_bus_volume("bgm")

func get_bus_volume(bus_name: String) -> float:
	var index := AudioServer.get_bus_index(bus_name)
	return AudioServer.get_bus_volume_linear(index)
	
func change_bus_volume(bus_name: String, linear_change: float):
	var current_volume_linear := get_bus_volume(bus_name)
	var index := AudioServer.get_bus_index(bus_name)
	var linear_vol = clamp(current_volume_linear+linear_change, 0.0, 1.0) 
	AudioServer.set_bus_volume_linear(index,linear_vol)
	update_display()
	#print("Before: ", current_volume_linear)
	#print("After set: ", AudioServer.get_bus_volume_linear(index))
	
func _on_down_pressed(bus_name: String):
	change_bus_volume(bus_name,-.1)

func _on_up_pressed(bus_name: String):
	change_bus_volume(bus_name,.1)

func _on_done_pressed():
	queue_free()
