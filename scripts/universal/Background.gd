extends Node

@onready var background_texture: TextureRect = $bg
@onready var color_main = $color

func _ready() -> void:
    if not ThemeManager.theme_changed.is_connected(_on_theme_changed):
        ThemeManager.theme_changed.connect(_on_theme_changed)
    ThemeManager.bg_changed.connect(_on_bg_changed)
    ThemeManager.primary_color_changed.connect(_on_primary_color_changed)
    _on_theme_changed()

func _on_theme_changed():
    background_texture.texture = ThemeManager.get_background_image()
    color_main.color = ThemeManager.get_primary_color()

func _on_bg_changed(bg_path):
    background_texture.texture = load(bg_path)

func _on_primary_color_changed(color: Color):
    color_main.color = color