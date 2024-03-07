extends CharacterBody2D

enum ACTION{NONE,REPULSE,ALIGNEMENT,ATTRACTION}


@export var SPEED : float = 100
@export var is_player : bool = false
@export var attraction : bool = false
@export var repulsion : bool = false
@export var alignement : bool = false

@onready var target_object = preload("res://target.tscn")
@onready var repulsion_area = $repulsion
@onready var alignement_area = $alignement
@onready var attraction_area = $attraction

@onready var repulsion_collision = $repulsion/CollisionShape2D
@onready var alignement_collision = $alignement/DonutCollisionPolygon2D
@onready var attraction_collision = $attraction/DonutCollisionPolygon2D
@onready var sprite = $Sprite2D

var target_point = Vector2.ZERO   # Initial target point
var has_reached_target = true     # Flag for reaching target
var distance_threshold = 2        # How close to consider reached
var repulsion_fishes = {}
var alignement_fishes = {}
var attraction_fishes = {}
#var movement : Movement
var target : Node2D
var action : ACTION
var can_act : bool = false
	
#class Movement:
	#var target : Vector2
	#var target_velocity : Vector2

func _ready():
	if is_player:
		SPEED *= 3
	#self.velocity = generate_next_point(50)
	#var m =  movements[0]
	#sprite.look_at(self.target.global_position)

		
	var sprite_n = randi_range(1,4)
	sprite.set_texture(load("res://textures/fish"+str(sprite_n)+"Texture.png"))

func set_speed(speed):
	self.SPEED = speed
	
func repulsion_logic(repulsion_range :float, forced : bool = false):
	if !repulsion_fishes.is_empty():
		var randomI = randi() % self.repulsion_fishes.size()
		var fish = \
		self.repulsion_fishes[self.repulsion_fishes.keys()[randomI]]
		var n = target_object.instantiate()
		get_parent().get_parent().add_child(n)
		n.global_position = within_walls(to_global((fish.position * repulsion_range)*-1),30)
		self.target = n
		self.action = ACTION.REPULSE

func alignement_logic():
	if alignement_fishes.size() > 0:
		var randomI = randi() % self.alignement_fishes.size()
		var fish = self.alignement_fishes[self.alignement_fishes.keys()[randomI]]
		var n = target_object.instantiate()
		get_parent().get_parent().add_child(n)
		n.global_position = within_walls(to_global(fish.position * randf_range(0.4,0.7)),30)
		#print(n.global_position)
		self.target = n
		self.action = ACTION.ALIGNEMENT

		
func attraction_logic():
	if attraction_fishes.size() > 0:
		var randomI = randi() % self.attraction_fishes.size()
		var fish = \
		self.attraction_fishes[self.attraction_fishes.keys()[randomI]]
		self.target = fish
		self.action = ACTION.ATTRACTION
	
func _physics_process(delta):
	if self.target:
		has_reached_target = (self.target.global_position - global_position).length() <= distance_threshold
		if has_reached_target:
			self.target = null
			self.action = ACTION.NONE
			var i = randi() % 3
			match i:
				0: attraction_logic()
				1: repulsion_logic(2)
				2: alignement_logic()
				
	if self.target != null:
		velocity = move_toward_target(self.global_position,self.target.global_position)
		sprite.look_at(self.target.global_position)
	if self.target == null:
		#print("no target")
		get_random_surrounding_point(self.global_position,100)
		self.action = ACTION.ATTRACTION
	move_and_slide()

#func _draw():
	#if self.target:
		#draw_line(Vector2(0,0), self.target.position,Color.AQUA,1)
	
func _on_repulsion_body_entered(body):
	if body.name != self.name:
		repulsion_fishes[body.name] = body

func _on_repulsion_body_exited(body):
	if body.name != self.name:
		repulsion_fishes.erase(body.name)

func _on_alignement_body_entered(body):
	if body.name != self.name:
		alignement_fishes[body.name] = body

func _on_alignement_body_exited(body):
	if body.name != self.name:
		alignement_fishes.erase(body.name)

func _on_attraction_body_entered(body):
	if body.name != self.name:
		attraction_fishes[body.name] = body

func _on_attraction_body_exited(body):
	if body.name != self.name:
		attraction_fishes.erase(body.name)

#
#func opposite_to_target(position: Vector2, target: Vector2, range: float = 50) -> Vector2:
	##print((target - position).normalized() * SPEED)
	#return (position- target ).normalized() * SPEED

func align_parallel_to_target(position: Vector2, target: Vector2) -> Vector2:

	var direction = (target - position).normalized()  # Get the direction vector
	var perpendicular = Vector2(direction.y, -direction.x)  # Arbitrary perpendicular direction

	return perpendicular.project(direction * SPEED)  # Project desired speed onto perpendicular plane

func move_toward_target(position: Vector2, target: Vector2) -> Vector2:
	return (target - position).normalized() * SPEED  # Scale direction vector by speed

func within_walls(point: Vector2, threshold: float):
	var n = point.clamp(Vector2(threshold,threshold),(get_viewport_rect().size* 0.9))
	print("==")
	print(point)
	print("==")
	return point.clamp(Vector2(threshold,threshold),(get_viewport_rect().size* 0.9))

func get_random_surrounding_point(position: Vector2, threshold: float):
	"""
	Generates a random point within a threshold distance surrounding the given position.

	Args:
		position: The central position (Vector2).
		threshold: The maximum distance for the random point (float).
1920*1080
0+threshold > point.x true = min(threshold, point)
min()
1980-threshold < point.x

	Returns:
		A new Vector2 representing the randomly generated point (Vector2).
	"""

	var random_point = Vector2(randf_range(-threshold + global_position.x,threshold+ global_position.x),randf_range(-threshold + global_position.y,threshold+ global_position.y))  # Get a random direction vector
	#movement.target = random_point
	self.target = Node2D.new()
	self.target.global_position = within_walls(random_point,50)	
	#return (random_point - position).normalized() * SPEED  # Normalize and scale by speed


func _on_initialisation_timeout():
	self.can_act = true
