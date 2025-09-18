class_name UI
extends Control

@onready var shop_button: Button = %ShopButton
@onready var shop = %Shop

@onready var tile_revealed_label: Label = %TileRevealedLabel
@onready var flags_placed_label: Label = %FlagsPlacedLabel


	
func set_tile_revealed_label(count: String):
	tile_revealed_label.text = "TILES: " + count
	
func set_flags_placed_label(count: String):
	flags_placed_label.text = "FLAGS: " + count


func _on_shop_button_pressed():
	$Shop.visible = !$Shop.visible
