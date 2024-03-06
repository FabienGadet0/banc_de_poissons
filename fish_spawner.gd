extends Node2D

@export var fish_amount : int = 10

@onready var fish_object = preload("res://fish.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	#var fishes = []
	for i in range(fish_amount):
		var new_fish = fish_object.instantiate()
		add_child(new_fish)
		if i % 2 == 0:
			new_fish.is_player = true
		new_fish.set_global_position(self.global_position)
		#fishes.append(new_fish)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
