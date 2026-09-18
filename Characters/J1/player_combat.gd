extends Node

@export var max_health: int = 100
var health: int = max_health

func take_damage(amount: int) -> void:
	health = max(health - amount, 0)
	if health <= 0:
		var body := get_parent()
		if body is CharacterBody2D:
			body.velocity = Vector2.ZERO
