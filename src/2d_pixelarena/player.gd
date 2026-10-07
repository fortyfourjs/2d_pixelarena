extends CharacterBody2D
@export var speed := 260.0
@export var max_health := 10
@export var fire_rate := 0.15


@onready var muzzle: Marker2D = $Muzzle

var alive := true
var health: int
var _cooldown := 0.0
var _invuln := 0.0

signal died
signal health_change(current: int, max: int)

func _ready() -> void:
	health = max_health
	emit_signal("health_change", health, max_health)

func _process(delta: float) -> void:
	if not alive:
		return
	
	look_at(get_global_mouse_position())
	
	_cooldown = maxf(0.0, _cooldown - delta)
	_invuln = maxf(0.0, _invuln - delta)
	
	if Input.is_action_pressed("shoot") and _cooldown <= 0.0:
		_cooldown = fire_rate
		shoot()
		
func _physics_process(_delta: float) -> void:
	if not alive:
		velocity = Vector2.ZERO
		return
		
	var input_vec := Input.get_vector("move_left","move_right","move_up","move_down")
	velocity =input_vec * speed
	move_and_slide()
	
	var rect := get_viewport_rect()
	var margin := 16.0
	global_position.x = clamp(global_position.x, margin, rect.size.x - margin)
	global_position.y = clamp(global_position.y, margin, rect.size.y - margin)
	
func shoot() -> void:
	get_tree().call_group("game","spawn_bullet",muzzle.global_position, global_rotation)

func take_damage(amount: int) -> void:
	if _invuln > 0.0:
		return
		
	_invuln = 0.5
	health -= amount
	emit_signal("health_change", health, max_health)
	
	if health <= 0 and alive:
		alive = false
		velocity = Vector2.ZERO
		set_process(false)
		set_physics_process(false)
		emit_signal("died")

func heal(amount: int) -> void:
	if not alive:
		return
	health = mini(max_health, health + amount)
	emit_signal("health_change", health, max_health)
	
