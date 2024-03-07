extends Control


@onready var repulsion_slider = $repulsion_slider
@onready var alignement_slider = $alignement_slider
@onready var attraction_slider = $attraction_slider
@onready var speed_slider = $speed_slider

func _ready():
	repulsion_slider.value = get_parent().repulsion_rate
	alignement_slider.value = get_parent().alignement_rate
	attraction_slider.value = get_parent().attraction_rate
	speed_slider.value = get_parent().speed_rate
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
