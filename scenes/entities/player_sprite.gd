class_name PlayerSprite
extends Sprite2D

## Componente visual do jogador responsável pelo chaveamento dinâmico de spritesheets
## direcionais (Down, Up, Side) e espelhamento horizontal (flip_h).

@export_group("Idle Spritesheets")
@export var idle_down: Texture2D
@export var idle_up: Texture2D
@export var idle_side: Texture2D

@export_group("Walk Spritesheets")
@export var walk_down: Texture2D
@export var walk_up: Texture2D
@export var walk_side: Texture2D


## Atualiza a textura e espelhamento do sprite com base no vetor direcional e no estado de animação ("idle" ou "walk").
func update_texture(direction: Vector2, anim_state: String) -> void:
	var selected_texture: Texture2D = null
	
	if abs(direction.x) > abs(direction.y):
		flip_h = direction.x < 0
		if anim_state == "idle":
			selected_texture = idle_side
		elif anim_state == "walk":
			selected_texture = walk_side
	else:
		flip_h = false
		if direction.y > 0:
			if anim_state == "idle":
				selected_texture = idle_down
			elif anim_state == "walk":
				selected_texture = walk_down
		elif direction.y < 0:
			if anim_state == "idle":
				selected_texture = idle_up
			elif anim_state == "walk":
				selected_texture = walk_up
				
	# Aplica a textura apenas se estiver configurada e for diferente da ativa atualmente
	if selected_texture != null and texture != selected_texture:
		texture = selected_texture
