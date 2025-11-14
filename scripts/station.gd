extends StaticBody2D

var score := 0

func _on_port_area_entered(area: Area2D) -> void:
	if area.get_parent().name == "Gem":
		area.get_parent().queue_free()
		score += 1
		get_node("%Score").text = str(score)+" / 10"
