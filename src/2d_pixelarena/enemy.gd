extends CharacterBody2D

@export var speed := 140.0
@export var shoot_interval := 1.5
@export var shoot_range := 400.0

var _shoot_cd := 0.0

var target : Node2D

@onready var sprite: Sprite2D = $Sprite2D
var skins := [
	preload("res://Enemy1.png"),
	preload("res://Enemy2.png"),
	preload("res://Enemy3.png"),
	preload("res://Enemy4.png"),
	preload("res://Enemy5.png"),
	]
	
func _ready() -> void:
	add_to_group("enemies")
	sprite.texture = skins[randi() % skins.size()]
	
func _physics_process(delta: float) -> void:
	if target == null:
		return
	var dir :=(target.global_position - global_position).normalized()
	velocity = dir * speed
	move_and_slide()
	
	_shoot_cd = maxf(0.0, _shoot_cd - delta)
	
	var dist := global_position.distance_to(target.global_position)
	if dist <= shoot_range and _shoot_cd <= 0.0:
		_shoot_cd = shoot_interval
		shoot_at_player()

func shoot_at_player() -> void:
	var dir := (target.global_position - global_position).normalized()
	
	get_tree().call_group("game", "spawn_enemy_bullet", global_position, dir)
	
func die() -> void:
	if target != null and target.has_method("heal"):
		target.heal(1)
	queue_free()
