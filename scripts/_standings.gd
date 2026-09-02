extends Node

@export var share : Share

@export var home_scene: StringName

@export var mode_name : Node
@export var store_name : Node

@export var heroi_destaque1_front : TextureRect
@export var heroi_destaque1_bg : TextureRect
@export var heroi_destaque1_nome : AutoSizeRichTextLabel
@export var heroi_destaque_1_vitoria : RichTextLabel

@export var heroi_destaque2_front : TextureRect
@export var heroi_destaque2_bg : TextureRect
@export var heroi_destaque2_nome : AutoSizeRichTextLabel
@export var heroi_destaque_2_vitoria : RichTextLabel

@export var heroi_destaque3_front : TextureRect
@export var heroi_destaque3_bg : TextureRect
@export var heroi_destaque3_nome : AutoSizeRichTextLabel
@export var heroi_destaque_3_vitoria : RichTextLabel

@export var standing_less : Node
@export var standing_results_1 : VBoxContainer
@export var standings_extra :VBoxContainer

@export var tab : TabContainer
@export var page_numb : RichTextLabel

@onready var standing_size : int = 3
@onready var num_standings : int = 1
@export var background_img : TextureRect
@export var color_transparent : ColorRect

@export var fileDialog : FileDialog

#Menu vars
@export var menu : Node
@export var btn_home : TextureButton
@export var btn_salvar : TextureButton
@export var btn_compartilhar : TextureButton
@export var btn_hamburguer : TextureButton
@export var btn_voltar : TextureButton
@export var btn_proximo : TextureButton

var save_path

var hamburguer_open: bool = false

var swipe_start_pos : Vector2 = Vector2.ZERO
var min_swipe_dist: float = 60.0

func _ready() -> void:
	
	share.set_share_target(true)
	
	$StandingTitle/VBoxContainer/AutoSizeRichTextLabel4.add_theme_color_override("default_color", UniversalDict.main_color)
	
	
	if UniversalDict.armory_data.size() <= 13:
		pass
	
	mode_name.text = UniversalDict.mode_selected.to_upper()
	var date = Time.get_date_dict_from_system()
	match UniversalDict.locale:
		"en":
			store_name.text = UniversalDict.store_name.to_upper() + " %02d/%02d/%d" % [date.month, date.day, date.year]
		"ja":
			store_name.text = UniversalDict.store_name.to_upper() + " %02d年%02d月%d" % [date.year, date.month, date.day]
		_:
			store_name.text = UniversalDict.store_name.to_upper() + " %02d/%02d/%d" % [date.day, date.month, date.year]
	
	var name_1_full = UniversalDict.armory_data.values()[0]["Name"].to_upper()
	var name_1_parts = name_1_full.split(" ")
	
	heroi_destaque1_nome.text = name_1_parts[0] + " " + name_1_parts[1]
	heroi_destaque_1_vitoria.text = UniversalDict.armory_data.values()[0]["Wins"].to_upper()
	
	if not HeroesDb.young_heroes[UniversalDict.armory_data.values()[0]["Hero"]]["background"]:
		heroi_destaque1_bg.texture = HeroesDb.hero_textures["unknown"]["background"]
	else:
		heroi_destaque1_bg.texture = HeroesDb.hero_textures[UniversalDict.armory_data.values()[0]["Hero"]]["background"]
	if HeroesDb.young_heroes[UniversalDict.armory_data.values()[0]["Hero"]]["front"] == "":
		heroi_destaque1_front.texture = HeroesDb.hero_textures["unknown"]["front"]
	else:
		heroi_destaque1_front.texture = HeroesDb.hero_textures[UniversalDict.armory_data.values()[0]["Hero"]]["front"]
	
	var name_2_full = UniversalDict.armory_data.values()[1]["Name"].to_upper()
	var name_2_parts = name_2_full.split(" ")
	
	heroi_destaque2_nome.text = name_2_parts[0] + " " + name_2_parts[1]
	heroi_destaque_2_vitoria.text = UniversalDict.armory_data.values()[1]["Wins"].to_upper()
	
	if HeroesDb.young_heroes[UniversalDict.armory_data.values()[1]["Hero"]]["background"] == "":
		heroi_destaque2_bg.texture = HeroesDb.hero_textures["unknown"]["background"]
	else:
		heroi_destaque2_bg.texture = HeroesDb.hero_textures[UniversalDict.armory_data.values()[1]["Hero"]]["background"]
	if HeroesDb.young_heroes[UniversalDict.armory_data.values()[1]["Hero"]]["front"] == "":
		heroi_destaque2_front.texture = HeroesDb.hero_textures["unknown"]["front"]
	else:
		heroi_destaque2_front.texture = HeroesDb.hero_textures[UniversalDict.armory_data.values()[1]["Hero"]]["front"]
	
	var name_3_full = UniversalDict.armory_data.values()[2]["Name"].to_upper()
	var name_3_parts = name_3_full.split(" ")
	
	heroi_destaque3_nome.text = name_3_parts[0] + " " + name_3_parts[1]
	heroi_destaque_3_vitoria.text = UniversalDict.armory_data.values()[2]["Wins"].to_upper()
	
	if HeroesDb.young_heroes[UniversalDict.armory_data.values()[2]["Hero"]]["background"] == "":
		heroi_destaque3_bg.texture = HeroesDb.hero_textures["unknown"]["background"]
	else:
		heroi_destaque3_bg.texture = HeroesDb.hero_textures[UniversalDict.armory_data.values()[2]["Hero"]]["background"]
	if HeroesDb.young_heroes[UniversalDict.armory_data.values()[2]["Hero"]]["front"] == "":
		heroi_destaque3_front.texture = HeroesDb.hero_textures["unknown"]["front"]
	else:
		heroi_destaque3_front.texture = HeroesDb.hero_textures[UniversalDict.armory_data.values()[2]["Hero"]]["front"]
	
	SortStanding.sort_standing(tab, standing_less, standings_extra, standing_results_1)
	
	page_numb.text = str(tab.current_tab + 1) + "/" + str(tab.get_tab_count())

