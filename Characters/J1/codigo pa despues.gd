extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
var jumping = false

func _on_jump_timer_timeout() -> void:
	if(jumping):
		jumping=false
		self.position.y = self.position.y + 10
	else:
		jumping=true
		self.position.y = self.position.y - 10
