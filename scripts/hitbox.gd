class_name Hitbox
extends Area2D

## AI Context Router:
## - Role: Componente ofensivo de colisão (Layer 4) que transfere dano e knockback
## - Scene: res://scenes/entities/player.tscn (nó Hitbox dentro de HitboxPivot)
## - Tests: res://tests/test_hitbox_structure.gd, res://tests/test_hitbox_sync.gd
## - Docs: docs/modules/player.md

## Componente de Hitbox para detecção de acerto e aplicação de dano em alvos (Hurtbox).
## Pertence à camada PlayerHitbox (Layer 4, valor 8) e detecta a camada Enemies (Layer 3, valor 4).

## Sinal emitido quando a hitbox se torna ativa para causar dano.
signal activated()

## Sinal emitido quando a janela ativa de dano da hitbox é encerrada.
signal deactivated()

## Quantidade de dano infligida pelo golpe.
@export var damage: int = 10

## Força de repulsão (knockback) aplicada ao alvo atingido.
@export var knockback_force: float = 120.0

## Referência à entidade de origem que desferiu o golpe.
@export var source: Node2D = null

## Indica se a hitbox está atualmente ativa e apta a registrar colisões de dano.
var is_active: bool = false:
	get:
		return is_active

## Referência ao CollisionShape2D filho responsável pelo volume de detecção.
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	# Garante estado desativado inicial seguro
	deactivate()


## Ativa a detecção e o volume de colisão da hitbox de maneira segura.
func activate() -> void:
	is_active = true
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)
	if collision_shape != null:
		collision_shape.set_deferred("disabled", false)
	activated.emit()


## Desativa a detecção e o volume de colisão da hitbox de maneira segura.
func deactivate() -> void:
	is_active = false
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	if collision_shape != null:
		collision_shape.set_deferred("disabled", true)
	deactivated.emit()

