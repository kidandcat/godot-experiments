extends KinematicBody

export var gravity = Vector3.DOWN * 10
export var speed = 4
export var jump_speed = 5
export var climb_reduction = 0.3

var velocity = Vector3.ZERO
var running = false
var rotation_lerp = 0.0
var rotation_speed = 1.0
var state_machine
var climbing = false

func _ready():
	add_to_group("Player")
	state_machine = $AnimationTree.get("parameters/playback")

func _physics_process(delta):
	if not climbing: velocity += gravity * delta
	get_input(delta)
	bodyTransformations(delta)
	velocity = move_and_slide(velocity, Vector3.UP)
	climb()
	animations()
	
func get_input(delta):
	var vy = velocity.y
	velocity = Vector3.ZERO
	if Input.is_action_pressed("move_up"):
		if climbing: velocity.y = speed * climb_reduction
		else: velocity += -transform.basis.z * speed
	if Input.is_action_pressed("move_down"): 
		if climbing: velocity.y = -1 * speed * climb_reduction
		else: velocity += transform.basis.z * speed
	if Input.is_action_pressed("move_right"): 
		if climbing: velocity -= $Skeleton.transform.basis.x * speed * climb_reduction
		else: velocity += transform.basis.x * speed
	if Input.is_action_pressed("move_left"): 
		if climbing: velocity += $Skeleton.transform.basis.x * speed * climb_reduction
		else: velocity += -transform.basis.x * speed
	if not climbing: velocity.y = vy
	# jump
	if Input.is_action_pressed("move_jump") and is_on_floor():
		velocity.y += jump_speed
	# rotation lerp
	if Input.is_action_just_pressed("move_up") \
		or Input.is_action_just_pressed("move_down") \
		or Input.is_action_just_pressed("move_right") \
		or Input.is_action_just_pressed("move_left"):
		rotation_lerp = 0

func animations():
	if isMoving():
		state_machine.travel("running")
	if not isMoving():
		state_machine.travel("idle")

func bodyTransformations(delta):
	if not climbing:
		if velocity.x != 0 || velocity.z != 0:
			$LookingAtTarget.look_at(global_transform.origin - velocity, Vector3(0, 1, 0))
			rotate_player(delta)
	else:
		var n_wall = $Skeleton/FrontRay.get_collision_normal()
		if n_wall:
			$Skeleton.look_at($Skeleton.global_transform.origin + n_wall, Vector3(0, 1, 0))

func rotate_player(delta):
	if rotation_lerp < 1:
		rotation_lerp += delta * rotation_speed
	elif rotation_lerp > 1:
		rotation_lerp = 1
	# clean X axis rotation (if not it will rotate in X axis when in air)
	var targetRotation = Vector3(0, $LookingAtTarget.rotation.y, 0)
	$Skeleton.transform.basis = $Skeleton.transform.basis.slerp(targetRotation, rotation_lerp).orthonormalized()

func isMoving():
	return abs(velocity.x) > 0.5 or abs(velocity.z) > 0.5

func climb():
	if $Skeleton/FrontRay.is_colliding() and !climbing:
		climbing = true
		velocity = Vector3.ZERO
	elif not $Skeleton/FrontRay.is_colliding() and climbing:
		climbing = false
		
