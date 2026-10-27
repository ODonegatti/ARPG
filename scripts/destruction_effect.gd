class_name DestructionEffect
extends Node2D

## AI Context Router:
## - Role: Efeito procedural global de estilhaçamento de sprite e partículas de sangue
## - Scene: Instanciado dinamicamente via código em qualquer nó pai da cena
## - Tests: res://tests/test_dummy_destruction.gd, res://tests/playtest_sprint2.gd
## - Docs: docs/guidelines/architecture_rules.md

## Efeito padrão de destruição do projeto (game feel por código).
## Quebra o sprite de um objeto em fragmentos que são arremessados pela tela.
## Se o objeto for um ser vivo, pixels vermelhos (sangue) voam junto.
## Uso: DestructionEffect.spawn(sprite, parent, is_living, hit_direction)

@export_group("Fragments")
## Número de colunas e linhas em que o sprite é recortado.
@export var grid_columns: int = 4
@export var grid_rows: int = 4
## Velocidade mínima/máxima (px/s) de arremesso dos fragmentos.
@export var piece_speed_min: float = 120.0
@export var piece_speed_max: float = 320.0
## Rotação máxima (rad/s) dos fragmentos.
@export var piece_spin_max: float = 12.0

@export_group("Blood")
@export var blood_count: int = 28
@export var blood_color: Color = Color(0.75, 0.05, 0.05)
## Tamanho (px) de cada pixel de sangue.
@export var blood_size: float = 2.0
@export var blood_speed_min: float = 80.0
@export var blood_speed_max: float = 360.0

@export_group("Motion")
## Desaceleração linear (px/s²) aplicada a fragmentos e sangue.
@export var friction: float = 500.0
## Tempo total de vida do efeito, em segundos.
@export var lifetime: float = 0.9
## Fração da vida (0..1) a partir da qual o efeito começa a desaparecer.
@export_range(0.0, 1.0) var fade_start: float = 0.5

var _pieces: Array[Sprite2D] = []
var _piece_velocities: Array[Vector2] = []
var _piece_spins: Array[float] = []
var _blood_positions: PackedVector2Array = PackedVector2Array()
var _blood_velocities: PackedVector2Array = PackedVector2Array()
var _age: float = 0.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


## Cria o efeito a partir do sprite de origem e o adiciona em `parent`.
## O sprite de origem NÃO é alterado/removido (quem chama decide escondê-lo ou liberá-lo).
static func spawn(source: Sprite2D, parent: Node, is_living: bool = false, hit_direction: Vector2 = Vector2.ZERO) -> DestructionEffect:
	var effect: DestructionEffect = DestructionEffect.new()
	parent.add_child(effect)
	effect.global_position = source.global_position
	effect.z_index = source.z_index + 1
	effect.setup(source, is_living, hit_direction)
	return effect


## Número de fragmentos de sprite gerados.
func get_piece_count() -> int:
	return _pieces.size()


## Número de pixels de sangue gerados.
func get_blood_count() -> int:
	return _blood_positions.size()


## Gera fragmentos (e sangue, se `is_living`) a partir do sprite.
func setup(source: Sprite2D, is_living: bool, hit_direction: Vector2) -> void:
	_rng.randomize()
	var base_dir: Vector2 = hit_direction.normalized()
	if source != null and source.texture != null:
		_build_pieces(source, base_dir)
	if is_living:
		_build_blood(base_dir)


func _build_pieces(source: Sprite2D, base_dir: Vector2) -> void:
	var texture: Texture2D = source.texture
	var size: Vector2i = Vector2i(texture.get_size())
	var cols: int = maxi(grid_columns, 1)
	var rows: int = maxi(grid_rows, 1)
	var cell_w: int = maxi(floori(float(size.x) / cols), 1)
	var cell_h: int = maxi(floori(float(size.y) / rows), 1)
	var scale_factor: Vector2 = source.global_scale
	
	# Imagem usada para ignorar recortes totalmente transparentes (quando disponível).
	var image: Image = texture.get_image()
	if image != null and (image.is_empty() or image.is_compressed()):
		image = null
	
	for row: int in range(rows):
		for col: int in range(cols):
			var x0: int = col * cell_w
			var y0: int = row * cell_h
			var w: int = (size.x - x0) if col == cols - 1 else cell_w
			var h: int = (size.y - y0) if row == rows - 1 else cell_h
			var rect: Rect2i = Rect2i(x0, y0, w, h)
			if image != null and image.get_region(rect).is_invisible():
				continue
			
			var piece: Sprite2D = Sprite2D.new()
			piece.texture = texture
			piece.region_enabled = true
			piece.region_rect = Rect2(rect)
			piece.scale = scale_factor
			piece.modulate = source.modulate
			
			var center: Vector2 = Vector2(rect.position) + Vector2(rect.size) / 2.0
			var local_offset: Vector2 = center + source.offset
			if source.centered:
				local_offset -= Vector2(size) / 2.0
			piece.position = local_offset * scale_factor
			add_child(piece)
			
			var outward: Vector2 = piece.position.normalized()
			var dir: Vector2 = (outward + base_dir * 1.5).normalized()
			if dir == Vector2.ZERO:
				dir = Vector2.from_angle(_rng.randf() * TAU)
			dir = dir.rotated(_rng.randf_range(-0.4, 0.4))
			_pieces.append(piece)
			_piece_velocities.append(dir * _rng.randf_range(piece_speed_min, piece_speed_max))
			_piece_spins.append(_rng.randf_range(-piece_spin_max, piece_spin_max))


func _build_blood(base_dir: Vector2) -> void:
	for i: int in range(blood_count):
		var dir: Vector2 = Vector2.from_angle(_rng.randf() * TAU)
		if base_dir != Vector2.ZERO:
			dir = (dir + base_dir * 1.5).normalized()
		_blood_positions.append(Vector2(_rng.randf_range(-4.0, 4.0), _rng.randf_range(-4.0, 4.0)))
		_blood_velocities.append(dir * _rng.randf_range(blood_speed_min, blood_speed_max))


func _process(delta: float) -> void:
	_age += delta
	var fade_time: float = lifetime * fade_start
	var alpha: float = 1.0
	if _age > fade_time:
		alpha = clampf(1.0 - (_age - fade_time) / maxf(lifetime - fade_time, 0.001), 0.0, 1.0)
	
	for i: int in range(_pieces.size()):
		var piece: Sprite2D = _pieces[i]
		piece.position += _piece_velocities[i] * delta
		piece.rotation += _piece_spins[i] * delta
		_piece_velocities[i] = _piece_velocities[i].move_toward(Vector2.ZERO, friction * delta)
		piece.modulate.a = alpha
	
	for j: int in range(_blood_positions.size()):
		_blood_positions[j] += _blood_velocities[j] * delta
		_blood_velocities[j] = _blood_velocities[j].move_toward(Vector2.ZERO, friction * delta)
	
	if not _blood_positions.is_empty():
		queue_redraw()
	
	if _age >= lifetime:
		queue_free()


func _draw() -> void:
	var fade_time: float = lifetime * fade_start
	var alpha: float = 1.0
	if _age > fade_time:
		alpha = clampf(1.0 - (_age - fade_time) / maxf(lifetime - fade_time, 0.001), 0.0, 1.0)
	var color: Color = Color(blood_color, alpha)
	var pixel: Vector2 = Vector2.ONE * blood_size
	for position_i: Vector2 in _blood_positions:
		draw_rect(Rect2(position_i - pixel / 2.0, pixel), color)
