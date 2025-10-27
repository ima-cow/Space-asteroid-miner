extends RigidBody2D

const SPEED = 100.0

var ship_pos := global_position

func _physics_process(_delta: float) -> void:
	var horizontal_direction := Input.get_axis("left", "right")
	var vertical_direction := Input.get_axis("up", "down")
	
	if horizontal_direction or vertical_direction:
		apply_central_force(Vector2(horizontal_direction*SPEED, vertical_direction*SPEED))
	
	if Input.is_action_just_pressed("beam"):
		$Beam.visible = true
		$Beam/CollisionPolygon2D.disabled = false
		ship_pos = global_position
	elif Input.is_action_pressed("beam"):
		print($Beam.get_overlapping_areas())
		if $Beam.get_overlapping_areas().size() > 0:
			print($Beam.get_overlapping_areas()[0].global_position)
			$Beam.get_overlapping_areas()[0].global_position += ship_pos-global_position
	else:
		$Beam.visible = false
		$Beam/CollisionPolygon2D.disabled = true


func _on_beam_property_list_changed() -> void:
	print("wow")

func _on_collision_polygon_2d_property_list_changed() -> void:
	pass # Replace with function body.
