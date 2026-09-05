extends Node

var young_heroes
var young_heroes_path = "res://database/young_heros_db.json"
var already_loaded : bool = false
var hero_textures: Dictionary = {}

signal texture_loading_progress(current: int, total: int)
signal texture_loading_finished

func _ready() -> void:
	young_heroes = load_json_file(young_heroes_path)

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


	for hero_name in young_heroes:
		var hero_data: Dictionary = young_heroes[hero_name]

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
			"hero": hero_name,
			"type": "background"
		}

		path_to_hero[front_path] = {
			"hero": hero_name,
			"type": "front"
		}
		path_to_hero[standing_path] = {
			"hero": hero_name,
			"type": "standing"
		}

	var total: int = paths.size()
	var loaded: int = 0

	for path in paths:

		# Already cached
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
		hero_name: String,
		texture_type: String
) -> void:

	if not hero_textures.has(hero_name):
		hero_textures[hero_name] = {}

	var texture := ResourceLoader.load_threaded_get(path) as Texture2D

	hero_textures[hero_name][texture_type] = texture


func get_hero_textures(hero_name: String) -> Dictionary:
	return hero_textures.get(hero_name, {})

func get_heroi_front(heroi_nome: String) -> Texture2D:
	if heroi_nome == "":
		return HeroesDb.hero_textures["unknown"]["front"]
	else:
		return HeroesDb.hero_textures[heroi_nome]["front"]

func get_heroi_bg(heroi_nome: String) -> Texture2D:
	if heroi_nome == "":
		return HeroesDb.hero_textures["unknown"]["background"]
	else:
		return HeroesDb.hero_textures[heroi_nome]["background"]
