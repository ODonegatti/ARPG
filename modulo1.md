# Módulo 1: Fundação do Personagem & Movimentação Top-Down (Sprint 1)

Bem-vindo ao **Módulo 1** do curso prático de desenvolvimento de jogos com **Godot 4 e GDScript**.

Neste curso, cada módulo corresponde a uma **Sprint de Desenvolvimento** real, e cada capítulo corresponde a um **Card Técnico** executado no projeto. Aqui você aprenderá não apenas a "fazer funcionar", mas a projetar arquitetura de software limpa, desacoplada, fortemente tipada e testável para um Action RPG (ARPG) 2D.

---

## 🎯 Objetivos de Aprendizagem do Módulo 1
Ao final deste módulo, você será capaz de:
1. Configurar um repositório Godot 4 profissional com padrões de branch e *Conventional Commits*.
2. Estruturar a física de um personagem Top-Down usando `CharacterBody2D`, vetores direcionais e normalização matemática.
3. Montar cenários modulares e camadas de colisão com o novo `TileMapLayer` da Godot 4.3+.
4. Criar um controlador de animações desacoplado (`PlayerSprite` + `AnimationPlayer`) com suporte a 8 direções e espelhamento horizontal.
5. Evitar e corrigir artefatos visuais clássicos de pixel art (*sub-pixel jitter* e desfoque bilinear).
6. Aplicar o Princípio da Responsabilidade Única (SRP) e encapsulamento em GDScript com tipagem estática rigorosa.
7. Escrever scripts de playtest automatizado para validação contínua (CI/CD) sem abrir a interface gráfica da engine.

---

