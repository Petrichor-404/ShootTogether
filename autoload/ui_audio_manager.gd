class_name UIAudioManager
extends Node


@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

static var instance: UIAudioManager

func _ready() -> void:
	instance = self

static func register_buttons(buttons: Array):
	for button in buttons:
		button.pressed.connect(instance._on_button_pressed)

func _on_button_pressed():
	instance.audio_stream_player.play()
