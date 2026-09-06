extends CharacterBody2D
class_name EnemyKnight

## Caballero enemigo basado en la misma idea de movimiento del Jugador1:
## CharacterBody2D + gravedad + movimiento horizontal + salto + AnimatedSprite2D.
## El jugador NO se modifica.

@export_category("Objetivo")
@export var target_path: NodePath = NodePath("../Jugador1")
@export var detection_distance: float = 500.0
@export var lose_target_distance: float = 700.0

@export_category("Movimiento")
@export var walk_speed: float = 82.0
@export var run_speed: float = 125.0
@export var acceleration: float = 700.0
@export var braking: float = 900.0
@export var jump_velocity: float = -360.0
@export var jump_height_difference: float = 38.0
@export var jump_cooldown: float = 0.75
@export var edge_check_distance: float = 18.0

@export_category("Ataque")
@export var attack_distance: float = 58.0
@export var attack_vertical_distance: float = 46.0
@export var attack_cooldown: float = 1.10
@export var attack_hit_start: float = 0.22
@export var attack_hit_end: float = 0.52

var target: Node2D = null
var facing: float = -1.0
var attack_cooldown_timer: float = 0.0
var attack_time: float = 0.0
var jump_cooldown_timer: float = 0.0
var attacking: bool = false
var attack_has_hit: bool = false
var dead: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var ledge_ray_left: RayCast2D = $LedgeRayLeft
@onready var ledge_ray_right: RayCast2D = $LedgeRayRight


func _ready() -> void:
	_find_player()

	attack_area.monitoring = false
	attack_shape.disabled = true

	if not sprite.animation_finished.is_connected(_on_animation_finished):
		sprite.animation_finished.connect(_on_animation_finished)

	_play_animation(&"Idle")
	_face_target()


func _physics_process(delta: float) -> void:
	if dead:
		return

	# Temporizadores.
	attack_cooldown_timer = maxf(0.0, attack_cooldown_timer - delta)
	jump_cooldown_timer = maxf(0.0, jump_cooldown_timer - delta)

	# Gravedad exactamente como una CharacterBody2D de plataformas.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Encontrar al jugador si todavía no tenemos referencia.
	if target == null or not is_instance_valid(target):
		_find_player()

	if target == null or not is_instance_valid(target):
		_stop(delta)
		_update_animation()
		move_and_slide()
		return

	var horizontal_distance: float = absf(target.global_position.x - global_position.x)
	var vertical_difference: float = target.global_position.y - global_position.y
	var vertical_distance: float = absf(vertical_difference)

	# Si está muy lejos, deja de perseguirlo temporalmente.
	if horizontal_distance > lose_target_distance:
		_stop(delta)
		_update_animation()
		move_and_slide()
		return

	# Mirar siempre al jugador cuando está dentro del rango de detección.
	if horizontal_distance <= detection_distance:
		_face_target()

	# Durante el ataque el caballero no camina.
	if attacking:
		_process_attack(delta)
		move_and_slide()
		return

	# Ataque cuando está enfrente y a una altura razonable.
	if horizontal_distance <= attack_distance \
	and vertical_distance <= attack_vertical_distance \
	and attack_cooldown_timer <= 0.0 \
	and is_on_floor():
		_start_attack()
		move_and_slide()
		return

	# Saltar si el jugador está claramente por encima.
	if is_on_floor() \
	and vertical_difference < -jump_height_difference \
	and horizontal_distance <= detection_distance \
	and jump_cooldown_timer <= 0.0:
		_start_jump()

	# Perseguir al jugador.
	_follow_player(delta, horizontal_distance)
	move_and_slide()


func _find_player() -> void:
	if target != null and is_instance_valid(target):
		return

	if target_path != NodePath(""):
		target = get_node_or_null(target_path) as Node2D

	if target == null:
		var scene: Node = get_tree().current_scene
		if scene != null:
			target = scene.find_child("Jugador1", true, false) as Node2D


