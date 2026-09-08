extends Control

enum MenuState { CLOSED, STANDINGS, SETTINGS }
var current_state: MenuState = MenuState.CLOSED

var standings = {}
var heroes = {}
var csv_check

@export var standings_scene: StringName

func _ready() -> void:
	SignalBus.csv_state.connect(_on_csv_state_connected)

	if HeroesDb.already_loaded == false:
		checkUpdate()
		preLoadAssets()
	loadSettings()

func checkUpdate():
	#UpdateManager.update_available.connect(_on_update_available)
	#UpdateManager.update_check_finished.connect(_on_update_check_finished)
	#UpdateManager.update_error.connect(_on_update_error)
	UpdateManager.check_for_update()

func preLoadAssets():
	#HeroesDb.texture_loading_progress.connect(_on_texture_loading_progress)
	#HeroesDb.texture_loading_finished.connect(_on_texture_loading_finished)
	HeroesDb.preload_hero_textures()
	HeroesDb.already_loaded = true

func loadSettings():
	pass

func csvImporterStandings(path):
	standings = CSVStanding.load_csv_to_dict(path, "standings")

	if not csv_check:
		%choose_heroes_btn.disabled = true
		%choose_standings_btn.text = tr("choose_standings_csv_str")
		%standings_error_msg_str.text = path.get_file() + " " + tr("not_a_valid_standings_csv_str")
		csvErrorTextAnim(%standings_error_msg_str, false)
	else:
		%choose_heroes_btn.disabled = false
		%choose_standings_btn.text = path.get_file()
		csvErrorTextAnim(%standings_error_msg_str, true)
	readyButtonCheck()

func csvImporterHeroes(path):
	heroes = CSVStanding.load_csv_to_dict(path, "heroes")
	if not csv_check:
		%choose_heroes_btn.text = tr("choose_heroes_csv_str")
		%heroes_error_msg_str.text = path.get_file() + " " + tr("not_a_valid_heroes_csv_str")
		csvErrorTextAnim(%heroes_error_msg_str, false)
	else:
		%choose_heroes_btn.text = path.get_file()
		csvErrorTextAnim(%heroes_error_msg_str, true)
	readyButtonCheck()

func csvErrorTextAnim(text: Control, error_showing: bool):
	var tween = create_tween()
	tween.set_trans(tween.TRANS_EXPO).set_ease(tween.EASE_OUT).set_parallel(true)
	print("animation being played")
	if not error_showing:
		tween.tween_property(text, "offset_transform_position", Vector2(0,0), 0.3).from(Vector2(0,-50))
		tween.tween_property(text, "modulate:a", 1, 0.3)
		print("error shown")
	else:
		tween.tween_property(text, "offset_transform_position", Vector2(0,-50), 0.3).from(Vector2(0,0))
		tween.tween_property(text, "modulate:a", 0, 0.3)
		print("error hidden")

func _on_csv_state_connected(state: bool):
	csv_check = state

func _on_menu_standings_btn_pressed() -> void:
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($MarginContainer/menu/menu_standings/menu_standings_btn/ProgressBar, "value", 100, 0.5)
	tween.tween_property($MarginContainer/menu/menu_settings/menu_settings_btn/ProgressBar, "value", 0, 0.5)
	match current_state:
		MenuState.STANDINGS:
			tween.tween_property(%menu_standings, "position", Vector2(0, 791), 0.5)
			tween.tween_property(%menu_settings_opt, "modulate:a", 0, 0.5)
			tween.tween_property(%menu_standings_opt, "modulate:a", 0, 0.5)
			tween.tween_property($MarginContainer/menu/menu_standings/menu_standings_btn/ProgressBar, "value", 0, 0.5)
			current_state = MenuState.CLOSED

		MenuState.SETTINGS:
			tween.tween_property(%menu_settings, "position", Vector2(0, 876), 0.5)
			tween.tween_property(%menu_standings, "position", Vector2(0, 50), 0.5)
			tween.tween_property(%menu_settings_opt, "modulate:a", 0, 0.5)
			tween.tween_property(%menu_standings_opt, "modulate:a", 1, 0.5)
			current_state = MenuState.STANDINGS

		MenuState.CLOSED:
			tween.tween_property(%menu_standings, "position", Vector2(0, 50), 0.5)
			tween.tween_property(%menu_standings_opt, "modulate:a", 1, 0.5)
			tween.tween_property(%menu_settings_opt, "modulate:a", 0, 0.5)
			current_state = MenuState.STANDINGS

	await tween.finished


