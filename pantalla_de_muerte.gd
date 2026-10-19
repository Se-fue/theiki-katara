extends CanvasLayer

#SEÑAL QUE SE EMITE CUANDO SE HACE CLICK EN EL BOTON
signal reaparecer_solicitado

func _ready() -> void:
	#CAPA ALTA PARA QUE QUEDE ENCIMA DE TODO Y OCULTA AL INICIO
	layer = 100
	visible = false
	
	#CONSTRUYE LA INTERFAZ (FONDO + TEXTO + BOTON)
	_crear_interfaz()
	
	#BUSCA AL JUGADOR POR GRUPO
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador == null:
		push_warning("PantallaMuerte: no se encontro ningun nodo en el grupo 'jugador'")
		return
	
	#CAMBIO: REVISA QUE EL JUGADOR TENGA LA SEÑAL Y LA FUNCION ANTES DE CONECTAR
	if not jugador.has_signal("murio") or not jugador.has_method("completar_reaparicion"):
		push_warning("PantallaMuerte: el jugador no tiene la señal 'murio' o la funcion 'completar_reaparicion'")
		return
	
	#CUANDO EL JUGADOR MUERE, SE MUESTRA LA PANTALLA
	jugador.murio.connect(mostrar)
	#CUANDO SE HACE CLICK, EL JUGADOR COMPLETA LA REAPARICION
	reaparecer_solicitado.connect(jugador.completar_reaparicion)

#CREA FONDO OSCURO, TEXTO Y BOTON POR CODIGO
func _crear_interfaz() -> void:
	#FONDO OSCURO QUE CUBRE TODA LA PANTALLA
	var fondo := ColorRect.new()
	fondo.color = Color(0, 0, 0, 0.7)
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(fondo)
	
	#CONTENEDOR QUE CENTRA EL TEXTO Y EL BOTON
	var centro := CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo.add_child(centro)
	
	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 20)
	centro.add_child(caja)
	
	#TEXTO
	var texto := Label.new()
	texto.text = "HAS MUERTO"
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto.add_theme_font_size_override("font_size", 48)
	caja.add_child(texto)
	
	#BOTON REAPARECER
	var boton := Button.new()
	boton.text = "Reaparecer"
	boton.custom_minimum_size = Vector2(220, 60)
	#SIN FOCO: ENTER, ESPACIO O EL MANDO NO PUEDEN PRESIONARLO, SOLO EL CLICK
	boton.focus_mode = Control.FOCUS_NONE
	#CAMBIO: FUNCION ANONIMA, YA NO NECESITA UNA FUNCION APARTE
	boton.pressed.connect(func():
		visible = false
		reaparecer_solicitado.emit()
	)
	caja.add_child(boton)

#MUESTRA LA PANTALLA Y EL CURSOR (SE EJECUTA POR LA SEÑAL murio DEL JUGADOR)
func mostrar() -> void:
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
