class_name UI
extends Control

# PANELS
@onready var shop_button: Button = %ShopButton
@onready var shop_panel: Panel = %ShopPanel
@onready var game_over_panel: PanelContainer = %GameOverPanel
@onready var game_win_panel: PanelContainer = %GameWinPanel

# GAME STATS
@onready var tile_revealed_label: Label = %TileRevealedLabel
@onready var flags_placed_label: Label = %FlagsPlacedLabel

# PLAYER STATS
@onready var vitality_label: Label = %VitalityLabel
@onready var stamina_label: Label = %StaminaLabel

var game_manager: GameManager

func _ready():
	game_manager = get_tree().get_first_node_in_group("GameManager")

func set_tile_revealed_label(value: String):
	if tile_revealed_label:
		tile_revealed_label.text = "TILES: " + value
	
func set_flags_placed_label(value: String):
	if flags_placed_label:
		flags_placed_label.text = "FLAGS: " + value
	
func set_vitality_label(value: String):
	if vitality_label:
		vitality_label.text = "VITALITY: " + value

func set_stamina_label(value: String):
	if stamina_label:
		stamina_label.text = "STAMINA: " + value
	
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
