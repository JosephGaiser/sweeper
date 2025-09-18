class_name GridManager
extends Node

signal player_moved_to_tile(grid_pos: Vector2i)
signal player_left_tile(grid_pos: Vector2i)

@export var grid_width: int = 24
@export var grid_height: int = 24
@export var tile_size: int = 16
@export var tile_scene: PackedScene

@onready var tile_container = %TileContainer

var tiles: Array[Array] = []

func _ready():
	setup_grid()

func setup_grid():
	tiles.resize(grid_height)
	for y in range(grid_height):
		tiles[y] = []
		tiles[y].resize(grid_width)
	create_tiles()

func create_tiles():
	for y in range(grid_height):
		for x in range(grid_width):
			var tile = tile_scene.instantiate()
			tile.position = grid_to_world(Vector2i(x, y))
			tile.grid_position = Vector2i(x, y)
			tile_container.add_child(tile)
			tiles[y][x] = tile

func world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i(int(world_pos.x / tile_size), int(world_pos.y / tile_size))

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(grid_pos.x * tile_size + tile_size/2, grid_pos.y * tile_size + tile_size/2)

func is_valid_grid_position(grid_pos: Vector2i) -> bool:
	return grid_pos.x >= 0 and grid_pos.x < grid_width and \
		   grid_pos.y >= 0 and grid_pos.y < grid_height

func get_tile_at(grid_pos: Vector2i) -> Tile:
	if is_valid_grid_position(grid_pos):
		return tiles[grid_pos.y][grid_pos.x]
	return null

func get_neighbors(grid_pos: Vector2i) -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = []
	var directions = [
		Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),  # Top row
		Vector2i(-1,  0),                  Vector2i(1,  0),  # Middle row
		Vector2i(-1,  1), Vector2i(0,  1), Vector2i(1,  1)   # Bottom row
	]
	
	for dir in directions:
		var neighbor_pos = grid_pos + dir
		if is_valid_grid_position(neighbor_pos):
			neighbors.append(neighbor_pos)
	
	return neighbors

func get_cardinal_neighbors(grid_pos: Vector2i) -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = []
	var directions = [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]  # Up, Right, Down, Left
	
	for dir in directions:
		var neighbor_pos = grid_pos + dir
		if is_valid_grid_position(neighbor_pos):
			neighbors.append(neighbor_pos)
	
	return neighbors

func player_stepped_on_tile(grid_pos: Vector2i):
	player_moved_to_tile.emit(grid_pos)
	var tile = get_tile_at(grid_pos)
	if tile:
		tile.on_player_step()

func player_stepped_off_tile(grid_pos: Vector2i):
	var tile = get_tile_at(grid_pos)
	if tile:
		tile.on_player_leave()