func share_screenshot():
	share.share_viewport(get_viewport(), "shared_title", "shared_subject", "Standings de hoje!")
	pass


func _on_share_share_canceled() -> void:
	menu.visible = true

func _on_share_share_completed(activity_type: String) -> void:
	menu.visible = true


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		SceneLoader.load_scene(home_scene)

func _on_file_dialog_file_selected(path: String) -> void:
	save_path = path

func taking_screenshot():
	menu.visible = false
	await RenderingServer.frame_post_draw
	var image = get_viewport().get_texture().get_image()
	var image_name = str(UniversalDict.mode_selected + Time.get_date_string_from_system())
	fileDialog.current_file = image_name
	fileDialog.show()
	await fileDialog.file_selected
	image.save_png(save_path)
	menu.visible = true

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			swipe_start_pos = event.position
		else:
			var swipe_vector = event.position - swipe_start_pos
			
			if swipe_vector.length() >= min_swipe_dist and abs(swipe_vector.x) > abs(swipe_vector.y):
				if swipe_vector.x < 0:
					_on_btn_proximo_pressed()
				else:
					_on_btn_voltar_pressed()


func _on_btn_home_pressed() -> void:
	Input.vibrate_handheld(50,0.2)
	var tween = create_tween()
	tween.tween_property(btn_home,"offset_transform_scale", Vector2(1.3,1.3), 0.3).set_trans(tween.TRANS_CUBIC).set_ease(tween.EASE_OUT)
	tween.tween_property(btn_home,"offset_transform_scale", Vector2(1,1), 0.3).set_trans(tween.TRANS_BACK).set_ease(tween.EASE_OUT)
	SceneLoader.load_scene(home_scene)


func _on_btn_salvar_pressed() -> void:
	Input.vibrate_handheld(50,0.2)
	var tween = create_tween()
	tween.tween_property(btn_salvar,"offset_transform_scale", Vector2(1.3,1.3), 0.3).set_trans(tween.TRANS_CUBIC).set_ease(tween.EASE_OUT)
	tween.tween_property(btn_salvar,"offset_transform_scale", Vector2(1,1), 0.3).set_trans(tween.TRANS_BACK).set_ease(tween.EASE_OUT)
	taking_screenshot()


func _on_btn_compartilhar_pressed() -> void:
	Input.vibrate_handheld(50,0.2)
	var tween = create_tween()
	tween.tween_property(btn_compartilhar,"offset_transform_scale", Vector2(1.3,1.3), 0.3).set_trans(tween.TRANS_CUBIC).set_ease(tween.EASE_OUT)
	tween.tween_property(btn_compartilhar,"offset_transform_scale", Vector2(1,1), 0.3).set_trans(tween.TRANS_BACK).set_ease(tween.EASE_OUT)
	menu.visible = false
	await RenderingServer.frame_post_draw
	share_screenshot()
	menu.visible = true


func _on_btn_hamburguer_pressed() -> void:
	Input.vibrate_handheld(50,0.2)
	var tween = create_tween()
	tween.tween_property(btn_hamburguer,"offset_transform_scale", Vector2(1.3,1.3), 0.3).set_trans(tween.TRANS_CUBIC).set_ease(tween.EASE_OUT)
	tween.tween_property(btn_hamburguer,"offset_transform_scale", Vector2(1,1), 0.3).set_trans(tween.TRANS_BACK).set_ease(tween.EASE_OUT)
	if hamburguer_open == false:
		tween.set_parallel().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		tween.tween_property(btn_home, "modulate:a", 1, 0.3)
		tween.tween_property(btn_compartilhar, "modulate:a", 1, 0.3)
		tween.tween_property(btn_salvar, "modulate:a", 1, 0.3)
		tween.tween_property(%hamburguer_menu, "theme_override_constants/separation", 30, 0.5)
		hamburguer_open = true
	else:
		tween.set_parallel().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		tween.tween_property(btn_home, "modulate:a", 0, 0.3)
		tween.tween_property(btn_compartilhar, "modulate:a", 0, 0.3)
		tween.tween_property(btn_salvar, "modulate:a", 0, 0.3)
		tween.tween_property(%hamburguer_menu, "theme_override_constants/separation", -40, 0.5)
		hamburguer_open = false
		


