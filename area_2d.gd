
extends Area2D

var hit_car: bool = false

func _on_body_entered(body: Node2D) -> void:
	print("Rock touched body: ", body.name)

	if body.name.to_lower() == "car":
		game_over()

func _on_area_entered(area: Area2D) -> void:
	print("Rock touched area: ", area.name)

func game_over() -> void:
	if hit_car:
		return

	hit_car = true
	print("GAME OVER!")
	get_tree().paused = true
