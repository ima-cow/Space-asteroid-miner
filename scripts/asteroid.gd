extends RigidBody2D

@onready var original_sprite := $Sprite2D
@onready var original_image:Image = original_sprite.texture.get_image()

const SMASH_ANGLE_DEVIATION_START := 14
const SMASH_ANGLE_DEVIATION_RATE := -2

func smash(num_pieces: int):
	var prev_angle := 0.0
	for i in num_pieces:
		var sprite := Sprite2D.new()
		var image := Image.create_empty(original_image.get_width(), original_image.get_height(), original_image.has_mipmaps(), original_image.get_format())
		var cur_angle := 0.0
		if i == num_pieces:
			cur_angle = 360
		else:
			cur_angle = prev_angle + randfn(360/float(num_pieces), SMASH_ANGLE_DEVIATION_START+(SMASH_ANGLE_DEVIATION_RATE*num_pieces))
		for x in original_image.get_width():
			for y in original_image.get_height():
				var angle_of_pixel := atan2(y, x)
				if original_sprite.is_pixel_opaque(Vector2(x, y)) and angle_of_pixel > prev_angle and angle_of_pixel <= cur_angle:
					image.set_pixel(x, y, original_image.get_pixel(x, y))
		prev_angle += cur_angle
		sprite.texture = ImageTexture.create_from_image(image)
		sprite.global_position = Vector2(20*i, 75)
		add_child(sprite)


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("left_click"):
		print(3)
		smash(3)
