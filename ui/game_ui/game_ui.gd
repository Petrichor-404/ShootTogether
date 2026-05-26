class_name GameUI
extends CanvasLayer

@export var enemy_manager: EnemyManager
@onready var timer_label: Label = %TimerLabel
@onready var round_label: Label = %RoundLabel
@onready var health_progress_bar: ProgressBar = %HealthProgressBar
@onready var display_name_label_ui: Label = %DisplayNameLabelUI
@onready var ready_label: Label = %ReadyLabel
@onready var ready_count_label: Label = %ReadyCountLabel
@onready var no_ready_label: Label = %NoReadyLabel
@onready var ready_up_container: VBoxContainer = $MarginContainer/ReadyUpContainer
@onready var player_info_container: HBoxContainer = $MarginContainer/PlayerInfoContainer
@onready var round_info_container: VBoxContainer = $MarginContainer/RoundInfoContainer

@export var lobby_manager: LobbyManager

func _ready() -> void:
	enemy_manager.round_changed.connect(_on_round_changed)
	lobby_manager.self_peer_ready.connect(_on_self_peer_ready)
	lobby_manager.lobby_closed.connect(_on_lobby_closed)
	lobby_manager.peer_ready_states_changed.connect(_on_peer_ready_states_changed)
	
	var is_single_player := multiplayer.multiplayer_peer is OfflineMultiplayerPeer
	ready_up_container.visible = !is_single_player
	round_info_container.visible = is_single_player
	ready_label.visible = false
	no_ready_label.visible = true

func _process(_delta: float) -> void:
	timer_label.text = "Left Time " + str(ceili(enemy_manager.get_round_time_remaining()))

func connect_player(player: Player):
	(func():
		if multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
			display_name_label_ui.text = "Player"
		else:
			display_name_label_ui.text = player.display_name
		player.health_component.health_changed.connect(_on_health_changed)
		_on_health_changed(player.health_component.current_health, \
			player.health_component.max_health)
		).call_deferred()

func _on_round_changed(round_count: int):
	round_label.text = "Round %s" % round_count
	
func _on_health_changed(current_health: int, max_health: int):
	health_progress_bar.value = float(current_health)/max_health if max_health !=0 else 0

func _on_self_peer_ready():
	ready_label.visible = true
	no_ready_label.visible = false
	
func _on_lobby_closed():
	round_info_container.visible = true
	ready_up_container.visible = false

func _on_peer_ready_states_changed(ready_count:int, total_count:int):
	ready_count_label.text = "%s/%s READY" % [ready_count,total_count]
