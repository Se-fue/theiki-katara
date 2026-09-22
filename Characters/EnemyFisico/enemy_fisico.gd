# El enemigo hereda de CharacterBody2D para utilizar gravedad, velocidad,
# detección de suelo, colisiones con paredes y la función move_and_slide().
extends CharacterBody2D


# Velocidad horizontal del enemigo.
# El valor 140.0 es semejante a la velocidad normal del jugador.
const VELOCIDAD: float = 140.0

# Fuerza vertical del salto.
# Es negativa porque en Godot 2D el eje Y disminuye al subir.
# Se utiliza el mismo valor base de salto que aparece en el jugador.
const FUERZA_SALTO: float = -500.0


# @export hace visible este valor en el Inspector de Godot.
# El enemigo solamente comienza a perseguir cuando el jugador se encuentra
# dentro de esta distancia, medida en píxeles.
@export var distancia_deteccion: float = 300.0


# Guarda una referencia al nodo Jugador1.
# Empieza en null porque el jugador se busca cuando la escena ya está cargada.
var jugador: CharacterBody2D = null

# Indica el sentido horizontal del movimiento:
# -1.0 significa izquierda, 1.0 significa derecha y 0.0 significa detenido.
var direccion: float = 0.0


# Referencia al AnimatedSprite2D del enemigo.
# Se utiliza para reproducir Idle y Run, y para voltear el dibujo.
@onready var animacion: AnimatedSprite2D = $AnimatedSprite2D


# Se ejecuta una sola vez cuando el enemigo entra en la escena.
func _ready() -> void:
	# Intenta encontrar al jugador desde el primer momento.
	_buscar_jugador()

	# Mientras todavía no persigue, muestra la animación de reposo.
	animacion.play("Idle")


# Se ejecuta en cada actualización de físicas.
# delta representa el tiempo transcurrido desde la actualización anterior.
func _physics_process(delta: float) -> void:
	# Aplica la gravedad cuando el enemigo está en el aire.
	# get_gravity() utiliza la gravedad configurada por el proyecto.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Si todavía no existe una referencia válida al jugador, vuelve a buscarlo.
	# is_instance_valid también detecta si el nodo anterior fue eliminado.
	if jugador == null or not is_instance_valid(jugador):
		_buscar_jugador()

	# Solamente calcula persecución si encontró al jugador.
	if jugador != null:
		# Calcula la distancia total entre el enemigo y el jugador.
		var distancia: float = global_position.distance_to(jugador.global_position)

		# Si entra en el rango establecido, comienza la persecución.
		if distancia <= distancia_deteccion:
			# Resta las posiciones horizontales y usa signf() para obtener -1 o 1.
			direccion = signf(jugador.global_position.x - global_position.x)

			# Multiplica la dirección por la velocidad para moverse hacia el jugador.
			velocity.x = direccion * VELOCIDAD

			# Voltea el sprite cuando el enemigo se desplaza hacia la izquierda.
			animacion.flip_h = direccion < 0.0

			# Reproduce la animación de movimiento.
			animacion.play("Run")

			# Si está apoyado en el piso y encuentra una pared, salta.
			# Esto evita que se quede empujando el obstáculo para siempre.
			if is_on_floor() and is_on_wall():
				velocity.y = FUERZA_SALTO
		else:
			# Si el jugador está lejos, el enemigo se detiene.
			_detenerse()
	else:
		# También se detiene si el jugador todavía no fue encontrado.
		_detenerse()

	# Ejecuta el movimiento y resuelve las colisiones contra el suelo y paredes.
	move_and_slide()


# Busca recursivamente un nodo llamado Jugador1 dentro de la escena actual.
func _buscar_jugador() -> void:
	# current_scene devuelve la escena que el árbol está ejecutando actualmente.
	var escena: Node = get_tree().current_scene

	# Se comprueba que exista antes de intentar buscar dentro de ella.
	if escena != null:
		# true permite buscar también dentro de los hijos y nietos de la escena.
		# El resultado se convierte a CharacterBody2D para utilizar su posición.
		jugador = escena.find_child("Jugador1", true, false) as CharacterBody2D


# Detiene suavemente el movimiento horizontal y activa la animación Idle.
func _detenerse() -> void:
	# Marca que no existe una dirección activa.
	direccion = 0.0

	# Acerca velocity.x a cero sin afectar la velocidad vertical de la gravedad.
	velocity.x = move_toward(velocity.x, 0.0, VELOCIDAD)

	# Muestra la animación de reposo.
	animacion.play("Idle")

