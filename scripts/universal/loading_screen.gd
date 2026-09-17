extends CanvasLayer

@onready var transition_shader: ColorRect = %transition
signal transition_finished

func _ready() -> void:
	print("LOADING SCREEN READY")
	set_transition()
	SceneLoader.load_finished.connect(_on_load_finished)

func set_transition():
	print("SET TRANSITION STARTED")
	transition_shader.material.set_shader_parameter("color", ThemeManager.get_primary_color())
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	
	tween.tween_method(
		func(value: float):
			print("TWEEN VALUE: ", value)
			transition_shader.material.set_shader_parameter("progress", value),
			0.0,
			0.5,
			0.7
	)

	await tween.finished
	print("TWEEN FINISHED")
	transition_finished.emit()

func _on_load_finished():
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_method(func(value:float):transition_shader.material.set_shader_parameter("progress", value), 0.5, 1.0, 0.7)
	await tween.finished
	queue_free()
