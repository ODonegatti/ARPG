# Objetivo do Módulo: Player (Controlador e Entidade Principal)

O módulo do **Player** é responsável por fornecer a entidade jogável em perspectiva Top-Down para o ARPG. Ele resolve de forma desacoplada e performática a orquestração de:
1. Leitura de inputs do teclado/gamepad em 8 direções com normalização de vetor.
2. Cálculo e aplicação de velocidade linear com colisão física contra o cenário.
3. Chaveamento automático de estados de animação (`idle` e `walk`) e direção das spritesheets (Down, Up e Side com espelhamento horizontal).

---

## Conceitos Chave Utilizados

- **`CharacterBody2D`**: Nó nativo da Godot especializado em corpos físicos controlados por código (jogadores, NPCs e inimigos). Permite movimentação precisa e colisão com o ambiente sem ser afetado diretamente por forças da física rígida (RigidBody2D).
- **`Input.get_vector("left", "right", "up", "down")`**: Função utilitária que mapeia 4 direções analógicas ou digitais retornando um vetor 2D. Em conjunto com `.normalized()`, impede o problema clássico de aceleração diagonal (`√2 ≈ 1.414`), garantindo velocidade uniforme nas 8 direções.
- **`move_and_slide()`**: Método nativo do `CharacterBody2D` que movimenta o corpo com base no vetor interno `velocity` e lida automaticamente com deslizamento em paredes e colisores do `TileMapLayer`.
- **`@export_group` & `@export`**: Mecanismo de encapsulamento e exposição de propriedades configuráveis no painel Inspector da Godot, permitindo ajuste fino de parâmetros (ex: `speed`) sem alterar o código-fonte.
- **Separação de Responsabilidades (SRP / Clean Architecture)**: Divisão clara entre o pipeline de entrada (`get_input_direction`), a lógica matemática (`calculate_velocity`) e a camada de apresentação visual (`update_animation`).

---

## Passo a Passo de Implementação

### 1. Hierarquia de Nós da Cena (`player.tscn`)
```text
Player (CharacterBody2D) [script: res://scripts/player.gd]
├── CollisionShape2D (CapsuleShape2D)
├── Camera2D
├── Sprite2D (PlayerSprite) [script: res://scripts/player_sprite.gd]
├── AnimationPlayer
└── HitboxPivot (Marker2D)
    └── Hitbox (Area2D) [script: res://scripts/hitbox.gd]
        └── CollisionShape2D (RectangleShape2D)
```

### 2. Configurações no Inspetor
1. **Player (`CharacterBody2D`)**:
   - `Scale`: `(0.5, 0.5)` para ajuste de escala relativa ao grid do mundo.
   - `Collision Layer`: `2` (`Player`), `Collision Mask`: `3` (`World` + `Player`).
   - `Speed`: `200.0 px/s` (campo exposto na aba *Movement Settings*).
2. **CollisionShape2D**:
   - `Shape`: `CapsuleShape2D` (Raio: `28`, Altura: `84`) cobrindo a base do personagem para colisões de chão.
3. **Sprite2D (`PlayerSprite`)**:
   - `Texture Filter`: `Nearest` (garante nitidez de pixel art sem blur).
   - `HFrames`: `8` (8 frames por linha de spritesheet).
   - Spritesheets atribuídas nos slots exportados (`idle_down`, `idle_up`, `idle_side`, `run_down`, etc.).
4. **AnimationPlayer**:
   - Trilhas de animação configuradas: `RESET`, `idle` (loop) e `walk` (loop), modulando a propriedade `Sprite2D:frame` de 0 a 7.
5. **HitboxPivot (`Marker2D`)**:
   - Pivô direcional que rotaciona dinamicamente (`rotation = direction.angle()`) acompanhando a última direção do jogador (`last_direction`).
6. **Hitbox (`Area2D` - `Hitbox.gd`)**:
   - `Collision Layer`: `4` (`PlayerHitbox`, valor 8).
   - `Collision Mask`: `3` (`Enemies`, valor 4).
   - `damage`: `10`, `knockback_force`: `120.0`.
   - `CollisionShape2D`: Inicia desativado (`disabled = true`) com offset frontal `(44, 0)`. Métodos `activate()` e `deactivate()` gerenciam o ciclo de golpe.

---

## Análise do Código (GDScript)

### 1. Orquestração no Loop de Física (`_physics_process`)
```gdscript
func _physics_process(_delta: float) -> void:
	var input_direction: Vector2 = get_input_direction()
	velocity = calculate_velocity(input_direction)
	update_animation(input_direction)
	move_and_slide()
```
*Por que foi feito assim:* Semelhante ao padrão *Update Loop* em POO, o `_physics_process` funciona como um orquestrador limpo de alto nível. Cada etapa do ciclo de vida da física do frame é delegada para uma função especializada.

### 2. Captação de Input Normalizado
```gdscript
func get_input_direction() -> Vector2:
	return Input.get_vector("left", "right", "up", "down").normalized()
```
*Por que foi feito assim:* Centraliza a consulta ao sistema de entrada da engine. O uso de `.normalized()` garante que o deslocamento nas diagonais mantenha magnitude 1.0.

### 3. Cálculo de Velocidade e Impulso Frontal (*Lunge*)
```gdscript
func calculate_velocity(direction: Vector2) -> Vector2:
	if not can_move:
		return Vector2.ZERO
	if is_attacking:
		return last_direction * attack_lunge_speed
	return direction * speed
```
*Por que foi feito assim:* Durante a locomoção padrão, calcula a velocidade escalar no vetor direcional. Durante o ataque, substitui a movimentação livre por um impulso frontal controlado (*lunge*) na direção do golpe (`last_direction * attack_lunge_speed`, padrão consagrado de ARPGs como *Minecraft Dungeons*). Isso elimina o estranhamento visual de deslizar lateralmente ou de costas no meio do golpe, conferindo peso e impacto à espada.

### 4. Controle de Animação e Orientação
```gdscript
func update_animation(direction: Vector2) -> void:
	if is_attacking:
		return

	if direction != Vector2.ZERO:
		last_direction = direction
		animation_player.play("walk")
		sprite.update_texture(direction, "walk")
	else:
		animation_player.play("idle")
		sprite.update_texture(last_direction, "idle")
```
*Por que foi feito assim:* Desacopla o estado de movimento da representação gráfica. Quando o jogador cessa o movimento, a variável `last_direction` garante que o sprite permaneça virado para o último quadrante de movimento durante o estado `idle`.

### 5. Execução do Golpe e Transição de Ataque (`attack`)
```gdscript
func attack() -> void:
	if not can_attack or is_attacking or _attack_cooldown_timer > 0.0:
		return
	
	is_attacking = true
	update_hitbox_direction(last_direction)
	_attack_cooldown_timer = attack_cooldown
	if sprite != null:
		sprite.update_texture(last_direction, "attack")
	if animation_player != null:
		animation_player.play("attack")
	attack_started.emit(last_direction)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"attack":
		is_attacking = false
		var current_input: Vector2 = get_input_direction()
		update_animation(current_input)
```
*Por que foi feito assim:* O ataque é disparado com proteção contra reentrância via `is_attacking` e `_attack_cooldown_timer`. Ao término da animação no `AnimationPlayer`, o sinal `animation_finished` restaura de forma assíncrona o estado `is_attacking = false` e devolve o controle ao movimento em tempo real sem interrupções indesejadas.

