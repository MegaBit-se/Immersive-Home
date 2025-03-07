extends Node3D

@onready var corner1 = $Corner1
@onready var corner2 = $Corner1/Corner2
@onready var edge = $Edge
@onready var marker = $Edge/Marker3D

@export var disabled: bool:
	set(value):
		disabled = value

		if !is_node_ready(): await ready

		corner1.get_node("CollisionShape3D").disabled = value
		corner2.get_node("CollisionShape3D").disabled = value
		edge.get_node("CollisionShape3D").disabled = value
		corner1.visible = !value
		corner2.visible = !value
		edge.visible = !value

func _ready():
	update_initial_positions()

	corner1.get_node("Movable").on_move.connect(func(position, rotation):
		edge.align_to_corners(corner1.global_position, corner2.global_position)
	)

	corner2.get_node("Movable").on_move.connect(func(position, rotation):
		edge.align_to_corners(corner1.global_position, corner2.global_position)

		corner2.look_at(corner1.global_position, Vector3.UP)
		corner2.rotate(Vector3.UP, deg_to_rad(-90))
	)

	corner2.get_node("Movable").restrict_movement = func(new_position):
		new_position.y = corner1.global_position.y

		var delta_new_pos_corner1 = (new_position - corner1.position).normalized()

		return corner1.position + delta_new_pos_corner1

func update_initial_positions():
	edge.align_to_corners(corner1.global_position, corner2.global_position)
	marker.global_transform = House.body.transform

func get_new_transform():
	marker.scale = Vector3(1, 1, 1)
	return marker.global_transform

func update_align_reference():
	corner1.global_position = Store.house.align_position1
	corner2.global_position = Store.house.align_position2

	corner2.look_at(corner1.global_position, Vector3.UP)
	corner2.rotate(Vector3.UP, deg_to_rad(-90))

	edge.align_to_corners(corner1.global_position, corner2.global_position)

func update_store():
	Store.house.align_position1 = corner1.global_position
	Store.house.align_position2 = corner2.global_position