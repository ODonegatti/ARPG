class_name Player
extends CharacterBody2D

## Controlador do jogador (CharacterBody2D) em perspectiva Top-Down 2D.
## Aplica o princípio de responsabilidade única (SRP) separando a captação de input,
## o cálculo da física e a atualização do estado visual e animação.

## Sinal emitido no início do ataque básico, informando a direção do golpe.
signal attack_started(direction: Vector2)

@export_group("Movement Settings")
## Velocidade linear de deslocamento do jogador em pixels por segundo.
@export var speed: float = 200.0

@export_group("State Flags")
## Determina se o jogador pode se mover. Pode ser desativado por atordoamentos ou travas de golpe.
@export var can_move: bool = true
## Determina se o jogador pode atacar. Pode ser desativado por atordoamentos ou cooldowns.
@export var can_attack: bool = true

@export_group("Combat Settings")
## Tempo de espera mínimo entre ataques consecutivos (cooldown em segundos).
@export var attack_cooldown: float = 0.4

@export_group("Dependencies")
## Referência ao componente visual de gerenciamento de sprites e direções.
@onready var sprite: PlayerSprite = $Sprite2D
## Referência ao AnimationPlayer responsável pelas trilhas de animação.
@onready var animation_player: AnimationPlayer = $AnimationPlayer

## Armazena o último vetor direcional válido para orientar o sprite em estado Idle e o ataque.
var last_direction: Vector2 = Vector2.DOWN

## Temporizador interno para controle de cadência do ataque.
var _attack_cooldown_timer: float = 0.0


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("player_attack") and not event.is_echo():
		attack()


func _physics_process(delta: float) -> void:
	update_timers(delta)
	var input_direction: Vector2 = get_input_direction()
	velocity = calculate_velocity(input_direction)
	update_animation(input_direction)
	move_and_slide()


## Atualiza temporizadores internos de combate a cada tick da física.
func update_timers(delta: float) -> void:
	if _attack_cooldown_timer > 0.0:
		_attack_cooldown_timer = max(0.0, _attack_cooldown_timer - delta)


## Captura e normaliza os eixos de entrada configurados no Input Map (movimentação em 8 direções).
## Retorna Vector2.ZERO caso can_move esteja falso (ex: atordoamento).
func get_input_direction() -> Vector2:
	if not can_move:
		return Vector2.ZERO
	return Input.get_vector("left", "right", "up", "down").normalized()


## Calcula a velocidade linear do corpo físico aplicando a velocidade escalar ao vetor unitário de direção.
## Retorna Vector2.ZERO caso can_move esteja falso.
func calculate_velocity(direction: Vector2) -> Vector2:
	if not can_move:
		return Vector2.ZERO
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


## Executa o ataque básico do jogador caso esteja apto (respeitando can_attack e o cooldown).
func attack() -> void:
	if not can_attack or _attack_cooldown_timer > 0.0:
		return
	
	_attack_cooldown_timer = attack_cooldown
	attack_started.emit(last_direction)


## Utilitário de conveniência: aplica atordoamento (stun) temporário ao jogador.
func apply_stun(duration: float) -> void:
	can_move = false
	can_attack = false
	await get_tree().create_timer(duration).timeout
	can_move = true
	can_attack = true
