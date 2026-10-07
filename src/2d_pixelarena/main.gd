extends Node2D


@export var enemy_scene: PackedScene
@export var bullet_scene: PackedScene
@export var enemy_bullet_scene: PackedScene
@export var hp_offset := Vector2(-40, 30)

@onready var player := $Player
@onready var spawn_timer := $SpawnTimer
@onready var health_bar: ProgressBar = $CanvasLayer/Healthbar
@onready var time_label: Label = $CanvasLayer/TimeLabel
@onready var game_over: Control = $CanvasLayer/GameOver
@onready var game_over_label: Label = $CanvasLayer/GameOver/GameOverLabel
@onready var final_time_label: Label = $CanvasLayer/GameOver/FinalTimeLabel
@onready var replay_button: Button = $CanvasLayer/GameOver/ReplayButton

var time_survived := 0.0
var is_game_over := false

func _ready() -> void:
	add_to_group("game")
	
	game_over.visible = false
	replay_button.pressed.connect(_on_replay_pressed)
	
	spawn_timer.timeout.connect(_on_spawn_timer)
	player.died.connect(_on_player_died)
	player.health_change.connect(_on_player_health_change)
	
func _on_player_health_change(current: int, max_hp: int) -> void:
	health_bar.max_value = max_hp
	health_bar.value = current
	
func _on_spawn_timer() -> void:
	print("TIMER tick stopped:", spawn_timer.is_stopped(), " game_over:", is_game_over)
	if is_game_over:
		return
	spawn_enemy()
	
func spawn_enemy() -> void:
	if enemy_scene == null:
		push_error("Enemy scene missing!")
		return
	
	var enemy = enemy_scene.instantiate()
	add_child(enemy)
	
	enemy.global_position = get_random_edge_position()
	enemy.target = player
	
func spawn_bullet(pos: Vector2, rot: float) -> void:
	if bullet_scene == null:
		push_error("Bullet scene missing!")
		return
	
	var bullet = bullet_scene.instantiate()
	add_child(bullet)
	
	bullet.global_position = pos
	bullet.rotation = rot
	bullet.direction = Vector2.RIGHT.rotated(rot)
	
func spawn_enemy_bullet(pos: Vector2, dir: Vector2) -> void:
	print("enemy bullet pos:", pos, " dir:", dir)
	if enemy_bullet_scene == null:
		push_error("EnemyBullet scne missing")
		return
	var b = enemy_bullet_scene.instantiate()
	add_child(b)
	b.global_position = pos
	b.direction = dir.normalized()
	
func get_random_edge_position() -> Vector2:
	var rect = get_viewport_rect()
	var margin = 20
	var side = randi() % 4
	
	match side:
		0: return Vector2(randf_range(margin, rect.size.x - margin), margin) ## sus
		1: return Vector2(rect.size.x - margin, randf_range(margin, rect.size.y - margin)) ##dreapta
		2: return Vector2(randf_range(margin, rect.size.x - margin), rect.size.y - margin) ##jos
		3: return Vector2(margin, randf_range(margin, rect.size.y - margin))##stanga
	return Vector2.ZERO
	
func _on_player_died() -> void:
	is_game_over = true
	spawn_timer.stop()
	
	get_tree().call_group("enemies", "set_physics_process", false)
	game_over.visible = true
	game_over_label.text = "Game Over!"
	final_time_label.text = "Time: %0.1f" % time_survived
	replay_button.grab_focus()
	
func _process(_delta: float) -> void:
	
	if is_game_over:
		return
	time_survived += _delta
	time_label.text = "Time: %0.1f" % time_survived
	
func _on_replay_pressed() -> void:
	get_tree().reload_current_scene()
