extends Control

enum MenuState { CLOSED, STANDINGS, SETTINGS }
var current_state: MenuState = MenuState.CLOSED


func _ready() -> void:
	pass


func _on_menu_standings_btn_pressed() -> void:
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($MarginContainer/VBoxContainer/menu_standings/menu_standings_btn/ProgressBar, "value", 100, 0.5)
	tween.tween_property($MarginContainer/VBoxContainer/menu_settings/menu_settings_btn/ProgressBar, "value", 0, 0.5)
	match current_state:
		MenuState.STANDINGS:
			tween.tween_property(%menu_standings, "position", Vector2(0, 791), 0.5)
			tween.tween_property(%menu_settings_opt, "modulate:a", 0, 0.5)
			tween.tween_property(%menu_standings_opt, "modulate:a", 0, 0.5)
			tween.tween_property($MarginContainer/VBoxContainer/menu_standings/menu_standings_btn/ProgressBar, "value", 0, 0.5)
			current_state = MenuState.CLOSED

		MenuState.SETTINGS:
			tween.tween_property(%menu_settings, "position", Vector2(0, 876), 0.5)
			tween.tween_property(%menu_standings, "position", Vector2(0, 285), 0.5)
			tween.tween_property(%menu_settings_opt, "modulate:a", 0, 0.5)
			tween.tween_property(%menu_standings_opt, "modulate:a", 1, 0.5)
			current_state = MenuState.STANDINGS

		MenuState.CLOSED:
			tween.tween_property(%menu_standings, "position", Vector2(0, 285), 0.5)
			tween.tween_property(%menu_standings_opt, "modulate:a", 1, 0.5)
			tween.tween_property(%menu_settings_opt, "modulate:a", 0, 0.5)
			current_state = MenuState.STANDINGS

	await tween.finished


func _on_menu_settings_btn_pressed() -> void:
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($MarginContainer/VBoxContainer/menu_settings/menu_settings_btn/ProgressBar, "value", 100, 0.5)
	tween.tween_property($MarginContainer/VBoxContainer/menu_standings/menu_standings_btn/ProgressBar, "value", 0, 0.5)

	match current_state:
		MenuState.SETTINGS:
			tween.tween_property(%menu_settings, "position", Vector2(0, 876), 0.5)
			tween.tween_property(%menu_standings, "position", Vector2(0, 791), 0.5)
			tween.tween_property(%menu_settings_opt, "modulate:a", 0, 0.5)
			tween.tween_property($MarginContainer/VBoxContainer/menu_settings/menu_settings_btn/ProgressBar, "value", 0, 0.5)
			current_state = MenuState.CLOSED

		MenuState.STANDINGS:
			tween.tween_property(%menu_settings, "position", Vector2(0, 470), 0.5)
			tween.tween_property(%menu_standings, "position", Vector2(0, 791 - 430), 0.5)
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
