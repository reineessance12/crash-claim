extends RigidBody2D

const SPEED := 330.0
const JUMP_FORCE := -520.0

var on_ground := false

func _ready() -> void:
	add_to_group("player")
	lock_rotation = true
	gravity_scale = 1.0
	freeze = false
	sleeping = false
	contact_monitor = true
	max_contacts_reported = 8

func _physics_process(_delta: float) -> void:
	var direction := Input.get_axis("ui_left", "ui_right")
	linear_velocity.x = direction * SPEED
	if Input.is_action_just_pressed("ui_accept") and on_ground:
		linear_velocity.y = JUMP_FORCE
		on_ground = false

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	on_ground = false
	for i in range(state.get_contact_count()):
		if state.get_contact_local_normal(i).y < -0.5:
			on_ground = true
