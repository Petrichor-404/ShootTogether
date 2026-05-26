extends Control

var main_scene: PackedScene = preload("uid://ccfyqtykhmsc4")

@onready var single_player_button: Button = $VBoxContainer2/VBoxContainer/SinglePlayerButton
@onready var multiplayer_button: Button = $VBoxContainer2/VBoxContainer/MultiplayerButton
@onready var quit_button: Button = $VBoxContainer2/VBoxContainer/QuitButton
@onready var options_button: Button = $VBoxContainer2/VBoxContainer/OptionsButton

@onready var multiplayer_menu_scene: PackedScene = load("uid://7r08yww1wekv")

var options_menu_scene: PackedScene = preload("uid://kk0nbledwot")
func _ready() -> void:
	single_player_button.pressed.connect(_on_single_player_button_pressed)
	multiplayer_button.pressed.connect(_on_multiplayer_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	
	UIAudioManager.register_buttons([
		single_player_button,
		multiplayer_button,
		options_button,
		quit_button
	])
	
func _on_single_player_button_pressed():
	get_tree().change_scene_to_packed(main_scene)

func _on_multiplayer_button_pressed():
	get_tree().change_scene_to_packed(multiplayer_menu_scene)

func _on_options_button_pressed():
	var options_menu := options_menu_scene.instantiate()
	add_child(options_menu)

func _on_quit_button_pressed():
	get_tree().quit()
