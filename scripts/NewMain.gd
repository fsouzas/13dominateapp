extends Control

enum MenuState { CLOSED, STANDINGS, SETTINGS }
var current_state: MenuState = MenuState.CLOSED

var standings = {}
var heroes = {}
var csv_check
var github_download_link

@export var standings_scene: StringName
@onready var theme_settings: OptionButton = %theme_settings


func _ready() -> void:

	SignalBus.csv_state.connect(_on_csv_state_connected)
	loadSettings()
	
	if HeroesDb.already_loaded == false:
		await showLoadingScreenInfo()
		await checkUpdate()
		await get_tree().create_timer(1).timeout
		await preLoadAssets()
		await clearLoadingScreen()
	%Loading.queue_free()

	for theme_name in ThemeManager.get_theme_names():
		var theme = ThemeManager.themes[theme_name]
		theme_settings.add_item(tr(theme["display_name"]))
		var index = theme_settings.item_count - 1
		theme_settings.set_item_metadata(index, theme_name)
	
	var current_theme = SettingsManager.theme

	for i in theme_settings.item_count:
		if theme_settings.get_item_metadata(i) == current_theme:
			theme_settings.select(i)
			break

func checkUpdate():
	%loading_str.text = tr("checking_new_update_str")
	textAnimLoading(%loading_str)
	await get_tree().create_timer(1).timeout
	UpdateManager.update_available.connect(_on_update_available)
	UpdateManager.update_check_finished.connect(_on_update_check_finished)
	UpdateManager.update_error.connect(_on_update_error)
	UpdateManager.check_for_update()

func preLoadAssets():
	HeroesDb.texture_loading_progress.connect(_on_texture_loading_progress)
	HeroesDb.texture_loading_finished.connect(_on_texture_loading_finished, CONNECT_ONE_SHOT)
	HeroesDb.preload_hero_textures()
	await HeroesDb.texture_loading_finished
	HeroesDb.already_loaded = true
	textAnimLoading(%loading_str)
	await get_tree().create_timer(1).timeout

func loadSettings():
	SettingsManager.load_settings()
	
	var pre_menu_style = StyleBoxFlat.new()

	pre_menu_style.bg_color = ThemeManager.get_primary_color()
	%loading_bg.color = ThemeManager.get_primary_color()
	%menu_standings_btn_bar.add_theme_stylebox_override("fill", pre_menu_style)
	%menu_settings_btn_bar.add_theme_stylebox_override("fill", pre_menu_style)

	var menu_style = StyleBoxFlat.new()
	
	menu_style.border_color = ThemeManager.get_primary_color()
	menu_style.border_width_top = 3
	menu_style.border_width_bottom = 3
	menu_style.border_width_right = 3
	menu_style.border_width_left = 3
	menu_style.corner_radius_top_left = 10
	menu_style.corner_radius_top_right = 10
	menu_style.corner_radius_bottom_right = 10
	menu_style.corner_radius_bottom_left = 10
	menu_style.corner_detail = 8
	menu_style.content_margin_left = 30
	menu_style.bg_color = Color.TRANSPARENT

	var menu_btn_style = StyleBoxFlat.new()
	menu_btn_style.bg_color = ThemeManager.get_primary_color()
	menu_btn_style.border_color = ThemeManager.get_primary_color().darkened(0.3)
	menu_btn_style.border_width_top = 3
	menu_btn_style.border_width_bottom = 6
	menu_btn_style.border_width_right = 3
	menu_btn_style.border_width_left = 3
	menu_btn_style.corner_radius_top_left = 10
	menu_btn_style.corner_radius_top_right = 10
	menu_btn_style.corner_radius_bottom_right = 10
	menu_btn_style.corner_radius_bottom_left = 10
	menu_btn_style.corner_detail = 8

	%MenuBar.add_theme_stylebox_override("pressed", menu_style)
	%MenuBar.add_theme_stylebox_override("focus", menu_style)
	%choose_standings_btn.add_theme_stylebox_override("pressed", menu_style)
	%choose_heroes_btn.add_theme_stylebox_override("pressed", menu_style)
	%store_name.add_theme_stylebox_override("focus", menu_style)
	%ready_btn.add_theme_stylebox_override("normal", menu_btn_style)
	%ready_btn.add_theme_stylebox_override("pressed", menu_btn_style)
	%language_settings.add_theme_stylebox_override("pressed", menu_style)
	%language_settings.add_theme_stylebox_override("focus", menu_style)
	%theme_settings.add_theme_stylebox_override("pressed", menu_style)
	%theme_settings.add_theme_stylebox_override("focus", menu_style)
	%credits_btn.add_theme_stylebox_override("normal", menu_btn_style)
	%github_btn.add_theme_stylebox_override("normal", menu_btn_style)
	%credits_btn.add_theme_stylebox_override("pressed", menu_btn_style)
	%github_btn.add_theme_stylebox_override("pressed", menu_btn_style)
	print(SettingsManager.locale)