func _on_menu_settings_btn_pressed() -> void:
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($MarginContainer/menu/menu_settings/menu_settings_btn/ProgressBar, "value", 100, 0.5)
	tween.tween_property($MarginContainer/menu/menu_standings/menu_standings_btn/ProgressBar, "value", 0, 0.5)

	match current_state:
		MenuState.SETTINGS:
			tween.tween_property(%menu_settings, "position", Vector2(0, 876), 0.5)
			tween.tween_property(%menu_standings, "position", Vector2(0, 791), 0.5)
			tween.tween_property(%menu_settings_opt, "modulate:a", 0, 0.5)
			tween.tween_property($MarginContainer/menu/menu_settings/menu_settings_btn/ProgressBar, "value", 0, 0.5)
			current_state = MenuState.CLOSED

		MenuState.STANDINGS:
			tween.tween_property(%menu_settings, "position", Vector2(0, 470), 0.5)
			tween.tween_property(%menu_standings, "position", Vector2(0, 370), 0.5)
			tween.tween_property(%menu_settings_opt, "modulate:a", 1, 0.5)
			tween.tween_property(%menu_standings_opt, "modulate:a", 0, 0.5)
			current_state = MenuState.SETTINGS

		MenuState.CLOSED:
			tween.tween_property(%menu_settings, "position", Vector2(0, 470), 0.5)
			tween.tween_property(%menu_standings, "position", Vector2(0, %menu_standings.position.y - 430), 0.5)
			tween.tween_property(%menu_settings_opt, "modulate:a", 1, 0.5)
			tween.tween_property(%menu_standings_opt, "modulate:a", 0, 0.5)
			current_state = MenuState.SETTINGS

	await tween.finished


func _on_choose_standings_btn_pressed() -> void:
	$FileDialog.show()
	var path : String = await $FileDialog.file_selected
	csvImporterStandings(path)


func _on_choose_heroes_btn_pressed() -> void:
	$FileDialog.show()
	var path : String = await $FileDialog.file_selected
	csvImporterHeroes(path)

func _on_menu_bar_item_selected(index: int) -> void:
	match index:
		1:
			UniversalDict.setModeSelected(tr("sage_str"))
			enableCsvButtons()
		2:
			UniversalDict.setModeSelected(tr("cc_str"))
			enableCsvButtons()
		3:
			UniversalDict.setModeSelected(tr("sealed_str"))
			enableCsvButtons()
		4:
			UniversalDict.setModeSelected(tr("draft_str"))
			enableCsvButtons()
		5:
			UniversalDict.setModeSelected(tr("pre_release_usurp_str"))
			enableCsvButtons()

func enableCsvButtons():
	%choose_standings_btn.disabled = false

func _on_store_name_text_changed() -> void:
	UniversalDict.setStoreName(str(%store_name.text))

func readyButtonCheck():
	if standings.is_empty() or heroes.is_empty():
		%ready_btn.disabled = true
	else:
		%ready_btn.disabled = false

func _on_ready_str_pressed():
	var result_merged: Array = CSVStanding.merge_dicts_keep_first_order(standings, heroes)
	var armory_merged: Dictionary = result_merged[0]
	var error_code: int = result_merged[1]

	if error_code != CSVStanding.MergeError.OK:
		match error_code:
			CSVStanding.MergeError.FIRST_EMPTY:
				%ready_error_msg_str.text = tr("error_standings_csv_str")
				csvErrorTextAnim(%ready_error_msg_str, false)
			CSVStanding.MergeError.SECOND_EMPTY:
				%ready_error_msg_str.text = tr("error_heroes_csv_str")
				csvErrorTextAnim(%ready_error_msg_str, false)
			CSVStanding.MergeError.PLAYER_ID_MISMATCH:
				%ready_error_msg_str.text = tr("error_player_id_mismatch_str")
				csvErrorTextAnim(%ready_error_msg_str, false)
		return
	csvErrorTextAnim(%ready_error_msg_str, false)
	UniversalDict.setArmoryData(armory_merged)
	SceneLoader.load_scene(standings_scene)


func _on_language_settings_item_selected(index: int) -> void:
	match index:
		1:
			UniversalDict.setLocale("pt_BR")
			get_tree().reload_current_scene()
		2:
			UniversalDict.setLocale("en")
			get_tree().reload_current_scene()
		3:
			UniversalDict.setLocale("ja")
			get_tree().reload_current_scene()
