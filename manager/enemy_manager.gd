class_name EnemyManager
extends Node

signal round_changed(round_number: int)
signal round_completed
signal game_completed

const ROUND_BASE_TIME: int = 10
const ROUND_GROWTH: int = 5
const BASE_ENEMY_SPAWN_TIME: float = 1
const ENEMY_SPAWN_TIME_GROWTH: float = 0.95
const MAX_ROUNDS: int = 100

@export var enemy_scene: PackedScene
@export var enemy_spawn_root: Node
@export var spawn_rect: ReferenceRect 
@export var upgrade_manager: UpgradeManager

@onready var spawn_interval_timer: Timer = $SpawnIntervalTimer
@onready var round_timer: Timer = $RoundTimer


var _round_count: int
var round_count: int :
	get:
		return _round_count
	set(value):
		_round_count = value
		round_changed.emit(_round_count)
var spawned_enemies: int

func _ready():
	spawn_interval_timer.timeout\
		.connect(_on_spawn_interval_timer_timeoout)
	round_timer.timeout.connect(_on_round_timer_timeout)
	GameEvents.enemy_died.connect(_on_enemy_died)
	upgrade_manager.upgrade_completed.connect(_on_upgrade_completed)

func start():
	if is_multiplayer_authority():
		begin_round()
	
func synchornize(to_peer_id: int = -1):	
	if !is_multiplayer_authority():
		return
	
	var data = {
		"round_timer_is_running": !round_timer.is_stopped(),
		"round_timer_time_left": round_timer.time_left,
		"round_count": round_count
	}
	
	if to_peer_id > -1 and to_peer_id != 1:
		_synchronize.rpc_id(to_peer_id,data)
	else:
		_synchronize.rpc(data)

@rpc("authority","call_remote","reliable")
func _synchronize(data: Dictionary):
	var wait_time: float = data["round_timer_time_left"]
	if wait_time > 0:
		round_timer.wait_time = wait_time
	if data["round_timer_is_running"]:
		round_timer.start()
	round_count = data["round_count"]
	
func get_round_time_remaining() -> float:
	return round_timer.time_left

func begin_round():
	round_count += 1
	round_timer.wait_time = ROUND_BASE_TIME + ((round_count - 1)*ROUND_GROWTH)
	round_timer.start()
	
	var enemy_spawn_time = clamp(BASE_ENEMY_SPAWN_TIME * \
		pow(ENEMY_SPAWN_TIME_GROWTH,(round_count  - 1)),pow(.1,5),1)
	spawn_interval_timer.wait_time = enemy_spawn_time
	spawn_interval_timer.start()
	
	synchornize()

func check_round_completed():
	if !round_timer.is_stopped():
		return
	if spawned_enemies == 0:
		if round_count == MAX_ROUNDS:
			complete_game()
		else:
			round_completed.emit()

func complete_game():
	await get_tree().create_timer(2).timeout
	game_completed.emit()
	
func get_random_spawn_position() -> Vector2:
	var x = randf_range(0,spawn_rect.size.x) 
	var y = randf_range(0,spawn_rect.size.y) 
	
	return spawn_rect.global_position+Vector2(x,y)

func spawn_enemy	():
	var enemy = enemy_scene.instantiate() as Enemy
	enemy.global_position = get_random_spawn_position()
	enemy_spawn_root.add_child(enemy,true)
	spawned_enemies += 1
	
func _on_spawn_interval_timer_timeoout():
	if is_multiplayer_authority():
		spawn_enemy()
		spawn_interval_timer.start()
		
func _on_round_timer_timeout():
	if is_multiplayer_authority():
		spawn_interval_timer.stop()
		check_round_completed()

func _on_enemy_died():
	spawned_enemies -= 1
	check_round_completed()

func _on_upgrade_completed():
	begin_round()
