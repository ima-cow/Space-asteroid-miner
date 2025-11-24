extends Node2D

@onready var original_asteriod:RigidBody2D = $RigidBody
@onready var original_sprite:Sprite2D = $RigidBody/Sprite2D
@onready var original_image:Image 
@onready var ship:RigidBody2D = $"../../Ship"

var textures:Array[Texture2D] = [preload("res://assets/asteroid_1.png"), preload("res://assets/asteroid_2.png"), preload("res://assets/asteroid_3.png")]

const SMASH_ANGLE_DEVIATION_START := 24
const SMASH_ANGLE_DEVIATION_RATE := -2

var edge_points:Array[Vector2i]
var edge_point_angles:Array[float]

func _ready() -> void:
	var rand_texture = textures[randi_range(0, textures.size()-1)]
	original_sprite.texture = rand_texture
	original_image = rand_texture.get_image()
	#rotation_degrees = randi_range(0, 360)

var prev_velocity := Vector2.ZERO
func _physics_process(_delta: float) -> void:
	if original_asteriod == null:
		return
	
	if abs(original_asteriod.linear_velocity - prev_velocity).x > 30 or abs(original_asteriod.linear_velocity - prev_velocity).y > 30:
		%Gem.reparent(self)
		smash(randi_range(5, 8))
	prev_velocity = original_asteriod.linear_velocity

func smash(num_pieces: int) -> void:
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
		asteroid_chunk.mass = _generate_chunk_mass(prev_angle, cur_angle)
		asteroid_chunk.global_position = original_asteriod.position
	
		add_child(asteroid_chunk)
		prev_angle = cur_angle
	
	original_asteriod.queue_free()

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
	
	var radius := 0.0
	
	polygon.append(Vector2(radius*cos(deg_to_rad(prev_angle)), radius*sin(deg_to_rad(prev_angle))))
	polygon.append(Vector2(radius*cos(deg_to_rad(cur_angle)), radius*sin(deg_to_rad(cur_angle))))
	polygon.append(Vector2(0, 0))
	
	collider.set_polygon(polygon)
	
	return collider

func _get_edge_points() -> void:
	for x in original_image.get_width():
		for y in original_image.get_height():
			if original_image.get_pixel(x, y).a != 0 and (x == original_image.get_width()-1 or y == original_image.get_height()-1 or x == 0 or y == 0):
				edge_points.append(Vector2i(x, y))
			elif original_image.get_pixel(x, y).a != 0 and original_image.get_pixel(x+1, y).a == 0:
				edge_points.append(Vector2i(x, y))
			elif original_image.get_pixel(x, y).a != 0 and original_image.get_pixel(x-1, y).a == 0:
				edge_points.append(Vector2i(x, y))
			elif original_image.get_pixel(x, y).a != 0 and original_image.get_pixel(x, y+1).a == 0:
				edge_points.append(Vector2i(x, y))
			elif original_image.get_pixel(x, y).a != 0 and original_image.get_pixel(x, y-1).a == 0:
				edge_points.append(Vector2i(x, y))
	
	for vec in edge_points:
		var cords_in_original := Vector2(vec.x-(original_image.get_width()/2.0), vec.y-(original_image.get_width()/2.0))
		var angle_of_pixel := rad_to_deg(atan2(cords_in_original.y, cords_in_original.x))
		print(vec," : ",angle_of_pixel+180)
	
	#print("exec")

func _generate_chunk_mass(prev_angle: float, cur_angle:float) -> float:
	var radius := -sqrt(pow(original_image.get_width()/2.8, 2)+pow(original_image.get_height()/2.8, 2))
	var area := PI*pow(radius, 2)
	var arc := cur_angle-prev_angle
	var area_under_arc := (arc/360)*area
	
	return area_under_arc/area

func _on_rigid_body_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		_get_edge_points()

#func test():
	#var prev_angle := 0.0
	#var num_pieces := 5
	#
	#for i in num_pieces:
		#var poly := Polygon2D.new()
		#
		#var cur_angle:float
		#if i == num_pieces-1:
			#cur_angle = 360.0
		#else:
			#cur_angle = prev_angle + randfn(360.0/num_pieces, SMASH_ANGLE_DEVIATION_START+SMASH_ANGLE_DEVIATION_RATE*num_pieces)
		#
		#var polygon: PackedVector2Array
		#var radius := -sqrt(pow(original_image.get_width()/2.8, 2)+pow(original_image.get_height()/2.8, 2))
		#
		#polygon.append(Vector2(radius*cos(deg_to_rad(prev_angle)), radius*sin(deg_to_rad(prev_angle))))
		#polygon.append(Vector2(radius*cos(deg_to_rad(cur_angle)), radius*sin(deg_to_rad(cur_angle))))
		#polygon.append(Vector2(0, 0))
		#
		#poly.set_polygon(polygon)
		#poly.color = Color(randf(), randf(), randf())
		#add_child(poly)
