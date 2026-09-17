extends CharacterBody2D

@export var max_health: int = 45
@export var move_speed: float = 95.0
@export var chase_distance: float = 300.0
@export var attack_distance: float = 60.0
@export var attack_damage: int = 8

var health: int = max_health
var target: Node2D
var busy := false
var attack_cooldown := 0.0
var facing := -1.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
    target = get_parent().get_node_or_null("Jugador1")
    sprite.play("Idle")

func _physics_process(delta: float) -> void:
    if attack_cooldown > 0.0:
        attack_cooldown -= delta
    if busy:
        velocity = velocity.move_toward(Vector2.ZERO, 500.0 * delta)
        move_and_slide()
        return

    if target == null or not is_instance_valid(target):
        sprite.play("Idle")
        velocity = velocity.move_toward(Vector2.ZERO, 500.0 * delta)
        move_and_slide()
        return

    var distance := global_position.distance_to(target.global_position)
    var to_target := target.global_position - global_position

    if distance <= attack_distance and attack_cooldown <= 0.0:
        _attack()
        return

    if distance <= chase_distance:
        facing = 1.0 if to_target.x > 0.0 else -1.0
        # El espectro flota libremente hacia el objetivo (no está sujeto al suelo)
        velocity = to_target.normalized() * move_speed
        sprite.flip_h = facing < 0.0
        sprite.play("Run")
    else:
        velocity = velocity.move_toward(Vector2.ZERO, 500.0 * delta)
        sprite.play("Idle")

    move_and_slide()

func _attack() -> void:
    busy = true
    velocity = Vector2.ZERO
    sprite.flip_h = facing < 0.0
    sprite.play("Attack")
    await sprite.animation_finished
    if is_instance_valid(target) and global_position.distance_to(target.global_position) <= attack_distance + 10.0:
        var combat := target.get_node_or_null("PlayerCombat")
        if combat and combat.has_method("take_damage"):
            combat.take_damage(attack_damage)
    attack_cooldown = 0.7
    busy = false

func take_damage(amount: int) -> void:
    health = max(health - amount, 0)
    if health <= 0:
        queue_free()
