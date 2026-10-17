class_name Dummy
extends CharacterBody2D

## Entidade de treino e alvo de teste de combate (Dummy).
## Herda de CharacterBody2D para permitir resposta cinemática (knockback e desaceleração por atrito)
## e feedback visual de impacto via AnimationPlayer.

@export_group("Physics Settings")
## Taxa de desaceleração linear para amortecer impulsos físicos recebidos (ex: knockback).
@export var friction: float = 800.0

@export_group("Hit Feedback")
## Cor temporária aplicada ao sprite ao sofrer dano (flash).
@export var flash_color: Color = Color(1.0, 0.3, 0.3)
## Duração do flash em segundos.
@export var flash_duration: float = 0.12

## Tween ativo do flash (evita flashes sobrepostos).
var _flash_tween: Tween = null

## Sinal emitido uma vez quando o boneco é destruído (hp chegou a zero).
signal died

@export_group("Destruction")
## Se verdadeiro, a destruição libera também pixels vermelhos (sangue). O Dummy é um objeto, então é falso.
@export var is_living: bool = false

## Impede que a destruição seja executada mais de uma vez.
var _is_dying: bool = false
## Direção do último golpe recebido (usada para arremessar os fragmentos).
var _last_hit_direction: Vector2 = Vector2.ZERO

@export_group("Visual Dependencies")
## Referência ao sprite principal do boneco.
@onready var sprite: Sprite2D = $Sprite2D
## Referência ao sprite da sombra projetada no chão.
@onready var shadow: Sprite2D = $Shadow
## Referência ao AnimationPlayer responsável pelas animações de repouso e impacto.
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export_group("Health Settings")
## Vida máxima do boneco.
@export var max_hp: int = 100

## Vida atual (encapsulada: só é alterada via receber_dano). Nunca fica abaixo de zero.
var hp: int = 0:
	set(value):
		hp = clampi(value, 0, max_hp)

@export_group("Combat Components")
## Referência ao componente Hurtbox responsável por detectar golpes recebidos.
@onready var hurtbox: Hurtbox = $Hurtbox


func _ready() -> void:
	velocity = Vector2.ZERO
	hp = max_hp
	if animation_player != null:
		if animation_player.has_animation(&"idle"):
			animation_player.play(&"idle")
		if not animation_player.animation_finished.is_connected(_on_animation_finished):
			animation_player.animation_finished.connect(_on_animation_finished)
	
	if hurtbox != null:
		hurtbox.owner_entity = self
		if not hurtbox.hit_received.is_connected(_on_hurtbox_hit_received):
			hurtbox.hit_received.connect(_on_hurtbox_hit_received)


func _physics_process(delta: float) -> void:
	if velocity != Vector2.ZERO:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		move_and_slide()


## Callback executado quando a Hurtbox detecta um acerto de Hitbox.
## Dispara a reação visual de impacto do boneco (Card #16).
## Deduz a vida (Card #17) e aplica knockback + flash (Card #18).
func _on_hurtbox_hit_received(hitbox: Hitbox) -> void:
	if _is_dying:
		return
	_last_hit_direction = _direcao_do_golpe(hitbox)
	receber_dano(hitbox.damage)
	if _is_dying:
		return
	aplicar_knockback(_calcular_knockback(hitbox))
	play_hit_animation()
	play_flash()


## Direção oposta ao atacante (ZERO se a origem do golpe for desconhecida).
func _direcao_do_golpe(hitbox: Hitbox) -> Vector2:
	if hitbox.source != null:
		return (global_position - hitbox.source.global_position).normalized()
	return Vector2.ZERO


## Calcula o vetor de knockback (direção oposta ao atacante * intensidade) a partir do golpe.
##
## FUTURO: o knockback dependerá do TIPO DO ATAQUE do player (ex: golpe leve, pesado,
## combo final, habilidade). Este é o ÚNICO ponto a alterar: o tipo virá do Hitbox
## (ex: `hitbox.attack_type`) e selecionará força/multiplicador/direção do impulso.
## Hoje usa apenas `Hitbox.knockback_force`.
func _calcular_knockback(hitbox: Hitbox) -> Vector2:
	return _direcao_do_golpe(hitbox) * hitbox.knockback_force


## Aplica um impulso instantâneo; o atrito em `_physics_process` o amortece.
func aplicar_knockback(impulso: Vector2) -> void:
	velocity = impulso


## Pisca o sprite com `flash_color` e retorna à cor normal.
func play_flash() -> void:
	if sprite == null:
		return
	if _flash_tween != null and _flash_tween.is_valid():
		_flash_tween.kill()
	sprite.modulate = flash_color
	_flash_tween = create_tween()
	_flash_tween.tween_property(sprite, "modulate", Color.WHITE, flash_duration)


## Aplica dano ao boneco, reduzindo o hp (limitado a zero).
##
## TODO (parâmetros futuros): esta função receberá mais parâmetros além de `valor`.
## Eles já existem ou serão derivados do Hitbox recebido em `_on_hurtbox_hit_received`:
##   - knockback_force: float -> Hitbox.knockback_force; hoje consumido por `_calcular_knockback`.
##   - source: Node2D         -> Hitbox.source; hoje usado por `_calcular_knockback`.
##   - (futuro) tipo de ataque -> definirá o knockback; ver `_calcular_knockback`.
## Ao adicioná-los, atualizar a chamada em `_on_hurtbox_hit_received`.
## A morte (hp <= 0) é tratada em `_morrer()` (Card #19).
func receber_dano(valor: int) -> void:
	if _is_dying:
		return
	hp -= valor
	if hp <= 0:
		_morrer()


## Destrói o boneco com o efeito padrão do projeto: o sprite se quebra em pedaços
## arremessados pela tela (e sangue, se `is_living`), e a cena é removida com segurança.
func _morrer() -> void:
	if _is_dying:
		return
	_is_dying = true
	velocity = Vector2.ZERO
	set_physics_process(false)
	if hurtbox != null:
		hurtbox.disable()
	if sprite != null and get_parent() != null:
		DestructionEffect.spawn(sprite, get_parent(), is_living, _last_hit_direction)
	died.emit()
	queue_free()


## Retorna para a animação de repouso após o término do impacto.
func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"hit":
		if animation_player != null and animation_player.has_animation(&"idle"):
			animation_player.play(&"idle")


## Dispara a animação visual de impacto do boneco ao sofrer dano.
func play_hit_animation() -> void:
	if animation_player != null and animation_player.has_animation(&"hit"):
		animation_player.stop()
		animation_player.play(&"hit")
