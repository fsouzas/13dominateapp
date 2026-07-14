extends Node

var importer_path

var standings = {}
var heroes = {}

@export var standings_scene: StringName

func csv_importer_standings(path):
	standings = CSVStanding.load_csv_to_dict(path)
	

func csv_importer_heroes(path):
	heroes = CSVStanding.load_csv_to_dict(path)

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
	UniversalDict.store_name = str($Panel/VBoxContainer/TextEdit.text)
	SceneLoader.load_scene(standings_scene)
	

func _on_text_edit_text_changed() -> void:
	print($Panel/VBoxContainer/TextEdit.text)


func _on_menu_bar_item_selected(index: int) -> void:
	match index:
		1:
			$Panel/VBoxContainer/Button.disabled = false
			UniversalDict.mode_selected = "SILVER AGE"
		2:
			$Panel/VBoxContainer/Button.disabled = false
			UniversalDict.mode_selected = "CLASSIC CONSTRUCTED"
