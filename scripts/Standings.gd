extends Node

@export var share : Share

@export var home_scene: StringName

@export var mode_name : AutoSizeRichTextLabel
@export var store_name : AutoSizeRichTextLabel

@export var heroi_1_front : TextureRect
@export var heroi_1_bg : TextureRect
@export var heroi_1_nome : AutoSizeRichTextLabel
@export var heroi_1_vitorias : RichTextLabel

@export var heroi_2_front : TextureRect
@export var heroi_2_bg : TextureRect
@export var heroi_2_nome : AutoSizeRichTextLabel
@export var heroi_2_vitorias : RichTextLabel

@export var heroi_3_front : TextureRect
@export var heroi_3_bg : TextureRect
@export var heroi_3_nome : AutoSizeRichTextLabel
@export var heroi_3_vitorias : RichTextLabel

@export var standing_less : Node
@export var standing_results_1 : VBoxContainer
@export var standings_extra :VBoxContainer

@export var tab : TabContainer
@export var page_number : RichTextLabel


@export var fileDialog : FileDialog

#Menu vars
@export var menu : Node
@export var btn_home : TextureButton
@export var btn_salvar : TextureButton
@export var btn_compartilhar : TextureButton
@export var btn_hamburguer : TextureButton
@export var btn_voltar : TextureButton
@export var btn_proximo : TextureButton
var mudando_pagina: bool = false

var save_path : String

var hamburguer_open: bool = false

var swipe_start_pos : Vector2 = Vector2.ZERO
const  MIN_SWIPE_DIST: float = 60.0
const BUTTON_PRESS_SCALE : Vector2 = Vector2(1.3,1.3)

func _ready() -> void:
	
	setup_share()
	setup_theme()
	setup_header()
	setup_destaques()
	setup_standings()
	update_pagina_num()
	
func setup_share():
	share.set_share_target(true)

func share_screenshot():
	share.share_viewport(get_viewport(), "shared_title", "shared_subject", "Standings de hoje!")

func setup_theme():
	$StandingTitle/VBoxContainer/AutoSizeRichTextLabel4.add_theme_color_override("default_color", UniversalDict.main_color)

func setup_header():
	mode_name.text = UniversalDict.mode_selected.to_upper()
	var date := Time.get_date_dict_from_system()
	match UniversalDict.locale:
		"en":
			store_name.text = UniversalDict.store_name.to_upper() + " %02d/%02d/%d" % [date.month, date.day, date.year]
		"ja":
			store_name.text = UniversalDict.store_name.to_upper() + " %02d年%02d月%d" % [date.year, date.month, date.day]
		_:
			store_name.text = UniversalDict.store_name.to_upper() + " %02d/%02d/%d" % [date.day, date.month, date.year]

func setup_destaques():
	var jogadores := UniversalDict.armory_data.values()

	setup_destaque(jogadores[0], heroi_1_front, heroi_1_bg, heroi_1_nome, heroi_1_vitorias)
	setup_destaque(jogadores[1], heroi_2_front, heroi_2_bg, heroi_2_nome, heroi_2_vitorias)
	setup_destaque(jogadores[2], heroi_3_front, heroi_3_bg, heroi_3_nome, heroi_3_vitorias)

func setup_destaque(jogador: Dictionary, front: TextureRect, background: TextureRect, nome: AutoSizeRichTextLabel, vitorias: RichTextLabel):
	nome.text = format_nome_jogador(jogador["Name"])
	vitorias.text = jogador["Wins"].to_upper()
	
	background.texture = HeroesDb.get_heroi_bg(jogador["Hero"])
	front.texture = HeroesDb.get_heroi_front(jogador["Hero"])

func format_nome_jogador(nome: String) -> String:
	var partes := nome.to_upper().split(" ")

	if partes.size() >= 2:
		return partes[0] + " " + partes[1]
	
	return nome.to_upper()


func setup_standings():
	SortStanding.sort_standing(tab, standing_less, standings_extra, standing_results_1)

func update_pagina_num():
	page_number.text = "%d/%d" % [tab.current_tab + 1, tab.get_tab_count()]

func _on_share_share_canceled() -> void:
	menu.visible = true

func _on_share_share_completed(_activity_type: String) -> void:
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
			
			if swipe_vector.length() >= MIN_SWIPE_DIST and abs(swipe_vector.x) > abs(swipe_vector.y):
				if swipe_vector.x < 0:
					_on_btn_proximo_pressed()
				else:
					_on_btn_voltar_pressed()


func _on_btn_home_pressed() -> void:
	anim_button(btn_home)
	SceneLoader.load_scene(home_scene)


func _on_btn_salvar_pressed() -> void:
	anim_button(btn_salvar)
	taking_screenshot()


func _on_btn_compartilhar_pressed() -> void:
	anim_button(btn_compartilhar)
	menu.visible = false
	await RenderingServer.frame_post_draw
	share_screenshot()
	menu.visible = true

func anim_button(button: TextureButton):
	Input.vibrate_handheld(50,0.2)
	var tween = create_tween()
	tween.tween_property(button,"offset_transform_scale", BUTTON_PRESS_SCALE, 0.3).set_trans(tween.TRANS_CUBIC).set_ease(tween.EASE_OUT)
	tween.tween_property(button,"offset_transform_scale", Vector2(1,1), 0.3).set_trans(tween.TRANS_BACK).set_ease(tween.EASE_OUT)

func _on_btn_hamburguer_pressed() -> void:
	anim_button(btn_hamburguer)
	anim_menu(hamburguer_open)

func anim_menu(open: bool):
	var tween = create_tween()
	if not open:
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
	anim_button(btn_voltar)
	mudar_pagina(-1)


func _on_btn_proximo_pressed() -> void:
	anim_button(btn_proximo)
	mudar_pagina(1)

func mudar_pagina(direcao: int):
	
	if mudando_pagina:
		return

	var current_page_index := tab.current_tab
	var target_page_index := current_page_index + direcao
	var total_pages = tab.get_tab_count()

	if target_page_index < 0 or target_page_index >= total_pages:
		return

	mudando_pagina = true

	disableButtons()
	
	var current_page = tab.get_child(tab.current_tab)
	var last_node_pos = current_page.offset_transform_position

	var tween_main: Tween = create_tween().set_parallel(true)
	tween_main.set_ease(tween_main.EASE_IN_OUT)
	tween_main.set_trans(tween_main.TRANS_EXPO)
	tween_main.tween_property(current_page,"offset_transform_position", Vector2(current_page.offset_transform_position.x , current_page.offset_transform_position.y + 100),1.0)
	tween_main.tween_property(current_page,"modulate:a", 0, 1.0)
	await tween_main.finished

	current_page.offset_transform_position = last_node_pos

	tab.current_tab = target_page_index

	var next_page = tab.get_child(target_page_index)
	last_node_pos = next_page.offset_transform_position

	next_page.offset_transform_position.y += 100

	tween_main = create_tween().set_parallel(true)
	tween_main.set_ease(tween_main.EASE_IN_OUT)
	tween_main.set_trans(tween_main.TRANS_EXPO)
	tween_main.tween_property(next_page,"offset_transform_position", Vector2(next_page.offset_transform_position.x , next_page.offset_transform_position.y - 100),1.0)
	tween_main.tween_property(next_page,"modulate:a", 1, 1.0)
	await tween_main.finished

	next_page.offset_transform_position = last_node_pos

	enableButtons()
	mudando_pagina = false

	update_pagina_num()

func disableButtons():
	get_tree().set_group("buttons", "disabled", true)


func enableButtons():
	get_tree().set_group("buttons", "disabled", false)
