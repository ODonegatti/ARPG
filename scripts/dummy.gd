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
## Deduz a vida (Card #17); o knockback será integrado no Card #18.
func _on_hurtbox_hit_received(hitbox: Hitbox) -> void:
	receber_dano(hitbox.damage)
	play_hit_animation()


## Aplica dano ao boneco, reduzindo o hp (limitado a zero).
##
## TODO (parâmetros futuros): esta função receberá mais parâmetros além de `valor`.
## Eles já existem ou serão derivados do Hitbox recebido em `_on_hurtbox_hit_received`:
##   - knockback_force: float -> Hitbox.knockback_force; intensidade do impulso (Card #18).
##   - source: Node2D         -> Hitbox.source; origem do golpe, usada para calcular
##                               a direção oposta do knockback (Card #18).
##   - (opcional) tipo de dano / crítico, se o sistema de combate evoluir.
## Ao adicioná-los, atualizar a chamada em `_on_hurtbox_hit_received`.
## A checagem de morte (hp <= 0 -> queue_free) será feita no Card #19.
func receber_dano(valor: int) -> void:
	hp -= valor


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
