# Módulo 2: Sistema de Combate Corpo a Corpo & Hitboxes (Sprint 2)

Bem-vindo ao **Módulo 2** do curso prático de desenvolvimento de jogos com **Godot 4 e GDScript**.

Neste curso, cada módulo corresponde a uma **Sprint de Desenvolvimento** real, e cada capítulo corresponde a um **Card Técnico** executado no projeto. Aqui você aprende arquitetura de software limpa, desacoplada, fortemente tipada e testável para um Action RPG (ARPG) 2D com estética e dinamismo de alto nível.

No Módulo 1, construímos as fundações físicas do protagonista: locomoção top-down em 8 direções, colisão com cenário via `TileMapLayer`, máquina de animação direcional e suítes de teste headless. Agora, no **Módulo 2**, daremos vida ao núcleo de um ARPG: o **Combate Melee (Corpo a Corpo)**.

---

## 🎯 Objetivos de Aprendizagem do Módulo 2
Ao final deste módulo, você será capaz de:
1. Modelar o **Padrão Hitbox / Hurtbox** utilizando o motor de física 2D da Godot com estrito desacoplamento arquitetural.
2. Configurar a matriz de **Collision Layers & Masks** de forma escalável e à prova de bugs.
3. Criar animações de ataque com **sincronização cirúrgica de frames** para ativação e desativação de janelas de dano no `AnimationPlayer`.
4. Implementar mecânica de avanço frontal rápido (**Lunge**) com frenagem instantânea por atrito, conferindo sensação tátil de corte (*game feel* estilo Minecraft Dungeons).
5. Projetar uma entidade alvo de treino (**Dummy**) orientada a componentes, sem acoplamento à classe do Player.
6. Aplicar encapsulamento rigoroso em atributos de combate (HP, dano e velocidade) utilizando *setters* restritivos (`clampi`) e tipagem estática.
7. Construir **Juice & Game Feel puramente por código**: repulsão física cinemática (*knockback* com amortecimento linear) e *flash* visual de dano via `Tween`.
8. Implementar o **Padrão Global de Destruição do Projeto**: fatiamento procedural de texturas em fragmentos e partículas de sangue por código GDScript (`DestructionEffect`).
9. Desenvolver suítes de teste automatizado de combate integrado de ponta a ponta sem interface gráfica.

---

