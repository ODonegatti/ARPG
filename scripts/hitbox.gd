class_name Hitbox
extends Area2D

## Componente de Hitbox para detecção de acerto e aplicação de dano em alvos (Hurtbox).
## Pertence à camada PlayerHitbox (Layer 4) e detecta a camada Enemies (Layer 3).

## Quantidade de dano infligida pelo golpe.
@export var damage: int = 10

## Força de repulsão (knockback) aplicada ao alvo atingido.
@export var knockback_force: float = 120.0

## Referência à entidade de origem que desferiu o golpe.
@export var source: Node2D = null

## Referência ao CollisionShape2D filho responsável pelo volume de detecção.
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	# Garante que a hitbox inicia desativada caso não tenha sido desativada no editor
	if collision_shape != null:
		collision_shape.set_deferred("disabled", true)


## Ativa a forma de colisão da hitbox de maneira segura na física.
func activate() -> void:
	if collision_shape != null:
		collision_shape.set_deferred("disabled", false)


## Desativa a forma de colisão da hitbox de maneira segura na física.
func deactivate() -> void:
	if collision_shape != null:
		collision_shape.set_deferred("disabled", true)
