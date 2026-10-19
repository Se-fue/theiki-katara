extends Area2D

#CONECTA LA SEÑAL QUE SE DISPARA CUANDO UN CUERPO ENTRA A LA ZONA
func _ready() -> void:
	body_entered.connect(_on_body_entered)

#SE EJECUTA CUANDO ALGO TOCA EL AREA
func _on_body_entered(body: Node2D) -> void:
	#SOLO REACCIONA SI EL CUERPO TIENE LA FUNCION reaparecer (EL JUGADOR)
	if body.has_method("reaparecer"):
		body.reaparecer()
