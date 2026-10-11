class_name Player
extends CharacterBody2D

## Controlador do jogador (CharacterBody2D) em perspectiva Top-Down 2D.
## Aplica o princípio de responsabilidade única (SRP) separando a captação de input,
## o cálculo da física e a atualização do estado visual e animação.

@export_group("Movement Settings")
## Velocidade linear de deslocamento do jogador em pixels por segundo.
@export var speed: float = 200.0

@export_group("Dependencies")
## Referência ao componente visual de gerenciamento de sprites e direções.
@onready var sprite: PlayerSprite = $Sprite2D
## Referência ao AnimationPlayer responsável pelas trilhas de animação.
@onready var animation_player: AnimationPlayer = $AnimationPlayer

## Armazena o último vetor direcional válido para orientar o sprite em estado Idle.
var last_direction: Vector2 = Vector2.DOWN


func _physics_process(_delta: float) -> void:
	var input_direction: Vector2 = get_input_direction()
	velocity = calculate_velocity(input_direction)
	update_animation(input_direction)
	move_and_slide()


## Captura e normaliza os eixos de entrada configurados no Input Map (movimentação em 8 direções).
func get_input_direction() -> Vector2:
	return Input.get_vector("left", "right", "up", "down").normalized()


## Calcula a velocidade linear do corpo físico aplicando a velocidade escalar ao vetor unitário de direção.
func calculate_velocity(direction: Vector2) -> Vector2:
	return direction * speed


## Gerencia as transições de animação (Idle / Walk) e orienta a textura direcional do sprite.
func update_animation(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		last_direction = direction
		animation_player.play("walk")
		sprite.update_texture(direction, "walk")
	else:
		animation_player.play("idle")
		sprite.update_texture(last_direction, "idle")
