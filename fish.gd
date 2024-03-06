extends CharacterBody2D

@export var SPEED : float = 100
@export var is_player : bool = false


@onready var repulsion_area = $repulsion
@onready var alignement_area = $alignement
@onready var attraction_area = $attraction

@onready var repulsion_collision = $repulsion/CollisionShape2D
@onready var alignement_collision = $alignement/DonutCollisionPolygon2D
@onready var attraction_collision = $attraction/DonutCollisionPolygon2D
@onready var sprite = $Sprite2D

var target_point = Vector2.ZERO   # Initial target point
var has_reached_target = true     # Flag for reaching target
var distance_threshold = 5        # How close to consider reached
var repulsion_fishes = {}
var alignement_fishes = {}
var attraction_fishes = {}

var movements = []

class Movement:
	var target : Vector2
	var target_velocity : Vector2

func _ready():
	if is_player:
		SPEED *= 3
	
	
	generate_next_point(50)
	var m =  movements.pop_front()
	velocity = m.target_velocity
	sprite.look_at(m.target)
	target_point = m.target
		
	var sprite_n = randi_range(1,4)
	sprite.set_texture(load("res://textures/fish"+str(sprite_n)+"Texture.png"))

func _process(delta):
	if is_player:
		print("repulsion : " + str(repulsion_fishes.size()))
		print("alignement : " + str(alignement_fishes.size()))
		print("attraction : " + str(attraction_fishes.size()))

func generate_next_point(radius):
	if is_player:
		return get_global_mouse_position()
	var new_m = get_random_surrounding_point(global_position,50)
	movements.push_back(new_m)
	#calculate_velocity_and_store_movement(get_random_point_around(radius))
	

func get_random_point_around(threshold):
	# Generate a random offset within the threshold range
	var random_offset = Vector2.ZERO  # Initialize with zero offset

	# Randomly choose positive or negative for each axis using if-else statements
	if randf() > 0.5:
		random_offset.x = randf_range(-threshold, threshold)
	else:
		random_offset.x = -randf_range(-threshold, threshold)

	if randf() > 0.5:
		random_offset.y = randf_range(-threshold, threshold)
	else:
		random_offset.y = -randf_range(-threshold, threshold)


	# Add the random offset to the given position
	return global_position + random_offset

func repulsion_logic():
	if repulsion_fishes.size() > 0:
		var randomI = randi() % self.repulsion_fishes.size()
		var fish = \
		self.repulsion_fishes[self.repulsion_fishes.keys()[randomI]]
		var n_movement = opposite_to_target(global_position,fish)
		movements.push_back(n_movement)
		#var d = self.global_position.direction_to(fish)
		##print(fish)
		##print(d)
		##print(d * SPEED)
		##print(self.global_position)
		##print()
		#calculate_velocity_and_store_movement(fish - (d * SPEED))

func alignement_logic():
	if alignement_fishes.size() > 0:
		var randomI = randi() % self.alignement_fishes.size()
		var fish = \
		self.alignement_fishes[self.alignement_fishes.keys()[randomI]]
		var n_movement = align_parallel_to_target(global_position,fish)
		movements.push_back(n_movement)
		
func attraction_logic():
	if attraction_fishes.size() > 0:
		var randomI = randi() % self.attraction_fishes.size()
		var fish = \
		self.attraction_fishes[self.attraction_fishes.keys()[randomI]]
		var n_movement = move_toward_target(global_position,fish)
		movements.push_back(n_movement)

func calculate_velocity_and_store_movement(target_position):
	if target_position == null:
		print("target is null")
	var current_position = get_global_position()
	var direction = target_position - current_position
	var v = direction.normalized()
	if v == null:
		print("v is null")
	else:
		var m = Movement.new()
		m.target = target_position
		m.target_velocity = v * SPEED
		movements.push_back(m)

	
