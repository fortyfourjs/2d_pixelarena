extends Area2D


@export var speed := 500.0
@export var lifetime := 2.0
@export var damage := 1


var direction := Vector2.RIGHT
var _t := 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
func _process(delta: float) -> void:
	
	global_position += direction * speed * delta
	_t += delta
	if _t >= lifetime:
		queue_free()
		
func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.call("take_damage", damage)
		queue_free()
