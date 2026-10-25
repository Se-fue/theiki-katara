extends Node

signal died
signal get_damage(Dmg : int)

var HFragments : int
var MAXHEARTS : int = 5
const HEART_WIDTH : int = 32
const HEART_HEIGHT : int = 32
var CurHearts : int 
@export var Dmg : int
var CurCoins : int
var Coins : int
var CoinsOnDeath : int

func _ready() -> void:
	for nodo in [%HH, %HF]:
		nodo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		nodo.stretch_mode = TextureRect.STRETCH_TILE
		nodo.clip_contents = true
		nodo.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	
	CurHearts = CurHearts + MAXHEARTS
	
	#CONECTA LAS SEÑALES: REACCIONAN CUANDO OCURREN, NO AL INICIAR
	%Hurtbox.body_entered.connect(damage)
	%Recolection.body_entered.connect(recolect)

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
	var tam := Vector2(MAXHEARTS * HEART_WIDTH, HEART_HEIGHT)
	for nodo in [%HH, %HF]:
		nodo.custom_minimum_size = tam
		nodo.size = tam
		
func damage(body: Node2D) -> void:
	if not body.is_in_group("enemigo"):
		return
	
	var cantidad : int = Dmg
	if "Dmg" in body:
		cantidad = body.Dmg
	
	CurHearts = max(CurHearts - cantidad, 0)
	get_damage.emit(cantidad)
	
	if CurHearts == 0:
		death()
	
func recolect(body: Node2D) -> void:
	if body.is_in_group("fragment"):
		HFragments += 1
		body.queue_free()
	elif body.is_in_group("coin"):
		var valor_moneda : int = 1
		if "Coins" in body:
			valor_moneda = body.Coins
		CurCoins += valor_moneda
		body.queue_free()
	elif body.is_in_group("charms"):
		var elpepe = 1
	elif body.is_in_group("habilities"):
		var elpepe = 2

func death():
	CoinsOnDeath = CurCoins
	CurCoins = 0
	died.emit()
