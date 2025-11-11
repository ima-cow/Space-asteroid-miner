extends RigidBody2D

const SPEED = 100.0

#@export var _rotation_speed : float = TAU * 2
#var _theta : float

var ship_pos := global_position

func _physics_process(_delta: float) -> void:
	var horizontal_direction := Input.get_axis("left", "right")
	var vertical_direction := Input.get_axis("up", "down")
	
	if horizontal_direction or vertical_direction:
		apply_central_force(Vector2(horizontal_direction*SPEED, vertical_direction*SPEED))
	
	if horizontal_direction or vertical_direction:
		#_theta * wrapf(atan2(vertical_direction, horizontal_direction) - rotation, -PI, PI)
		#rotation += clamp(_rotation_speed * _delta, 0, abs(_theta) * sign(_theta))
		look_at(Vector2(horizontal_direction, vertical_direction))
		
	if Input.is_action_just_pressed("beam"):
		$Beam.visible = true
		$Beam/CollisionPolygon2D.disabled = false
		ship_pos = global_position
	elif Input.is_action_pressed("beam"):
		#print($Beam.visible, $Beam/CollisionPolygon2D.disabled)
		var amount_in_beam:int = $Beam.get_overlapping_areas().size()
		if amount_in_beam > 0:
			var first_object_in_beam: Node = $Beam.get_overlapping_areas()[0].get_parent()
			if first_object_in_beam.name == "Gem":
				first_object_in_beam.global_position += global_position-ship_pos
		ship_pos = global_position
		
	else:
		$Beam.visible = false
		$Beam/CollisionPolygon2D.disabled = true
