class_name GameManager
extends Node

signal game_over
signal game_reset
signal game_won

enum GameState {
	PLAYING,
	WON,
	LOST,
	PAUSED
}

@export var mine_count: int = 3
@export var player: Player
@export var grid_manager: GridManager
@export var ui: UI

var current_state: GameState = GameState.PLAYING
var tiles_revealed: int = 0
var flags_placed: int = 0

func _ready():
	setup_game()

func setup_game():
	connect_signals()
	
	# Initialize the game
	await get_tree().process_frame  # Wait for everything to be ready
	initialize_minesweeper()

func connect_signals():
	grid_manager.player_moved_to_tile.connect(_on_player_moved_to_tile)
	grid_manager.player_left_tile.connect(_on_player_left_tile)
	player.player_action_reveal.connect(_on_player_action_reveal)
	player.player_action_flag.connect(_on_player_action_flag)

func initialize_minesweeper():
	place_mines()
	calculate_adjacent_mines()

func place_mines():
	var total_tiles = grid_manager.grid_width * grid_manager.grid_height
	var mine_positions: Array[Vector2i] = []
	
	# Make sure we don't place more mines than tiles
	var actual_mine_count = min(mine_count, total_tiles - 1)
	
	# Get player starting position to avoid placing mine there
	var player_start = player.get_current_grid_position()
	
	# Randomly select mine positions
	while mine_positions.size() < actual_mine_count:
		var x = randi() % grid_manager.grid_width
		var y = randi() % grid_manager.grid_height
		var pos = Vector2i(x, y)
		
		# Don't place mine on player start or if already selected
		if pos != player_start and not mine_positions.has(pos):
			mine_positions.append(pos)
	
	# Place mines on tiles
	for pos in mine_positions:
		var tile = grid_manager.get_tile_at(pos)
		if tile:
			tile.set_mine(true)

func calculate_adjacent_mines():
	for y in range(grid_manager.grid_height):
		for x in range(grid_manager.grid_width):
			var pos = Vector2i(x, y)
			var tile = grid_manager.get_tile_at(pos)
			
			if tile and not tile.is_mine():
				var mine_count = 0
				var neighbors = grid_manager.get_neighbors(pos)
				
				for neighbor_pos in neighbors:
					var neighbor_tile = grid_manager.get_tile_at(neighbor_pos)
					if neighbor_tile and neighbor_tile.is_mine():
						mine_count += 1
				
				tile.set_adjacent_mines(mine_count)

func _on_player_moved_to_tile(grid_pos: Vector2i):
	print("Player moved to: ", grid_pos)

func _on_player_left_tile(grid_pos: Vector2i):
	pass

func _on_player_action_reveal(grid_pos: Vector2i):
	if current_state != GameState.PLAYING:
		return
	
	var tile = grid_manager.get_tile_at(grid_pos)
	if not tile:
		return
	
	if tile.reveal():
		tiles_revealed += 1
		ui.set_tile_revealed_label(str(tiles_revealed))
		
		if tile.is_mine():
			trigger_game_over(false)  # Player hit a mine
		else:
			# If it's an empty tile (0 adjacent mines), reveal neighbors
			if tile.adjacent_mines == 0:
				reveal_empty_area(grid_pos)
			
			check_win_condition()

func _on_player_action_flag(grid_pos: Vector2i):
	if current_state != GameState.PLAYING:
		return
	
	var tile = grid_manager.get_tile_at(grid_pos)
	if tile:
		var was_flagged = tile.is_flagged()
		tile.toggle_flag()
		
		if tile.is_flagged() and not was_flagged:
			flags_placed += 1
		elif not tile.is_flagged() and was_flagged:
			flags_placed -= 1
		ui.set_flags_placed_label(str(flags_placed))
		

func reveal_empty_area(start_pos: Vector2i):
	# Flood fill algorithm to reveal connected empty tiles
	var to_check: Array[Vector2i] = [start_pos]
	var checked: Array[Vector2i] = []
	
	while to_check.size() > 0:
		var current_pos = to_check.pop_front()
		
		if checked.has(current_pos):
			continue
		
		checked.append(current_pos)
		var neighbors = grid_manager.get_neighbors(current_pos)
		
		for neighbor_pos in neighbors:
			var neighbor_tile = grid_manager.get_tile_at(neighbor_pos)
			
			if neighbor_tile and not neighbor_tile.is_revealed() and not neighbor_tile.is_flagged():
				if neighbor_tile.reveal():
					tiles_revealed += 1
				
				# If neighbor is also empty, add it to check list
				if neighbor_tile.adjacent_mines == 0:
					to_check.append(neighbor_pos)

func check_win_condition():
	var total_tiles = grid_manager.grid_width * grid_manager.grid_height
	var total_safe_tiles = total_tiles - mine_count
	
	if tiles_revealed >= total_safe_tiles:
		trigger_game_over(true)  # Player won

func trigger_game_over(won: bool):
	if won:
		current_state = GameState.WON
		print("Congratulations! You won!")
		game_won.emit()
	else:
		current_state = GameState.LOST
		print("Game Over! You hit a mine!")
		reveal_all_mines()
		game_over.emit()

func reveal_all_mines():
	for y in range(grid_manager.grid_height):
		for x in range(grid_manager.grid_width):
			var tile = grid_manager.get_tile_at(Vector2i(x, y))
			if tile and tile.is_mine():
				tile.reveal()

func restart_game():
	# Reset game state
	current_state = GameState.PLAYING
	tiles_revealed = 0
	flags_placed = 0
	
	# Reset all tiles
	for y in range(grid_manager.grid_height):
		for x in range(grid_manager.grid_width):
			var tile: Tile = grid_manager.get_tile_at(Vector2i(x, y))
			if tile:
				tile.reset()
	
	# Reinitialize
	initialize_minesweeper()
	
	# Reset player position
	player.set_grid_position(player.starting_grid_pos)
	game_reset.emit()
