
extends Area2D

const FALL_GRAVITY := 980.0
var fall_speed := 0.0

func _ready() -> void:
	add_to_group("hazards")
	body_entered.connect(_on_body_entered)
	collision_layer = 0
	collision_mask = 3

func _physics_process(delta: float) -> void:
	fall_speed = minf(fall_speed + FALL_GRAVITY * delta, 900.0)
	position.y += fall_speed * delta
	if position.y > 1100.0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var games := get_tree().get_nodes_in_group("game")
		if not games.is_empty():
			games[0].call("play_rock_hit_sound")
			games[0].call("game_over")
		queue_free()
