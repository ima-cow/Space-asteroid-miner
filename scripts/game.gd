extends Node

var asteroid := preload("res://scenes/asteroid.tscn")
@onready var asteroids := $Asteroids

const ASTEROID_SPAWN_PREVENTION_RADIUS := 25
const STATION_SPAWN_PRENVTION_AREA := Vector2i(50, 50)

func _ready() -> void:
	for i in 12:
		var asteroid_to_generate := _atempt_to_instantiate_asteroid(STATION_SPAWN_PRENVTION_AREA)
		if asteroid_to_generate != null:
			asteroids.add_child(asteroid_to_generate)

func _atempt_to_instantiate_asteroid(prevent_within: Vector2i) -> Node2D:
	var asteroid_instance:Node2D = asteroid.instantiate()
	var window_width := get_window().size.x
	var window_heigth := get_window().size.y
	
	for i in 1200:
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
