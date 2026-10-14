extends SceneTree

func _init() -> void:
	print("==================================================")
	print("  TESTE UNITÁRIO: HURTBOX NO INIMIGO (CARD #16)   ")
	print("==================================================")
	call_deferred("_run_tests")


func _run_tests() -> void:
	# 1. Carregamento e instância da cena Dummy
	var dummy_scene: PackedScene = load("res://scenes/entities/dummy.tscn")
	assert(dummy_scene != null, "A cena do Dummy deve existir em res://scenes/entities/dummy.tscn.")
	
	var dummy: Dummy = dummy_scene.instantiate() as Dummy
	assert(dummy != null, "A instância deve ser do tipo Dummy.")
	root.add_child(dummy)
	dummy.global_position = Vector2(250, 200)
	
	await physics_frame
	await physics_frame
	
	# 2. Validação da hierarquia de nós e tipagem
	assert(dummy.hurtbox != null, "Dummy deve possuir uma referência válida ao nó Hurtbox.")
	assert(dummy.hurtbox is Hurtbox, "O nó Hurtbox deve ser uma instância da classe Hurtbox.")
	assert(dummy.hurtbox.collision_shape != null, "Hurtbox deve conter um CollisionShape2D filho.")
	assert(dummy.hurtbox.owner_entity == dummy, "owner_entity da Hurtbox deve referenciar o Dummy.")
	print("[PASS] 1. Hierarquia de nós, tipagem e dependências da Hurtbox validadas.")
	
	# 3. Validação das camadas de colisão (Layers e Masks)
	# Layer 3 (bitmask 1 << 2 = 4) -> Enemies (Camada em que a Hurtbox reside)
	# Mask 4 (bitmask 1 << 3 = 8) -> PlayerHitbox (Camada que a Hurtbox escuta)
	assert(dummy.hurtbox.collision_layer == 4, "Hurtbox deve estar na Camada 3 (Enemies, valor 4). Valor atual: %d" % dummy.hurtbox.collision_layer)
	assert(dummy.hurtbox.collision_mask == 8, "Hurtbox deve escutar a Camada 4 (PlayerHitbox, valor 8). Valor atual: %d" % dummy.hurtbox.collision_mask)
	assert(dummy.hurtbox.monitoring == true, "Hurtbox deve iniciar com monitoring == true.")
	assert(dummy.hurtbox.monitorable == true, "Hurtbox deve iniciar com monitorable == true.")
	assert(dummy.hurtbox.collision_shape.disabled == false, "CollisionShape2D da Hurtbox deve iniciar ativo.")
	print("[PASS] 2. Configurações de Collision Layer (3) e Mask (4) da Hurtbox validadas.")
	
	# 4. Validação dos métodos de controle da Hurtbox (disable / enable)
	dummy.hurtbox.disable()
	await physics_frame
	await physics_frame
	assert(dummy.hurtbox.monitoring == false, "disable() deve definir monitoring = false.")
	assert(dummy.hurtbox.monitorable == false, "disable() deve definir monitorable = false.")
	assert(dummy.hurtbox.collision_shape.disabled == true, "disable() deve desabilitar o CollisionShape2D.")
	
	dummy.hurtbox.enable()
	await physics_frame
	await physics_frame
	assert(dummy.hurtbox.monitoring == true, "enable() deve definir monitoring = true.")
	assert(dummy.hurtbox.monitorable == true, "enable() deve definir monitorable = true.")
	assert(dummy.hurtbox.collision_shape.disabled == false, "enable() deve reabilitar o CollisionShape2D.")
	print("[PASS] 3. Métodos disable() e enable() da Hurtbox validados com sucesso.")
	
	# 5. Validação de integração e recepção de golpe via Hitbox do Player
	var player_scene: PackedScene = load("res://scenes/entities/player.tscn")
	assert(player_scene != null, "A cena do Player deve existir.")
	
	var player: Player = player_scene.instantiate() as Player
	root.add_child(player)
	player.global_position = Vector2(210, 200) # Posiciona o player adjacente ao Dummy
	player.update_hitbox_direction(Vector2.RIGHT)
	
	# Rastreador de sinais via dicionário (referência mutável em closures no GDScript)
	var signal_tracker = {
		"hit_count": 0,
		"last_hitbox": null
	}
	
	dummy.hurtbox.hit_received.connect(func(hitbox: Hitbox) -> void:
		signal_tracker.hit_count += 1
		signal_tracker.last_hitbox = hitbox
	)
	
	# Ativa a Hitbox do player manualmente simulando a janela de golpe
	player.hitbox.activate()
	
	# Aguarda frames de física para a engine processar a sobreposição de áreas
	for i in range(5):
		await physics_frame
	
	assert(signal_tracker.hit_count > 0, "O sinal hit_received da Hurtbox deve ser emitido quando a Hitbox do Player colidir.")
	assert(signal_tracker.last_hitbox == player.hitbox, "A hitbox recebida no sinal deve ser a Hitbox do Player.")
	assert(signal_tracker.last_hitbox.damage == 10, "O dano reportado deve ser igual ao configurado na Hitbox (10).")
	assert(dummy.animation_player.current_animation == "hit", "Dummy deve transicionar para a animação 'hit' ao receber o golpe.")
	print("[PASS] 4. Integração física entre Player Hitbox e Dummy Hurtbox validada com sucesso.")
	
	# 6. Validação de invulnerabilidade (i-frames)
	player.hitbox.deactivate()
	for i in range(3):
		await physics_frame
	
	signal_tracker.hit_count = 0
	signal_tracker.last_hitbox = null
	dummy.hurtbox.set_invulnerable(true)
	player.hitbox.activate()
	
	for i in range(5):
		await physics_frame
	
	assert(signal_tracker.hit_count == 0, "Hurtbox com is_invulnerable = true não deve emitir hit_received.")
	print("[PASS] 5. Mecanismo de invulnerabilidade (i-frames) validado com sucesso.")
	
	# 7. Finalização e limpeza
	player.hitbox.deactivate()
	player.queue_free()
	dummy.queue_free()
	
	print("==================================================")
	print("  TODOS OS TESTES DO CARD #16 PASSARAM COM SUCESSO! ")
	print("==================================================")
	quit(0)
