extends CharacterBody2D

const Speed = 130
@onready var area = $Area2D
var direction = Vector2.LEFT

func _ready():
	area.body_entered.connect(changeDirection)
func _physics_process(delta: float) -> void:
# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if direction.x > 0:
		$AnimatedSprite2D.play("walk")
		$AnimatedSprite2D.scale.x = -1
	else:
		$AnimatedSprite2D.play("walk")
		$AnimatedSprite2D.scale.x = 1
	velocity.x = direction.x * Speed
	move_and_slide()
	
func changeDirection(_body):
	pass
