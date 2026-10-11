extends Sprite2D
class_name PlayerSprite

@export_category("Spritesheets de Idle (8 frames)")
@export var idle_down: Texture2D
@export var idle_up: Texture2D
@export var idle_side: Texture2D

@export_category("Spritesheets de Walk (8 frames)")
@export var walk_down: Texture2D
@export var walk_up: Texture2D
@export var walk_side: Texture2D

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
			if anim_state == "idle": selected_texture = idle_down
			elif anim_state == "walk": selected_texture = walk_down
		elif direction.y < 0:
			if anim_state == "idle": selected_texture = idle_up
			elif anim_state == "walk": selected_texture = walk_up
			
	# Aplica a textura apenas se ela estiver preenchida no Inspetor e for diferente da atual
	if selected_texture != null and texture != selected_texture:
		texture = selected_texture


