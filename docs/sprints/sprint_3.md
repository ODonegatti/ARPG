# Sprint 3: IA Básica do Inimigo & Máquina de Estados (FSM) (ATIVA)

- **Período:** 19 de Outubro de 2026 – 23 de Outubro de 2026
- **Status:** **EM ANDAMENTO (Sprint Ativa)**
- **Documento do Módulo do Curso (a criar):** `modulo3.md`

---

## 1. Objetivo da Sprint 3
Evoluir o alvo de testes para um inimigo ativo com ciclo completo de comportamento (Patrulha/Idle, Perseguição e Ataque) utilizando uma **Máquina de Estados Finitos (FSM)** modular em GDScript, detecção de proximidade e campo de visão via `Area2D`, ataque com cooldown e aplicação de dano/knockback bidirecional (Inimigo causando dano ao Player com i-frames).

---

## 2. Backlog e Cards do Trello (Cards #21 a #30)

### Segunda-feira (19/10)
- **Card #21:** `[Dev] #21 - Arquitetura da Máquina de Estados Finitos (FSM Base)`
  - *Critérios:* Criação dos scripts modulares `StateMachine.gd` e `State.gd`; desacoplamento da lógica de transição de estados via nós filhos e herança de classes; setup inicial no nó raiz do inimigo.
  - *Tempo:* Segunda, 13:20 – 14:20 (1h)
- **Card #22:** `[Dev] #22 - Implementação dos Estados Iniciais: Idle e Wander/Patrol`
  - *Critérios:* Criação dos estados `EnemyIdleState` e `EnemyWanderState`; temporizador (`Timer`) para troca de direções aleatórias e pausas na movimentação física via `move_and_slide()`.
  - *Tempo:* Segunda, 14:20 – 15:30 (1h 10m)

### Terça-feira (20/10)
- **Card #23:** `[Dev] #23 - Área de Detecção e Campo de Visão (Detection Area2D)`
  - *Critérios:* Adição de um nó `Area2D` no Inimigo com `CollisionShape2D` circular (raio de visão); configuração de Layers/Masks exclusivas para escanear a camada física do Player.
  - *Tempo:* Terça, 13:20 – 14:15 (55m)
- **Card #24:** `[Dev] #24 - Estado de Perseguição (EnemyChaseState)`
  - *Critérios:* Conexão do sinal `body_entered` da área de detecção à FSM; cálculo do vetor de perseguição normalizado (`direction_to(player.global_position)`) e transição fluida para o estado de perseguição.
  - *Tempo:* Terça, 14:15 – 15:30 (1h 15m)

### Quarta-feira (21/10)
- **Card #25:** `[Dev] #25 - Área de Alcance de Ataque do Inimigo (Attack Range Area2D)`
  - *Critérios:* Adição de uma segunda `Area2D` menor de alcance corpo a corpo no Inimigo; trigger de transição de estado quando o Player entrar nessa área de contato.
  - *Tempo:* Quarta, 13:20 – 14:20 (1h)
- **Card #26:** `[Dev] #26 - Estado de Ataque do Inimigo e Cooldown (EnemyAttackState)`
  - *Critérios:* Parada da movimentação durante o ataque; ativação temporária de Hitbox do inimigo; temporizador de recarga de golpe (`attack_cooldown`) antes de retornar a Chase ou Idle.
  - *Tempo:* Quarta, 14:20 – 15:30 (1h 10m)

### Quinta-feira (22/10)
- **Card #27:** `[Dev] #27 - Implementação da Hurtbox e Componente de HP no Player`
  - *Critérios:* Adição do nó `Area2D` de Hurtbox no Player; script com variável `hp`, sinal `player_damaged` e tratamento de dano recebido das Hitboxes de inimigos.
  - *Tempo:* Quinta, 13:20 – 14:20 (1h)
- **Card #28:** `[Dev] #28 - Invulnerabilidade Pós-Dano e Knockback no Player`
  - *Critérios:* Janela de invulnerabilidade (`i-frames`) com `Timer` desativando a colisão da Hurtbox temporariamente; efeito de piscar o sprite (modulate/shader simples) e impulso de knockback físico.
  - *Tempo:* Quinta, 14:20 – 15:30 (1h 10m)

### Sexta-feira (23/10)
- **Card #29:** `[Dev] #29 - Desengajamento e Limite de Perseguição (Perda de Alvo)`
  - *Critérios:* Conexão do sinal `body_exited` da área de visão; retorno seguro do Inimigo ao estado de Idle/Patrol caso o Player se afaste além do limite de perseguição.
  - *Tempo:* Sexta, 13:20 – 14:20 (1h)
- **Card #30:** `[Dev] #30 - Revisão, Testes de Combate Bidirecional e Fechamento`
  - *Critérios:* Playtest integrando Player atacando/derrotando inimigo e Inimigo perseguindo/atacando Player com FSM e knockback em ambos; validação sem vazamento de memória ou erros no debugger; commit e push no Git.
  - *Tempo:* Sexta, 14:20 – 15:30 (1h 10m)
