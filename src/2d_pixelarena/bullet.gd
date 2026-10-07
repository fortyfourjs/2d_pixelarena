extends Area2D

@export var speed := 900.0
@export var lifetime := 1.5

var direction := Vector2.RIGHT
var _time := 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
func _process(delta: float) -> void:
	global_position += direction * speed * delta
	_time += delta
	if _time >= lifetime:
		queue_free()
		
func _on_body_entered(body : Node) -> void:
	if body.is_in_group("enemies"):
		body.call("die")
		queue_free()
