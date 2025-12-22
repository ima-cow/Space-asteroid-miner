extends RigidBody2D

const SPEED = 10000.0
const ROTATION_SPEED_DEGREES:float = 240.0

var object_in_beam:Node

func _physics_process(delta: float) -> void:
	var horizontal_direction := Input.get_axis("forward", "back")
	var vertical_direction := Input.get_axis("left", "right")
	
	var relative_direction_x:Vector2 = transform.x * horizontal_direction
	var relative_direction_y:Vector2 = -transform.y * vertical_direction * 0
	var rotation_direction:float = Input.get_axis("left", "right")
	rotation_degrees += rotation_direction * ROTATION_SPEED_DEGREES * delta
	
	if horizontal_direction or vertical_direction:
		apply_central_force((relative_direction_x+relative_direction_y)*SPEED*delta)
	
	if Input.is_action_just_pressed("beam"):
		$Beam.visible = true
		$Beam/CollisionPolygon2D.disabled = false
	elif Input.is_action_pressed("beam"):
		var amount_in_beam:int = $Beam.get_overlapping_areas().size()
		if amount_in_beam > 0:
			object_in_beam = $Beam.get_overlapping_areas()[0].get_parent()
			if object_in_beam.name == "Gem":
				object_in_beam.reparent(self)
	else:
		if object_in_beam != null and object_in_beam.name == "Gem":
				object_in_beam.reparent($"../Asteroids")
		$Beam.visible = false
		$Beam/CollisionPolygon2D.disabled = true
