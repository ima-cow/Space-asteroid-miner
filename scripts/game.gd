extends Node

var asteroid := [preload("res://scenes/asteriods/asteroid_1.tscn"), preload("res://scenes/asteriods/asteroid_2.tscn"), preload("res://scenes/asteriods/asteroid_3.tscn"), preload("res://scenes/asteriods/asteroid_4.tscn"), preload("res://scenes/asteriods/asteroid_4.tscn"), preload("res://scenes/asteriods/asteroid_5.tscn"), preload("res://scenes/asteriods/asteroid_6.tscn")]
@onready var asteroids := $Asteroids
@onready var time_left:SceneTreeTimer

const ASTEROID_SPAWN_PREVENTION_RADIUS := 22
const STATION_SPAWN_PRENVTION_AREA := Vector2i(35, 35)
const AMOUNT_TO_GENERATE := 30
const TIME_ALLOWED := 60
const MAX_TIME_OUT_OF_PLAY_AREA := 150

var ship_lives := 2
var score := 0
var asteriods_left := 0
#var first_round := true

func _ready() -> void:
	for i in AMOUNT_TO_GENERATE:
		var asteroid_to_generate := _atempt_to_instantiate_asteroid(STATION_SPAWN_PRENVTION_AREA)
		if asteroid_to_generate != null:
			asteroids.add_child(asteroid_to_generate)


var time_out_of_play_area := 0
func _process(delta: float) -> void:
	if ship_lives < 0:
		$LoseScreen.visible = true
	if asteriods_left <= 0:
		$WinScreen.visible = true
		$WinScreen/CenterContainer/VBoxContainer/Label.text = "All asteroids\ncollected!\nScore: "+str(score)
	
	if time_left != null:
		$TimeLeft/CenterContainer/Time.text = str(roundi(time_left.time_left))
	
	var ship_out_of_play_area:bool = %Ship.global_position.x > 175 or %Ship.global_position.x < -175 or %Ship.global_position.y > 100 or %Ship.global_position.y < -100
	if ship_out_of_play_area:
		%LostShip.visible = true
		if time_out_of_play_area*delta > MAX_TIME_OUT_OF_PLAY_AREA:
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
		
	for asteroid_instance in $Asteroids.get_children():
		if asteroid_instance is Node2D and asteroid_instance.has_meta("broken") and !asteroid_instance.get_meta("broken"):
			var asteroid_instance_body = asteroid_instance.get_child(0) 
			if asteroid_instance_body is RigidBody2D:
				var asteroid_out_of_play_area:bool = asteroid_instance_body.global_position.x > 175 or asteroid_instance_body.global_position.x < -175 or asteroid_instance_body.global_position.y > 100 or asteroid_instance_body.global_position.y < -100
				if asteroid_out_of_play_area:
					asteriods_left -= 1
					asteroid_instance.queue_free()

func _on_port_area_entered(area: Area2D) -> void:
	if area.get_parent().name == "Gem":
		area.get_parent().queue_free()
		asteriods_left -= 1
		score += 1
		get_node("%Score").text = "Score: "+str(score)+""
		#if score >= 5:
			#$WinScreen.visible = true
			#$WinScreen/CenterContainer/Label.text = "You survived! \n Score: "+str(score)

func _atempt_to_instantiate_asteroid(prevent_within: Vector2i) -> Node2D:
	var asteroid_instance:Node2D = asteroid[randi_range(0, asteroid.size()-1)].instantiate()
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
		asteriods_left += 1
		return asteroid_instance


func _on_reset_button_pressed() -> void:
	get_tree().reload_current_scene()
	#print(first_round)
	#first_round = false


func _on_start_button_pressed() -> void:
	$Control.visible = false
	
	time_left = get_tree().create_timer(TIME_ALLOWED)
	await time_left.timeout
	
	$WinScreen.visible = true
	$WinScreen/CenterContainer/VBoxContainer/Label.text = "You survived! \n Score: "+str(score)
	set_process(false)
	set_physics_process(false)
