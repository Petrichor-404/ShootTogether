class_name Main
extends Node

var player_scene: PackedScene = preload("uid://drjwnqv5kw156")

static var background_effects: Node2D
static var background_mask: Sprite2D

const MAIN_MENU_SCENE_PATH := "res://ui/main_menu/main_menu.tscn"

@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var center_position: Marker2D = $CenterPosition
@onready var enemy_manager: EnemyManager = $EnemyManager
@onready var _background_effects: Node2D = $BackgroundEffects
@onready var _background_mask: Sprite2D = %BackgroundMask
@onready var game_ui: GameUI = $GameUI
@onready var pause_menu: PauseMenu = $PauseMenu
@onready var lobby_manager: LobbyManager = $LobbyManager
@onready var upgrade_manager: UpgradeManager = $UpgradeManager

var dead_peers: Array[int] = []
var player_dictionary: Dictionary[int, Player] = {}
var player_name_dictionary: Dictionary[int, String] = {}

func _ready() ->void:
	background_effects = _background_effects
	background_mask = _background_mask
	
	multiplayer_spawner.spawn_function = func(data):
		var player = player_scene.instantiate() as Player
		player.name = str(data.peer_id)
		player.set_display_name(data.display_name)
		player.input_multiplayer_authority = data.peer_id
		player.global_position = center_position.global_position
		
		if multiplayer.get_unique_id() == data.peer_id:
			game_ui.connect_player(player)
		
		if is_multiplayer_authority():
			if data.is_respawning:
				player.is_respawn = true
			player.died.connect(_on_player_died.bind(data.peer_id))
		
		player_dictionary[data.peer_id] = player
		return player
		
	peer_ready.rpc_id(1,MultiplayerConfig.display_name)
	
	pause_menu.quit_request.connect(_on_quit_request)
	lobby_manager.all_peers_ready.connect(_on_all_peers_ready)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	if is_multiplayer_authority():
		enemy_manager.round_completed.connect(_on_round_completed)
		enemy_manager.game_completed.connect(_on_game_completed)
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
		
	
@rpc("any_peer","call_local","reliable")
func peer_ready(display_name: String):
	print("peer %s ready" % multiplayer.get_remote_sender_id())
	var sender_id = multiplayer.get_remote_sender_id()
	player_name_dictionary[sender_id] = display_name
	multiplayer_spawner.spawn({
		"peer_id":sender_id,
		"display_name":display_name,
		"is_respawning":false
		})
	enemy_manager.synchornize(sender_id)

func respawn_dead_peers():
	var all_peers := get_all_peers()
	for peer_id in dead_peers :
		if !all_peers.has(peer_id):
			continue; 
		multiplayer_spawner.spawn({
			"peer_id":peer_id,
			"display_name":player_name_dictionary[peer_id],
			"is_respawning": true
		})
	dead_peers.clear()

func end_game():
	get_tree().paused = false
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)

func check_game_over():
	var is_game_over := true
	for peer_id in get_all_peers():
		if !dead_peers.has(peer_id):
			is_game_over = false
			break
	if is_game_over:
		end_game()

func get_all_peers()->PackedInt32Array:
	var all_peers := multiplayer.get_peers()
	all_peers.push_back(multiplayer.get_unique_id())
	return all_peers

func _on_player_died(peer_id: int):
	dead_peers.append(peer_id)
	check_game_over()
	pass

func _on_round_completed():
	respawn_dead_peers()

func _on_game_completed():
	end_game()

func _on_server_disconnected():
	end_game()

func _on_peer_disconnected(peer_id: int):
	
	if player_dictionary.has(peer_id):
		var player := player_dictionary[peer_id]
		if is_instance_valid(player):
			player.kill()
		player_dictionary.erase(peer_id)
	
func _on_quit_request():
	end_game()

func _on_all_peers_ready():
	lobby_manager.close_lobby()
	enemy_manager.start()