func _on_update_available(latest_version : String, download_url : String):
	%update_popup.visible = true
	%update_avaliable_str.text = tr("update_avaliable_str") +" "+ latest_version
	github_download_link = download_url

func _on_update_check_finished(new_update: bool):
	if new_update:
		%loading_str.text = tr("new_update_str")
		textAnimLoading(%loading_str)
	if !new_update:
		%loading_str.text = tr("already_latest_version_str")
		textAnimLoading(%loading_str)
	await get_tree().create_timer(1).timeout

func _on_update_error():
	pass

func _on_texture_loading_progress(current: int, _total: int):
	%loading_bar.value = current
	%loading_str.text = tr("loading_assets_str")
func _on_texture_loading_finished():
	%loading_str.text = tr("loading_assets_finished_str")
	textAnimLoading(%loading_str)

func showLoadingScreenInfo():
	var tween = create_tween()
	tween.set_trans(tween.TRANS_EXPO).set_ease(tween.EASE_OUT).set_parallel(true)
	tween.tween_property(%loading_info, "modulate:a", 1, 2)

	await tween.finished


func clearLoadingScreen():
	var tween = create_tween()
	tween.set_trans(tween.TRANS_EXPO).set_ease(tween.EASE_OUT).set_parallel(true)
	tween.tween_property(%Standing1Icon, "position", Vector2(104,-500), 0.5)
	tween.tween_property(%Standing1Icon, "modulate:a", 0, 0.5)

	tween.tween_property(%Stading3Icon, "position", Vector2(-800,260), 0.5)
	tween.tween_property(%Stading3Icon, "modulate:a", 0, 0.5)

	tween.tween_property(%Stading2Icon, "position", Vector2(800,257), 0.5)
	tween.tween_property(%Stading2Icon, "modulate:a", 0, 0.5)

	tween.chain().tween_property(%Loading, "modulate:a", 0, 0.5)

	await tween.finished

func textAnimLoading(text: Control):
	var tween = create_tween()
	tween.set_trans(tween.TRANS_EXPO).set_ease(tween.EASE_OUT).set_parallel(true)
	tween.tween_property(text, "offset_transform_position", Vector2(0,0), 0.3).from(Vector2(0,-50))
	tween.tween_property(text, "modulate:a", 1, 0.3).from(0)

func csvImporterStandings(path):
	standings = CSVStanding.load_csv_to_dict(path, "standings")

	var file_name := get_file_name(path)

	if not csv_check:
		%choose_heroes_btn.disabled = true
		%choose_standings_btn.text = tr("choose_standings_csv_str")
		%standings_error_msg_str.text = file_name + " " + tr("not_a_valid_standings_csv_str")
		csvErrorTextAnim(%standings_error_msg_str, false)
	else:
		%choose_heroes_btn.disabled = false
		%choose_standings_btn.text = file_name
		csvErrorTextAnim(%standings_error_msg_str, true)

	readyButtonCheck()


