@tool

extends StaticBody3D
class_name Button3D

signal on_button_down()
signal on_button_up()

const IconFont = preload("res://assets/icons/icons.tres")

@onready var label_node: Label3D = $Label

@export var label: String = "":
	set(value):
		if !is_inside_tree(): await ready
		label_node.text = value
	get:
		return label_node.text
@export var icon: bool = false:
	set(value):
		icon = value

		if !is_inside_tree(): await ready
		label_node.font = IconFont if value else null
		label_node.font_size = 48 if value else 10

@export var toggleable: bool = false
@export var disabled: bool = false
@export var external_state: bool = false
@export var initial_active: bool = false
var active: bool = false :
	set(value):
		animation_player.stop()
		if value == active:
			return

		active = value

		if active:
			animation_player.play("down")
		else:
			animation_player.play_backwards("down")

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	if initial_active:
		active = true
		
func _on_press_down(event):
	if disabled:
		event.bubbling = false
		return

	AudioPlayer.play_effect("click")

	if external_state || toggleable:
		return

	active = true
	on_button_down.emit()
	
	

func _on_press_up(event):
	if disabled:
		event.bubbling = false
		return

	if external_state:
		return

	if toggleable:
		active = !active

		if active:
			on_button_down.emit()
		else:
			on_button_up.emit()
	else:
		active = false
		on_button_up.emit()
