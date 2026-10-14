class_name Hurtbox
extends Area2D

## Componente de Hurtbox para detecção de recebimento de golpes e vulnerabilidade a dano.
## Pertence à camada Enemies (Layer 3, valor 4) e escuta a camada PlayerHitbox (Layer 4, valor 8).

## Sinal emitido quando um golpe válido de uma Hitbox atinge esta Hurtbox.
signal hit_received(hitbox: Hitbox)

## Referência à entidade dona desta Hurtbox (ex: Dummy, Enemy, Player, etc.).
@export var owner_entity: Node2D = null

## Controla se a Hurtbox está atualmente invulnerável a receber dano (ex: frames de imunidade).
@export var is_invulnerable: bool = false

## Referência ao CollisionShape2D filho responsável pelo volume de recepção de impacto.
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	# Define a entidade proprietária caso não tenha sido atribuída no Inspector
	if owner_entity == null and get_parent() is Node2D:
		owner_entity = get_parent() as Node2D
	
	# Garante que a Hurtbox esteja monitorando e monitorável por padrão
	monitoring = true
	monitorable = true
	
	# Conecta o sinal interno de colisão de áreas
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)


## Callback executado quando outra Area2D sobrepõe a área de recepção desta Hurtbox.
func _on_area_entered(area: Area2D) -> void:
	if is_invulnerable:
		return
	
	if area is Hitbox:
		var hitbox: Hitbox = area as Hitbox
		hit_received.emit(hitbox)


## Define se a Hurtbox está em período de invulnerabilidade.
func set_invulnerable(invulnerable: bool) -> void:
	is_invulnerable = invulnerable


## Desativa a detecção da Hurtbox de maneira segura (adiada pela física da engine).
func disable() -> void:
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	if collision_shape != null:
		collision_shape.set_deferred("disabled", true)


## Reativa a detecção da Hurtbox de maneira segura.
func enable() -> void:
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)
	if collision_shape != null:
		collision_shape.set_deferred("disabled", false)
