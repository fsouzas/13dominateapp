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

@export var menu : Node
@export var voltar_button : Button
@export var share_button : Button
@export var save_button : Button 
@export var proximo_button : Button 
@export var home : Button

@export var background_img : TextureRect
@export var color_transparent : ColorRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	share.set_share_target(true)
	
	background_img.material.set_shader_parameter("replace_color", UniversalDict.main_color)
	$StandingTitle/VBoxContainer/AutoSizeRichTextLabel4.add_theme_color_override("default_color", UniversalDict.main_color)
	color_transparent.color = UniversalDict.main_color
	
	#voltar_button.self_modulate.a = 0
	voltar_button.disabled = true
	
	if UniversalDict.armory_data.size() <= 13:
		proximo_button.self_modulate.a = 0
		proximo_button.disabled = true
	
	mode_name.text = UniversalDict.mode_selected
	store_name.text = UniversalDict.store_name.to_upper() +" "+ Time.get_date_string_from_system()
	
	var name_1_full = UniversalDict.armory_data.values()[0]["Name"].to_upper()
	var name_1_parts = name_1_full.split(" ")
	
	heroi_destaque1_nome.text = name_1_parts[0] + " " + name_1_parts[1]
	heroi_destaque_1_vitoria.text = UniversalDict.armory_data.values()[0]["Wins"].to_upper()
	
	if not HeroesDb.young_heroes[UniversalDict.armory_data.values()[0]["Hero"]]["background"]:
		heroi_destaque1_bg.texture = load("res://assets/standing_destaque/unknown/unknown_bg.png")
	else:
		heroi_destaque1_bg.texture = load(HeroesDb.young_heroes[UniversalDict.armory_data.values()[0]["Hero"]]["background"])
	if HeroesDb.young_heroes[UniversalDict.armory_data.values()[0]["Hero"]]["front"] == "":
		heroi_destaque1_front.texture = load("res://assets/standing_destaque/unknown/unknown_front.png")
	else:
		heroi_destaque1_front.texture = load(HeroesDb.young_heroes[UniversalDict.armory_data.values()[0]["Hero"]]["front"])
	
	var name_2_full = UniversalDict.armory_data.values()[1]["Name"].to_upper()
	var name_2_parts = name_2_full.split(" ")
	
	heroi_destaque2_nome.text = name_2_parts[0] + " " + name_2_parts[1]
	heroi_destaque_2_vitoria.text = UniversalDict.armory_data.values()[1]["Wins"].to_upper()
	
	if HeroesDb.young_heroes[UniversalDict.armory_data.values()[1]["Hero"]]["background"] == "":
		heroi_destaque2_bg.texture = load("res://assets/standing_destaque/unknown/unknown_bg.png")
	else:
		heroi_destaque2_bg.texture = load(HeroesDb.young_heroes[UniversalDict.armory_data.values()[1]["Hero"]]["background"])
	if HeroesDb.young_heroes[UniversalDict.armory_data.values()[1]["Hero"]]["front"] == "":
		heroi_destaque2_front.texture = load("res://assets/standing_destaque/unknown/unknown_front.png")
	else:
		heroi_destaque2_front.texture = load(HeroesDb.young_heroes[UniversalDict.armory_data.values()[1]["Hero"]]["front"])
	
	var name_3_full = UniversalDict.armory_data.values()[2]["Name"].to_upper()
	var name_3_parts = name_3_full.split(" ")
	
	heroi_destaque3_nome.text = name_3_parts[0] + " " + name_3_parts[1]
	heroi_destaque_3_vitoria.text = UniversalDict.armory_data.values()[2]["Wins"].to_upper()
	
	if HeroesDb.young_heroes[UniversalDict.armory_data.values()[2]["Hero"]]["background"] == "":
		heroi_destaque3_bg.texture = load("res://assets/standing_destaque/unknown/unknown_bg.png")
	else:
		heroi_destaque3_bg.texture = load(HeroesDb.young_heroes[UniversalDict.armory_data.values()[2]["Hero"]]["background"])
	if HeroesDb.young_heroes[UniversalDict.armory_data.values()[2]["Hero"]]["front"] == "":
		heroi_destaque3_front.texture = load("res://assets/standing_destaque/unknown/unknown_front.png")
	else:
		heroi_destaque3_front.texture = load(HeroesDb.young_heroes[UniversalDict.armory_data.values()[2]["Hero"]]["front"])
	
	SortStanding.sort_standing(tab, standing_less, standings_extra, standing_results_1)
	
	page_numb.text = str(tab.current_tab + 1) + "/" + str(tab.get_tab_count())

