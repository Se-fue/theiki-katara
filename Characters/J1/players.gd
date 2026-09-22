extends CharacterBody2D

#VELOCIDAD CAMINAR
@onready var Speed : float = 200
#VELOCIDAD CORRER
@onready var Speed_run : float = 500
#FUERZA SALTO
@onready var Jump : int = -600
#TIEMPO DE MANTENERSE PRESIONADO EL BOTON
@onready var Jump_T : float = 0.4
#FUERZA DEL DASH
@onready var Dash_speed : float = 700
#COOLDOWN DEL DASH
@onready var Dash_CD : float = 0.125
#GRAVEDAD
@onready var Gravity : float = 0.02
#DURACION DEL DASH
@onready var dash_time : float = 0.25

#VARIABLE QUE DETERMINA A QUE LADO MIRA EL PERSONAJE
var mira = 1
#VELOCIDAD ACTUAL
var current_speed = 0.0
# Bandera para saber si el dash está activo en este momento
var is_dashing : bool = false
# Bandera para saber si el dash está en cooldown
var can_dash : bool = true

# ESTADOS DEL PERSONAJE
enum mov_states {
	idle,
	walk,
	run,
	jump,
	fall,
	dash,
	atack
}

var cur_mov_state : mov_states = mov_states.idle


func _physics_process(delta: float) -> void:
	#OBTIENE LA DIRECCION DEL MOVIMIENTO
	var direction = Input.get_axis("Left", "Right")
	
	#CAMBIA HACIA DONDE MIRA EL PERSONAJE
	if direction > 0:
		mira = -1
		$AnimatedSprite2D.scale.x = -1
		
	elif direction < 0:
		mira = 1
		$AnimatedSprite2D.scale.x = 1
		
	if not is_on_floor():
		velocity += get_gravity() * Gravity
		
	#DETECTA CUANDO SE SUELTA EL SALTO
	if Input.is_action_just_released("Jump") and velocity.y < 0:
		velocity.y = Jump / 10
		
	#DETECTA CUANDO SE PRESIONA EL SALTO
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = Jump
		
	#CUANDO DASH ES VERDADERO CAMBIA LA GRAVEDAD Y LA VELOCIDAD
	if(dashing()):	
		current_speed = Dash_speed
		Gravity=0
	else:
		Gravity=0.02
		
	#DECIDE A QUÉ ESTADO CAMBIAR SEGÚN EL INPUT ACTUAL
	#SE AGREGÓ ESTA CONDICIÓN NUEVA: SI ESTÁ DASHEANDO, TIENE PRIORIDAD SOBRE TODO LO DEMÁS
	#SIN ESTO, cur_mov_state NUNCA CAMBIABA A "dash" Y EL MATCH DE ABAJO NUNCA APLICABA LA VELOCIDAD DEL DASH
	if dashing():
		cur_mov_state = mov_states.dash
	elif not is_on_floor():
		cur_mov_state = mov_states.fall if velocity.y >= 0 else mov_states.jump
	elif Input.is_action_just_pressed("Jump"):
		cur_mov_state = mov_states.jump
	elif direction != 0:
		if Input.is_action_pressed("Sprint"):
			cur_mov_state = mov_states.run
		else:
			cur_mov_state = mov_states.walk
	else:
		cur_mov_state = mov_states.idle
		
	#DETERMINA EL ESTADO ACTUAL
	match cur_mov_state:
		mov_states.idle:
			current_speed = 0.0
			velocity.x = move_toward(velocity.x, 0, Speed)
			$AnimatedSprite2D.play("Idle")

		mov_states.walk:
			current_speed = Speed
			velocity.x = direction * current_speed
			$AnimatedSprite2D.play("Walk")

		mov_states.run:
			current_speed = Speed_run
			velocity.x = direction * current_speed
			$AnimatedSprite2D.play("Run")

		mov_states.jump:
			$AnimatedSprite2D.play("Jump")
			var target_speed = Speed_run if Input.is_action_pressed("Sprint") else Speed
			velocity.x = move_toward(velocity.x, direction * target_speed, target_speed * delta * 4)

		mov_states.fall:
			$AnimatedSprite2D.play("Fall")
			var target_speed = Speed_run if Input.is_action_pressed("Sprint") else Speed
			velocity.x = move_toward(velocity.x, direction * target_speed, target_speed * delta * 4)

		mov_states.dash:
			# Durante el dash, la velocidad se fija y no la toca la gravedad ni el input normal
			velocity.x = Dash_speed * mira * -1
			velocity.y = 0
			$AnimatedSprite2D.play("Dash")
	
	move_and_slide()
	print(current_speed)

func dashing():
	return not $Timer.is_stopped()

func start_dash():
	#SE AGREGÓ ESTA LÍNEA: FUERZA A QUE EL TIMER SEA "ONE SHOT" POR CÓDIGO
	#SIN ESTO, SI EL NODO Timer NO TIENE "One Shot" ACTIVADO EN EL INSPECTOR, SE REPITE SOLO EN BUCLE
	#Y dashing() NUNCA VUELVE A DAR "false", ASÍ QUE EL DASH NO SE DESACTIVA NUNCA
	$Timer.one_shot = true
	#SE AGREGÓ ESTA LÍNEA: BLOQUEA NUEVOS DASHES HASTA QUE TERMINE EL COOLDOWN
	can_dash = false
	$Timer.wait_time = dash_time
	$Timer.start()

#FUNCIÓN NUEVA: SE LLAMA CUANDO EL TIMER TERMINA, Y VUELVE A PERMITIR DASHEAR
#DEBES CONECTAR LA SEÑAL "timeout" DEL NODO Timer A ESTA FUNCIÓN DESDE EL PANEL DE NODO -> SEÑALES
func _on_timer_timeout():
	can_dash = true

func _input(event):
	#DASH AL PRESIONAR LA TECLA
	if Input.is_action_just_pressed("Sprint") and can_dash and not dashing():
		start_dash()
	
	
	
