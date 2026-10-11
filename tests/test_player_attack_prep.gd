extends SceneTree

var _attack_signal_count: int = 0
var _attack_dir_received: Vector2 = Vector2.ZERO

func _init() -> void:
	print("==================================================")
	print("  TESTE UNITÁRIO: PREPARAÇÃO DE ATAQUE E STUN    ")
	print("==================================================")
	call_deferred("_run_tests")

func _on_attack_started(dir: Vector2) -> void:
	_attack_signal_count += 1
	_attack_dir_received = dir

func _run_tests() -> void:
	var player_scene: PackedScene = load("res://scenes/entities/player.tscn")
	assert(player_scene != null, "A cena do player deve existir.")
	
	var player: Player = player_scene.instantiate() as Player
	root.add_child(player)
	
	await process_frame
	await process_frame
	
	# 1. Validação dos valores iniciais
	assert(player.can_move == true, "can_move deve iniciar como true")
	assert(player.can_attack == true, "can_attack deve iniciar como true")
	assert(player.attack_cooldown == 0.4, "attack_cooldown padrão deve ser 0.4s")
	print("[PASS] 1. Flags iniciais e propriedades de combate válidas.")
	
	# 2. Validação da restrição de movimento (can_move = false)
	player.can_move = false
	var vel_blocked: Vector2 = player.calculate_velocity(Vector2.RIGHT)
	assert(vel_blocked == Vector2.ZERO, "calculate_velocity deve ser Vector2.ZERO quando can_move == false")
	assert(player.get_input_direction() == Vector2.ZERO, "get_input_direction deve ser Vector2.ZERO quando can_move == false")
	
	player.can_move = true
	var vel_ok: Vector2 = player.calculate_velocity(Vector2.RIGHT)
	assert(vel_ok == Vector2.RIGHT * player.speed, "calculate_velocity deve responder normalmente quando can_move == true")
	print("[PASS] 2. Restrição de movimento (can_move) validada.")
	
	# 3. Validação do sinal e execução do ataque
	player.attack_started.connect(_on_attack_started)
	
	player.last_direction = Vector2.UP
	_attack_signal_count = 0
	player.attack()
	assert(_attack_signal_count == 1, "attack_started deve ser emitido exatamente 1 vez ao chamar attack()")
	assert(_attack_dir_received == Vector2.UP, "A direção emitida no sinal deve ser last_direction")
	print("[PASS] 3. Emissão de sinal attack_started com direção correta.")
	
	# 4. Validação de Cooldown
	_attack_signal_count = 0
	player.attack() # Segunda chamada imediata durante o cooldown
	assert(_attack_signal_count == 0, "Não deve permitir ataque consecutivo antes do cooldown terminar")
	
	# Avança o cooldown manualmente via update_timers
	player.update_timers(player.attack_cooldown + 0.05)
	player.attack()
	assert(_attack_signal_count == 1, "Deve permitir atacar novamente após o cooldown expirar")
	print("[PASS] 4. Lógica de cooldown de ataque validada com sucesso.")
	
	# 5. Validação de Bloqueio de Ataque (can_attack = false)
	_attack_signal_count = 0
	player.update_timers(player.attack_cooldown + 0.05)
	player.can_attack = false
	player.attack()
	assert(_attack_signal_count == 0, "Não deve atacar se can_attack for false")
	player.can_attack = true
	print("[PASS] 5. Restrição de can_attack validada.")
	
	# 6. Validação do Input Map de player_attack
	_attack_signal_count = 0
	player.update_timers(player.attack_cooldown + 0.05)
	var attack_event: InputEventAction = InputEventAction.new()
	attack_event.action = "player_attack"
	attack_event.pressed = true
	player._unhandled_input(attack_event)
	assert(_attack_signal_count == 1, "Ação 'player_attack' deve invocar attack()")
	print("[PASS] 6. Integração do Input Map 'player_attack' via _unhandled_input validada.")
	
	# 7. Validação do utilitário apply_stun
	player.apply_stun(0.05)
	assert(player.can_move == false, "apply_stun deve desativar can_move imediatamente")
	assert(player.can_attack == false, "apply_stun deve desativar can_attack imediatamente")
	await create_timer(0.08).timeout
	assert(player.can_move == true, "can_move deve ser restaurado após término do stun")
	assert(player.can_attack == true, "can_attack deve ser restaurado após término do stun")
	print("[PASS] 7. Mecânica de Stun temporário (apply_stun) validada.")
	
	print("==================================================")
	print("  TODOS OS TESTES DE PREPARAÇÃO DE ATAQUE PASSARAM!")
	print("==================================================")
	quit(0)
