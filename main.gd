extends Node2D

const ROCK_SCENE := preload("res://rock.tscn")
const ROCK_HIT_SOUND := preload("res://sounds/crash.mp3")
const FALLING_SOUND := preload("res://sounds/falling.mp3")
const LEVEL_STRETCH_X := 1.10
const LEVEL_STRETCH_Y := 1.30
const LEVEL_START_X := 201.0
const LEVEL_CENTER_Y := 448.0
const FINISH_X := 4010.0

@onready var car: RigidBody2D = $car
@onready var rock_timer: Timer = $rocktimer
@onready var tile_map: TileMap = $TileMap

var score := 0
var ended := false
var total_coins := 0
var score_label: Label
var message_label: Label
var finish_position := Vector2.ZERO
var rock_hit_player: AudioStreamPlayer
var falling_player: AudioStreamPlayer

func _ready() -> void:
	add_to_group("game")
	rock_hit_player = AudioStreamPlayer.new()
	rock_hit_player.name = "RockHitSound"
	rock_hit_player.stream = ROCK_HIT_SOUND
	add_child(rock_hit_player)
	falling_player = AudioStreamPlayer.new()
	falling_player.name = "FallingSound"
	falling_player.stream = FALLING_SOUND
	add_child(falling_player)
	car.gravity_scale = 1.0
	car.freeze = false
	_configure_tile_collisions()
	_stretch_tilemap()
	_stretch_course()
	_build_finish_line()
	total_coins = get_tree().get_nodes_in_group("collectible").size()
	_build_hud()

func _configure_tile_collisions() -> void:
	# The atlas stores walkable terrain in its first three rows. All later rows
	# are scenery and hazards such as trunks, foliage, and props.
	var runtime_tileset := tile_map.tile_set.duplicate(true) as TileSet
	tile_map.tile_set = runtime_tileset
	runtime_tileset.set_physics_layer_collision_layer(0, 1)
	var atlas := runtime_tileset.get_source(0) as TileSetAtlasSource
	var processed_tiles: Dictionary = {}
	for layer in range(tile_map.get_layers_count()):
		for cell in tile_map.get_used_cells(layer):
			if tile_map.get_cell_source_id(layer, cell) != 0:
				continue
			var tile_id := tile_map.get_cell_atlas_coords(layer, cell)
			if tile_id.y < 3 or processed_tiles.has(tile_id):
				continue
			processed_tiles[tile_id] = true
			var data := atlas.get_tile_data(tile_id, tile_map.get_cell_alternative_tile(layer, cell))
			if data != null:
				data.set_collision_polygons_count(0, 0)

func _build_hud() -> void:
	var hud := CanvasLayer.new()
	add_child(hud)
	score_label = Label.new()
	score_label.position = Vector2(20, 16)
	score_label.add_theme_font_size_override("font_size", 26)
	score_label.text = "Coins: 0 / %d" % total_coins
	hud.add_child(score_label)
	var controls := Label.new()
	controls.position = Vector2(20, 50)
	controls.text = "Move: ← / →   Jump: Space"
	controls.add_theme_font_size_override("font_size", 16)
	hud.add_child(controls)
	message_label = Label.new()
	message_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.add_theme_font_size_override("font_size", 32)
	message_label.add_theme_color_override("font_color", Color.WHITE)
	message_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	message_label.add_theme_constant_override("shadow_offset_x", 2)
	message_label.add_theme_constant_override("shadow_offset_y", 2)
	message_label.hide()
	hud.add_child(message_label)

func collect_coin() -> void:
	if ended:
		return
	score += 1
	score_label.text = "Coins: %d / %d" % [score, total_coins]

func game_over() -> void:
	_end_run("GAME OVER")

func play_rock_hit_sound() -> void:
	if rock_hit_player != null:
		rock_hit_player.play()

func play_falling_sound() -> void:
	if falling_player != null:
		falling_player.play()

func level_complete() -> void:
	if score >= total_coins:
		_end_run("PERFECT RUN!\nALL COINS COLLECTED!")
	else:
		_end_run("LEVEL COMPLETE!")

func _end_run(title: String) -> void:
	if ended:
		return
	ended = true
	car.freeze = true
	rock_timer.stop()
	for hazard in get_tree().get_nodes_in_group("hazards"):
		hazard.queue_free()
	message_label.text = "%s\nCoins: %d / %d\nPress Enter to play again" % [title, score, total_coins]
	message_label.show()

func _unhandled_input(event: InputEvent) -> void:
	if ended and event.is_action_pressed("ui_accept"):
		get_tree().reload_current_scene()

func _on_rocktimer_timeout() -> void:
	if ended:
		return
	var rock := ROCK_SCENE.instantiate()
	var camera := car.get_node("Camera2D") as Camera2D
	rock.position = Vector2(camera.global_position.x + randf_range(160.0, 360.0), camera.global_position.y - 230.0)
	add_child(rock)
	rock_timer.start(randf_range(1.6, 2.6))

func _stretch_course() -> void:
	for node in get_children():
		var node_name := str(node.name)
		if node is Node2D and (node_name.begins_with("platform") or node_name.begins_with("platfrom")):
			var platform_node := node as Node2D
			platform_node.position = _stretch_point(platform_node.position)
	for coin_node in $coins.get_children():
		var coin := coin_node as Node2D
		coin.position = _stretch_point(coin.position)
	finish_position = _stretch_point(Vector2(FINISH_X, 560.0))
	var killzone := $killzone as Node2D
	killzone.position = _stretch_point(killzone.position)
	killzone.scale *= Vector2(LEVEL_STRETCH_X, LEVEL_STRETCH_Y)

func _stretch_tilemap() -> void:
	var pivot := Vector2(LEVEL_START_X, LEVEL_CENTER_Y)
	var stretch := Vector2(LEVEL_STRETCH_X, LEVEL_STRETCH_Y)
	tile_map.position = pivot + (tile_map.position - pivot) * stretch
	tile_map.scale *= stretch

func _stretch_point(point: Vector2) -> Vector2:
	return Vector2(
		LEVEL_START_X + (point.x - LEVEL_START_X) * LEVEL_STRETCH_X,
		LEVEL_CENTER_Y + (point.y - LEVEL_CENTER_Y) * LEVEL_STRETCH_Y
	)

func _build_finish_line() -> void:
	var finish := Area2D.new()
	finish.name = "FinishLine"
	finish.position = finish_position
	finish.collision_layer = 0
	finish.collision_mask = 2
	var shape := RectangleShape2D.new()
	shape.size = Vector2(48.0, 300.0)
	var collision := CollisionShape2D.new()
	collision.shape = shape
	finish.add_child(collision)
	finish.body_entered.connect(_on_finish_body_entered)
	add_child(finish)
	var sign := Label.new()
	sign.text = "FINISH"
	sign.position = Vector2(-34.0, -170.0)
	sign.add_theme_font_size_override("font_size", 24)
	finish.add_child(sign)

func _on_finish_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		level_complete()
