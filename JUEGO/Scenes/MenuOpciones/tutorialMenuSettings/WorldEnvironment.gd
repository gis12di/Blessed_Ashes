extends WorldEnvironment


func _ready() -> void:
	GlobalSettings.connect("brightness_updated", Callable(self, "_on_brightness_updated"))
	
func _on_brightness_updated(value):
	environment.adjustment_brightness = value
