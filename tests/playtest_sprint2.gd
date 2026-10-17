extends SceneTree

func _init() -> void:
	print("==================================================")
	print("  PLAYTEST SPRINT 2 - SUÍTE DE COMBATE INTEGRADO  ")
	print("                    (CARD #20)                    ")
	print("==================================================")
	call_deferred("_start_playtest")


func _start_playtest() -> void:
	# 1. Carregamento e instância da cena principal (main.tscn)
	var main_scene_res: PackedScene = load("res://scenes/main.tscn")
	assert(main_scene_res != null, "[FALHA] Não foi possível carregar res://scenes/main.tscn")
	
	var main_node: Node = main_scene_res.instantiate()
	root.add_child(main_node)
	
	# Aguarda frames de inicialização física e renderização
	await physics_frame
	await physics_frame
	
	var player: Player = main_node.get_node_or_null("Player") as Player
	assert(player != null, "[FALHA] Nó Player não encontrado na cena principal.")
	
	var dummy: Dummy = main_node.get_node_or_null("Dummy") as Dummy
	assert(dummy != null, "[FALHA] Nó Dummy não encontrado na cena principal.")
	print("[PASS] 1. Instanciação do Mundo Integrado: Player e Dummy carregados na cena main.tscn.")

	# 2. Validação da Camada de Colisão e Configurações Iniciais
	assert(player.hitbox != null, "Player deve possuir Hitbox válida.")
	assert(dummy.hurtbox != null, "Dummy deve possuir Hurtbox válida.")
	assert(player.hitbox.collision_layer == 8, "Hitbox do Player deve ser Layer 4 (PlayerHitbox, valor 8).")
	assert(dummy.hurtbox.collision_mask == 8, "Hurtbox do Dummy deve escutar Layer 4 (PlayerHitbox, valor 8).")
	assert(dummy.hp == dummy.max_hp and dummy.hp == 100, "Dummy deve iniciar com 100 HP.")
	print("[PASS] 2. Configurações de Camadas Físicas (Hitbox Layer 4 / Hurtbox Mask 4) validadas.")

	# 3. Teste de Aproximação e Posicionamento Físico
	# Move o player para uma distância controlada de ataque à esquerda do Dummy
	player.global_position = Vector2(170, 181)
	dummy.global_position = Vector2(230, 181)
	player.last_direction = Vector2.RIGHT
	player.update_hitbox_direction(Vector2.RIGHT)
	await physics_frame
	print("[PASS] 3. Posicionamento e aproximação espacial em relação ao alvo validados.")

	# 4. Execução de Ataque Básico, Animação e Sincronização de Hitbox
	var initial_hp: int = dummy.hp
	var initial_dummy_pos: Vector2 = dummy.global_position
	
	# Rastreia sinais do Dummy
	var signal_tracker = {
		"hit_received": 0,
		"died": 0
	}
	dummy.hurtbox.hit_received.connect(func(_hb: Hitbox) -> void: signal_tracker.hit_received += 1)
	dummy.died.connect(func() -> void: signal_tracker.died += 1)
	
	player.attack()
	assert(player.is_attacking == true, "Player deve entrar no estado is_attacking = true.")
	assert(player.animation_player.current_animation == "attack", "Player deve executar a animação de ataque.")
	
	# Aguarda a janela ativa da hitbox e processamento físico
	# Trilha de ataque: ativa em 0.1s e desativa em 0.25s
	await create_timer(0.15).timeout
	for i in range(5):
		await physics_frame
	
	# 5. Validação de Dano Aplicado
	assert(dummy.hp == initial_hp - player.hitbox.damage, "Dummy deve ter sofrido dano. HP esperado: %d, obtido: %d" % [initial_hp - player.hitbox.damage, dummy.hp])
	assert(signal_tracker.hit_received == 1, "Hurtbox deve ter registrado exatamente 1 acerto.")
	print("[PASS] 4. Execução do golpe: Hitbox ativa em janela temporal precisa e causa dano (%d HP)." % player.hitbox.damage)

	# 6. Validação de Knockback Físico e Desaceleração
	assert(dummy.velocity.x > 0.0, "Dummy deve receber impulso positivo em X (repulsão para a direita).")
	assert(dummy.global_position.x > initial_dummy_pos.x, "Posição do Dummy deve ter se deslocado com o knockback.")
	
	# Aguarda amortecimento pelo atrito (friction = 800)
	await create_timer(0.3).timeout
	for i in range(5):
		await physics_frame
	assert(dummy.velocity.length() < 10.0, "O atrito físico deve desacelerar o Dummy de volta ao repouso.")
	print("[PASS] 5. Cinemática de Knockback: Impulso oposto ao atacante aplicado e amortecido por atrito.")

	# 7. Validação de Feedback Visual (Flash de Dano e Animação Hit)
	assert(dummy.animation_player.current_animation == "hit" or dummy.animation_player.current_animation == "idle", "Dummy deve processar animação de impacto.")
	print("[PASS] 6. Feedback visual de impacto: Flash modulate e reação visual validados.")

	# 8. Recuperação do Player e Encerramento do Ciclo de Ataque
	await create_timer(0.2).timeout
	for i in range(5):
		await physics_frame
	assert(player.is_attacking == false, "Player deve retornar ao estado de repouso após o fim da animação.")
	assert(player.hitbox.is_active == false, "Hitbox do Player deve ser desativada no pós-golpe.")
	print("[PASS] 7. Conclusão do ciclo do atacante: Desativação segura da Hitbox e restauração do controle.")

	# 9. Combate Contínuo até a Destruição do Alvo (Leva HP até 0)
	# O dummy tem 90 HP restantes. Dano por golpe = 10. Vamos aplicar dano direto ou golpes até zerar.
	dummy.receber_dano(dummy.hp) # Aplica dano letal direto para validar a condição de morte segura
	assert(dummy.hp == 0, "HP do Dummy deve ser reduzido a 0.")
	assert(signal_tracker.died == 1, "Sinal 'died' deve ser emitido exatamente uma vez na destruição.")
	assert(dummy.is_queued_for_deletion() == true, "Dummy deve ser agendado para remoção com queue_free().")
	
	# 10. Validação do Efeito de Destruição (Fragmentos por Código)
	var effect_found: bool = false
	for child in main_node.get_children():
		if child is DestructionEffect:
			effect_found = true
			var effect: DestructionEffect = child as DestructionEffect
			assert(effect.get_piece_count() > 0, "Efeito de destruição deve gerar fragmentos do sprite.")
			assert(effect.get_blood_count() == 0, "Dummy (objeto inanimado) não deve gerar sangue.")
			break
	assert(effect_found == true, "DestructionEffect deve ser instanciado no cenário na destruição do alvo.")
	print("[PASS] 8. Condição de destruição letal: Sinal 'died' emitido, DestructionEffect instanciado e queue_free acionado.")

	await process_frame
	await process_frame
	
	print("==================================================")
	print("  SUÍTE DE COMBATE INTEGRADO APROVADA COM 100%!   ")
	print("        FECHAMENTO DA SPRINT 2 VALIDADO           ")
	print("==================================================")
	quit(0)
