extends Node

@export var share : Share

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

@onready var standing_size : int = 3
@onready var num_standings : int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	share.set_share_target(true)
	
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
	
	SortStanding.sort_standing(self, standing_less, standings_extra, standing_results_1)
	

	
func _on_button_pressed() -> void:
	%Button.visible = false
	await RenderingServer.frame_post_draw
	save_and_share_screenshot()

func save_and_share_screenshot():
	share.share_viewport(get_viewport(), "shared_title", "shared_subject", "Standings de hoje!")
	pass


func _on_share_share_canceled() -> void:
	%Button.visible = true


func _on_share_share_completed(activity_type: String) -> void:
	%Button.visible = true
