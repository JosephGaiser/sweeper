class_name Player
extends Area2D

signal player_action_reveal(grid_pos: Vector2i)
signal player_action_flag(grid_pos: Vector2i)

@export var move_duration: float = 0.4  # How long the tween takes
@export var starting_grid_pos: Vector2i = Vector2i(0, 0)
@export var action_range: int = 1

@export_group("Stats")
@export var vitality: int = 3
@export var stamina: int = 5
@export var dexterity: int = 1
@export var intelligence: int = 1
@export var faith: int = 1


var previous_grid_position: Vector2i
var grid_position: Vector2i
var target_world_position: Vector2
var is_moving: bool = false
var grid_manager: GridManager
var game_manager: GameManager
var move_tween: Tween
var ui: UI

func _ready():
	ui = get_tree().get_first_node_in_group("UI")
	await ui.ready
	ui.set_vitality_label(str(vitality))
	ui.set_stamina_label(str(stamina))
	
	grid_manager = get_tree().get_first_node_in_group("GridManager")
	game_manager = get_tree().get_first_node_in_group("GameManager")
	
	set_grid_position(starting_grid_pos)
	grid_manager.player_stepped_on_tile(starting_grid_pos)

func _input(event):
	if game_manager.current_state != GameManager.GameState.PLAYING:
		return # Don't accept input while not playing

	if is_moving:
		return  # Don't accept input while moving
	
	var input_direction = Vector2i(Input.get_vector("move_left", "move_right", "move_up", "move_down"))
	if input_direction != Vector2i.ZERO and !is_moving:
		attempt_move(input_direction)
	
	# Action input
	if event.is_action_pressed("reveal_tile"):
		reveal_current_tile()
	elif event.is_action_pressed("flag_tile"):
		flag_current_tile()

func attempt_move(direction: Vector2i):
	var new_grid_pos = grid_position + direction
	if grid_manager.is_valid_grid_position(new_grid_pos) and stamina > 0:
		move_to_grid_position(new_grid_pos)

func move_to_grid_position(new_grid_pos: Vector2i):
	if is_moving:
		return  # Prevent multiple moves at once
	
	stamina -= 1 # Spend 1 stamina to move
	print("remaining stamina", stamina)
	ui.set_stamina_label(str(stamina))

	previous_grid_position = grid_position
	grid_position = new_grid_pos
	target_world_position = grid_manager.grid_to_world(new_grid_pos)
	is_moving = true
	
	if move_tween:
		move_tween.kill()
	
	move_tween = create_tween()
	move_tween.set_ease(Tween.EASE_OUT)
	move_tween.set_trans(Tween.TRANS_BACK)  # This creates the bouncy "snap" effect
	
	move_tween.tween_property(self, "position", target_world_position, move_duration)
	
	move_tween.finished.connect(on_movement_complete, CONNECT_ONE_SHOT)

func set_grid_position(new_grid_pos: Vector2i):
	previous_grid_position = grid_position
	grid_position = new_grid_pos
	position = grid_manager.grid_to_world(grid_position)
	target_world_position = position

func on_movement_complete():
	is_moving = false
	grid_manager.player_stepped_on_tile(grid_position)
	grid_manager.player_stepped_off_tile(previous_grid_position)
	# TODO add other completion effects here

func reveal_current_tile():
	var target_position = grid_manager.world_to_grid(get_global_mouse_position())
	if grid_manager.get_chebyshev_distance(target_position, grid_position) > action_range:
		return
	if !grid_manager.is_valid_grid_position(target_position):
		return
	print("reveal: ", target_position)
	player_action_reveal.emit(target_position)

func flag_current_tile():
	var target_position = grid_manager.world_to_grid(get_global_mouse_position())
	if !grid_manager.is_valid_grid_position(target_position):
		return
	print("flag: ", target_position)
	player_action_flag.emit(target_position)

func get_current_grid_position() -> Vector2i:
	return grid_position
