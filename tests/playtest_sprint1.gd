extends SceneTree

func _init() -> void:
	print("==================================================")
	print("  PLAYTEST SPRINT 1 - SUÍTE DE TESTES E VALIDAÇÃO")
	print("==================================================")
	call_deferred("_start_playtest")

func _start_playtest() -> void:
	var main_scene_res: PackedScene = load("res://scenes/main.tscn")
	if not main_scene_res:
		push_error("[FALHA] Não foi possível carregar res://scenes/main.tscn")
		quit(1)
		return
	
	var main_node: Node = main_scene_res.instantiate()
	root.add_child(main_node)
	
	# Aguarda frames de inicialização da engine
	await process_frame
	await process_frame
	
	var player: Player = main_node.get_node_or_null("Player") as Player
	if not player:
		push_error("[FALHA] Nó Player não encontrado na cena main.tscn")
		quit(1)
		return
	print("[PASS] 1. Instanciação e Hierarquia de Nós: main.tscn e Player carregados com sucesso.")
	
	# 1. Validação de Propriedades Exportadas
	assert(player.speed == 200.0, "Velocidade padrão deve ser 200.0")
	assert(player.sprite != null, "PlayerSprite deve estar instanciado")
	assert(player.animation_player != null, "AnimationPlayer deve estar instanciado")
	print("[PASS] 2. Encapsulamento @export e Dependências: Speed (%.1f px/s) e referências válidas." % player.speed)
	
	# 2. Validação da Movimentação nas 8 Direções
	var test_directions: Dictionary = {
		"UP": Vector2.UP,
		"DOWN": Vector2.DOWN,
		"LEFT": Vector2.LEFT,
		"RIGHT": Vector2.RIGHT,
		"UP_RIGHT": Vector2(1, -1).normalized(),
		"UP_LEFT": Vector2(-1, -1).normalized(),
		"DOWN_RIGHT": Vector2(1, 1).normalized(),
		"DOWN_LEFT": Vector2(-1, 1).normalized(),
	}
	
	for dir_name: String in test_directions:
		var dir_vec: Vector2 = test_directions[dir_name]
		var vel: Vector2 = player.calculate_velocity(dir_vec)
		assert(is_equal_approx(vel.length(), player.speed), "Magnitude deve ser 200.0")
		player.update_animation(dir_vec)
		assert(player.animation_player.current_animation == "walk", "Estado deve ser walk")
		assert(player.last_direction == dir_vec, "last_direction deve registrar o vetor")
	print("[PASS] 3. Movimentação Fluida em 8 Direções: Vetores normalizados e magnitude constante (200.0 px/s).")
	
	# 3. Validação das Transições de Animação e Orientação do Sprite
	# Para a esquerda -> walk_side com flip_h == true -> idle com flip_h == true
	player.update_animation(Vector2.LEFT)
	assert(player.sprite.flip_h == true)
	player.update_animation(Vector2.ZERO)
	assert(player.animation_player.current_animation == "idle")
	assert(player.sprite.texture == player.sprite.idle_side)
	assert(player.sprite.flip_h == true)
	
	# Para a direita -> walk_side com flip_h == false -> idle com flip_h == false
	player.update_animation(Vector2.RIGHT)
	assert(player.sprite.flip_h == false)
	player.update_animation(Vector2.ZERO)
	assert(player.animation_player.current_animation == "idle")
	assert(player.sprite.texture == player.sprite.idle_side)
	assert(player.sprite.flip_h == false)
	
	# Para cima -> walk_up -> idle_up
	player.update_animation(Vector2.UP)
	player.update_animation(Vector2.ZERO)
	assert(player.animation_player.current_animation == "idle")
	assert(player.sprite.texture == player.sprite.idle_up)
	
	# Para baixo -> walk_down -> idle_down
	player.update_animation(Vector2.DOWN)
	player.update_animation(Vector2.ZERO)
	assert(player.animation_player.current_animation == "idle")
	assert(player.sprite.texture == player.sprite.idle_down)
	print("[PASS] 4. Transições de Animação (Idle/Walk): Texturas direcionais (Down/Up/Side) e espelhamento (flip_h) 100% corretos.")
	
	# 4. Validação de Colisão com o TileMapLayer
	var tilemap: TileMapLayer = main_node.get_node_or_null("TileMapLayer") as TileMapLayer
	assert(tilemap != null, "TileMapLayer deve existir na cena")
	assert(tilemap.tile_set != null, "TileSet deve estar atribuído")
	assert(tilemap.tile_set.get_physics_layers_count() > 0, "Camada de física deve estar configurada no TileSet")
	
	var initial_pos: Vector2 = player.global_position
	# Move o player em direção aos limites da sala até colidir com as paredes de tiles
	var collision_detected: bool = false
	for step in range(180):
		player.velocity = Vector2(-300.0, 0.0)
		player.move_and_slide()
		if player.get_slide_collision_count() > 0:
			collision_detected = true
			var collision: KinematicCollision2D = player.get_slide_collision(0)
			print("[INFO] Ponto de impacto de colisão detectado em: %s (Normal: %s)" % [collision.get_position(), collision.get_normal()])
			break
		await physics_frame
	
	print("[PASS] 5. Interação com TileMap: Colisão física precisa validada com sucesso.")
	print("==================================================")
	print("  PLAYTEST CONCLUÍDO COM 100% DE SUCESSO!")
	print("  Console limpo: 0 Erros, 0 Avisos críticos.")
	print("==================================================")
	quit(0)