func csvImporterHeroes(path):
	heroes = CSVStanding.load_csv_to_dict(path, "heroes")

	var file_name := get_file_name(path)

	if not csv_check:
		%choose_heroes_btn.text = tr("choose_heroes_csv_str")
		%heroes_error_msg_str.text = file_name + " " + tr("not_a_valid_heroes_csv_str")
		csvErrorTextAnim(%heroes_error_msg_str, false)
	else:
		%choose_heroes_btn.text = file_name
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
	tween.tween_property(%menu_standings_btn_bar, "value", 100, 0.5)
	tween.tween_property(%menu_settings_btn_bar, "value", 0, 0.5)
	match current_state:
		MenuState.STANDINGS:
			tween.tween_property(%menu_standings, "position", Vector2(0, 791), 0.5)
			tween.tween_property(%menu_settings_opt, "modulate:a", 0, 0.5)
			tween.tween_property(%menu_standings_opt, "modulate:a", 0, 0.5)
			tween.tween_property(%menu_standings_btn_bar, "value", 0, 0.5)
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
	tween.tween_property(%menu_settings_btn_bar, "value", 100, 0.5)
	tween.tween_property(%menu_standings_btn_bar, "value", 0, 0.5)

	match current_state:
		MenuState.SETTINGS:
			tween.tween_property(%menu_settings, "position", Vector2(0, 876), 0.5)
			tween.tween_property(%menu_standings, "position", Vector2(0, 791), 0.5)
			tween.tween_property(%menu_settings_opt, "modulate:a", 0, 0.5)
			tween.tween_property(%menu_settings_btn_bar, "value", 0, 0.5)
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

func get_file_name(path: String) -> String:
	var file_name := path.get_file()

	if path.begins_with("content://"):
		var uri := path.uri_decode()

		file_name = uri.get_file()

		file_name = file_name.split("?")[0]

	return file_name

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


func readyButtonCheck():
	if standings.is_empty() or heroes.is_empty():
		%ready_btn.disabled = true
	else:
		%ready_btn.disabled = false

func _on_ready_str_pressed():
	var result_merged: Array = CSVStanding.merge_dicts_keep_first_order(standings, heroes)
	var armory_merged: Dictionary = result_merged[0]
	var error_code: int = result_merged[1]

	var store_name = str(%store_name.text).strip_edges()
	

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
	if armory_merged.size() < 3:
		%ready_error_msg_str.text = tr("not_enough_players_str")
		csvErrorTextAnim(%ready_error_msg_str, false)
	
	UniversalDict.setStoreName(store_name)

	SettingsManager.store = store_name

	if store_name not in SettingsManager.store_names:
		SettingsManager.store_names.append(store_name)
	
	SettingsManager.save_settings()
	csvErrorTextAnim(%ready_error_msg_str, true)
	UniversalDict.setArmoryData(armory_merged)
	SceneLoader.load_scene(standings_scene)


func _on_language_settings_item_selected(index: int) -> void:
	match index:
		1:
			SettingsManager.locale = "pt_BR"
			UniversalDict.setLocale("pt_BR")
			SettingsManager.save_settings()
			get_tree().reload_current_scene()
		2:
			SettingsManager.locale = "en"
			UniversalDict.setLocale("en")
			SettingsManager.save_settings()
			get_tree().reload_current_scene()
		3:
			SettingsManager.locale = "ja"
			UniversalDict.setLocale("ja")
			SettingsManager.save_settings()
			get_tree().reload_current_scene()


func _on_theme_settings_item_selected(index: int) -> void:
	var theme_name = theme_settings.get_item_metadata(index)
	ThemeManager.set_theme(theme_name)
	SettingsManager.theme = theme_name
	get_tree().reload_current_scene()
	SettingsManager.save_settings()


func _on_cancel_btn_pressed() -> void:
	%update_popup.queue_free()


func _on_download_btn_pressed() -> void:
	OS.shell_open(github_download_link)


func _on_github_btn_pressed() -> void:
	OS.shell_open("https://github.com/fsouzas/13dominateapp")


func _on_credits_btn_pressed() -> void:
	%credits_popup.visible = true


func _on_credits_close_pressed() -> void:
	%credits_popup.visible = false
