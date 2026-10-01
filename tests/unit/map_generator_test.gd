extends GdUnitTestSuite

const MapGeneratorScript := preload("res://scenes/modulars/map_generator.gd")


func test_extends_node2d() -> void:
	var mg: Node2D = MapGeneratorScript.new()
	assert_that(mg).is_instanceof(Node2D)
	mg.free()


func test_source_id_default_is_1() -> void:
	var mg: MapGenerator = MapGeneratorScript.new()
	assert_that(mg.source_id).is_equal(1)
	mg.free()


func test_large_asteroids_atlas_default() -> void:
	var mg: MapGenerator = MapGeneratorScript.new()
	assert_that(mg.large_asteroids_atlas).is_equal(Vector2i(2, 0))
	mg.free()


func test_medium_asteroids_atlas_default() -> void:
	var mg: MapGenerator = MapGeneratorScript.new()
	assert_that(mg.medium_asteroids_atlas).is_equal(Vector2i(1, 0))
	mg.free()


func test_small_asteroids_atlas_default() -> void:
	var mg: MapGenerator = MapGeneratorScript.new()
	assert_that(mg.small_asteroids_atlas).is_equal(Vector2i(0, 0))
	mg.free()


func test_noise_value_arr_starts_empty() -> void:
	var mg: MapGenerator = MapGeneratorScript.new()
	assert_that(mg.noise_value_arr).is_empty()
	mg.free()


func test_asteroids_to_spawn_starts_empty() -> void:
	var mg: MapGenerator = MapGeneratorScript.new()
	assert_that(mg.asteroids_to_spawn).is_empty()
	mg.free()


func test_width_and_height_start_at_zero() -> void:
	var mg: MapGenerator = MapGeneratorScript.new()
	assert_that(mg.width).is_equal(0.0)
	assert_that(mg.height).is_equal(0.0)
	mg.free()


func test_noise_starts_null() -> void:
	var mg: MapGenerator = MapGeneratorScript.new()
	assert_that(mg.noise).is_null()
	mg.free()


func test_tile_map_layer_default_is_null() -> void:
	var mg: MapGenerator = MapGeneratorScript.new()
	assert_that(mg.tile_map_layer_asteroids).is_null()
	mg.free()


func test_asteroids_noise_texture_default_is_null() -> void:
	var mg: MapGenerator = MapGeneratorScript.new()
	assert_that(mg.asteroids_noise_texture).is_null()
	mg.free()
