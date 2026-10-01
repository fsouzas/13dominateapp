extends Node

var young_heroes: Dictionary = {}
var young_heroes_path = "res://database/young_heros_db.json"
var already_loaded : bool = false
var hero_textures: Dictionary = {}
var hero_name_to_id: Dictionary = {}

signal texture_loading_progress(current: int, total: int)
signal texture_loading_finished

func _ready() -> void:
	young_heroes = load_json_file(young_heroes_path)
	build_hero_name_index()

func normalize_heros_names(heroes: Dictionary):
	for player_id in heroes:
		var hero_id: String = get_hero_id(heroes[player_id]["hero"])
		heroes[player_id]["hero"] = hero_id

func build_hero_name_index():
	for hero_id in young_heroes:
		var hero_names: Dictionary = young_heroes[hero_id]["names"]

		for language in hero_names:
			if hero_names[language].is_empty():
				continue

			hero_name_to_id[hero_names[language]] = hero_id
func load_json_file(filePath : String):
	if FileAccess.file_exists(filePath):
		var dataFile = FileAccess.open(filePath, FileAccess.READ)
		var parsedResult = JSON.parse_string(dataFile.get_as_text())

		if parsedResult is Dictionary:
			print(filePath + " is dictionary")
			return parsedResult
		else:
			print("Not dictionary")
	else:
		print("Cant find file")


func preload_hero_textures() -> void:
	var paths: Array[String] = []
	var path_to_hero: Dictionary = {}


	for hero_id in young_heroes:
		var hero_data: Dictionary = young_heroes[hero_id]

		var background_path: String = hero_data["background"]
		var front_path: String = hero_data["front"]
		var standing_path : String = hero_data["standing"]

		if not ResourceLoader.has_cached(background_path):
			ResourceLoader.load_threaded_request(background_path)

		if not ResourceLoader.has_cached(front_path):
			ResourceLoader.load_threaded_request(front_path)

		if not ResourceLoader.has_cached(standing_path):
			ResourceLoader.load_threaded_request(standing_path)

		paths.append(background_path)
		paths.append(front_path)
		paths.append(standing_path)

		path_to_hero[background_path] = {
			"hero": hero_id,
			"type": "background"
		}

		path_to_hero[front_path] = {
			"hero": hero_id,
			"type": "front"
		}
		path_to_hero[standing_path] = {
			"hero": hero_id,
			"type": "standing"
		}

	var total: int = paths.size()
	var loaded: int = 0

	for path in paths:

		if ResourceLoader.has_cached(path):
			_store_texture(
					path,
					path_to_hero[path]["hero"],
					path_to_hero[path]["type"]
			)

			loaded += 1
			texture_loading_progress.emit(loaded, total)
			continue

		while true:

			var status := ResourceLoader.load_threaded_get_status(path)

			if status == ResourceLoader.THREAD_LOAD_LOADED:
				break

			if status == ResourceLoader.THREAD_LOAD_FAILED:
				push_error("Failed to load hero texture: " + path)
				break

			await get_tree().process_frame

		if ResourceLoader.load_threaded_get_status(path) == \
				ResourceLoader.THREAD_LOAD_LOADED:

			_store_texture(
					path,
					path_to_hero[path]["hero"],
					path_to_hero[path]["type"],
			)

		loaded += 1
		texture_loading_progress.emit(loaded, total)

		await get_tree().process_frame

	texture_loading_finished.emit()


func _store_texture(
		path: String,
		hero_id: String,
		texture_type: String
) -> void:

	if not hero_textures.has(hero_id):
		hero_textures[hero_id] = {}

	var texture := ResourceLoader.load_threaded_get(path) as Texture2D

	hero_textures[hero_id][texture_type] = texture


func get_hero_textures(hero_id: String) -> Dictionary:
	return hero_textures.get(hero_id, {})

func get_heroi_front(hero_id: String) -> Texture2D:
	return _get_heroi_texture(hero_id, "front")

func get_heroi_bg(hero_id: String) -> Texture2D:
	return _get_heroi_texture(hero_id, "background")

func get_heroi_color(hero_id: String) -> Color:
	return Color.from_string(str(young_heroes[hero_id]["color"]), Color.MIDNIGHT_BLUE)

func get_heroi_standing(hero_id: String) -> Texture2D:
	return _get_heroi_texture(hero_id, "standing")

func _get_heroi_texture(hero_id: String, texture_type: String) -> Texture2D:
	if hero_id.is_empty():
		return hero_textures["unknown"][texture_type]
	if not hero_textures.has(hero_id):
		return hero_textures["unknown"][texture_type]
	if not hero_textures[hero_id].has(texture_type):
		return hero_textures["unknown"][texture_type]
	
	var texture: Texture2D = hero_textures[hero_id][texture_type]

	if texture == null:
		return hero_textures["unknown"][texture_type]
	
	return texture

func get_hero_id(hero_name: String) -> String:
	return hero_name_to_id.get(hero_name, "unknown")
	
