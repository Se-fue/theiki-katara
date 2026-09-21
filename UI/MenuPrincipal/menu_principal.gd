# Este script controla todas las acciones del menú principal.
# Se coloca en un nodo Control porque el menú forma parte de la interfaz 2D.
extends Control


# Ruta de la escena que se abrirá al presionar el botón JUGAR.
# Se guarda en una constante para tener la ruta escrita en un solo lugar.
# Si después cambia el primer nivel, solamente debe modificarse esta línea.
const ESCENA_JUEGO: String = "res://Niveles/Zonas/Z1/Z1N1.tscn"


# @onready espera hasta que todos los nodos de la escena estén disponibles.
# Después guarda una referencia directa a cada elemento que utilizaremos.
# Esto evita buscar repetidamente el mismo nodo durante la ejecución.

# Contiene el título y los cinco botones del menú principal.
@onready var contenido_principal: VBoxContainer = $Centro/ContenidoPrincipal

# Panel que muestra la lista de teclas del jugador.
@onready var panel_controles: CenterContainer = $PanelControles

# Panel que contiene el volumen y la opción de pantalla completa.
@onready var panel_opciones: CenterContainer = $PanelOpciones

# Panel que muestra la información de los creadores y del motor utilizado.
@onready var panel_creditos: CenterContainer = $PanelCreditos

# Botón principal. También se usa para recuperar el enfoque al volver.
@onready var boton_jugar: Button = $Centro/ContenidoPrincipal/MarcoMenu/MargenMenu/Botones/BotonJugar

# Barra que permite seleccionar un volumen entre 0.0 y 1.0.
@onready var volumen: HSlider = $PanelOpciones/MarcoOpciones/MargenOpciones/ContenidoOpciones/Volumen

# Casilla que activa o desactiva el modo de pantalla completa.
@onready var pantalla_completa: CheckButton = $PanelOpciones/MarcoOpciones/MargenOpciones/ContenidoOpciones/PantallaCompleta


# _ready() se ejecuta una sola vez cuando la escena del menú termina de cargar.
func _ready() -> void:
	# La señal pressed de cada botón se conecta con la función que debe ejecutar.
	# Por ejemplo: al presionar BotonJugar se llama automáticamente a _jugar().
	$Centro/ContenidoPrincipal/MarcoMenu/MargenMenu/Botones/BotonJugar.pressed.connect(_jugar)
	$Centro/ContenidoPrincipal/MarcoMenu/MargenMenu/Botones/BotonControles.pressed.connect(_mostrar_controles)
	$Centro/ContenidoPrincipal/MarcoMenu/MargenMenu/Botones/BotonOpciones.pressed.connect(_mostrar_opciones)
	$Centro/ContenidoPrincipal/MarcoMenu/MargenMenu/Botones/BotonCreditos.pressed.connect(_mostrar_creditos)
	$Centro/ContenidoPrincipal/MarcoMenu/MargenMenu/Botones/BotonSalir.pressed.connect(_salir)

	# Los tres botones VOLVER realizan la misma acción: regresar al menú principal.
	$PanelControles/MarcoControles/MargenControles/ContenidoControles/BotonVolver.pressed.connect(_volver)
	$PanelOpciones/MarcoOpciones/MargenOpciones/ContenidoOpciones/BotonVolver.pressed.connect(_volver)
	$PanelCreditos/MarcoCreditos/MargenCreditos/ContenidoCreditos/BotonVolver.pressed.connect(_volver)

	# value_changed se activa cada vez que el usuario mueve la barra de volumen.
	volumen.value_changed.connect(_cambiar_volumen)

	# toggled envía true cuando se marca la casilla y false cuando se desmarca.
	pantalla_completa.toggled.connect(_cambiar_pantalla)

	# La casilla muestra correctamente si el juego ya inició en pantalla completa.
	pantalla_completa.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN

	# Coloca el enfoque inicial en JUGAR.
	# Esto permite usar teclado o control sin tener que utilizar primero el ratón.
	boton_jugar.grab_focus()


# Captura entradas que no fueron consumidas por otro elemento de la interfaz.
func _unhandled_input(event: InputEvent) -> void:
	# ui_cancel normalmente corresponde a la tecla Escape.
	if event.is_action_pressed("ui_cancel"):
		# Si estamos dentro de Controles, Opciones o Créditos, Escape regresa.
		if not contenido_principal.visible:
			_volver()
		# Si ya estamos en la pantalla principal, Escape cierra el juego.
		else:
			_salir()


# Acción del botón JUGAR.
func _jugar() -> void:
	# Sustituye la escena actual del menú por el primer nivel del juego.
	# La variable error recibe OK si Godot pudo abrirla correctamente.
	var error: Error = get_tree().change_scene_to_file(ESCENA_JUEGO)

	# Si la ruta dejara de existir, se mostraría un mensaje en el depurador.
	if error != OK:
		push_error("No se pudo abrir la escena del juego.")


# Acción del botón CONTROLES.
func _mostrar_controles() -> void:
	# Primero oculta todos los paneles para impedir que se encimen.
	_ocultar_todo()

	# Después hace visible solamente el panel de controles.
	panel_controles.show()

	# Selecciona VOLVER para permitir regresar usando Enter.
	$PanelControles/MarcoControles/MargenControles/ContenidoControles/BotonVolver.grab_focus()


# Acción del botón OPCIONES.
func _mostrar_opciones() -> void:
	_ocultar_todo()
	panel_opciones.show()

	# Deja seleccionada la barra para poder ajustar el volumen con las flechas.
	volumen.grab_focus()


# Acción del botón CRÉDITOS.
func _mostrar_creditos() -> void:
	_ocultar_todo()
	panel_creditos.show()
	$PanelCreditos/MarcoCreditos/MargenCreditos/ContenidoCreditos/BotonVolver.grab_focus()


# Función auxiliar usada antes de mostrar cualquier pantalla del menú.
func _ocultar_todo() -> void:
	# hide() vuelve invisible el elemento, pero no lo elimina de la escena.
	contenido_principal.hide()
	panel_controles.hide()
	panel_opciones.hide()
	panel_creditos.hide()


# Regresa desde una pantalla secundaria hasta el menú principal.
func _volver() -> void:
	_ocultar_todo()

	# Vuelve a mostrar el título y los botones principales.
	contenido_principal.show()

	# Recupera el enfoque en JUGAR para continuar navegando con el teclado.
	boton_jugar.grab_focus()


# Recibe el valor seleccionado en la barra de volumen.
func _cambiar_volumen(valor: float) -> void:
	# La barra trabaja con valores lineales de 0.0 a 1.0, pero Godot controla
	# el volumen mediante decibelios. linear_to_db() realiza esa conversión.
	# maxf evita calcular el logaritmo de cero, que no está definido.
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(valor, 0.001)))

	# Cuando la barra llega prácticamente a cero, se silencia el bus principal.
	AudioServer.set_bus_mute(0, valor <= 0.001)


# Recibe el estado de la casilla Pantalla completa.
func _cambiar_pantalla(activada: bool) -> void:
	if activada:
		# Cambia la ventana al modo de pantalla completa.
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		# Regresa al modo de ventana normal.
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


# Acción del botón SALIR y de Escape cuando estamos en la pantalla principal.
func _salir() -> void:
	# Finaliza correctamente la ejecución del juego.
	get_tree().quit()
