
extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var games := get_tree().get_nodes_in_group("game")
		if not games.is_empty():
			games[0].call("play_falling_sound")
			games[0].call("game_over")
