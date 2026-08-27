extends Node

var armory_data = {}
var store_name
var mode_selected
var standing_size : int
var main_color : Color = Color.html("bd0000")
var locale

func _ready() -> void:
	locale = TranslationServer.get_locale().left(2)
