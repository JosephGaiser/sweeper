class_name Tile
extends Node2D

signal tile_revealed(grid_pos: Vector2i)
signal tile_flagged(grid_pos: Vector2i)

enum TileState {
	HIDDEN,
	REVEALED,
	FLAGGED,
	EXPLODED
}

@export var grid_position: Vector2i
@export var tile_size: int = 16
@export var hover_lift_distance: float = 8.0
@export var hover_tilt_angle: float = 5.0
@export var hover_scale_factor: float = 1.05
@export var hover_duration: float = 0.2

var state: TileState = TileState.HIDDEN
var has_mine: bool = false
var has_player: bool = false
var adjacent_mines: int = 0

# Store original transform values
var original_position: Vector2
var original_rotation: float
var original_scale: Vector2
var is_hovering: bool = false

# Visual components
@onready var background_sprite: Sprite2D = %Background
@onready var content_sprite: Sprite2D = %Content
@onready var flag_sprite: Sprite2D = %Flag
@onready var player_indicator: Sprite2D = %PlayerIndicator
@onready var mine: Sprite2D = %Mine
@onready var adjacent_mines_label: Label = %AdjacentMinesLabel

# Tween for smooth animations
var hover_tween: Tween

func _ready():
	# Store original transform values
	original_position = position
	original_rotation = rotation
	original_scale = scale
	
	# Create tween for hover animations
	hover_tween = create_tween()
	hover_tween.kill() # Stop it initially

func set_mine(is_mine: bool):
	has_mine = is_mine

func set_adjacent_mines(count: int):
	adjacent_mines = count

func reveal() -> bool:
	if state == TileState.FLAGGED or state == TileState.REVEALED:
		return false
	
	# Reset hover effect when revealed
	if is_hovering:
		_exit_hover_effect()
	
	state = TileState.REVEALED
	content_sprite.visible = true
	
	if has_mine:
		state = TileState.EXPLODED
		show_mine()
		# TODO explosion animation
	else:
		show_number()
	
	tile_revealed.emit(grid_position)
	return true

func reset() -> bool:	
	if is_flagged():
		toggle_flag()
	
	# Reset hover effect
	if is_hovering:
		_exit_hover_effect()
		
	state = TileState.HIDDEN
	set_mine(false)
	set_adjacent_mines(0)
	hide_content()
	obscure_number()
	
	return true

func toggle_flag():
	if state == TileState.REVEALED:
		return
	
	if state == TileState.FLAGGED:
		state = TileState.HIDDEN
		flag_sprite.visible = false
	else:
		state = TileState.FLAGGED
		flag_sprite.visible = true
	
	tile_flagged.emit(grid_position)

func hide_content():
	content_sprite.texture = null

func show_mine():
	content_sprite.texture = mine.texture

func show_number():
	if adjacent_mines == 0:
		pass
	adjacent_mines_label.text = str(adjacent_mines)

func obscure_number():
	adjacent_mines_label.text = ""

func on_player_step():
	has_player = true

func on_player_leave():
	has_player = false

func is_revealed() -> bool:
	return state == TileState.REVEALED

func is_flagged() -> bool:
	return state == TileState.FLAGGED

func is_mine() -> bool:
	return has_mine

func _enter_hover_effect():
	if is_hovering or state == TileState.REVEALED:
		return
		
	is_hovering = true
	
	# Kill any existing tween
	if hover_tween:
		hover_tween.kill()
	
	hover_tween = create_tween()
	hover_tween.set_parallel(true)  # Allow multiple properties to animate simultaneously
	hover_tween.set_ease(Tween.EASE_OUT)
	hover_tween.set_trans(Tween.TRANS_BACK)
	
	# Lift the tile up with subtle parallax
	var target_pos = original_position + Vector2(
		randf_range(-2.0, 2.0),  # Slight random horizontal offset
		-hover_lift_distance
	)
	hover_tween.tween_property(self, "position", target_pos, hover_duration)
	
	# Add subtle tilt
	var target_rotation = original_rotation + deg_to_rad(randf_range(-hover_tilt_angle, hover_tilt_angle))
	hover_tween.tween_property(self, "rotation", target_rotation, hover_duration)
	
	# Slight scale increase
	var target_scale = original_scale * hover_scale_factor
	hover_tween.tween_property(self, "scale", target_scale, hover_duration)

func _exit_hover_effect():
	if not is_hovering:
		return
		
	is_hovering = false
	
	# Kill any existing tween
	if hover_tween:
		hover_tween.kill()
	
	hover_tween = create_tween()
	hover_tween.set_parallel(true)
	hover_tween.set_ease(Tween.EASE_OUT)
	hover_tween.set_trans(Tween.TRANS_QUART)
	
	# Return to original transform
	hover_tween.tween_property(self, "position", original_position, hover_duration * 0.8)
	hover_tween.tween_property(self, "rotation", original_rotation, hover_duration * 0.8)
	hover_tween.tween_property(self, "scale", original_scale, hover_duration * 0.8)

func _on_hover_area_2d_mouse_entered():
	if !has_player:
		_enter_hover_effect()

func _on_hover_area_2d_mouse_exited():
	_exit_hover_effect()