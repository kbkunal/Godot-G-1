extends CharacterBody3D

# ── Movement ──────────────────────────────────────────
@export var walk_speed       : float = 4.5
@export var sprint_speed     : float = 8.0
@export var crouch_speed     : float = 2.2
@export var jump_velocity    : float = 4.8
@export var acceleration     : float = 10.0
@export var friction         : float = 14.0
@export var air_acceleration : float = 3.0

# ── Mouse Look ─────────────────────────────────────────
@export var mouse_sensitivity : float = 0.002
@export var max_pitch         : float = 88.0   # degrees

# ── Crouch ─────────────────────────────────────────────
@export var crouch_height        : float = 0.9
@export var stand_height         : float = 1.8
@export var crouch_lerp_speed    : float = 10.0

# ── Head Bob ───────────────────────────────────────────
@export var bob_frequency  : float = 2.4
@export var bob_amplitude  : float = 0.055
@export var sprint_bob_mul : float = 1.6

# ── Gravity ────────────────────────────────────────────
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")

# ── Nodes ──────────────────────────────────────────────
@onready var head          : Node3D            = $Head
@onready var camera        : Camera3D          = $Head/Camera3D
@onready var ceiling_check : RayCast3D         = $CeilingCheck
@onready var stand_shape   : CollisionShape3D  = $StandingShape
@onready var crouch_shape  : CollisionShape3D  = $CrouchShape

# ── State ──────────────────────────────────────────────
var _is_crouching  : bool  = false
var _is_sprinting  : bool  = false
var _bob_t         : float = 0.0
var _target_height : float = stand_height
var _camera_default_y : float

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_camera_default_y = head.position.y

func _unhandled_input(event: InputEvent) -> void:
	# Mouse look
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-max_pitch), deg_to_rad(max_pitch))

	# Toggle mouse capture
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(
			Input.MOUSE_MODE_VISIBLE if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
			else Input.MOUSE_MODE_CAPTURED
		)

func _physics_process(delta: float) -> void:
	_handle_gravity(delta)
	_handle_crouch(delta)
	_handle_movement(delta)
	_handle_jump()
	_handle_head_bob(delta)
	move_and_slide()

# ── Gravity ────────────────────────────────────────────
func _handle_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

# ── Movement ───────────────────────────────────────────
func _handle_movement(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction  := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	_is_sprinting = Input.is_action_pressed("sprint") and not _is_crouching and input_dir != Vector2.ZERO

	var target_speed : float
	if _is_crouching:
		target_speed = crouch_speed
	elif _is_sprinting:
		target_speed = sprint_speed
	else:
		target_speed = walk_speed

	var accel := acceleration if is_on_floor() else air_acceleration
	var fric  := friction     if is_on_floor() else 0.0

	if direction != Vector3.ZERO:
		velocity.x = move_toward(velocity.x, direction.x * target_speed, accel * delta)
		velocity.z = move_toward(velocity.z, direction.z * target_speed, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, fric * delta)
		velocity.z = move_toward(velocity.z, 0.0, fric * delta)

# ── Jump ───────────────────────────────────────────────
func _handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor() and not _is_crouching:
		velocity.y = jump_velocity

# ── Crouch ─────────────────────────────────────────────
func _handle_crouch(delta: float) -> void:
	var wants_crouch := Input.is_action_pressed("crouch")

	if wants_crouch:
		_is_crouching = true
	elif _is_crouching and not ceiling_check.is_colliding():
		_is_crouching = false

	_target_height = crouch_height if _is_crouching else stand_height

	# Smooth capsule resize
	var capsule := stand_shape.shape as CapsuleShape3D
	capsule.height = lerp(capsule.height, _target_height, crouch_lerp_speed * delta)

	# Smooth eye/head position
	var eye_y := _target_height / 2.0 - 0.1   # eyes near top of capsule
	head.position.y = lerp(head.position.y, eye_y, crouch_lerp_speed * delta)

	stand_shape.disabled = _is_crouching
	crouch_shape.disabled = not _is_crouching

# ── Head Bob ───────────────────────────────────────────
func _handle_head_bob(delta: float) -> void:
	var moving := velocity.length() > 0.5 and is_on_floor()

	if moving:
		var mul := sprint_bob_mul if _is_sprinting else 1.0
		_bob_t += delta * bob_frequency * mul
		var bob_x := cos(_bob_t)          * bob_amplitude * 0.5 * mul
		var bob_y := sin(_bob_t * 2.0)   * bob_amplitude       * mul
		camera.position = camera.position.lerp(Vector3(bob_x, bob_y, 0.0), delta * 8.0)
	else:
		_bob_t = 0.0
		camera.position = camera.position.lerp(Vector3.ZERO, delta * 8.0)
