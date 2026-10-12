extends SceneTree

func _init() -> void:
	print("==================================================")
	print("  TESTE UNITÁRIO: ESTRUTURA DA HITBOX (CARD #12)  ")
	print("==================================================")
	call_deferred("_run_tests")


func _run_tests() -> void:
	var player_scene: PackedScene = load("res://scenes/entities/player.tscn")
	assert(player_scene != null, "A cena do player deve existir.")
	
	var player: Player = player_scene.instantiate() as Player
	root.add_child(player)
	player.global_position = Vector2(200, 200)
	
	await process_frame
	await process_frame
	
	# 1. Validação da presença e tipagem dos nós da Hitbox
	assert(player.hitbox_pivot != null, "HitboxPivot (Marker2D) deve existir na cena.")
	assert(player.hitbox != null, "Hitbox (Area2D / Hitbox script) deve existir na cena.")
	assert(player.hitbox is Hitbox, "Hitbox deve ser uma instância da classe Hitbox.")
	assert(player.hitbox.collision_shape != null, "CollisionShape2D da Hitbox deve existir.")
	assert(player.hitbox.source == player, "A propriedade 'source' da Hitbox deve referenciar a entidade Player.")
	assert(player.hitbox.damage == 10, "Dano padrão da Hitbox deve ser 10.")
	print("[PASS] 1. Hierarquia de nós, tipagem e dependências da Hitbox validadas.")
	
	# 2. Validação das camadas de colisão (Layers e Masks)
	# Layer 4 (bitmask 1 << 3 = 8) -> PlayerHitbox
	# Mask 3 (bitmask 1 << 2 = 4) -> Enemies
	assert(player.hitbox.collision_layer == 8, "Hitbox deve estar na Camada 4 (PlayerHitbox, valor 8). Valor atual: %d" % player.hitbox.collision_layer)
	assert(player.hitbox.collision_mask == 4, "Hitbox deve escutar a Máscara 3 (Enemies, valor 4). Valor atual: %d" % player.hitbox.collision_mask)
	print("[PASS] 2. Configurações de Collision Layer (4) e Mask (3) da Hitbox validadas.")
	
	# 3. Validação do estado inicial desativado da forma de colisão
	assert(player.hitbox.collision_shape.disabled == true, "A forma de colisão da Hitbox deve iniciar desativada (disabled == true).")
	print("[PASS] 3. Estado inicial inativo da forma de colisão validado.")
	
	# 4. Validação dos métodos de ativação e desativação segura
	player.hitbox.activate()
	await process_frame
	assert(player.hitbox.collision_shape.disabled == false, "Hitbox.activate() deve habilitar a colisão (disabled == false).")
	
	player.hitbox.deactivate()
	await process_frame
	assert(player.hitbox.collision_shape.disabled == true, "Hitbox.deactivate() deve desabilitar a colisão (disabled == true).")
	print("[PASS] 4. Métodos activate() e deactivate() validados.")
	
	# 5. Validação de posicionamento direcional do pivô da Hitbox
	# Direção: DOWN
	player.update_hitbox_direction(Vector2.DOWN)
	await process_frame
	assert(is_equal_approx(player.hitbox_pivot.rotation, Vector2.DOWN.angle()), "Pivô deve rotacionar no ângulo de Vector2.DOWN.")
	assert(player.hitbox.collision_shape.global_position.y > player.global_position.y, "Colisor da Hitbox deve estar posicionado abaixo do player quando olhando para DOWN.")
	
	# Direção: UP
	player.update_hitbox_direction(Vector2.UP)
	await process_frame
	assert(is_equal_approx(player.hitbox_pivot.rotation, Vector2.UP.angle()), "Pivô deve rotacionar no ângulo de Vector2.UP.")
	assert(player.hitbox.collision_shape.global_position.y < player.global_position.y, "Colisor da Hitbox deve estar posicionado acima do player quando olhando para UP.")
	
	# Direção: RIGHT
	player.update_hitbox_direction(Vector2.RIGHT)
	await process_frame
	assert(is_equal_approx(player.hitbox_pivot.rotation, Vector2.RIGHT.angle()), "Pivô deve rotacionar no ângulo de Vector2.RIGHT.")
	assert(player.hitbox.collision_shape.global_position.x > player.global_position.x, "Colisor da Hitbox deve estar posicionado à direita do player quando olhando para RIGHT.")
	
	# Direção: LEFT
	player.update_hitbox_direction(Vector2.LEFT)
	await process_frame
	assert(is_equal_approx(abs(player.hitbox_pivot.rotation), PI), "Pivô deve rotacionar no ângulo de Vector2.LEFT (PI radianos).")
	assert(player.hitbox.collision_shape.global_position.x < player.global_position.x, "Colisor da Hitbox deve estar posicionado à esquerda do player quando olhando para LEFT.")
	print("[PASS] 5. Rotação do pivô e posicionamento espacial da Hitbox nas 4 direções validados.")
	
	# 6. Validação da sincronização do attack() com a última direção
	player.last_direction = Vector2.UP
	player.attack()
	assert(is_equal_approx(player.hitbox_pivot.rotation, Vector2.UP.angle()), "attack() deve alinhar o HitboxPivot com last_direction.")
	print("[PASS] 6. Sincronização do ataque com a orientação direcional validada.")
	
	print("==================================================")
	print("  TODOS OS TESTES DA HITBOX (CARD #12) PASSARAM!  ")
	print("==================================================")
	quit(0)
