extends SceneTree

func _init() -> void:
	print("==========================================================")
	print("  TESTE UNITÁRIO: ANIMAÇÃO DE ATAQUE DIRECIONAL (CARD #13)  ")
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
	
	# 1. Validação dos slots de textura de ataque exportados no PlayerSprite
	assert(player.sprite != null, "PlayerSprite deve existir.")
	assert(player.sprite.attack_down != null, "attack_down deve estar atribuído no PlayerSprite.")
	assert(player.sprite.attack_up != null, "attack_up deve estar atribuído no PlayerSprite.")
	assert(player.sprite.attack_side != null, "attack_side deve estar atribuído no PlayerSprite.")
	print("[PASS] 1. Spritesheets direcionais de ataque (Down, Up, Side) configurados no PlayerSprite.")
	
	# 2. Validação da trilha de animação 'attack' no AnimationPlayer
	assert(player.animation_player != null, "AnimationPlayer deve existir.")
	assert(player.animation_player.has_animation("attack"), "AnimationPlayer deve possuir a animação 'attack'.")
	
	var attack_anim: Animation = player.animation_player.get_animation("attack")
	assert(attack_anim != null, "Objeto da animação 'attack' deve ser válido.")
	assert(is_equal_approx(attack_anim.length, 0.4), "A duração da animação de ataque deve ser 0.4s (compatível com attack_cooldown). Duração atual: %f" % attack_anim.length)
	assert(attack_anim.loop_mode == Animation.LOOP_NONE, "A animação de ataque NÃO deve estar em loop.")
	assert(attack_anim.get_track_count() > 0, "A animação de ataque deve conter trilhas.")
	assert(attack_anim.track_get_path(0) == NodePath("Sprite2D:frame"), "Trilha 0 deve modular Sprite2D:frame.")
	assert(attack_anim.track_get_key_count(0) == 8, "Trilha de frame deve conter 8 frames.")
	print("[PASS] 2. Configuração da animação 'attack' (0.4s, 8 frames, sem loop) validada.")
	
	# 3. Validação do chaveamento de textura e espelhamento direcional em estado 'attack'
	# DOWN
	player.sprite.update_texture(Vector2.DOWN, "attack")
	assert(player.sprite.texture == player.sprite.attack_down, "Textura de ataque para DOWN deve ser attack_down.")
	assert(player.sprite.flip_h == false, "flip_h deve ser false para DOWN.")
	
	# UP
	player.sprite.update_texture(Vector2.UP, "attack")
	assert(player.sprite.texture == player.sprite.attack_up, "Textura de ataque para UP deve ser attack_up.")
	assert(player.sprite.flip_h == false, "flip_h deve ser false para UP.")
	
	# RIGHT
	player.sprite.update_texture(Vector2.RIGHT, "attack")
	assert(player.sprite.texture == player.sprite.attack_side, "Textura de ataque para RIGHT deve ser attack_side.")
	assert(player.sprite.flip_h == false, "flip_h deve ser false para RIGHT.")
	
	# LEFT
	player.sprite.update_texture(Vector2.LEFT, "attack")
	assert(player.sprite.texture == player.sprite.attack_side, "Textura de ataque para LEFT deve ser attack_side.")
	assert(player.sprite.flip_h == true, "flip_h deve ser true para LEFT.")
	print("[PASS] 3. Chaveamento direcional e espelhamento horizontal (flip_h) no ataque validados.")
	
	# 4. Validação da execução de player.attack() e disparo da animação
	var tracker = {"emitted": false, "dir": Vector2.ZERO}
	player.attack_started.connect(func(dir: Vector2) -> void:
		tracker.emitted = true
		tracker.dir = dir
	)
	
	player.last_direction = Vector2.RIGHT
	player.attack()
	
	assert(player.is_attacking == true, "player.is_attacking deve ser true após attack().")
	assert(tracker.emitted == true, "Sinal attack_started deve ser emitido.")
	assert(tracker.dir == Vector2.RIGHT, "Direção informada no sinal deve ser Vector2.RIGHT.")
	assert(player.animation_player.current_animation == "attack", "AnimationPlayer deve estar tocando 'attack'.")
	assert(player.sprite.texture == player.sprite.attack_side, "Sprite deve assumir attack_side.")
	assert(player.sprite.flip_h == false, "flip_h deve ser false para ataque à direita.")
	print("[PASS] 4. Execução de attack() com ativação de is_attacking e reprodução da animação validada.")
	
	# 5. Validação de bloqueio de re-trigger de ataque durante execução e proteção de cooldown
	var second_tracker = {"emitted": false}
	player.attack_started.connect(func(_dir: Vector2) -> void:
		second_tracker.emitted = true
	)
	player.attack() # Segunda chamada consecutiva
	assert(second_tracker.emitted == false, "Novo ataque não deve ser disparado enquanto is_attacking for true.")
	print("[PASS] 5. Prevenção de reentrância durante ataque ativa e funcional.")
	
	# 6. Validação de movimentação simultânea sem travamento físico
	var move_vel: Vector2 = player.calculate_velocity(Vector2.RIGHT)
	assert(is_equal_approx(move_vel.length(), player.speed), "O jogador pode se mover durante o ataque sem travamento físico indesejado.")
	print("[PASS] 6. Física de movimentação simultânea validada.")
	
	# 7. Validação do término da animação e restauração de estado
	player._on_animation_player_animation_finished(&"attack")
	assert(player.is_attacking == false, "is_attacking deve retornar para false ao concluir a animação.")
	print("[PASS] 7. Conclusão da animação e restauração automática do estado de locomoção validados.")
	
	print("==========================================================")
	print("  TODOS OS TESTES DE ANIMAÇÃO DE ATAQUE PASSARAM COM 100%! ")
	print("==========================================================")
	quit(0)