## 📑 Índice dos Capítulos (Cards da Sprint 2)
- [Capítulo 1 (Card #11): Configuração de Input de Ataque e Cooldowns](#capítulo-1-card-11-configuração-de-input-de-ataque-e-cooldowns)
- [Capítulo 2 (Card #12): Estrutura Espacial da Hitbox (Area2D & Pivô)](#capítulo-2-card-12-estrutura-espacial-da-hitbox-area2d--pivô)
- [Capítulo 3 (Card #13): Animação Direcional de Ataque e o Mecanismo de Lunge](#capítulo-3-card-13-animação-direcional-de-ataque-e-o-mecanismo-de-lunge)
- [Capítulo 4 (Card #14): Sincronização Cirúrgica de Frame da Hitbox](#capítulo-4-card-14-sincronização-cirúrgica-de-frame-da-hitbox)
- [Capítulo 5 (Card #15): Entidade Dummy (Alvo de Treino) e Física Cinemática](#capítulo-5-card-15-entidade-dummy-alvo-de-treino-e-física-cinemática)
- [Capítulo 6 (Card #16): Componente Hurtbox e Comunicação por Sinais](#capítulo-6-card-16-componente-hurtbox-e-comunicação-por-sinais)
- [Capítulo 7 (Card #17): Encapsulamento de Vida (HP) e Aplicação de Dano](#capítulo-7-card-17-encapsulamento-de-vida-hp-e-aplicação-de-dano)
- [Capítulo 8 (Card #18): Feedback Visual de Impacto (Knockback & Flash Tween)](#capítulo-8-card-18-feedback-visual-de-impacto-knockback--flash-tween)
- [Capítulo 9 (Card #19): O Padrão Global de Destruição e Remoção Segura](#capítulo-9-card-19-o-padrão-global-de-destruição-e-remoção-segura)
- [Capítulo 10 (Card #20): Playtest Integrado de Combate e Fechamento](#capítulo-10-card-20-playtest-integrado-de-combate-e-fechamento)
- [🚀 Detalhamento das Pull Requests (PRs da Sprint 2)](#-detalhamento-das-pull-requests-prs-da-sprint-2)
- [💡 Desafio Prático para o Aluno](#-desafio-prático-para-o-aluno)

---

## Capítulo 1 (Card #11): Configuração de Input de Ataque e Cooldowns

### 1.1 Objetivo do Capítulo
Mapear a ação de ataque do jogador no `InputMap` da Godot, gerenciar flags de restrição de estado (`can_move`, `can_attack`, `is_attacking`), controlar a cadência entre golpes consecutivos via *cooldown* e criar o utilitário de atordoamento (`apply_stun`).

### 1.2 Por que isso importa na vida real?
Sem um controle rígido de cadência e estados, jogadores conseguem disparar ações repetidas (*input spam*), cancelando animações no frame 1 e multiplicando o dano de forma exploratória. Além disso, jogos de ação exigem mecanismos arquiteturais limpos para interromper o jogador (atordoamentos, cutscenes ou morte).

### 1.3 Implementação e Controle de Cadência
O ataque é escutado através de `_unhandled_input(event)`, evitando capturar cliques que deveriam ser tratados pela interface de usuário (HUD/UI):

```gdscript
func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("player_attack") and not event.is_echo():
        attack()
```

O método `attack()` verifica se o jogador satisfaz as condições antes de iniciar o golpe:

```gdscript
func attack() -> void:
    if not can_attack or is_attacking or _attack_cooldown_timer > 0.0:
        return
    
    is_attacking = true
    update_hitbox_direction(last_direction)
    _attack_cooldown_timer = attack_cooldown
    _lunge_velocity = last_direction * attack_lunge_speed
    if sprite != null:
        sprite.update_texture(last_direction, "attack")
    if animation_player != null:
        animation_player.play("attack")
    attack_started.emit(last_direction)
```

No loop `_physics_process(delta)`, o temporizador é decrementado com precisão:
```gdscript
func update_timers(delta: float) -> void:
    if _attack_cooldown_timer > 0.0:
        _attack_cooldown_timer = max(0.0, _attack_cooldown_timer - delta)
```

---

## Capítulo 2 (Card #12): Estrutura Espacial da Hitbox (Area2D & Pivô)

### 2.1 O que é uma Hitbox?
Na arquitetura de combate, uma **Hitbox** é o volume espacial que representa a arma ou golpe atacante. Ela não bloqueia movimento físico (como paredes), mas detecta intersecções de sobreposição geométrica.

### 2.2 Arquitetura de Rotação por Pivô (`HitboxPivot`)
Em jogos 2D Top-Down, criar 4 ou 8 colisores distintos para cada direção de ataque gera duplicação de nós e complexidade no Inspector. 

A solução elegante e matemática adotada no projeto utiliza um **Pivô Central (`Marker2D`)**:
1. Criamos um nó `Marker2D` chamado `HitboxPivot` centralizado no corpo do Player em `(0, 0)`.
2. Como filho do pivô, instanciamos a `Hitbox` (`Area2D`) com sua forma `CollisionShape2D` deslocada para frente (offset positivo no eixo X local: `x = 44`).
3. Quando o personagem olha para uma nova direção, rotacionamos apenas o pivô através do ângulo do vetor:
```gdscript
func update_hitbox_direction(direction: Vector2) -> void:
    if direction != Vector2.ZERO and hitbox_pivot != null:
        hitbox_pivot.rotation = direction.angle()
```
*Vantagem Matemática:* Com apenas uma forma retangular e uma linha de código, o corte de espada cobre perfeitamente qualquer direção em 360 graus.

### 2.3 Camadas de Colisão Físicas (Collision Layers & Masks)
Configurar corretamente os bits de colisão da Godot é vital:
- **Layer 4 (`PlayerHitbox`, bitmask 8):** Camada onde a `Hitbox` do jogador reside.
- **Mask 3 (`Enemies`, bitmask 4):** Camada que a `Hitbox` escuta ativamente.

```gdscript
class_name Hitbox
extends Area2D

signal activated()
signal deactivated()

@export var damage: int = 10
@export var knockback_force: float = 120.0
@export var source: Node2D = null

var is_active: bool = false
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func activate() -> void:
    is_active = true
    set_deferred("monitoring", true)
    set_deferred("monitorable", true)
    if collision_shape != null:
        collision_shape.set_deferred("disabled", false)
    activated.emit()

func deactivate() -> void:
    is_active = false
    set_deferred("monitoring", false)
    set_deferred("monitorable", false)
    if collision_shape != null:
        collision_shape.set_deferred("disabled", true)
    deactivated.emit()
```

> [!IMPORTANT]
> **Por que usar `set_deferred`?**
> A Godot não permite alterar o estado físico de colisores (`disabled`, `monitoring`) no meio da iteração do motor de física. O método `set_deferred()` adia a atribuição com segurança para o momento de sincronização física da engine, eliminando travamentos e avisos de runtime.

---

## Capítulo 3 (Card #13): Animação Direcional de Ataque e o Mecanismo de Lunge

### 3.1 Transição de Textura e Espelhamento Horizontal
O `PlayerSprite` foi estendido para mapear as spritesheets de corte do guerreiro nas 4 orientações cardinais:
- `attack_down`: Golpes verticais para baixo.
- `attack_up`: Golpes verticais para cima.
- `attack_side`: Golpes horizontais laterais. Se o jogador olhar para a esquerda, ativamos `flip_h = true`.

### 3.2 O Mecanismo de Avanço Frontal (*Lunge*)
Em ARPGs dinâmicos (como *Minecraft Dungeons* ou *Hades*), golpes de espada não são desferidos com o personagem estático nem com o jogador correndo livremente. Existe um pequeno **avanço físico vigoroso** seguido de **parada brusca**.

Implementamos essa cinemática com duas forças:
1. **Velocidade de Impulso (`attack_lunge_speed = 240.0 px/s`):** No momento em que o golpe é desferido, aplicamos velocidade na direção do ataque.
2. **Atrito Elevado (`attack_lunge_friction = 2400.0 px/s²`):** A cada tick de física, o vetor de lunge é desacelerado para zero:
```gdscript
if is_attacking and _lunge_velocity != Vector2.ZERO:
    _lunge_velocity = _lunge_velocity.move_toward(Vector2.ZERO, attack_lunge_friction * delta)
```

No cálculo de velocidade (`calculate_velocity`):
```gdscript
func calculate_velocity(direction: Vector2) -> Vector2:
    if not can_move:
        return Vector2.ZERO
    if is_attacking:
        return _lunge_velocity
    return direction * speed
```
O resultado é um golpe rápido, tátil e que impede que o jogador "patine" no cenário enquanto ataca.

---

## Capítulo 4 (Card #14): Sincronização Cirúrgica de Frame da Hitbox

### 4.1 O Erro dos Iniciantes
Muitos desenvolvedores ligam a Hitbox assim que o botão de ataque é pressionado e a deixam ligada até a animação acabar. Isso causa acertos fantasmas antes mesmo da espada sair da bainha ou após a lâmina já ter repousado.

### 4.2 A Janela Ativa de Golpe (Hit Window)
A animação de ataque do nosso guerreiro possui duração total de `0.4s` (8 frames). Dividimos o golpe em 3 fases:
1. **Fase de Preparação (Wind-up - 0.0s a 0.1s):** O guerreiro levanta a espada. A Hitbox permanece **desativada**.
2. **Fase Ativa de Dano (Active Arc - 0.1s a 0.25s):** A lâmina corta o ar. A Hitbox é **ativada** (`enable_hitbox()`).
3. **Fase de Recuperação (Recovery - 0.25s a 0.4s):** A espada encerra a trajetória. A Hitbox é **desativada** (`disable_hitbox()`).

### 4.3 Fail-Safe Arquitetural
Mesmo que a trilha do `AnimationPlayer` comande o encerramento da janela ativa, eventos imprevistos podem ocorrer (ex: o jogador sofre atordoamento ou a animação é cancelada).

Para garantir robustez absoluta, conectamos o sinal nativo de término da animação:
```gdscript
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
    if anim_name == &"attack":
        is_attacking = false
        _lunge_velocity = Vector2.ZERO
        disable_hitbox() # Trava de segurança (Fail-Safe)
        var current_input: Vector2 = get_input_direction()
        update_animation(current_input)
```

---

## Capítulo 5 (Card #15): Entidade Dummy (Alvo de Treino) e Física Cinemática

### 5.1 Arquitetura do Alvo (`CharacterBody2D`)
Para testar o combate de forma fidedigna aos futuros inimigos, o `Dummy` não foi criado como um simples objeto estático, mas sim como um `CharacterBody2D` cinemático:

```text
Dummy (CharacterBody2D)
├── Shadow (Sprite2D)
├── Sprite2D
├── CollisionShape2D (CapsuleShape2D)
├── AnimationPlayer
└── Hurtbox (Area2D)
    └── CollisionShape2D (RectangleShape2D)
```

### 5.2 Cinemática com Atrito Linear
O `Dummy` possui a propriedade exportada `friction: float = 800.0`. Quando sofre um empurrão físico, ele se desloca e para suavemente:
```gdscript
func _physics_process(delta: float) -> void:
    if velocity != Vector2.ZERO:
        velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
        move_and_slide()
```

---

## Capítulo 6 (Card #16): Componente Hurtbox e Comunicação por Sinais

### 6.1 O que é uma Hurtbox?
Se a **Hitbox** é a lâmina ofensiva, a **Hurtbox** é o receptor defensivo de dano.

Em vez de verificar colisões no script principal do monstro, extraímos toda a lógica de vulnerabilidade para a classe reutilizável `Hurtbox` (`scripts/hurtbox.gd`):

```gdscript
class_name Hurtbox
extends Area2D

signal hit_received(hitbox: Hitbox)

@export var owner_entity: Node2D = null
@export var is_invulnerable: bool = false
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
    if owner_entity == null and get_parent() is Node2D:
        owner_entity = get_parent() as Node2D
    monitoring = true
    monitorable = true
    area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
    if is_invulnerable:
        return
    if area is Hitbox:
        var hitbox: Hitbox = area as Hitbox
        hit_received.emit(hitbox)
```

### 6.2 Benefícios de POO dessa Estrutura
- **Duck Typing / Tipagem Estrutural Segura:** A Hurtbox filtra `area is Hitbox`. Áreas de coleta de moedas ou gatilhos de diálogo nunca dispararão dano por engano.
- **Composição sobre Herança:** Qualquer objeto destrutível do jogo (um baú, um vaso de cerâmica, um chefe gigante) precisa apenas receber um nó filho `Hurtbox` para se tornar atacável.

---

## Capítulo 7 (Card #17): Encapsulamento de Vida (HP) e Aplicação de Dano

### 7.1 Encapsulamento com Setter Restritivo
Para evitar que a vida assuma valores negativos ou ultrapasse o valor máximo, o atributo `hp` no `Dummy` é protegido por um *setter* que utiliza a função nativa `clampi()` da Godot:

```gdscript
@export_group("Health Settings")
@export var max_hp: int = 100

var hp: int = 0:
    set(value):
        hp = clampi(value, 0, max_hp)
```

### 7.2 Método `receber_dano(valor: int)`
Toda alteração de saúde passa obrigatoriamente por um método público:
```gdscript
func receber_dano(valor: int) -> void:
    if _is_dying:
        return
    hp -= valor
    if hp <= 0:
        _morrer()
```
Isso garante integridade: nenhuma parte externa do código modifica a vida diretamente sem acionar as verificações e efeitos de morte.

---

## Capítulo 8 (Card #18): Feedback Visual de Impacto (Knockback & Flash Tween)

### 8.1 Repulsão Cinemática (Knockback)
Quando a espada atinge o alvo, o impacto empurra o inimigo para longe da origem do ataque. O vetor diretor unitário é obtido subtraindo a posição da fonte da posição do alvo:

```gdscript
func _direcao_do_golpe(hitbox: Hitbox) -> Vector2:
    if hitbox.source != null:
        return (global_position - hitbox.source.global_position).normalized()
    return Vector2.ZERO

func _calcular_knockback(hitbox: Hitbox) -> Vector2:
    return _direcao_do_golpe(hitbox) * hitbox.knockback_force

func aplicar_knockback(impulso: Vector2) -> void:
    velocity = impulso
```

### 8.2 Flash de Dano com `Tween`
O feedback visual imediato (*juice*) é gerado 100% por código usando a API de `Tween` da Godot 4:
```gdscript
func play_flash() -> void:
    if sprite == null:
        return
    if _flash_tween != null and _flash_tween.is_valid():
        _flash_tween.kill() # Mata tweens anteriores para evitar sobreposição
    
    sprite.modulate = flash_color # Cor de impacto (vermelho claro)
    _flash_tween = create_tween()
    _flash_tween.tween_property(sprite, "modulate", Color.WHITE, flash_duration)
```

---

## Capítulo 9 (Card #19): O Padrão Global de Destruição e Remoção Segura

### 9.1 A Regra de Ouro da Destruição no Projeto
Conforme estabelecido nas diretrizes centrais de arquitetura (`AI_CONTEXT.md`):
> **Padrão de Destruição:** Quando qualquer objeto é destruído no jogo, seu sprite se quebra em pedaços que são arremessados pela tela. Se for um **ser vivo** (`is_living = true`), pixels vermelhos (sangue) voam junto com os fragmentos.

### 9.2 A Classe `DestructionEffect` (`scripts/destruction_effect.gd`)
Em vez de desenhar manualmente spritesheets de explosão para cada entidade, criamos um sistema procedural que fatia a textura do sprite em tempo de execução:
1. O método estático `DestructionEffect.spawn(sprite, parent, is_living, hit_direction)` calcula a grade de pedaços a partir do `texture` original e de `hframes`/`vframes`.
2. Cria nós `Sprite2D` individuais para cada pedaço, atribuindo impulsos com dispersão angular (`hit_direction + random_offset`).
3. Se `is_living` for verdadeiro, instancia pixels vermelhos adicionais representando sangue.
4. Anima a transparência (`alpha`) até sumir e agenda a própria remoção com `queue_free()`.

### 9.3 Remoção Segura do Alvo (`_morrer()`)
```gdscript
func _morrer() -> void:
    if _is_dying:
        return
    _is_dying = true
    velocity = Vector2.ZERO
    set_physics_process(false)
    if hurtbox != null:
        hurtbox.disable() # Evita registrar danos adicionais
    if sprite != null and get_parent() != null:
        DestructionEffect.spawn(sprite, get_parent(), is_living, _last_hit_direction)
    died.emit()
    queue_free() # Liberação segura de memória
```

---

## Capítulo 10 (Card #20): Playtest Integrado de Combate e Fechamento

### 10.1 Por que Testes Integrados de Combate?
Testes unitários isolados garantem que cada função funcione em seu próprio vácuo, mas jogos falham na **integração**. A suíte `tests/playtest_sprint2.gd` simula o ciclo completo de um combate real:
1. Instancia a cena principal `main.tscn`.
2. Posiciona o Player e o Dummy no espaço 2D.
3. Dispara `player.attack()`.
4. Valida a passagem do tempo e ativação da Hitbox no frame correto.
5. Valida a emissão do sinal na Hurtbox e dedução exata de HP.
6. Valida o vetor de knockback em X e a desaceleração pelo atrito.
7. Valida o flash visual e animações de impacto.
8. Aplica dano letal, comprovando a criação de `DestructionEffect`, emissão de `died` e remoção com `queue_free()`.

---

## 🚀 Detalhamento das Pull Requests (PRs da Sprint 2)

Abaixo está o registro histórico e formal das Pull Requests que compõem a Sprint 2:

### PR #6: Input Map e Cooldowns de Ataque
- **Título:** `feat(player): configura input de ataque e flags de can_attack e can_move`
- **Branch:** `feat/card-11/configuracao-input-map-e-ataque` ➔ `main`
- **Contexto:** Mapeia a ação `player_attack` e implementa controle de cadência e travas de estado.
- **Arquivos Alterados:** `project.godot`, `scripts/player.gd`, `tests/test_player_attack_prep.gd`.
- **Lição Arquitetural:** Uso de temporizadores em `_physics_process` garante consistência temporal independente da taxa de quadros (FPS).

---

### PR #7: Estrutura da Hitbox do Espadachim
- **Título:** `feat: implementa estrutura de hitbox direcional do player (Card #12)`
- **Branch:** `feat/card-12/estrutura-hitbox-area2d` ➔ `main`
- **Contexto:** Criação da classe `Hitbox` (`Area2D`) acoplada a um pivô rotacional (`HitboxPivot`).
- **Arquivos Alterados:** `scripts/hitbox.gd`, `scenes/entities/player.tscn`, `tests/test_hitbox_structure.gd`.
- **Lição Arquitetural:** Rotação vetorial por pivô elimina redundância de colisores e simplifica a hierarquia de cenas.

---

### PR #8: Animações de Ataque Direcional & Lunge
- **Título:** `feat(player): implementa animacao direcional de ataque e transicao de estado (Card #13)`
- **Branch:** `feat/card-13/animacao-ataque-direcional` ➔ `main`
- **Contexto:** Adiciona spritesheets de ataque nas 4 direções e mecânica de avanço frontal rápido com forte desaceleração linear.
- **Arquivos Alterados:** `scripts/player.gd`, `scripts/player_sprite.gd`, `scenes/entities/player.tscn`, `tests/test_attack_animation.gd`.
- **Lição Arquitetural:** O movimento de avanço desacelerado confere peso físico e satisfação sensorial (*game feel*) ao golpe.

---

### PR #9: Sincronização de Frame da Hitbox
- **Título:** `feat(player): sincroniza ativacao de frame da hitbox com animation_player (Card #14)`
- **Branch:** `feat/card-14/sincronizacao-hitbox-animacao` ➔ `main`
- **Contexto:** Sincroniza o período ativo da colisão da Hitbox exclusivamente entre os frames 0.1s e 0.25s da animação de golpe.
- **Arquivos Alterados:** `scenes/entities/player.tscn`, `scripts/player.gd`, `tests/test_hitbox_sync.gd`.
- **Lição Arquitetural:** Janelas ativas precisas eliminam colisões fantasmas e conferem justiça e responsividade ao gameplay.

---

### PR #10: Criação da Cena Base do Inimigo / Dummy
- **Título:** `feat(enemy): cria cena base e animacoes do dummy com sombras (Card #15)`
- **Branch:** `feat/card-15/cena-base-dummy` ➔ `main`
- **Contexto:** Instanciação da entidade `Dummy` (`CharacterBody2D`) com suporte a movimentação cinemática, sprites e sombra básica.
- **Arquivos Alterados:** `scenes/entities/dummy.tscn`, `scripts/dummy.gd`.
- **Lição Arquitetural:** Entidades alvos devem herdar de nós cinemáticos para que reajam fisicamente a forças de impacto no mundo.

---

### PR #11: Componente Hurtbox no Inimigo
- **Título:** `feat(enemy): implementa componente hurtbox e deteccao de acertos no dummy (Card #16)`
- **Branch:** `feat/card-16/implementacao-hurtbox-inimigo` ➔ `main`
- **Contexto:** Criação da classe `Hurtbox` na Collision Layer 3 com escuta na Layer 4, conectada a sinais no `Dummy`.
- **Arquivos Alterados:** `scripts/hurtbox.gd`, `scenes/entities/dummy.tscn`, `scripts/dummy.gd`, `tests/test_hurtbox_dummy.gd`.
- **Lição Arquitetural:** O Padrão de Componente desacopla a recepção de colisão da lógica interna da entidade receptora.

---

### PR #12: Sistema de Vida e Dano
- **Título:** `feat(enemy): implementa sistema de vida e receber_dano no dummy (Card #17)`
- **Branch:** `feat/card-17/sistema-dano-e-vida` ➔ `main`
- **Contexto:** Encapsulamento de HP máximo e atual com restrição por setter e método `receber_dano()`.
- **Arquivos Alterados:** `scripts/dummy.gd`, `scenes/entities/dummy.tscn`.
- **Lição Arquitetural:** A proteção do estado interno de saúde impede vazamento de regras de negócio para fora da entidade.

---

### PR #13: Feedback Visual de Dano (Knockback e Flash)
- **Título:** `feat(enemy): adiciona knockback e flash de dano no dummy (Card #18)`
- **Branch:** `feat/card-18/feedback-visual-dano` ➔ `main`
- **Contexto:** Impulso físico de repulsão amortecido por atrito e Tween de modulação de cor temporária ao sofrer impacto.
- **Arquivos Alterados:** `scripts/dummy.gd`.
- **Lição Arquitetural:** O isolamento do cálculo de knockback em `_calcular_knockback()` deixa o sistema pronto para receber tipos variados de ataque no futuro.

---

### PR #14: Destruição do Alvo e Fechamento da Sprint 2
- **Título:** `feat(combat): adiciona destruicao por codigo com fragmentos e fecha sprint 2 (Cards #19 e #20)`
- **Branch:** `feat/card-19/destruicao-do-alvo` ➔ `main`
- **Contexto:** Implementação do padrão global de estilhaçamento de texturas e sangue (`DestructionEffect`), suíte integrada de playtest e encerramento da Sprint 2.
- **Arquivos Alterados:** `scripts/destruction_effect.gd`, `scripts/dummy.gd`, `tests/test_dummy_destruction.gd`, `tests/playtest_sprint2.gd`, `docs/sprint_2_review.md`, `modulo2.md`.
- **Lição Arquitetural:** A reutilização de um gerador procedural de efeitos gráficos (`DestructionEffect`) economiza memória e padroniza o feedback visual de morte para todos os atores do jogo.

---

## 💡 Desafio Prático para o Aluno
Antes de avançar para o **Módulo 3 (Inteligência Artificial de Inimigos e HUD)**:
1. **Adicione um Ataque Pesado (Heavy Attack):** Crie uma ação no Input Map chamada `player_heavy_attack` (tecla `K` ou botão direito do mouse). Ao executá-la, aumente o tempo de preparação (wind-up), defina `hitbox.damage = 30` e aumente `hitbox.knockback_force = 300.0`.
2. **Implemente Frames de Invulnerabilidade (i-frames):** No `Dummy` ou em um novo protótipo, após receber um golpe, ative `hurtbox.set_invulnerable(true)` por `0.2s` e faça o sprite piscar em alfa (`modulate.a = 0.5`), impedindo acertos múltiplos em um mesmo corte.
