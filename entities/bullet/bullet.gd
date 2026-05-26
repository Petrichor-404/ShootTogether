class_name Bullet
extends Node2D

const SPEED: int = 600

@onready var life_timer: Timer = $LifeTimer
@onready var hitbox_component: HitboxComponent = $HitboxComponent

var direction: Vector2
var source_peer_id: int
var damage: int = 1

func _ready() -> void:
	hitbox_component.damage = damage
	hitbox_component.source_peer_id = source_peer_id
	hitbox_component.hit_hurtbox.connect(_on_hit_hurtbox)
	life_timer.timeout.connect(_on_life_timer_timeout)

func _process(delta: float) -> void:
	global_position += direction * SPEED *delta

func start(root_direction: Vector2):
	self.direction = root_direction
	rotation = root_direction.angle()

func register_collision():
	hitbox_component.is_hit_handled = true
	queue_free()

func _on_life_timer_timeout() -> void:
	if is_multiplayer_authority():
		queue_free()

func _on_hit_hurtbox(_hurtbox_component: HurtboxComponent):
	register_collision()
	
