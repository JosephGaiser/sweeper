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

var state: TileState = TileState.HIDDEN
var has_mine: bool = false
var adjacent_mines: int = 0
var has_player: bool = false

# Visual components
@onready var background_sprite: Sprite2D = %Background
@onready var content_sprite: Sprite2D = %Content
@onready var flag_sprite: Sprite2D = %Flag
@onready var player_indicator: Sprite2D = %PlayerIndicator
@onready var mine: Sprite2D = %Mine
@onready var adjacent_mines_label: Label = %AdjacentMinesLabel

func _ready():
	pass

func set_mine(is_mine: bool):
	has_mine = is_mine

func set_adjacent_mines(count: int):
	adjacent_mines = count

func reveal() -> bool:
	if state == TileState.FLAGGED or state == TileState.REVEALED:
		return false
	
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

func toggle_flag():
	print("flagging ", self)
	if state == TileState.REVEALED:
		return
	
	# un-flag logic
	if state == TileState.FLAGGED:
		state = TileState.HIDDEN
		flag_sprite.visible = false
	else:
		state = TileState.FLAGGED
		flag_sprite.visible = true
	
	tile_flagged.emit(grid_position)

func show_mine():
	content_sprite.texture = mine.texture

func show_number():
	if adjacent_mines == 0:
		pass
	adjacent_mines_label.text = str(adjacent_mines)

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


func _on_hover_area_2d_mouse_entered():
	if !has_player:
		%PlayerIndicator.visible = true


func _on_hover_area_2d_mouse_exited():
	%PlayerIndicator.visible = false
	
