extends Node

var armory_data = {}
var store_name = " "
var mode_selected = " "
var standing_size : int
var main_color : Color = Color.html("bd0000")
var locale

func _ready() -> void:
	locale = TranslationServer.get_locale().left(2)

func setArmoryData(armory: Dictionary):
	armory_data = armory

func getArmoryData():
	pass

func setStoreName(store: String):
	if store == null:
		store_name = " "
	else:
		store_name = store

func getStoreName(_store: String):
	pass

func setModeSelected(mode: String):
	if mode == null:
		mode_selected = " "
	else:
		mode_selected = mode

func getModeSelected():
	pass

func setLocale(language: String):
	locale =  language
	TranslationServer.set_locale(language)

func getLocale():
	pass

