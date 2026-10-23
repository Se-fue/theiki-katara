extends Area2D

@export var NSP : String

#DURACION DEL FUNDIDO EN SEGUNDOS (CADA LADO)
@export var duracion : float = 0.4
#EVITA QUE SE ACTIVE DOS VECES
var usada : bool = false

func  _process(delta):
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not usada:
		change_scene(body)
		
func change_scene(body: Node2D):
	usada = true
	
	#CONGELA AL JUGADOR MIENTRAS SE OSCURECE
	body.set_physics_process(false)
	body.velocity = Vector2.ZERO
	
	#CREA LA PANTALLA NEGRA EN LA RAIZ, PARA QUE SOBREVIVA AL CAMBIO DE ESCENA
	var capa := CanvasLayer.new()
	capa.layer = 200
	var fundido := ColorRect.new()
	fundido.color = Color.BLACK
	fundido.set_anchors_preset(Control.PRESET_FULL_RECT)
	fundido.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fundido.modulate.a = 0.0
	capa.add_child(fundido)
	get_tree().root.add_child(capa)
	
	#FUNCION ESTATICA: SIGUE CORRIENDO AUNQUE ESTA PUERTA SE BORRE AL CAMBIAR DE ESCENA
	_transicion(get_tree(), capa, fundido, NSP, duracion)

#OSCURECE, CAMBIA DE ESCENA Y ACLARA
static func _transicion(arbol: SceneTree, capa: CanvasLayer, fundido: ColorRect, ruta: String, dur: float) -> void:
	#OSCURECE
	var t := capa.create_tween()
	t.tween_property(fundido, "modulate:a", 1.0, dur)
	await t.finished
	
	#CAMBIA LA ESCENA (LA MISMA LINEA QUE TENIAS) Y ESPERA A QUE CARGUE
	arbol.change_scene_to_file(ruta)
	await arbol.process_frame
	await arbol.process_frame
	
	#ACLARA Y BORRA LA PANTALLA NEGRA
	t = capa.create_tween()
	t.tween_property(fundido, "modulate:a", 0.0, dur)
	await t.finished
	capa.queue_free()
