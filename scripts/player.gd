class_name Player
extends CharacterBody2D

## Velocidade de movimento do jogador em pixels por segundo
@export var speed: float = 200.0


func _physics_process(_delta: float) -> void:
	move_player()


## Gerencia a movimentação em 8 direções e colisões físicas
func move_player() -> void:
	var direction: Vector2 = get_movement_direction()
	velocity = direction * speed
	move_and_slide()


## Obtém o vetor de direção do input normalizado (8 direções)
func get_movement_direction() -> Vector2:
	var direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	return direction.normalized()
