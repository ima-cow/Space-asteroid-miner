extends Node

var asteroid := preload("res://scenes/asteroid.tscn")
@onready var asteroids := $Asteroids

func _ready() -> void:
	_generate_asteroids(4)

func _generate_asteroids(amount: int) -> void:
	for i in amount:
		asteroids.add_child(_atempt_to_instantiate_asteroid(Vector2i(50, 50)))

func _atempt_to_instantiate_asteroid(prevent_within: Vector2i) -> Node2D:
	var asteroid_instance:Node2D = asteroid.instantiate()
	var window_width := get_window().size.x
	var window_heigth := get_window().size.y
	
	for i in 3:
		var possible_position := Vector2i(randi_range(-window_width/8, window_width/8), randi_range(-window_heigth/8, window_heigth/8))
		if possible_position > prevent_within and possible_position < -prevent_within:
			asteroid_instance.global_position = possible_position
			break
	return asteroid_instance
