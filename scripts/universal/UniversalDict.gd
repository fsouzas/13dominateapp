extends Node

var armory_data = {}
var store_name = " "
var mode_selected = " "
var standing_size : int
var locale : String

func _ready() -> void:
	#locale = TranslationServer.get_locale()
	pass

func setArmoryData(armory: Dictionary):
	armory_data = armory

func getArmoryData() -> Dictionary:
	return armory_data


func setStoreName(store: String):
	if store == null:
		store_name = " "
	else:
		store_name = store

func getStoreName():
	pass

func setModeSelected(mode: String):
	if mode == null:
		mode_selected = " "
	else:
		mode_selected = mode

func getModeSelected():
	pass

func setLocale(language: String):
	locale = language
	TranslationServer.set_locale(language)

func getLocale() -> String:
	return locale
