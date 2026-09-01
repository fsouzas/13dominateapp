extends Control

var timer = 5

func _ready() -> void:
	SignalBus.error_msg.connect(push_notification)


func push_notification(message, message_type):
	%notification_text.text = message
	var tween = create_tween()
	tween.set_trans(tween.TRANS_EXPO).set_ease(tween.EASE_IN_OUT)
	tween.tween_property(%push_notification,"offset_transform_position",Vector2(0,100),0.5)
	tween.tween_interval(timer)
	tween.tween_property(%push_notification,"offset_transform_position",Vector2(0,0),0.5)
