extends Node

var HFragments : int = 15
var MAXHEARTS : int = 5
const ANCHO_CORAZON : int = 32
const ALTO_CORAZON : int = 32

func _ready() -> void:
	# CONFIGURA UNA SOLA VEZ AMBOS NODOS PARA QUE SEAN UNA SOLA FILA
	for nodo in [%HH, %HF]:
		nodo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE # LA TEXTURA NO FUERZA EL TAMAÑO MINIMO
		nodo.stretch_mode = TextureRect.STRETCH_TILE      # REPITE EL CORAZON
		nodo.clip_contents = true                         # RECORTA CUALQUIER FILA QUE SOBRE
		nodo.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

func _process(delta: float) -> void:
	# 1. CONDICIONES DE FRAGMENTOS
	if HFragments >= 15:
		MAXHEARTS = 10
	elif HFragments >= 12:
		MAXHEARTS = 9
	elif HFragments >= 9:
		MAXHEARTS = 8
	elif HFragments >= 6:
		MAXHEARTS = 7
	elif HFragments >= 3:
		MAXHEARTS = 6
	else:
		MAXHEARTS = 5

	# 2. TAMAÑO DE UNA SOLA FILA
	var tam := Vector2(MAXHEARTS * ANCHO_CORAZON, ALTO_CORAZON)
	for nodo in [%HH, %HF]:
		nodo.custom_minimum_size = tam
		nodo.size = tam