## 📑 Índice dos Capítulos (Cards da Sprint 1)
- [Capítulo 1 (Cards #1 a #5): Setup de Engenharia, Git e Arquitetura](#capítulo-1-cards-1-a-5-setup-de-engenharia-git-e-arquitetura)
- [Capítulo 2 (Card #6): Criação da Entidade Player e Movimento](#capítulo-2-card-6-criação-da-entidade-player-e-movimento)
- [Capítulo 3 (Card #7): Cenário e Colisões com TileMapLayer](#capítulo-3-card-7-cenário-e-colisões-com-tilemaplayer)
- [Capítulo 4 (Card #8): Sistema de Animações Direcionais](#capítulo-4-card-8-sistema-de-animações-direcionais)
- [Capítulo 5 (Card Fix): Nitidez Visual e Ajustes de Pixel Art](#capítulo-5-card-fix-nitidez-visual-e-ajustes-de-pixel-art)
- [Capítulo 6 (Card #9): Refatoração Limpa e Desacoplamento](#capítulo-6-card-9-refatoração-limpa-e-desacoplamento)
- [Capítulo 7 (Card #10): Playtest Automatizado e Fechamento](#capítulo-7-card-10-playtest-automatizado-e-fechamento)
- [🚀 Detalhamento das Pull Requests (PRs)](#-detalhamento-das-pull-requests-prs)

---

## Capítulo 1 (Cards #1 a #5): Setup de Engenharia, Git e Arquitetura

### 1.1 Objetivo do Capítulo
Criar as fundações de engenharia de software para o projeto: estruturação limpa de pastas, configuração do Git com `.gitignore` adequado para a Godot 4 e alinhamento de diretrizes técnicas (tipagem estática, OOP e Conventional Commits).

### 1.2 Por que isso importa na vida real?
Projetos de jogos frequentemente viram "espaguete" por falta de convenções no dia zero. Cenas misturadas com scripts, texturas na raiz e commits genéricos como *"ajustes"* tornam impossível a manutenção ou trabalho em equipe.

### 1.3 Estrutura de Diretórios Adotada
```text
/actionRpg
├── /assets        # Sprites, tilesets e recursos visuais brutos
├── /scenes        # Cenas (.tscn) organizadas por domínio (/entities, /levels, /ui)
├── /scripts       # Scripts (.gd) puros ou vinculados a nós
├── /tilesets      # Recursos TileSet e camadas pré-configuradas
├── /tests         # Scripts de teste automatizado e asserções
├── /docs          # Documentações técnicas e revisões de sprints
├── AI_CONTEXT.md  # Diretrizes de arquitetura e contexto do projeto
└── project.godot  # Arquivo mestre de configuração da Godot Engine
```

### 1.4 Regras de Git e Commits
Adotamos o padrão **Conventional Commits**:
```
<tipo>(<escopo>): <descrição no imperativo/presente>
```
- `feat(player): adiciona movimentacao direcional`
- `fix(world): corrige camada de colisao do tilemap`
- `refactor(player): divide funcoes de fisica e animacao`

---

## Capítulo 2 (Card #6): Criação da Entidade Player e Movimento

### 2.1 Objetivo do Capítulo
Construir a cena base do jogador utilizando `CharacterBody2D`, mapear ações de entrada e implementar física de velocidade uniforme nas 8 direções cardinais e diagonais.

### 2.2 Conceitos-Chave da Godot & POO
- **`CharacterBody2D`**: Nó especializado em corpos com física cinemática própria. Ao contrário de um `RigidBody2D` (controlado pela gravidade e forças da engine), o `CharacterBody2D` é controlado diretamente pelo programador via código.
- **`Input.get_vector(negative_x, positive_x, negative_y, positive_y)`**: Lê e interpola os eixos horizontais e verticais, retornando um `Vector2`.
- **A Armadilha da Diagonal ($\sqrt{2}$)**: Se você andar para a direita ($x = 1$) e para cima ($y = -1$) sem normalizar, o comprimento do vetor será $\sqrt{1^2 + (-1)^2} \approx 1.414$. O personagem andaria **41.4% mais rápido na diagonal**! O método `.normalized()` converte o comprimento para exatamente $1.0$.

### 2.3 Montagem da Cena (`scenes/entities/player.tscn`)
```text
Player (CharacterBody2D)
├── CollisionShape2D (CapsuleShape2D)
├── Camera2D
├── Sprite2D (PlayerSprite)
└── AnimationPlayer
```

### 2.4 Código: Movimentação Básica Inicial
```gdscript
extends CharacterBody2D

@export var speed: float = 200.0

func _physics_process(_delta: float) -> void:
    var direction: Vector2 = Input.get_vector("left", "right", "up", "down").normalized()
    velocity = direction * speed
    move_and_slide()
```

---

## Capítulo 3 (Card #7): Cenário e Colisões com TileMapLayer

### 3.1 Objetivo do Capítulo
Integrar o asset pack *Tiny Swords*, configurar o terreno com o nó moderno `TileMapLayer` da Godot 4.3+ e definir máscaras de colisão física para impedir que o Player atravesse paredes ou água.

### 3.2 O que mudou na Godot 4.3?
O antigo nó monolítico `TileMap` foi descontinuado em favor de instâncias individuais de **`TileMapLayer`**. Isso traz:
1. Menor overhead de renderização.
2. Controle individual de Z-index, física e visibilidade por camada.
3. Compatibilidade nativa com Y-sorting (profundidade isométrica).

### 3.3 Configurando a Colisão
1. No editor do **TileSet**, adicione uma **Physics Layer** (Layer 0).
2. Na aba **TileMap**, pinte os polígonos de colisão apenas nas partes sólidas dos tiles (ex: topos de penhascos e bordas de água).
3. O método `move_and_slide()` do Player calculará os vetores normais das colisões e fará o personagem deslizar suavemente pelas paredes.

---

## Capítulo 4 (Card #8): Sistema de Animações Direcionais

### 4.1 Objetivo do Capítulo
Criar um sistema de animações que reaja dinamicamente à direção do movimento e ao estado de repouso (`idle` vs `walk`), suportando spritesheets em 4 orientações (Down, Up, Side) com espelhamento horizontal automático para esquerda/direita.

### 4.2 Arquitetura de Componentes
Em vez de sobrecarregar o script principal do Player com troca de texturas, criamos um nó filho especializado: **`PlayerSprite`** (`scripts/player_sprite.gd`).

```gdscript
class_name PlayerSprite
extends Sprite2D

@export_group("Texturas de Movimento")
@export var idle_down: Texture2D
@export var idle_up: Texture2D
@export var idle_side: Texture2D
@export var walk_down: Texture2D
@export var walk_up: Texture2D
@export var walk_side: Texture2D

func update_texture(direction: Vector2, state: String) -> void:
    if direction.x != 0:
        flip_h = direction.x < 0
        texture = walk_side if state == "walk" else idle_side
    elif direction.y > 0:
        flip_h = false
        texture = walk_down if state == "walk" else idle_down
    elif direction.y < 0:
        flip_h = false
        texture = walk_up if state == "walk" else idle_up
```

### 4.3 O AnimationPlayer
O `AnimationPlayer` anima a propriedade `frame` do sprite de `0` a `7`. Com isso, a mesma faixa de animação no `AnimationPlayer` funciona para qualquer direção — o script apenas troca a textura base!

---

## Capítulo 5 (Card Fix): Nitidez Visual e Ajustes de Pixel Art

### 5.1 O Problema Identificado
Durante os testes de caminhada, o sprite do personagem apresentava:
- Leve borramento ao se deslocar (*blur* de interpolação bilinear).
- *Sub-pixel shimmering*: distorção nos pixels ao renderizar em coordenadas de ponto flutuante.

### 5.2 A Solução Técnica
1. **Filtro de Textura:**
   No `PlayerSprite`, definimos `texture_filter = TextureFilter.TEXTURE_FILTER_NEAREST`. Isso força a GPU a renderizar pixels puros sem interpolação linear.
2. **Snap 2D no `project.godot`:**
   Ativamos as diretrizes no motor gráfico:
   ```ini
   [rendering]
   2d/snap/snap_2d_transforms_to_pixel=true
   2d/snap/snap_2d_vertices_to_pixel=true
   ```
   Isso força que qualquer transformação matemática seja arredondada para o grid de pixels da tela antes de desenhar, garantindo nitidez cristalina.

---

## Capítulo 6 (Card #9): Refatoração Limpa e Desacoplamento

### 6.1 Princípio da Responsabilidade Única (SRP)
O script `player.gd` foi refatorado para que cada função execute exatamente uma tarefa bem delimitada:

```gdscript
extends CharacterBody2D

@export_group("Movement Settings")
@export var speed: float = 200.0

@onready var sprite: PlayerSprite = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var last_direction: Vector2 = Vector2.DOWN

func _physics_process(_delta: float) -> void:
    var input_direction: Vector2 = get_input_direction()
    velocity = calculate_velocity(input_direction)
    update_animation(input_direction)
    move_and_slide()

func get_input_direction() -> Vector2:
    return Input.get_vector("left", "right", "up", "down").normalized()

func calculate_velocity(direction: Vector2) -> Vector2:
    return direction * speed

func update_animation(direction: Vector2) -> void:
    if direction != Vector2.ZERO:
        last_direction = direction
        animation_player.play("walk")
        sprite.update_texture(direction, "walk")
    else:
        animation_player.play("idle")
        sprite.update_texture(last_direction, "idle")
```

### 6.2 Benefícios dessa Abordagem
- **Testabilidade:** Podemos testar `calculate_velocity` passando qualquer vetor sem precisar simular entradas de teclado reais.
- **Manutenibilidade:** Se quisermos adicionar *Dash* ou *Knockback*, basta mexer na composição de velocidade, sem quebrar o loop de animações.

---

## Capítulo 7 (Card #10): Playtest Automatizado e Fechamento

### 7.1 Por que Testes Automatizados em Jogos?
Testar na mão toda vez que você altera o código consome tempo precioso e deixa passar regressões. Na Godot 4, podemos criar scripts de teste executáveis via linha de comando (`headless`).

### 7.2 Implementação do Playtest (`tests/playtest_sprint1.gd`)
A suíte instancia a cena do Player e valida:
1. **Normalização Diagonal:** Verifica se $(\sqrt{2}/2, \sqrt{2}/2) \times 200$ mantém a magnitude escalar exata de $200.0$.
2. **Parada Estática:** Verifica se com vetor zero a velocidade zera imediatamente.
3. **Persistência de Olhar:** Verifica se ao soltar os direcionais, o sprite mantém a `last_direction`.
4. **Detecção de Colisão:** Instancia o cenário real e simula passos físicos até colidir com a parede do `TileMapLayer`.

```gdscript
# Trecho de asserção matemática do teste
var diagonal_input = Vector2(1, 1).normalized()
var velocity = player.calculate_velocity(diagonal_input)
assert(is_equal_approx(velocity.length(), 200.0), "Erro: magnitude diagonal inconsistente!")
```

---

## 🚀 Detalhamento das Pull Requests (PRs)

Abaixo está o registro formal das Pull Requests que compõem o ciclo de vida deste Módulo 1.

### PR #1: Criação da Entidade Player
- **Título:** `feat(player): integra sprites Tiny Swords, animacoes do guerreiro e tilemap`
- **Branch:** `feat/cria-o-player` ➔ `main`
- **Contexto:** Estabelece a primeira versão jogável do protagonista com movimentação básica e física.
- **Arquivos Alterados:**
  - `scenes/entities/player.tscn`
  - `scripts/player.gd`
  - `project.godot` (Input Map: `left`, `right`, `up`, `down`)
- **Critérios de Aceitação:**
  - [x] Personagem responde a teclas WASD e Setas.
  - [x] Personagem colide com as bordas do mundo.

---

### PR #2: Sistema Direcional de Animações
- **Título:** `feat(player): implementa sistema de animacoes direcionais com PlayerSprite e AnimationPlayer`
- **Branch:** `feat/implementa-animacoes-player` ➔ `main`
- **Contexto:** Adiciona feedback visual à movimentação, separando texturas por direção e implementando flip horizontal.
- **Arquivos Alterados:**
  - `scripts/player_sprite.gd`
  - `scenes/entities/player.tscn`
- **Critérios de Aceitação:**
  - [x] O sprite olha para a direção correta em repouso (`idle`).
  - [x] Animação de caminhada executa em loop contínuo durante o deslocamento.

---

### PR #3: Correção de Nitidez de Pixel Art
- **Título:** `fix(player): corrige desfoque da animacao walk ativando snap 2d e textura nearest`
- **Branch:** `fix/nitidez-animacao-walk` ➔ `main`
- **Contexto:** Elimina o desfoque bilinear e trepidação de sub-pixels durante a movimentação.
- **Arquivos Alterados:**
  - `project.godot` (`rendering/2d/snap/*`)
  - `scenes/entities/player.tscn` (`texture_filter = 1`)
- **Critérios de Aceitação:**
  - [x] Pixels mantêm fidelidade 1:1 sem interpolação borrada.

---

### PR #4: Refatoração da Arquitetura do Player
- **Título:** `refactor(player): organiza funcoes de input, velocidade e controle de animacao`
- **Branch:** `refactor/codigo-player` ➔ `main`
- **Contexto:** Aplicação de Clean Code e SRP para isolar entrada, física e camada gráfica.
- **Arquivos Alterados:**
  - `scripts/player.gd`
  - `scenes/entities/player.tscn`
- **Critérios de Aceitação:**
  - [x] Funções puras criadas e documentadas com tipagem estática.
  - [x] Variáveis expostas no Inspector via `@export_group`.

---

### PR #5: Suíte de Testes Automatizados da Sprint 1
- **Título:** `test(core): adiciona suite de playtest automatizado e valida fechamento da sprint 1`
- **Branch:** `test/playtest-sprint-1` ➔ `main`
- **Contexto:** Validação de ponta a ponta dos critérios de aceitação da Sprint 1 via script automatizado.
- **Arquivos Alterados:**
  - `tests/playtest_sprint1.gd`
  - `docs/sprint_1_review.md`
- **Critérios de Aceitação:**
  - [x] 100% dos testes de asserção matemática e física aprovados.
  - [x] Zero erros ou avisos críticos no console.

---

## 💡 Desafio Prático para o Aluno
Antes de avançar para o Módulo 2 (Combate e Inimigos), pratique os conhecimentos deste módulo:
1. **Adicione um modificador de Corrida (Sprint):** Crie uma ação no Input Map (`sprint` com a tecla `Shift`) e aumente a velocidade do Player em $50\%$ enquanto a tecla estiver pressionada.
2. **Crie uma barreira decorativa:** Adicione novos elementos ao `TileMapLayer` com colisão para criar um labirinto simples.
