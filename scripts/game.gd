extends Node

var asteroid := preload("res://scenes/asteroid.tscn")
@onready var asteroids := $Asteroids

const ASTEROID_SPAWN_PREVENTION_RADIUS := 15
const STATION_SPAWN_PRENVTION_AREA := Vector2i(50, 50)
var ship_lives := 2
const AMOUNT_TO_GENERATE := 10

func _ready() -> void:
	for i in 5:
		var asteroid_to_generate := _atempt_to_instantiate_asteroid(STATION_SPAWN_PRENVTION_AREA)
		if asteroid_to_generate != null:
			asteroids.add_child(asteroid_to_generate)

var time_out_of_play_area := 0
const MAX_TIME_OUT_OF_PLAY_AREA := 200
func _process(_delta: float) -> void:
	if $Control.visible == true and Input.is_action_just_pressed("left_click"):
		$Control.visible = false
		print("wow")
	
	if ship_lives < 0:
		get_tree().change_scene_to_file("res://scenes/lose_screen.tscn")
	
	var ship_out_of_play_area:bool = %Ship.global_position.x > 175 or %Ship.global_position.x < -175 or %Ship.global_position.y > 100 or %Ship.global_position.y < -100
	if ship_out_of_play_area:
		%LostShip.visible = true
		if time_out_of_play_area > MAX_TIME_OUT_OF_PLAY_AREA:
				%Ship.global_position = Vector2(0, 25)
				%Ship.linear_velocity = Vector2.ZERO
				%Ship.angular_velocity = 0.0
				%Ship.rotation = 0.0
				ship_lives -= 1
				%Lives.text = "Lives: "+str(ship_lives)
		time_out_of_play_area += 1
	else:
		%LostShip.visible = false
		time_out_of_play_area = 0

func _atempt_to_instantiate_asteroid(prevent_within: Vector2i) -> Node2D:
	var asteroid_instance:Node2D = asteroid.instantiate()
	var window_width := get_window().size.x
	var window_heigth := get_window().size.y
	
	for i in 10000:
		@warning_ignore("integer_division")
		var possible_position := Vector2i(randi_range(-window_width/10, window_width/10), randi_range(-window_heigth/10, window_heigth/10))
		var too_close := false
		
		if possible_position.x > prevent_within.x or possible_position.y > prevent_within.y or possible_position.x < -prevent_within.x or possible_position.y < -prevent_within.y:
			for j in asteroids.get_child_count():
				var asteroid_sibling:Node2D = asteroids.get_child(j)
				if asteroid_sibling.global_position.distance_squared_to(possible_position) < ASTEROID_SPAWN_PREVENTION_RADIUS**2:
					too_close = true
					break
			if not too_close:
				asteroid_instance.global_position = possible_position
			break
	
	if asteroid_instance.global_position == Vector2.ZERO:
		return null
	else:
		return asteroid_instance
