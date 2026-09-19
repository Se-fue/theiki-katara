extends CharacterBody2D

signal health_changed(current: int, maximum: int)
signal player_died

const SPEED: float = 180.0
const SPRINT_SPEED: float = 260.0
const JUMP_FORCE: float = -420.0
const DASH_SPEED: float = 520.0
const ATTACK_RANGE: float = 78.0
const ATTACK_DAMAGE: int = 20

@export var max_health: int = 120
var health: int = 120
var facing: float = 1.0
var jumps_left: int = 2
var attacking: bool = false
var dashing: bool = false
var shielding: bool = false
var invulnerable: bool = false
var dash_ready: bool = true

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_sprite: AnimatedSprite2D = $AttackSprite

func _ready() -> void:
	add_to_group("player")
	health = max_health
	health_changed.emit(health, max_health)

func _physics_process(delta: float) -> void:
	shielding = Input.is_action_pressed("Shield") and not attacking and is_on_floor()
	if not is_on_floor() and not dashing:
		velocity += get_gravity() * delta
	else:
		jumps_left = 2

	if Input.is_action_just_pressed("Jump") and jumps_left > 0 and not attacking:
		velocity.y = JUMP_FORCE
		jumps_left -= 1

	if Input.is_action_just_pressed("Dash") and dash_ready and not attacking:
		_start_dash()

	if Input.is_action_just_pressed("Atack") and not attacking and not shielding:
		_start_attack()

	if dashing:
		velocity.x = facing * DASH_SPEED
		move_and_slide()
		return

	if attacking or shielding:
		velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
		move_and_slide()
		return

	var direction: float = Input.get_axis("Left", "Right")
	if direction != 0.0:
		facing = direction
		sprite.scale.x = -1.0 if facing > 0.0 else 1.0
	var speed: float = SPRINT_SPEED if Input.is_action_pressed("Sprint") else SPEED
	velocity.x = direction * speed if direction != 0.0 else move_toward(velocity.x, 0.0, 1000.0 * delta)
	_update_animation(direction)
	move_and_slide()

func _update_animation(direction: float) -> void:
	if not is_on_floor():
		sprite.play("Jump" if velocity.y < 0.0 else "Fall")
	elif direction == 0.0:
		sprite.play("Idle")
	elif Input.is_action_pressed("Sprint"):
		sprite.play("Run")
	else:
		sprite.play("Walk")

func _start_attack() -> void:
	attacking = true
	sprite.visible = false
	attack_sprite.visible = true
	attack_sprite.play("AttackRight" if facing > 0.0 else "AttackLeft")
	await get_tree().create_timer(0.18).timeout
	_damage_attack_hitbox()
	await attack_sprite.animation_finished
	attack_sprite.visible = false
	sprite.visible = true
	attacking = false

func _damage_attack_hitbox() -> void:
	var attack_shape := RectangleShape2D.new()
	attack_shape.size = Vector2(ATTACK_RANGE, 54.0)
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = attack_shape
	query.transform = Transform2D(0.0, global_position + Vector2(facing * 44.0, -22.0))
	query.collision_mask = 2
	query.collide_with_bodies = true
	query.collide_with_areas = false
	query.exclude = [get_rid()]
	var hits: Array[Dictionary] = get_world_2d().direct_space_state.intersect_shape(query, 8)
	for hit: Dictionary in hits:
		var enemy: Object = hit.get("collider")
		if is_instance_valid(enemy) and enemy.has_method("take_damage"):
			enemy.call("take_damage", ATTACK_DAMAGE, global_position)

func _start_dash() -> void:
	dashing = true
	dash_ready = false
	invulnerable = true
	await get_tree().create_timer(0.16).timeout
	dashing = false
	invulnerable = false
	await get_tree().create_timer(0.65).timeout
	dash_ready = true

func take_damage(amount: int) -> void:
	if invulnerable or health <= 0:
		return
	var final_damage: int = maxi(1, int(amount * 0.25)) if shielding else amount
	health = maxi(0, health - final_damage)
	health_changed.emit(health, max_health)
	invulnerable = true
	modulate = Color(1.0, 0.35, 0.35)
	await get_tree().create_timer(0.12).timeout
	modulate = Color.WHITE
	if health <= 0:
		player_died.emit()
		set_physics_process(false)
		await get_tree().create_timer(0.8).timeout
		get_tree().reload_current_scene()
	else:
		await get_tree().create_timer(0.45).timeout
		invulnerable = false

func heal(amount: int) -> void:
	health = mini(max_health, health + amount)
	health_changed.emit(health, max_health)
