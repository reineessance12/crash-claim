
extends Area2D

@onready var timer: Timer = $Timer

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	timer.timeout.connect(_on_timer_timeout)

func _on_body_entered(body: Node2D) -> void:
	if body.name.to_lower() == "car":
		print("You died!")
		timer.start()

func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
