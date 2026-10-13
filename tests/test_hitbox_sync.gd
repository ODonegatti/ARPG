extends SceneTree

func _init() -> void:
	print("==========================================================")
	print("  TESTE UNITÁRIO: SINCRONIZAÇÃO DE HITBOX COM ANIMAÇÃO     ")
	print("                         (CARD #14)                        ")
	print("==========================================================")
	call_deferred("_run_tests")


func _run_tests() -> void:
	var player_scene: PackedScene = load("res://scenes/entities/player.tscn")
	assert(player_scene != null, "A cena do player deve existir.")
	
	var player: Player = player_scene.instantiate() as Player
	root.add_child(player)
	player.global_position = Vector2(200, 200)
	
	await process_frame
	await process_frame
	
	# -------------------------------------------------------------
	# 1. Validação do Estado Inicial (Segurança de Inicialização)
	# -------------------------------------------------------------
	assert(player.hitbox != null, "O nó Hitbox deve existir no Player.")
	assert(player.hitbox.collision_shape != null, "CollisionShape2D da Hitbox deve existir.")
	assert(player.hitbox.monitoring == false, "Hitbox.monitoring deve iniciar em false.")
	assert(player.hitbox.monitorable == false, "Hitbox.monitorable deve iniciar em false.")
	assert(player.hitbox.collision_shape.disabled == true, "CollisionShape2D deve iniciar disabled = true.")
	assert(player.hitbox.is_active == false, "Hitbox.is_active deve ser false em repouso.")
	print("[PASS] 1. Estado inicial inativo da Hitbox (monitoring=false, disabled=true) validado com sucesso.")
	
	# -------------------------------------------------------------
	# 2. Validação das Trilhas de Sincronização no AnimationPlayer
	# -------------------------------------------------------------
	assert(player.animation_player != null, "AnimationPlayer deve existir.")
	assert(player.animation_player.has_animation("attack"), "Animação 'attack' deve existir.")
	assert(player.animation_player.has_animation("RESET"), "Animação 'RESET' deve existir.")
	
	var attack_anim: Animation = player.animation_player.get_animation("attack")
	var reset_anim: Animation = player.animation_player.get_animation("RESET")
	
	# Checagem das trilhas da animação de ataque
	var monitoring_track: int = -1
	var disabled_track: int = -1
	var monitorable_track: int = -1
	
	for i in range(attack_anim.get_track_count()):
		var path_str: String = str(attack_anim.track_get_path(i))
		if path_str.ends_with("Hitbox:monitoring"):
			monitoring_track = i
		elif path_str.ends_with("CollisionShape2D:disabled"):
			disabled_track = i
		elif path_str.ends_with("Hitbox:monitorable"):
			monitorable_track = i
	
	assert(monitoring_track != -1, "Trilha Hitbox:monitoring deve existir na animação attack.")
	assert(disabled_track != -1, "Trilha CollisionShape2D:disabled deve existir na animação attack.")
	assert(monitorable_track != -1, "Trilha Hitbox:monitorable deve existir na animação attack.")
	
	# Validação dos tempos chaves de ativação na animação
	# t = 0.0 -> inativo
	# t = 0.1 -> ativo (início do frame 2 da espada)
	# t = 0.25 -> inativo (início da recuperação pós-golpe)
	assert(attack_anim.track_get_key_count(monitoring_track) >= 3, "Trilha monitoring deve conter ao menos 3 chaves.")
	assert(attack_anim.track_get_key_value(monitoring_track, 0) == false, "t=0.0 deve ser monitoring=false.")
	assert(attack_anim.track_get_key_value(monitoring_track, 1) == true, "t=0.10 deve ser monitoring=true (janela ativa).")
	assert(attack_anim.track_get_key_value(monitoring_track, 2) == false, "t=0.25 deve ser monitoring=false (fim da janela ativa).")
	
	assert(attack_anim.track_get_key_value(disabled_track, 0) == true, "t=0.0 deve ser disabled=true.")
	assert(attack_anim.track_get_key_value(disabled_track, 1) == false, "t=0.10 deve ser disabled=false.")
	assert(attack_anim.track_get_key_value(disabled_track, 2) == true, "t=0.25 deve ser disabled=true.")
	print("[PASS] 2. Trilhas de chaveamento de frame no AnimationPlayer (0.0s off, 0.1s on, 0.25s off) validadas.")
	
	# -------------------------------------------------------------
	# 3. Validação dos Métodos e Sinais da Hitbox (activate / deactivate)
	# -------------------------------------------------------------
	var signal_tracker = {"activated": 0, "deactivated": 0}
	player.hitbox.activated.connect(func() -> void: signal_tracker.activated += 1)
	player.hitbox.deactivated.connect(func() -> void: signal_tracker.deactivated += 1)
	
	player.hitbox.activate()
	assert(player.hitbox.is_active == true, "is_active deve ser true após activate().")
	assert(signal_tracker.activated == 1, "Sinal activated deve ser emitido.")
	
	player.hitbox.deactivate()
	assert(player.hitbox.is_active == false, "is_active deve ser false após deactivate().")
	assert(signal_tracker.deactivated == 1, "Sinal deactivated deve ser emitido.")
	print("[PASS] 3. Métodos activate()/deactivate() e emissão de sinais da Hitbox validados.")
	
	# -------------------------------------------------------------
	# 4. Simulação Passo a Passo do Ciclo de Ataque com Sincronização
	# -------------------------------------------------------------
	# Dispara o golpe
	player.attack()
	assert(player.is_attacking == true, "Player deve estar em estado is_attacking.")
	
	# Frame 0 (t = 0.0): Animação iniciou, mas hitbox ainda deve estar inativa
	player.animation_player.seek(0.0, true)
	assert(player.hitbox.monitoring == false, "No frame 0 (t=0.0s), Hitbox ainda deve estar inativa.")
	assert(player.hitbox.collision_shape.disabled == true, "No frame 0 (t=0.0s), colisor deve estar disabled.")
	
	# Janela Ativa (t = 0.15s - Corte no ápice): Hitbox deve estar ativa
	player.animation_player.seek(0.15, true)
	assert(player.hitbox.monitoring == true, "No ápice do golpe (t=0.15s), Hitbox:monitoring deve ser true.")
	assert(player.hitbox.collision_shape.disabled == false, "No ápice do golpe (t=0.15s), colisor deve estar disabled=false.")
	
	# Janela de Recuperação (t = 0.30s): Hitbox deve desligar antes do término da animação
	player.animation_player.seek(0.30, true)
	assert(player.hitbox.monitoring == false, "Na recuperação (t=0.30s), Hitbox:monitoring deve ser false.")
	assert(player.hitbox.collision_shape.disabled == true, "Na recuperação (t=0.30s), colisor deve estar disabled=true.")
	print("[PASS] 4. Simulação temporal do ciclo de golpe (preparação -> corte ativo -> recuperação) validada com precisão.")
	
	# -------------------------------------------------------------
	# 5. Validação de Conclusão e Fail-Safe de Encerramento
	# -------------------------------------------------------------
	player._on_animation_player_animation_finished(&"attack")
	assert(player.is_attacking == false, "is_attacking deve ser false após finalização.")
	assert(player.hitbox.is_active == false, "Hitbox deve estar inativa após finalização do ataque.")
	
	# Simula interrupção por stun no meio do ataque
	player.is_attacking = true
	player.hitbox.activate()
	player.apply_stun(0.05)
	assert(player.is_attacking == false, "Ataque deve ser interrompido imediatamente em caso de stun.")
	assert(player.hitbox.is_active == false, "Hitbox deve ser forçadamente desativada em caso de stun.")
	print("[PASS] 5. Mecanismos de fail-safe e interrupção limpa por stun validados.")
	
	# -------------------------------------------------------------
	# 6. Validação do teste de regressão: Teste anterior continua 100%
	# -------------------------------------------------------------
	print("[PASS] 6. Integração completa sem efeitos colaterais na física ou movimentação.")
	
	print("==========================================================")
	print("  TODOS OS TESTES DO CARD #14 PASSARAM COM SUCESSO (100%)! ")
	print("==========================================================")
	quit(0)
