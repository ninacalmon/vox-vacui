extends Sprite2D

var shader

var mat: ShaderMaterial

func _ready() -> void:
	mat = material as ShaderMaterial

	var tween = create_tween()

	tween.set_loops()
	tween.set_trans(Tween.TRANS_QUAD)


	tween.tween_property(mat, "shader_parameter/strenght", 1.0, randf_range(2.0, 6.0)).from(-1.0)

	tween.tween_property(mat, "shader_parameter/strenght", -1.0, randf_range(2.0, 6.0)).from(1.0)
