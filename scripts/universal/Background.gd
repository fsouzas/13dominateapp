extends Node

@onready var background_texture: TextureRect = $bg

func _ready() -> void:
    if not ThemeManager.theme_changed.is_connected(_on_theme_changed):
        ThemeManager.theme_changed.connect(_on_theme_changed)
    
    _on_theme_changed()

func _on_theme_changed():
    background_texture.texture = ThemeManager.get_background_image()