func share_screenshot():
	share.share_viewport(get_viewport(), "shared_title", "shared_subject", "Standings de hoje!")
	pass


func _on_share_share_canceled() -> void:
	menu.visible = true
	home.visible = true

func _on_share_share_completed(activity_type: String) -> void:
	menu.visible = true
	home.visible = true

func _on_share_pressed() -> void:
	menu.visible = false
	home.visible = false
	await RenderingServer.frame_post_draw
	share_screenshot()
	menu.visible = true
	home.visible = true


func _on_voltar_pressed() -> void:
	voltar_button.disabled = true
	share_button.disabled = true
	#save_button.disabled = true
	proximo_button.disabled = true
	
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
	
	
	if(tab.current_tab == 0):
		var tween: Tween = create_tween().set_parallel()
		tween.set_ease(tween.EASE_IN_OUT)
		tween.set_trans(tween.TRANS_EXPO)                                                                                  
		tween.tween_property(voltar_button,"offset_transform_position",Vector2(0,100), 1.0)
		tween.tween_property(voltar_button,"self_modulate:a", 0, 1.0)
	if (tab.get_tab_count() > 0):
		var tween: Tween = create_tween().set_parallel()                                                                              
		tween.set_ease(tween.EASE_IN_OUT)
		tween.set_trans(tween.TRANS_EXPO)                                                                                  
		tween.tween_property(proximo_button,"offset_transform_position",Vector2(0,0), 1.0)
		tween.tween_property(proximo_button,"self_modulate:a",1, 1.0)
	voltar_button.disabled = false
	share_button.disabled = false
	#save_button.disabled = false
	proximo_button.disabled = false
	page_numb.text = str(tab.current_tab + 1) + "/" + str(tab.get_tab_count())





func _on_proximo_pressed() -> void:
	voltar_button.disabled = true
	share_button.disabled = true
	#save_button.disabled = true
	proximo_button.disabled = true
	
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
	
	tween_main = create_tween().set_parallel()                                                                                
	tween_main.set_ease(tween_main.EASE_IN_OUT)
	tween_main.set_trans(tween_main.TRANS_EXPO)                                                                                  
	tween_main.tween_property(voltar_button,"offset_transform_position",Vector2(0,0), 1.0)
	tween_main.tween_property(voltar_button,"self_modulate:a",1, 1.0)
	
	if(tab.current_tab == tab.get_tab_count()- 1):
		var tween: Tween = create_tween().set_parallel()                                                                              
		tween.set_ease(tween.EASE_IN_OUT)
		tween.set_trans(tween.TRANS_EXPO)                                                                                  
		tween.tween_property(proximo_button,"offset_transform_position",Vector2(0,100), 1.0)
		tween.tween_property(proximo_button,"self_modulate:a", 0, 1.0)
	
	voltar_button.disabled = false
	share_button.disabled = false
	#save_button.disabled = false
	proximo_button.disabled = false
	page_numb.text = str(tab.current_tab + 1) + "/" + str(tab.get_tab_count())


func _on_hide_pressed() -> void:
	print("pressionado")
	menu.visible = false
	if menu.visible == true:
		menu.visible = false
		$hide.texture_normal = load("res://assets/icons/Invisible-1--Streamline-Core.png")
	if menu.visible == false:
		menu.visible = true
		$hide.texture_normal = load("res://assets/icons/Visible--Streamline-Core.png")


func _on_home_pressed() -> void:
	SceneLoader.load_scene(home_scene)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		SceneLoader.load_scene(home_scene)
