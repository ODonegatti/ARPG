extends SceneTree

func _init() -> void:
	print("==================================================")
	print("  TESTE UNITÁRIO: DESTRUIÇÃO DO ALVO (CARD #19)   ")
	print("==================================================")
	call_deferred("_run_tests")


func _make_dummy(position: Vector2) -> Dummy:
	var dummy_scene: PackedScene = load("res://scenes/entities/dummy.tscn")
	assert(dummy_scene != null, "A cena do Dummy deve existir.")
	var dummy: Dummy = dummy_scene.instantiate() as Dummy
	root.add_child(dummy)
	dummy.global_position = position
	return dummy


func _count_effects() -> int:
	var count: int = 0
	for child: Node in root.get_children():
		if child is DestructionEffect:
			count += 1
	return count


func _first_effect() -> DestructionEffect:
	for child: Node in root.get_children():
		if child is DestructionEffect:
			return child as DestructionEffect
	return null


func _run_tests() -> void:
	await physics_frame
	await physics_frame
	
	# 1. Dano parcial não destrói o alvo
	var dummy: Dummy = _make_dummy(Vector2(100, 100))
	await physics_frame
	var tracker: Dictionary = {"died": 0}
	dummy.died.connect(func() -> void: tracker.died += 1)
	dummy.receber_dano(dummy.max_hp - 1)
	await process_frame
	assert(dummy.hp == 1, "hp deve ser 1 após dano parcial. Atual: %d" % dummy.hp)
	assert(is_instance_valid(dummy) and not dummy.is_queued_for_deletion(), "Dummy não deve ser removido com hp > 0.")
	assert(_count_effects() == 0, "Nenhum efeito de destruição deve existir com hp > 0.")
	assert(tracker.died == 0, "Sinal died não deve ser emitido com hp > 0.")
	print("[PASS] 1. Dano parcial não destrói o alvo.")
	
	# 2. hp <= 0 destrói o alvo (objeto): fragmentos, sem sangue, queue_free e sinal died
	dummy.receber_dano(5)
	assert(dummy.hp == 0, "hp deve parar em 0.")
	assert(dummy.is_queued_for_deletion(), "Dummy deve ser marcado para remoção (queue_free) com hp <= 0.")
	assert(tracker.died == 1, "Sinal died deve ser emitido exatamente uma vez.")
	assert(_count_effects() == 1, "Deve ser criado exatamente um efeito de destruição.")
	var effect: DestructionEffect = _first_effect()
	assert(effect.get_piece_count() > 0, "O sprite deve ser quebrado em fragmentos.")
	assert(effect.get_blood_count() == 0, "Objeto (não vivo) não deve gerar sangue.")
	print("[PASS] 2. Objeto destruído gera fragmentos, sem sangue, e é removido com segurança.")
	
	# 3. Destruição não se repete
	dummy.receber_dano(50)
	assert(tracker.died == 1, "Dano após a morte não deve emitir died novamente.")
	assert(_count_effects() == 1, "Dano após a morte não deve criar novo efeito.")
	print("[PASS] 3. Destruição ocorre apenas uma vez.")
	
	await process_frame
	await process_frame
	assert(not is_instance_valid(dummy), "Dummy deve ser liberado da árvore após queue_free.")
	print("[PASS] 4. Dummy liberado da árvore.")
	
	# 5. Ser vivo: fragmentos + pixels vermelhos (sangue)
	var living: Dummy = _make_dummy(Vector2(300, 100))
	living.is_living = true
	await physics_frame
	living.receber_dano(living.max_hp)
	var living_effect: DestructionEffect = null
	for child: Node in root.get_children():
		if child is DestructionEffect and child != effect:
			living_effect = child as DestructionEffect
	assert(living_effect != null, "Ser vivo deve gerar efeito de destruição.")
	assert(living_effect.get_piece_count() > 0, "Ser vivo também deve se quebrar em fragmentos.")
	assert(living_effect.get_blood_count() > 0, "Ser vivo deve liberar pixels de sangue.")
	assert(living_effect.blood_color.r > living_effect.blood_color.g and living_effect.blood_color.r > living_effect.blood_color.b, "Sangue deve ser vermelho.")
	print("[PASS] 5. Ser vivo gera fragmentos e pixels vermelhos (sangue).")
	
	# 6. Fragmentos são arremessados (movem-se) e o efeito se auto-remove
	var start_pos: Vector2 = living_effect.get_child(0).position
	await create_timer(0.2).timeout
	assert(living_effect.get_child(0).position != start_pos, "Fragmentos devem se mover (ser arremessados).")
	await create_timer(living_effect.lifetime + 0.3).timeout
	assert(not is_instance_valid(living_effect), "O efeito deve se auto-remover ao fim da vida útil.")
	print("[PASS] 6. Fragmentos são arremessados e o efeito se auto-remove.")
	
	print("==================================================")
	print("  TODOS OS TESTES DO CARD #19 PASSARAM COM SUCESSO! ")
	print("==================================================")
	quit(0)
