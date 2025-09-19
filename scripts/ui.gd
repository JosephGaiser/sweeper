class_name UI
extends Control

@onready var shop_button: Button = %ShopButton
@onready var shop_panel = %ShopPanel
@onready var game_over_panel: PanelContainer = %GameOverPanel
@onready var game_win_panel: PanelContainer = %GameWinPanel

@onready var tile_revealed_label: Label = %TileRevealedLabel
@onready var flags_placed_label: Label = %FlagsPlacedLabel

var game_manager: GameManager

func _ready():
	game_manager = get_tree().get_first_node_in_group("GameManager")
	if !game_manager:
		print("No game manger uh oh")

	
func set_tile_revealed_label(count: String):
	tile_revealed_label.text = "TILES: " + count
	
func set_flags_placed_label(count: String):
	flags_placed_label.text = "FLAGS: " + count


func _on_shop_button_pressed():
	shop_panel.visible = !shop_panel.visible


func _on_reset_button_pressed():
	game_manager.restart_game()
	
func _on_game_manager_game_won():
	game_win_panel.show()

func _on_game_manager_game_over():
	game_over_panel.show()

func _on_game_manager_game_reset():
	game_over_panel.hide()
	game_win_panel.hide()
	shop_panel.hide()