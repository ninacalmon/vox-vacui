class_name PowerUpSetup
extends VBoxContainer


signal busy_state_changed()

@export_enum("Impulse", "Fuel", "Teleport", "Health", "Propulsors", "Bullet", "Perfurator") var effect: String

@export var title: String

@export var price: int = 100

@export var texture: Texture

@export var description: String

@export var max_level: int = 1

@export var price_label: RichTextLabel

@export var texture_button: TextureButton

@export var description_label: RichTextLabel

@export var default_color: Color

@export var unavailiable_color: Color

@export var focused_color: Color

@export var unavailiable_focused_color: Color

@export var bought_color: Color

var have_enough_to_buy: bool

var current_level: int

var custom_tooltip_text

@onready var progress_bar: ProgressBar = $ProgressBar

@onready var bought_power_up: AudioStreamPlayer = $BoughtPowerUp



func _ready() -> void:
	current_level = PowerUps.get_current_level(effect)
	modulate = default_color

	setup_nodes()
	check_availability()

	SpaceshipEventBus.resources_spent.connect(_on_resources_spent)

	texture_button.pressed.connect(_on_button_pressed)
	texture_button.focus_entered.connect(_on_focus_entered)
	texture_button.focus_exited.connect(_on_focus_exited)
	#texture_button.mouse_entered.connect(_on_focus_entered)
	#texture_button.mouse_exited.connect(_on_focus_exited)


func setup_nodes():
	progress_bar.value = 0
	var next_level: int = min(current_level + 1, max_level)
	price = max(price * next_level, price)
	price_label.text = "%d fragmentos" %price
	description_label.text = "%s[br]* %s *" %[title, description]
	var next_level_string: String = str(next_level)
	description_label.text = description_label.text.replace("&", next_level_string)
	texture_button.texture_normal = texture


func check_availability():
	have_enough_to_buy = StatsManager.current_resources >= price

	if not have_enough_to_buy:
		deactivate_buying("Not enough resources")
	if current_level >= max_level:
		deactivate_buying("Already at max level")


func deactivate_buying(reason: String):
	default_color = unavailiable_color
	focused_color = unavailiable_focused_color
	modulate = default_color #self

	if reason == "Not enough resources":
		custom_tooltip_text = "Sem fragmentos suficientes.
[color=68b820]%d / %d[/color] fragmentos" %[StatsManager.current_resources, price]
	if reason == "Already at max level":
		custom_tooltip_text = "Já alcançou o nível máximo.
nível [color=68b820]%d / %d[/color]" %[current_level, max_level]


func buy_power_up():
	become_busy()

	PowerUps.add_current_level(effect)
	current_level = PowerUps.get_current_level(effect)
	#modulate = bought_color
	#default_color = bought_color
	PowerUps.apply_power_up(effect)
	StatsManager.current_resources -= price

	SpaceshipEventBus.resources_spent.emit()

	progress_bar.show()
	bought_power_up.pitch_scale = randf_range(0.8, 1.2)
	SFXManager.play_sound(bought_power_up)
	var tween = create_tween()
	tween.tween_property(progress_bar, "value", progress_bar.max_value, 1)
	await tween.finished
	progress_bar.hide()
	setup_nodes()

	become_free()


func become_busy() -> void:
	add_to_group("Busy_PU_Button_Group")
	_notify_pu_state_changed()


func become_free() -> void:
	remove_from_group("Busy_PU_Button_Group")
	_notify_pu_state_changed()


func _notify_pu_state_changed() -> void:
	for node in get_tree().get_nodes_in_group("PU_State_Listeners"):
		node.update_pu_state()


func shake():
	var original_pos_x = position.x
	var tween = create_tween()
	tween.tween_property(self, "position:x", original_pos_x-4, 0.1)
	tween.tween_property(self, "position:x", original_pos_x+4, 0.1)
	tween.tween_property(self, "position:x", original_pos_x-4, 0.1)
	tween.tween_property(self, "position:x", original_pos_x+4, 0.1)
	tween.tween_property(self, "position:x", original_pos_x, 0.1)


func _grab_focus():
	texture_button.grab_focus()


func _on_button_pressed():
	if not have_enough_to_buy:
		shake()
		return
	buy_power_up()


func _on_focus_entered():
	modulate = focused_color
	if custom_tooltip_text:
		CustomTooltip.show_tooltip(custom_tooltip_text, self.global_position)


func _on_focus_exited():
	modulate = default_color
	if custom_tooltip_text:
		CustomTooltip.hide_tooltip()


func _on_resources_spent():
	check_availability()