func _on_btn_voltar_pressed() -> void:

	Input.vibrate_handheld(50,0.2)
	var tween = create_tween()
	tween.tween_property(btn_voltar,"offset_transform_scale", Vector2(1.3,1.3), 0.3).set_trans(tween.TRANS_CUBIC).set_ease(tween.EASE_OUT)
	tween.tween_property(btn_voltar,"offset_transform_scale", Vector2(1,1), 0.3).set_trans(tween.TRANS_BACK).set_ease(tween.EASE_OUT)
	
	var last_node_pos = tab.get_child(tab.current_tab).offset_transform_position
	var tween_main: Tween = create_tween().set_parallel(true)
	tween_main.set_ease(tween_main.EASE_IN_OUT)
	tween_main.set_trans(tween_main.TRANS_EXPO)
	tween_main.tween_property(tab.get_child(tab.current_tab),"offset_transform_position", Vector2(tab.get_child(tab.current_tab).offset_transform_position.x , tab.get_child(tab.current_tab).offset_transform_position.y + 100),1.0)
	tween_main.tween_property(tab.get_child(tab.current_tab),"modulate:a", 0, 1.0)
	await tween_main.finished
	if tween_main:
		tween_main.kill()
	tab.get_child(tab.current_tab).offset_transform_position = last_node_pos

	tab.current_tab -= 1

	print(tab.current_tab)

	last_node_pos = tab.get_child(tab.current_tab).offset_transform_position
	tab.get_child(tab.current_tab).offset_transform_position.y += 100
	tween_main = create_tween().set_parallel(true)
	tween_main.set_ease(tween_main.EASE_IN_OUT)
	tween_main.set_trans(tween_main.TRANS_EXPO)
	tween_main.tween_property(tab.get_child(tab.current_tab),"offset_transform_position", Vector2(tab.get_child(tab.current_tab).offset_transform_position.x , tab.get_child(tab.current_tab).offset_transform_position.y - 100),1.0)
	tween_main.tween_property(tab.get_child(tab.current_tab),"modulate:a", 1, 1.0)
	await tween_main.finished
	if tween_main:
		tween_main.kill()
	tab.get_child(tab.current_tab).offset_transform_position = last_node_pos
	
	page_numb.text = str(tab.current_tab + 1) + "/" + str(tab.get_tab_count())


func _on_btn_proximo_pressed() -> void:

	Input.vibrate_handheld(50,0.2)
	var tween = create_tween()
	tween.tween_property(btn_proximo,"offset_transform_scale", Vector2(1.3,1.3), 0.3).set_trans(tween.TRANS_CUBIC).set_ease(tween.EASE_OUT)
	tween.tween_property(btn_proximo,"offset_transform_scale", Vector2(1,1), 0.3).set_trans(tween.TRANS_BACK).set_ease(tween.EASE_OUT)
	
	var last_node_pos = tab.get_child(tab.current_tab).offset_transform_position
	var tween_main: Tween = create_tween().set_parallel(true)
	tween_main.set_ease(tween_main.EASE_IN_OUT)
	tween_main.set_trans(tween_main.TRANS_EXPO)
	var last_node_pos_offset : Vector2 = tab.get_child(tab.current_tab).offset_transform_position
	tween_main.tween_property(tab.get_child(tab.current_tab),"offset_transform_position", Vector2(tab.get_child(tab.current_tab).offset_transform_position.x , tab.get_child(tab.current_tab).offset_transform_position.y + 100),1.0)
	tween_main.tween_property(tab.get_child(tab.current_tab),"modulate:a", 0, 1.0)
	await tween_main.finished
	if tween_main:
		tween_main.kill()
	tab.get_child(tab.current_tab).offset_transform_position = last_node_pos

	tab.current_tab += 1
	print(tab.current_tab)

	last_node_pos = tab.get_child(tab.current_tab).offset_transform_position
	tab.get_child(tab.current_tab).offset_transform_position.y += 100
	tween_main = create_tween().set_parallel(true)
	tween_main.set_ease(tween_main.EASE_IN_OUT)
	tween_main.set_trans(tween_main.TRANS_EXPO)
	tween_main.tween_property(tab.get_child(tab.current_tab),"offset_transform_position", Vector2(tab.get_child(tab.current_tab).offset_transform_position.x , tab.get_child(tab.current_tab).offset_transform_position.y - 100),1.0)
	tween_main.tween_property(tab.get_child(tab.current_tab),"modulate:a", 1, 1.0)
	await tween_main.finished
	if tween_main:
		tween_main.kill()
	print(tab.get_tab_count())
	tab.get_child(tab.current_tab).offset_transform_position = last_node_pos

	page_numb.text = str(tab.current_tab + 1) + "/" + str(tab.get_tab_count())
