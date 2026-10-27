# Diretrizes de Arquitetura e Padrões de Código (GDScript / Godot 4)

Este documento centraliza as diretrizes de engenharia de software, arquitetura de nós e game feel para o desenvolvimento do ARPG na Godot 4.

---

## 1. Padrões de Codificação GDScript (Strict Static Typing)
- **Tipagem Estática Rigorosa:** Sempre declare tipos explícitos para variáveis, parâmetros de funções e retornos de métodos.
  ```gdscript
  var speed: float = 300.0
  var direction: Vector2 = Vector2.ZERO
  
  func calculate_velocity(input_dir: Vector2) -> Vector2:
      return input_dir.normalized() * speed
  ```
  Evite inferências implícitas dúbias ou tipagem dinâmica (`Variant`). O código deve seguir um nível de rigor próximo ao Java/C# para prevenir bugs em tempo de execução.

- **Padrões Semelhantes a Interfaces (Duck Typing Estruturado / Composição):**
  Como o GDScript não possui palavras-chave nativas como `interface`, simule contratos estruturais utilizando:
  - Registro global com `class_name` (ex: `class_name Hitbox extends Area2D`).
  - Verificação tipada direta (`if area is Hitbox:`).
  - Custom Resources (`Resource`) para dados e contratos desacoplados.
  - Verificações de capacidade pontuais (`has_method("receber_dano")`).

- **Desacoplamento de Nós (Separation of Concerns / SRP):**
  Evite scripts monolíticos. Isole responsabilidades em camadas claras:
  1. **Camada de Entrada (Input Layer):** Interpreta intenções do jogador ou IA e produz vetores de direção/comandos.
  2. **Camada de Física (Physics Layer):** Manipula colisões, impulsos, atrito e executa `move_and_slide()` no `CharacterBody2D`.
  3. **Camada de Animação (Animation Layer):** Observa vetores de velocidade/estados e atualiza visualmente o `AnimationPlayer` ou `AnimationTree` de forma desacoplada.
  4. **Camada de Combate (Combat Components):** `Hitbox` e `Hurtbox` independentes comunicando-se por sinais tipados.

- **Encapsulamento e Parametrização:**
  Exponha constantes configuráveis e parâmetros de balanceamento ao Godot Inspector utilizando a anotação `@export`:
  ```gdscript
  @export var max_speed: float = 200.0
  @export var acceleration: float = 1200.0
  @export var friction: float = 1000.0
  ```

- **Sintaxe Exclusiva Godot 4.x:**
  Nunca utilize padrões legados da Godot 3 (como conversões de tipo antigas, sintaxe antiga de sinais ou propriedades descontinuadas). Use a sintaxe moderna de sinais:
  ```gdscript
  signal health_changed(new_health: int, max_health: int)
  ```

---

## 2. Arte & Game Feel (Juice) Feitos por Código
Para manter o projeto leve, modular e focado em engenharia:
- **Tudo por Código:** Todo o feedback sensorial (*game feel* / *juice*) deve ser gerado programaticamente via GDScript:
  - `Tween` para interpolações rápidas de escala (squash & stretch), rotação e opacidade.
  - `modulate` para flashes de dano (*damage flash*).
  - Shaders simples em GDShader para efeitos visuais pontuais.
  - Funções de desenho vetorial `_draw()` para sombras, linhas de mira e indicadores de alcance.
  - `GPUParticles2D` configurado via script para poeira de passos, faíscas de lâmina e sangue.
- **Parametrização Visual:** Exponha durações, cores e forças de feedback como variáveis `@export` para facilitar o ajuste fino de design.

---

## 3. Padrão Global de Destruição (`DestructionEffect`)
Quando qualquer entidade física for destruída no jogo:
- **Regra do Efeito:** O sprite da entidade **se quebra em pedaços e estilhaços que são arremessados pela tela**.
- **Entidades Vivas vs Inanimadas:**
  - Se a entidade for um **ser vivo** (`is_living = true`), partículas vermelhas procedurais (**sangue**) voam junto com os fragmentos da textura.
  - Se for um objeto inanimado (`is_living = false`, ex: Dummy, caixas, postes), apenas os fragmentos materiais do sprite voam.
- **Implementação Centralizada:** Implementado em `scripts/destruction_effect.gd`:
  ```gdscript
  DestructionEffect.spawn(sprite: Sprite2D, parent: Node, is_living: bool, hit_direction: Vector2)
  ```
  Toda entidade destruível deve reutilizar esse padrão único em vez de criar efeitos locais.

---

## 4. Política Estrita de Testes Automatizados
- **Teste Obrigatório Antes do Commit:** Nenhuma funcionalidade deve ser commitada sem a criação ou atualização de um script de teste na pasta `/tests`.
- **Execução Headless:** Os testes devem ser capazes de rodar em modo headless (`godot --headless -s tests/...`).
- **Critério de Fechamento:** Se os testes não passarem ou o console acusar erros críticos, o commit é bloqueado.

---

## 5. Estrutura de Diretórios do Projeto
```
/scenes       # Cenas autônomas (.tscn) para Player, Inimigos, Itens e Cenários
/scripts      # Scripts GDScript (.gd), organizados por responsabilidade única
/assets       # Texturas, spritesheets e efeitos sonoros organizados por pacotes
/tilesets     # Tilesets e camadas físicas de colisão do cenário
/tests        # Playtests e suítes de teste automatizado headless
/docs         # Documentações complementares, guias e especificações de sprints
/moduloX.md   # Módulos didáticos do curso correspondentes a cada Sprint
```
