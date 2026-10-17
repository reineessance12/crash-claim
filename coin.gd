extends Area2D

@onready var pickup_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D
var collected := false

func _ready() -> void:
	add_to_group("collectible")

func _on_body_entered(body: Node2D) -> void:
	if collected or not body.is_in_group("player"):
		return
	collected = true
	set_deferred("monitoring", false)
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimatedSprite2D.hide()
	var games := get_tree().get_nodes_in_group("game")
	if not games.is_empty():
		games[0].call("collect_coin")
	pickup_sound.finished.connect(queue_free, CONNECT_ONE_SHOT)
	pickup_sound.play()
