extends RigidBody2D

const SPEED = 100.0

func _physics_process(delta: float) -> void:
	var horizontal_direction := Input.get_axis("left", "right")
	var vertical_direction := Input.get_axis("up", "down")
	
	if horizontal_direction or vertical_direction:
		apply_central_force(Vector2(horizontal_direction*SPEED, vertical_direction*SPEED))
	
