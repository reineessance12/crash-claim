
extends Node2D

@onready var car: RigidBody2D = $car
@onready var ground: StaticBody2D = $Ground

func _ready() -> void:
	car.gravity_scale = 1.0
	car.freeze = false
