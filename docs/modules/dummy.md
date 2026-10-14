# Objetivo do Módulo: Dummy (Alvo de Treino) & Componente Hurtbox

O módulo do **Dummy** e o componente **Hurtbox** fornecem a infraestrutura de detecção de acerto e vulnerabilidade a dano para alvos e inimigos no ARPG.

Este módulo implementa os **Cards #15 e #16 da Sprint 2**:
1. **Card #15:** Criação da entidade `Dummy` (`CharacterBody2D`) com feedback visual via `AnimationPlayer` (animações de repouso `idle` e impacto `hit`).
2. **Card #16:** Componente autônomo e desacoplado `Hurtbox` (`Area2D`), configurado nas camadas de física corretas para detectar a lâmina do `Player` (`Hitbox`) e emitir eventos fortemente tipados.

---

## Conceitos Chave Utilizados

- **Composição vs. Herança (Component Pattern):** Em vez de acoplar a física do inimigo diretamente na lógica de colisão de combate, criamos o componente reutilizável `Hurtbox` (`scripts/hurtbox.gd`). Qualquer entidade futura (goblins, chefes, barris destrutíveis) pode incorporar uma `Hurtbox` sem herdar de uma classe base rígida.
- **Camadas de Colisão Físicas (Layers & Masks):**
  - **Collision Layer 3 (`Enemies`, bitmask valor 4):** Camada de existência física do inimigo e de sua Hurtbox no espaço 2D.
  - **Collision Mask 4 (`PlayerHitbox`, bitmask valor 8):** Camada de escuta ativa da Hurtbox. Ela monitora exclusivamente os volumes de ataque gerados pela espada do jogador.
- **Sinais Desacoplados (`hit_received(hitbox: Hitbox)`):** Quando uma `Hitbox` válida atinge a `Hurtbox`, um sinal com a referência tipada da `Hitbox` atacante é disparado, permitindo que o `Dummy` responda visualmente (e futuramente calcule dano e knockback nos Cards #17 e #18).
- **Tratamento de Física Segura (`set_deferred`):** Alterações de ativação/desativação e de formas de colisão (`CollisionShape2D.disabled`) são postergadas para a sincronização de física da engine via `set_deferred`, prevenindo falhas de memória e conflitos de flush na árvore de física.
- **Frames de Invulnerabilidade (`is_invulnerable`):** Propriedade preparada para controle de imunidade temporária pós-dano (*i-frames*).

---

## Hierarquia de Nós da Cena (`dummy.tscn`)

```text
Dummy (CharacterBody2D) [script: res://scripts/dummy.gd]
├── Shadow (Sprite2D)
├── Sprite2D
├── CollisionShape2D (CapsuleShape2D)
├── AnimationPlayer
└── Hurtbox (Area2D) [script: res://scripts/hurtbox.gd]
    └── CollisionShape2D (RectangleShape2D)
```

### Configurações no Inspetor:
1. **Dummy (`CharacterBody2D`)**:
   - `Scale`: `(1.8, 1.8)`.
   - `Collision Layer`: `3` (`Enemies`, valor 4).
   - `Collision Mask`: `1, 2, 3` (`World`, `Player`, `Enemies`).
   - `Motion Mode`: `Floating` (Top-Down 2D sem gravidade vertical de plataforma).
2. **Hurtbox (`Area2D` - `hurtbox.gd`)**:
   - `Collision Layer`: `3` (`Enemies`, valor 4).
   - `Collision Mask`: `4` (`PlayerHitbox`, valor 8).
   - `monitoring`: `true`, `monitorable`: `true`.
3. **CollisionShape2D (filho de Hurtbox)**:
   - `Shape`: `RectangleShape2D` (`size = (17.78, 31.11)` cobrindo o volume do tronco do boneco).
   - `disabled`: `false`.

---

## Análise de Código (GDScript)

### 1. Componente Hurtbox (`scripts/hurtbox.gd`)
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
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if is_invulnerable:
		return
	if area is Hitbox:
		var hitbox: Hitbox = area as Hitbox
		hit_received.emit(hitbox)
```
*Por que foi feito assim:* A Hurtbox se auto-gerencia e abstrai o protocolo de recebimento de golpes. Ela verifica com segurança estática (`area is Hitbox`) se a área interceptada é uma fonte legítima de dano, evitando acidentes com outras áreas utilitárias do mapa.

### 2. Integração no Controlador do Dummy (`scripts/dummy.gd`)
```gdscript
@export_group("Combat Components")
@onready var hurtbox: Hurtbox = $Hurtbox

func _ready() -> void:
	if hurtbox != null:
		hurtbox.owner_entity = self
		if not hurtbox.hit_received.is_connected(_on_hurtbox_hit_received):
			hurtbox.hit_received.connect(_on_hurtbox_hit_received)

func _on_hurtbox_hit_received(_hitbox: Hitbox) -> void:
	play_hit_animation()
```
*Por que foi feito assim:* O Dummy atua como ouvinte do sinal da Hurtbox. Ao ser atingido, a animação `hit` é acionada imediatamente, fornecendo feedback visual responsivo ao jogador sem acoplar a física do ataque à estrutura gráfica.

---

## Validação Automatizada de Testes

A suíte em `tests/test_hurtbox_dummy.gd` executa em modo headless via CI/CD e valida:
1. **Hierarquia e Tipagem:** Instanciação dinâmica de nós, existência de `Hurtbox`, `CollisionShape2D` e tipagem estática.
2. **Camadas de Física:** `collision_layer == 4` (Layer 3) e `collision_mask == 8` (Layer 4).
3. **Controle de Estado:** `disable()` e `enable()` com propagação diferida segura.
4. **Colisão Integrada:** Spawn do Player e Dummy adjacentes, ativação da `Hitbox`, verificação do sinal `hit_received` e disparo da animação `hit`.
5. **Invulnerabilidade:** Garantia de que com `is_invulnerable = true`, golpes não disparam eventos de dano.
