extends TileMapLayer

@export var small_asteroid_scene: PackedScene

@export var medium_asteroid_scene: PackedScene

@export var large_asteroid_scene: PackedScene

@export var resource_scene: PackedScene

var small_asteroid_atlas: Vector2i = Vector2i(0, 0)

var medium_asteroid_atlas: Vector2i = Vector2i(1, 0)

var large_asteroid_atlas: Vector2i = Vector2i(2, 0)

var resource_atlas: Vector2i = Vector2i(7, 0)

func _ready() -> void:
	spawn_bodies()

func spawn_bodies():
	for cell in get_used_cells():
		var atlas_coords = get_cell_atlas_coords(cell)

		var scene_to_spawn: PackedScene = null

		match atlas_coords:
			small_asteroid_atlas: scene_to_spawn = small_asteroid_scene
			medium_asteroid_atlas: scene_to_spawn = medium_asteroid_scene
			large_asteroid_atlas: scene_to_spawn = large_asteroid_scene
			resource_atlas: scene_to_spawn = resource_scene

		if scene_to_spawn:
			var new_instance: RigidBody2D = scene_to_spawn.instantiate()

			new_instance.global_position = to_global(map_to_local(cell))

			add_child(new_instance)

			erase_cell(cell)
