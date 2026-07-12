extends Node

var importer_path

var standings = {}
var heroes = {}

@export var standings_scene: StringName

func csv_importer_standings(path):
	standings = CSVAccess.load_csv_data(path)
	if standings.has("1"):
		print("É standing")
		$Panel/VBoxContainer/Button2.disabled = false
	else:
		print("O QUE")
		standings = null
		return
	

func csv_importer_heroes(path):
	heroes = CSVAccess.load_csv_data(path)
	if !heroes.has("1"):
		print("É herois")
		$Panel/VBoxContainer/Button3.disabled = false
	else:
		print("O QUE")
		heroes = null
		return
	
func merge_data():
	for rank_key in standings:
		var ranking_data = standings[rank_key]
		var player_id = ranking_data["Player ID"]
		
		var combined = ranking_data.duplicate()
		
		for player_name in heroes:
			var player_data = heroes[player_name]
			
			if player_data["Player ID"] == player_id:
				combined.merge(player_data)
				break
		UniversalDict.merge_data[player_id] = combined
	var i = 0
	while i < UniversalDict.merge_data.size():
		print(UniversalDict.merge_data.values()[i]["Name"])
		i += 1
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
	merge_data()
	UniversalDict.store_name = str($Panel/VBoxContainer/TextEdit.text)
	await merge_data()
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
