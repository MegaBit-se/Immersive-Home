@tool
extends Function
class_name Movable

var hit_node := Node3D.new()

func _on_grab_down(event: EventRay):
	event.controller.add_child(hit_node)
	hit_node.global_transform = get_parent().global_transform

func _on_grab_move(_event: EventRay):
	get_parent().global_transform = hit_node.global_transform

func _on_grab_up(event: EventRay):
	event.controller.remove_child(hit_node)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()

	if get_parent() is StaticBody3D == false:
		warnings.append("Movable requires a StaticBody3D as parent.")
	

	return warnings
