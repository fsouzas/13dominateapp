extends Node

var theme_path := "res://app_themes/themes.json"
var themes: Dictionary = {}
var current_theme: String = "default"
signal theme_changed

func _ready() -> void:
	load_themes()

func load_themes():
	var file = FileAccess.open(theme_path, FileAccess.READ)

	if file == null:
		print("Could not open themes.json")
		return
	
	var json_text = file.get_as_text()

	var json = JSON.new()
	var error = json.parse(json_text)

	if error != OK:
		print("Could not parse themes.json")
		return
	
	themes = json.data

func set_theme(theme_name: String):
	
	if not themes.has(theme_name):
		print("Theme not found: ", theme_name)
		return
	current_theme = theme_name
	theme_changed.emit()

func get_current_theme() -> Dictionary:
	var theme = themes[current_theme].duplicate()
	theme["primary_color"] = Color.html((theme["primary_color"]))
	theme["secondary_color"] = Color.html((theme["secondary_color"]))
	theme["background_image"] = load(theme["background_image"])

	return theme

func get_primary_color() -> Color:
	return get_current_theme()["primary_color"]

func get_secondary_color() -> Color:
	return get_current_theme()["secondary_color"]

func get_background_image() -> Texture2D:
	return get_current_theme()["background_image"]

func get_theme_names() -> Array:
	return themes.keys()

func get_current_theme_name():
	return current_theme
