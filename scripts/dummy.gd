class_name Dummy
extends CharacterBody2D

## Entidade de treino e alvo de teste de combate (Dummy).
## Herda de CharacterBody2D para permitir resposta cinemática (knockback e desaceleração por atrito)
## e feedback visual de impacto via AnimationPlayer.

@export_group("Physics Settings")
## Taxa de desaceleração linear para amortecer impulsos físicos recebidos (ex: knockback).
@export var friction: float = 800.0

@export_group("Visual Dependencies")
## Referência ao sprite principal do boneco.
@onready var sprite: Sprite2D = $Sprite2D
## Referência ao sprite da sombra projetada no chão.
@onready var shadow: Sprite2D = $Shadow
## Referência ao AnimationPlayer responsável pelas animações de repouso e impacto.
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	velocity = Vector2.ZERO
	if animation_player != null and animation_player.has_animation(&"idle"):
		animation_player.play(&"idle")


func _physics_process(delta: float) -> void:
	if velocity != Vector2.ZERO:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		move_and_slide()


## Dispara a animação visual de impacto do boneco ao sofrer dano.
## Será conectado à Hurtbox no Card #16 e ao sistema de vida no Card #17.
func play_hit_animation() -> void:
	if animation_player != null and animation_player.has_animation(&"hit"):
		animation_player.stop()
		animation_player.play(&"hit")
