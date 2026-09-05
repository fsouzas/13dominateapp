extends Node

var importer_path

var standings = {}
var heroes = {}

@export var standings_scene: StringName

func _ready() -> void:
	
	if HeroesDb.already_loaded == false:
		
		%carregando.text = tr("update_checking_str")
		UpdateManager.update_available.connect(_on_update_available)
		UpdateManager.update_check_finished.connect(_on_update_check_finished)
		UpdateManager.update_error.connect(_on_update_error)
		UpdateManager.check_for_update()
		HeroesDb.texture_loading_progress.connect(_on_texture_loading_progress)
		HeroesDb.texture_loading_finished.connect(_on_texture_loading_finished)
		HeroesDb.preload_hero_textures()
		HeroesDb.already_loaded = true
	else:
		%loading.queue_free()

func csv_importer_standings(path):
	standings = CSVStanding.load_csv_to_dict(path, "standings")
	

func csv_importer_heroes(path):
	heroes = CSVStanding.load_csv_to_dict(path, "heroes")

func _on_file_dialog_file_selected(path: String) -> void:
	importer_path = path

func _on_button_pressed(extra_arg_0: bool) -> void:
	$FileDialog.show()
	await $FileDialog.file_selected
	csv_importer_standings(importer_path)


func _on_button_2_pressed() -> void:
	$FileDialog.show()
	await $FileDialog.file_selected
	csv_importer_heroes(importer_path)


func _on_button_3_pressed() -> void:
	UniversalDict.armory_data = CSVStanding.merge_dicts_keep_first_order(standings, heroes)
	UniversalDict.store_name = str(%store_name.text)
	SceneLoader.load_scene(standings_scene)
	

func _on_text_edit_text_changed() -> void:
	pass


func _on_menu_bar_item_selected(index: int) -> void:
	match index:
		1:
			UniversalDict.mode_selected = tr("sage_str").to_upper()
		2:
			UniversalDict.mode_selected = tr("cc_str").to_upper()


func _on_color_picker_button_color_changed(color: Color) -> void:
	UniversalDict.main_color = color

func _on_update_available(latest_version : String, download_url : String):
	%ConfirmationDialog.visible = true

func _on_update_check_finished(has_update: bool):
	print("update check finished")
	if has_update == true:
		%carregando.text = tr("new_update_available_str")
		print(tr("new_update_available_str"))
	if has_update == false:
		%carregando.text = tr("already_current_version_str")
		print(tr("already_current_version_str"))

func _on_update_error(error: String):
	%carregando.text = error
	print(error)

func _on_texture_loading_progress(current: int, total : int) -> void:
	%carregando.text = tr("loading_assets_str %d / %d") % [current, total]
func _on_texture_loading_finished() -> void:
	%carregando.text = tr("loading_finished")
	await get_tree().create_timer(0.2).timeout
	%loading.queue_free()


func _on_confirmation_dialog_confirmed() -> void:
	if UpdateManager.latest_download_url.is_empty():
		return
	OS.shell_open(UpdateManager.latest_download_url)
