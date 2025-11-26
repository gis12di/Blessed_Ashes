extends Label

func _ready() -> void:
	GlobalSettings.connect("fps_displayed", Callable(self, "_on_fps_displayed"))
	visible = Save.game_data.display_fps
func _process(delta: float) -> void:
	text = "FPS: %s"% [Engine.get_frames_per_second()]
	#print(Engine.get_frames_per_second())

func _on_fps_displayed(value):
	visible=value
	
