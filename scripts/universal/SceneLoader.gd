extends Node

signal progress_changed(progress)
signal load_finished


const LOADING_SCREEN := preload("res://scenes/prefabs/loading_screen.tscn")
var loading_screen: CanvasLayer
var loaded_resource: PackedScene
var scene_path: String
var progress: Array = []
var use_sub_threads: bool = true
var scene_loaded: bool = false
var transition_finished: bool = false

func _ready() -> void:
	set_process(false)

func load_scene(_scene_path: String) -> void:
	scene_path = _scene_path

	scene_loaded = false
	transition_finished = false

	loading_screen = LOADING_SCREEN.instantiate()
	get_tree().root.add_child(loading_screen)

	loading_screen.transition_finished.connect(_on_transition_finished)
	
	start_load()
	
func start_load() -> void:
	var state = ResourceLoader.load_threaded_request(scene_path, "", use_sub_threads)
	if state == OK:
		set_process(true)

func _process(_delta: float) -> void:
	var load_status = ResourceLoader.load_threaded_get_status(scene_path, progress)
	SceneLoader.progress_changed.emit(progress[0])
	match load_status:
		ResourceLoader.THREAD_LOAD_LOADED:
			loaded_resource = ResourceLoader.load_threaded_get(scene_path)
			scene_loaded = true
			set_process(false)
			try_change_scene()

func try_change_scene() -> void:
	if scene_loaded and transition_finished:
		get_tree().change_scene_to_packed(loaded_resource)
		load_finished.emit()

func _on_transition_finished() -> void:
	transition_finished = true
	try_change_scene()