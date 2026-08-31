extends Node
class_name State;

signal stateChange (newState: State);

enum state{
	Walk,
	Idle,
	Run,
	Jump,
	Fall,
	Atack
}

var mira
	
var currentCharacter : CharacterBody2D;

func enter() -> void:
	pass;

func update_process(delta: float) -> void:
	pass;
	
func update_physic_process(delta: float) -> void:
	pass;
	
func exit() -> void:
	pass;
