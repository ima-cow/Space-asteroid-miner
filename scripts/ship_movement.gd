extends RigidBody2D

const SPEED = 100.0

var ship_pos := global_position

func _physics_process(_delta: float) -> void:
	var horizontal_direction := Input.get_axis("left", "right")
	var vertical_direction := Input.get_axis("up", "down")
	var horizontal_rotation := Input.get_axis("Rotation_Left", "Rotation_Right")
	var vertical_rotation := Input.get_axis("Rotation_Up", "Rotation_Down")
	
	if horizontal_direction or vertical_direction:
		apply_central_force(Vector2(horizontal_direction*SPEED, vertical_direction*SPEED))
	
	if horizontal_rotation or vertical_rotation:
		look_at(Vector2(horizontal_rotation, vertical_rotation))
	
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