func _physics_process(delta):
	has_reached_target = (target_point - global_position).length() <= distance_threshold
	if has_reached_target:
		var i = randi() % 3
		#match i:
			#0 => repu
		repulsion_logic()
		#alignement_logic()
		#attraction_logic()
		
		if movements.is_empty():
			print("no movement")
			generate_next_point(200)
		var m = movements.pop_front()
		if m != null:
			sprite.look_at(m.target)
			target_point = m.target
			velocity = m.target_velocity
			print(global_position)
			print("=")
			print(m.target)
			print("=")
			print(velocity)
			print("===============")
	#print("*********************")
	#print(repulsion_fishes.size())
	#print(alignement_fishes.size())
	#print(attraction_fishes.size())
	#print("*********************")
#

#
	#var direction = target_point - global_position
	#direction = direction.normalized()
	#velocity = direction * SPEED

	move_and_slide()


func _on_repulsion_body_entered(body):
	if body.name != self.name:
		repulsion_fishes[body.name] = body.global_position

func _on_repulsion_body_exited(body):
	if body.name != self.name:
		repulsion_fishes.erase(body.name)

func _on_alignement_body_entered(body):
	if body.name != self.name:
		alignement_fishes[body.name] = body.global_position

func _on_alignement_body_exited(body):
	if body.name != self.name:
		alignement_fishes.erase(body.name)

func _on_attraction_body_entered(body):
	if body.name != self.name:
		attraction_fishes[body.name] = body.global_position

func _on_attraction_body_exited(body):
	if body.name != self.name:
		attraction_fishes.erase(body.name)


func opposite_to_target(position: Vector2, target: Vector2) -> Movement:
	"""
	Generates a new Movement struct with target and velocity to move away from the target.

	Args:
		position: The current position of the object (Vector2).
		target: The target position to move away from (Vector2).

	Returns:
		A new Movement struct with target and velocity to move away (Movement).
	"""

	var movement = Movement.new()
	movement.target = target
	movement.target_velocity = (position - target).normalized() * SPEED  # Normalize and scale by speed
	return movement

func align_parallel_to_target(position: Vector2, target: Vector2) -> Movement:
	"""
	Generates a new Movement struct with target and velocity to move parallel to the target.

	Args:
		position: The current position of the object (Vector2).
		target: The target position (Vector2).

		**Note:** This function doesn't directly move towards the target. It sets a velocity parallel to the target's direction.

	Returns:
		A new Movement struct with target and velocity to move parallel (Movement).
	"""

	var movement = Movement.new()
	var direction = (target - position).normalized()  # Get the direction vector
	var perpendicular = Vector2(direction.y, -direction.x)  # Arbitrary perpendicular direction

	movement.target = target
	movement.target_velocity = perpendicular.project(direction * SPEED)  # Project desired speed onto perpendicular plane

	return movement

func move_toward_target(position: Vector2, target: Vector2) -> Movement:
	"""
	Generates a new Movement struct with target and velocity to move towards the target.

	Args:
		position: The current position of the object (Vector2).
		target: The target position to move towards (Vector2).

	Returns:
		A new Movement struct with target and velocity to move towards (Movement).
	"""

	var movement = Movement.new()
	movement.target = target
	movement.target_velocity = (target - position).normalized() * SPEED  # Scale direction vector by speed
	return movement

func get_random_surrounding_point(position: Vector2, threshold: float) -> Movement:
	"""
	Generates a random point within a threshold distance surrounding the given position.

	Args:
		position: The central position (Vector2).
		threshold: The maximum distance for the random point (float).

	Returns:
		A new Vector2 representing the randomly generated point (Vector2).
	"""

	var random_point = Vector2(randf_range(-threshold + global_position.x,threshold+ global_position.y),randf_range(-threshold + global_position.x,threshold+ global_position.y))  # Get a random direction vector
	var movement = Movement.new()
	movement.target = random_point 
	movement.target_velocity = (movement.target - position).normalized() * SPEED  # Normalize and scale by speed
	return movement
