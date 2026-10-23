extends CanvasLayer

#DURACION DEL FUNDIDO EN SEGUNDOS (CADA LADO)
var duracion : float = 0.4
#EVITA QUE SE ACTIVEN DOS TRANSICIONES A LA VEZ
var ocupado : bool = false
#GUARDA POR DONDE ENTRASTE (ESCENA Y POSICION) PARA PODER REGRESAR
var historial : Array = []
#PANTALLA NEGRA QUE SE DESVANECE
var fundido : ColorRect

func _ready() -> void:
	#CAPA ALTA PARA QUE QUEDE ENCIMA DE TODO
	layer = 200
	fundido = ColorRect.new()
	fundido.color = Color.BLACK
	fundido.set_anchors_preset(Control.PRESET_FULL_RECT)
	#NO BLOQUEA EL MOUSE
	fundido.mouse_filter = Control.MOUSE_FILTER_IGNORE
	#EMPIEZA TRANSPARENTE
	fundido.modulate.a = 0.0
	add_child(fundido)

#CAMBIA DE ESCENA CON FUNDIDO
#ruta: ESCENA DESTINO | id_spawn: NOMBRE DEL Marker2D DONDE APARECE | regresando: true = VUELVE POR DONDE ENTRO
func ir_a(ruta: String, id_spawn: String = "", regresando: bool = false) -> void:
	if ocupado:
		return
	ocupado = true
	
	var jugador = get_tree().get_first_node_in_group("jugador")
	var pos_regreso := Vector2.ZERO
	
	if regresando:
		#SI NO HAY HISTORIAL NO HAY A DONDE REGRESAR
		if historial.is_empty():
			ocupado = false
			return
		var origen = historial.pop_back()
		ruta = origen["escena"]
		pos_regreso = origen["pos"]
	elif jugador:
		#GUARDA DE DONDE VIENES ANTES DE CAMBIAR
		historial.push_back({
			"escena": get_tree().current_scene.scene_file_path,
			"pos": jugador.global_position
		})
	
	#CONGELA AL JUGADOR MIENTRAS SE OSCURECE
	if jugador:
		jugador.set_physics_process(false)
		jugador.velocity = Vector2.ZERO
	
	#OSCURECE
	var t = create_tween()
	t.tween_property(fundido, "modulate:a", 1.0, duracion)
	await t.finished
	
	#CAMBIA LA ESCENA Y ESPERA A QUE CARGUE
	get_tree().change_scene_to_file(ruta)
	await get_tree().process_frame
	await get_tree().process_frame
	
	#COLOCA AL JUGADOR EN LA NUEVA ESCENA
	var nuevo = get_tree().get_first_node_in_group("jugador")
	if nuevo:
		if regresando:
			nuevo.global_position = pos_regreso
		elif id_spawn != "":
			for punto in get_tree().get_nodes_in_group("spawn"):
				if punto.name == id_spawn:
					nuevo.global_position = punto.global_position
					break
	
	#ACLARA
	t = create_tween()
	t.tween_property(fundido, "modulate:a", 0.0, duracion)
	await t.finished
	
	#PEQUEÑA ESPERA PARA QUE LA PUERTA DONDE APARECES NO SE ACTIVE DE NUEVO
	await get_tree().create_timer(0.2).timeout
	ocupado = false
