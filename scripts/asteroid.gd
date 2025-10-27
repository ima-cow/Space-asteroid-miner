extends Node2D

@onready var original_sprite := $RigidBody/Sprite2D
@onready var original_image:Image = original_sprite.texture.get_image()

const SMASH_ANGLE_DEVIATION_START := 24
const SMASH_ANGLE_DEVIATION_RATE := -2

func smash(num_pieces: int):
	var prev_angle := 0.0
	
	for i in num_pieces:
		var asteroid_chunk := RigidBody2D.new()
		
		var cur_angle:float
		if i == num_pieces-1:
			cur_angle = 360.0
		else:
			cur_angle = prev_angle + randfn(360.0/num_pieces, SMASH_ANGLE_DEVIATION_START+SMASH_ANGLE_DEVIATION_RATE*num_pieces)
		
		var sprite := _generate_chunk_sprite(prev_angle, cur_angle)
		asteroid_chunk.add_child(sprite)
		
		var collider := _generate_chunk_collider(prev_angle, cur_angle)
		asteroid_chunk.add_child(collider)
		
		asteroid_chunk.set_meta("smashed", true)
		
		add_child(asteroid_chunk)
		
		prev_angle = cur_angle
	
	$RigidBody.queue_free()

func _generate_chunk_sprite(prev_angle: float, cur_angle:float) -> Sprite2D:
	prev_angle -= 180
	cur_angle -= 180
	var sprite := Sprite2D.new()
	var image := Image.create_empty(original_image.get_width(), original_image.get_height(), original_image.has_mipmaps(), original_image.get_format())
	
	for x in original_image.get_width():
		for y in original_image.get_height():
			var cords_in_original := Vector2(x-(original_image.get_width()/2.0), y-(original_image.get_width()/2.0))
			var angle_of_pixel := rad_to_deg(atan2(cords_in_original.y, cords_in_original.x))
			if angle_of_pixel >= prev_angle and angle_of_pixel < cur_angle and original_sprite.is_pixel_opaque(cords_in_original):
				if !((abs(angle_of_pixel-prev_angle) < 5 or abs(angle_of_pixel-cur_angle) < 5) and randf() > (sqrt(pow(x, 2)+pow(y, 2)))/(sqrt(pow(original_image.get_width(), 2)+pow(original_image.get_height(), 2)))):
					image.set_pixel(x, y, original_image.get_pixel(x, y))
	
	sprite.texture = ImageTexture.create_from_image(image)
	return sprite

func _generate_chunk_collider(prev_angle: float, cur_angle:float) -> CollisionPolygon2D:
	var collider := CollisionPolygon2D.new()
	var polygon: PackedVector2Array
	var radius := sqrt(pow(original_image.get_width()/2.8, 2)+pow(original_image.get_height()/2.8, 2))
	
	polygon.append(Vector2(-radius*cos(deg_to_rad(prev_angle)), -radius*sin(deg_to_rad(prev_angle))))
	polygon.append(Vector2(-radius*cos(deg_to_rad(cur_angle)), -radius*sin(deg_to_rad(cur_angle))))
	polygon.append(Vector2(0, 0))
	
	collider.set_polygon(polygon)
	
	return collider

func test():
	var sprite := Sprite2D.new()
	var image := Image.create_empty(original_image.get_width(), original_image.get_height(), original_image.has_mipmaps(), original_image.get_format())
	for x in original_image.get_width():
		for y in original_image.get_height():
			var angle_of_pixel := rad_to_deg(atan2(y-(original_image.get_width()/2.0), x-(original_image.get_height()/2.0)))
			#print("x ",x," y ", y, " angle ",angle_of_pixel)
			if angle_of_pixel >= -180 and angle_of_pixel < 0 and original_sprite.is_pixel_opaque(Vector2(x-(original_image.get_width()/2.0), y-(original_image.get_height()/2.0))):
				image.set_pixel(x, y, Color.RED)
			else:
				image.set_pixel(x, y, original_image.get_pixel(x, y))
			print("x ",x," y ", y, " ", 1-(sqrt(pow(x, 2)+pow(y, 2)))/(sqrt(pow(original_image.get_width(), 2)+pow(original_image.get_height(), 2))))
	sprite.texture = ImageTexture.create_from_image(image)
	sprite.global_position = Vector2(20, 20)
	add_child(sprite)


func _on_rigid_body_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	smash(randi_range(4, 8))
