extends RigidBody2D

const SPEED = 100.0

var ship_pos := global_position

@export var rotation_speed_degrees:float = 180

func _physics_process(_delta: float) -> void:
	var horizontal_direction := Input.get_axis("left", "right")
	var vertical_direction := Input.get_axis("up", "down")
	
	var relative_direction:Vector2 = transform.x * horizontal_direction
	var rotation_direction:float = Input.get_axis("Rotation_Left", "Rotation_Right")
	rotation_degrees += rotation_direction * rotation_speed_degrees * _delta
	
	if horizontal_direction or vertical_direction:
		apply_central_force(Vector2(horizontal_direction*SPEED, vertical_direction*SPEED))
	
	if Input.is_action_just_pressed("beam"):
		$Beam.visible = true
		$Beam/CollisionPolygon2D.disabled = false
		ship_pos = global_position
	elif Input.is_action_pressed("beam"):
		var amount_in_beam:int = $Beam.get_overlapping_areas().size()
		if amount_in_beam > 0:
			var first_object_in_beam: Node = $Beam.get_overlapping_areas()[0].get_parent()
			if first_object_in_beam.name == "Gem":
				first_object_in_beam.global_position += global_position-ship_pos
		ship_pos = global_position
	else:
		$Beam.visible = false
		$Beam/CollisionPolygon2D.disabled = true
