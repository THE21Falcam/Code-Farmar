extends Node2D

@onready var TestEdit = $CanvasLayer/CommandWindow/TextEdit
@onready var Robot = $Robot

#func _process(delta: float) -> void:
	#print(TestEdit.get_line_count()) # gets the number of lines
	#print(TestEdit.get_line(0)) # Gets Text in cirten line

var max_speed = 100
var input = Vector2.ZERO
var direction = Vector2.RIGHT
var rotation_step = PI / 2 
var Code_Run = false
@onready var raycast = $Robot/CollisionShape2D/RayCast2D
@export var Speed:float = 100
var tile_size = 32
var animation_speed = 5
var moving = false
@onready var line_timer = $Timer
var inputs = {"Right_Key":Vector2.RIGHT,
			"UP_Key":Vector2.UP,
			"Left_Key":Vector2.LEFT,
			"Down_Key":Vector2.DOWN}

var Current_line = 0

func _ready():
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2
	raycast.target_position = direction * tile_size
	line_timer = Timer.new()
	line_timer.wait_time = 0.5  # 1 second delay
	line_timer.one_shot = false
	add_child(line_timer)
	line_timer.timeout.connect(_on_line_timer_timeout)

func start_code():
	Current_line = 0
	Code_Run = true
	line_timer.start()

func _on_line_timer_timeout():
	if Code_Run and Current_line < TestEdit.get_line_count():
		var linetext = TestEdit.get_line(Current_line)

		if linetext == "move_forward":
			move()
		elif linetext == "turn_left":
			$Robot/CollisionShape2D/Marker2D.rotation -= rotation_step
			direction = direction.rotated(-rotation_step).round()
			raycast.target_position = direction * tile_size
			raycast.force_raycast_update()
		elif linetext == "turn_right":
			$Robot/CollisionShape2D/Marker2D.rotation += rotation_step
			direction = direction.rotated(rotation_step).round()
			print(direction)
			raycast.target_position = direction * tile_size
			raycast.force_raycast_update()


		Current_line += 1
	else:
		Code_Run = false
		line_timer.stop()
		$CanvasLayer/CommandWindow/HBoxContainer/Run.disabled = false
		$CanvasLayer/CommandWindow/HBoxContainer/Stop.disabled = true

func move():
	if !raycast.is_colliding():
		var HeadTween = get_tree().create_tween()
		HeadTween.tween_property($Robot, "position", $Robot.position + direction * tile_size, 1.0/animation_speed).set_trans(Tween.TRANS_SINE)
		moving = true
		await HeadTween.finished
		moving = false

func _on_run_button_up() -> void:
	start_code()
	$CanvasLayer/CommandWindow/HBoxContainer/Run.disabled = true
	$CanvasLayer/CommandWindow/HBoxContainer/Stop.disabled = false

func _on_stop_button_up() -> void:
	Code_Run = false
	$CanvasLayer/CommandWindow/HBoxContainer/Run.disabled = false
	$CanvasLayer/CommandWindow/HBoxContainer/Stop.disabled = true


func _on_flag_body_entered(body: Node2D) -> void:
	$CanvasLayer/ColorRect.visible = true


func _on_end_button_button_up() -> void:
	get_tree().quit()
