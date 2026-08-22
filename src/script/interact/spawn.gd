class_name Spawn
extends Area2D

signal entities_spawned(entities:Node2D)
signal spawn_failed(reason:String)

@export_group("Spawn Config")
@export var spawn_parent:Node
@export var active:bool = false
@export var spawn_immediately:bool = false
@export_range(0.1, 60, 0.1) var spawn_interval:float = 2.0
@export_range(1, 1000, 1) var max_entities_spawn:int = 5

@export_subgroup("Entities")
@export var entities:Array[PackedScene] = []

@onready var spawn_area: CollisionShape2D = $CollisionShape2D
@onready var spawn_timer: Timer = $SpawnTimer

var entities_alive:int = 0
var random: = RandomNumberGenerator.new()

func _ready() -> void:
	random.randomize()
	
	spawn_timer.wait_time = spawn_interval
	spawn_timer.one_shot = false
	
	if not spawn_timer.timeout.is_connected(_on_spawn_timer_timeout):
		spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	
	if active:
		start_spawning()
		
		if spawn_immediately:
			call_deferred(&"spawn_entities")
			
func start_spawning() -> void:
	active = true
	spawn_timer.wait_time = spawn_interval
	
	if spawn_timer.is_stopped():
		spawn_timer.start()
		
func stop_spawning() -> void:
	active = false
	spawn_timer.stop()
	
func _on_spawn_timer_timeout() -> void:
	spawn_entities()
	
func spawn_entities() -> void:
	
	var entities := _get_random_entitie_scene()
	var instance:= entities.instantiate()
	
	if not active:
		return
		
	if entities_alive >= max_entities_spawn:
		return
		
	
	if entities.is_empty():
		print_debug("Nenhuma cena de entities foi configurada.")
		return
		
	if spawn_area == null or spawn_area.shape == null:
		print_debug("O spawner não possui CollisionShape configurado.")
		return
		
	
	if entities == null or not entities.can_instantiate():
		print_debug("A cena de entities não pode ser instanciada.")
		return
		
	
	if not (instance is Node2D):
		instance.queue_free()
		print_debug("A raiz da cena entities precisa herdar um Node2d.")
		return
		
	var entitie := instance as Node2D
	var parent := _get_spawn_parent()
	
	if parent == null:
		entitie.queue_free()
		print_debug("Não foi possível encontrar um nó pai para a entitie.")
		return
		
	parent.add_child(entitie)
	entitie.global_position = _get_random_spawn_position()
	entities_alive += 1
	
	entitie.tree_exited.connect(
		_on_spawned_entitie_exited,
		CONNECT_ONE_SHOT
	)
	
	entities_spawned.emit(entitie)
	
func _get_random_entitie_scene() -> PackedScene:
	var index := random.randi_range(0, entities.size() - 1)
	return entities[index]

func _get_spawn_parent() -> Node:
	if is_instance_valid(spawn_parent):
		return spawn_parent
		
	if get_tree().current_scene != null:
		return get_tree().current_scene
		
	return get_parent()
	
func _get_random_spawn_position() -> Vector2:
	var shape := spawn_area.shape
	var local_point := Vector2.ZERO

	if shape is RectangleShape2D:
		var rectangle := shape as RectangleShape2D
		var half_size := rectangle.size * 0.5

		local_point = Vector2(
			random.randf_range(-half_size.x, half_size.x),
			random.randf_range(-half_size.y, half_size.y)
		)

	elif shape is CircleShape2D:
		var circle := shape as CircleShape2D

		var angle := random.randf_range(0.0, TAU)

		# sqrt() distribui os pontos uniformemente pela área do círculo.
		var distance := sqrt(random.randf()) * circle.radius

		local_point = Vector2.from_angle(angle) * distance

	else:
		push_warning(
			"Formato não suportado. Use RectangleShape2D ou CircleShape2D."
		)

	# Converte a posição local do CollisionShape2D para o mundo.
	return spawn_area.to_global(local_point)


func _on_spawned_entitie_exited() -> void:
	entities_alive = maxi(entities_alive - 1, 0)


func _report_failure(reason: String) -> void:
	push_warning("MonsterSpawner2D: " + reason)
	spawn_failed.emit(reason)