func _follow_player(delta: float, horizontal_distance: float) -> void:
	if target == null or not is_instance_valid(target):
		_stop(delta)
		return

	var direction: float = signf(target.global_position.x - global_position.x)

	if is_zero_approx(direction):
		_stop(delta)
		return

	# Nunca avanza fuera del borde de la plataforma.
	if is_on_floor() and not _has_floor_ahead(direction):
		_stop(delta)
		return

	var desired_speed: float = run_speed if horizontal_distance > 180.0 else walk_speed
	var desired_velocity: float = direction * desired_speed

	velocity.x = move_toward(velocity.x, desired_velocity, acceleration * delta)

	# En el aire sigue intentando llegar al jugador, pero sin perder la gravedad.
	if not is_on_floor():
		velocity.x = move_toward(velocity.x, desired_velocity, acceleration * 0.55 * delta)
		return

	if horizontal_distance > 180.0:
		_play_animation(&"Run")
	else:
		_play_animation(&"Walk")


func _stop(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, braking * delta)

	if is_on_floor() and not attacking:
		_play_animation(&"Idle")


func _start_jump() -> void:
	velocity.y = jump_velocity
	jump_cooldown_timer = jump_cooldown
	_play_animation(&"Jump")


func _has_floor_ahead(direction: float) -> bool:
	# Los RayCast están colocados cerca de los pies y apuntan hacia abajo.
	if direction < 0.0:
		return ledge_ray_left.is_colliding()

	return ledge_ray_right.is_colliding()


func _face_target() -> void:
	if target == null or not is_instance_valid(target):
		return

	if target.global_position.x < global_position.x:
		facing = -1.0
	else:
		facing = 1.0

	sprite.scale.x = facing
	attack_area.position.x = 25.0 * facing


func _start_attack() -> void:
	attacking = true
	attack_time = 0.0
	attack_has_hit = false
	attack_cooldown_timer = attack_cooldown
	velocity.x = 0.0

	_face_target()
	_play_animation(&"Attack")

	# La zona de espada se activa durante el ataque.
	attack_area.monitoring = true
	attack_shape.disabled = false


func _process_attack(delta: float) -> void:
	velocity.x = 0.0
	attack_time += delta

	# Puede corregir la orientación antes de golpear.
	_face_target()

	if attack_time >= attack_hit_start \
	and attack_time <= attack_hit_end \
	and not attack_has_hit:
		_check_attack_hit()

	if attack_time > attack_hit_end:
		attack_area.monitoring = false
		attack_shape.disabled = true


func _check_attack_hit() -> void:
	if target == null or not is_instance_valid(target):
		return

	var bodies: Array[Node2D] = attack_area.get_overlapping_bodies()

	for body: Node2D in bodies:
		if body == target:
			attack_has_hit = true

			# El jugador actual no tiene sistema de vida, por lo que NO
			# se modifica. Si más adelante tiene receive_damage(), se usará.
			if body.has_method("receive_damage"):
				body.receive_damage(1)

			break


func _on_animation_finished() -> void:
	if sprite.animation == &"Attack":
		attack_area.monitoring = false
		attack_shape.disabled = true
		attacking = false
		attack_time = 0.0
		attack_has_hit = false
		_play_animation(&"Idle")

	elif sprite.animation == &"Hit":
		_play_animation(&"Idle")

	elif sprite.animation == &"Death":
		queue_free()


func _update_animation() -> void:
	if attacking or dead:
		return

	if not is_on_floor():
		if velocity.y < 0.0:
			_play_animation(&"Jump")
		else:
			_play_animation(&"Fall")

	elif absf(velocity.x) > 8.0:
		if absf(velocity.x) > 105.0:
			_play_animation(&"Run")
		else:
			_play_animation(&"Walk")

	else:
		_play_animation(&"Idle")


func _play_animation(animation_name: StringName) -> void:
	if sprite.sprite_frames == null:
		return

	if not sprite.sprite_frames.has_animation(animation_name):
		return

	if sprite.animation != animation_name:
		sprite.play(animation_name)


## Entrada opcional para que futuros ataques puedan dañar al enemigo.
func receive_damage(amount: int = 1) -> void:
	if dead or amount <= 0:
		return

	_play_animation(&"Hit")


func die() -> void:
	if dead:
		return

	dead = true
	attacking = false
	attack_area.monitoring = false
	attack_shape.disabled = true
	velocity = Vector2.ZERO
	_play_animation(&"Death")
