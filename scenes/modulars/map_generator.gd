class_name MapGenerator
extends Node2D

@export var asteroids_noise_texture: NoiseTexture2D

@export var tile_map_layer_asteroids: TileMapLayer

var noise: Noise

var width: float

var height: float

var noise_value_arr = []

var source_id = 1

var large_asteroids_atlas = Vector2i(2, 0)

var medium_asteroids_atlas = Vector2i(1, 0)

var small_asteroids_atlas = Vector2i(0, 0)

var asteroids_to_spawn: Array[InstancePlaceholder]

@onready var small_asteroid_scene = preload(
		"res://scenes/asteroids/asteroid_body/asteroid_small.tscn"
	)

@onready var medium_asteroid_scene = preload(
		"res://scenes/asteroids/asteroid_body/asteroid_small.tscn"
	)

@onready var large_asteroid_scene = preload(
		"res://scenes/asteroids/asteroid_body/asteroid_big.tscn"
	)

func generate(map_size: Vector2):
	noise = asteroids_noise_texture.noise
	width = map_size.x
	height = map_size.y
	generate_asteroids()

func generate_asteroids():
	for x in range(-width/2, width/2):
		for y in range(-height/2, height/2):
			if x % 2 == 0 and y % 2 == 0:
				var noise_value: float = noise.get_noise_2d(x, y)
				noise_value_arr.append(noise_value)

				if noise_value < -0.78:
					tile_map_layer_asteroids.set_cell(Vector2(x, y), source_id, large_asteroids_atlas)

				elif noise_value < -0.65:
					tile_map_layer_asteroids.set_cell(Vector2(x, y), source_id, medium_asteroids_atlas)

				elif noise_value < -0.48:
					tile_map_layer_asteroids.set_cell(Vector2(x, y), source_id, small_asteroids_atlas)

				else:
					pass
					# place nothing
	spawn_asteroids()

func spawn_asteroids():
	for cell in tile_map_layer_asteroids.get_used_cells():
		var atlas_coords = tile_map_layer_asteroids.get_cell_atlas_coords(cell)

		var asteroid_scene: PackedScene = null

		if atlas_coords == small_asteroids_atlas:
			asteroid_scene = small_asteroid_scene
		elif atlas_coords == medium_asteroids_atlas:
			asteroid_scene = medium_asteroid_scene
		elif atlas_coords == large_asteroids_atlas:
			asteroid_scene = large_asteroid_scene

		if asteroid_scene:
			var asteroid = asteroid_scene.instantiate()

			# Convert tile coord → world position

			asteroid.global_position = tile_map_layer_asteroids.map_to_local(cell)
			asteroid.rotation = randf() * TAU
			asteroid.linear_velocity = Vector2(randf_range(-50, 50), randf_range(-50, 50))
			asteroid.angular_velocity = randf_range(-1.0, 1.0)

			#add_child(asteroid)

			# remove the tile
			tile_map_layer_asteroids.set_cell(cell, -1)
