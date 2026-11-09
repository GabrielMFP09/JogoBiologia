extends CharacterBody2D

@export var velocidade: float = 280.0
@export var forca_pulo: float = 460.0

var gravidade: float = float(ProjectSettings.get_setting("physics/2d/default_gravity"))


func _physics_process(delta: float) -> void:
	var direcao := Input.get_axis("ui_left", "ui_right")
	velocity.x = direcao * velocidade

	if not is_on_floor():
		velocity.y += gravidade * delta
	elif Input.is_action_just_pressed("ui_accept"):
		velocity.y = -forca_pulo

	move_and_slide()
