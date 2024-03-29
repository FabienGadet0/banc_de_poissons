extends Node

@export var repulsion_rate : int = 40
@export var alignement_rate : int = 65
@export var attraction_rate : int = 115
@export var speed_rate : float = 100

@onready var fishes = $fish_spawner

func _on_repulsion_slider_drag_ended(value_changed):
	if value_changed:
		repulsion_rate = $ui/repulsion_slider.value
		if fishes.get_child_count() > 0:
			for fish in fishes.get_children():
				fish.repulsion_collision.shape.radius = $ui/repulsion_slider.value


func _on_alignement_slider_drag_ended(value_changed):
	if value_changed:
		alignement_rate = $ui/alignement_slider.value
		if fishes.get_child_count() > 0:
			for fish in fishes.get_children():
				fish.alignement_collision.radius = $ui/alignement_slider.value
	

func _on_attraction_slider_drag_ended(value_changed):
	if value_changed:
		attraction_rate = $ui/attraction_slider.value
		if fishes.get_child_count() > 0:
			for fish in fishes.get_children():
				fish.attraction_collision.radius = $ui/attraction_slider.value

func _on_speed_slider_drag_ended(value_changed):
	if value_changed:
		attraction_rate = $ui/speed_slider.value
		if fishes.get_child_count() > 0:
			for fish in fishes.get_children():
				#print($ui/speed_slider.value)
				fish.set_speed($ui/speed_slider.value)
