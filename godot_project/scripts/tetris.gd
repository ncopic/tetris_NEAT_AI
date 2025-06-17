extends Node2D

#define all Tetris pieces and their orientation at the 4 different rotation values. 
#These values match the tetris_rotation_orientation.png orientations in base .git directory
var i_tetromino: Array = [
	[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)], # 0 degrees
	[Vector2i(2, 0), Vector2i(2, 1), Vector2i(2, 2), Vector2i(2, 3)], # 90 degrees
	[Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2)], # 180 degrees
	[Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3)]  # 270 degrees
]
 
var t_tetromino: Array = [
	[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)], # 0 degrees
	[Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)], # 90 degrees
	[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)], # 180 degrees
	[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)]  # 270 degrees
]
 
var o_tetromino: Array = [ #Square piece does not match rotation orientation exactly, but it's fine
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)], # All rotations are the same
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)], # All rotations are the same
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)], # All rotations are the same
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]  # All rotations are the same
]
 
var z_tetromino: Array = [
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1)], # 0 degrees
	[Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)], # 90 degrees
	[Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)], # 180 degrees
	[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)]  # 270 degrees
]
 
var s_tetromino: Array = [
	[Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)], # 0 degrees
	[Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)], # 90 degrees
	[Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2), Vector2i(1, 2)], # 180 degrees
	[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)]  # 270 degrees
]
 
var l_tetromino: Array = [
	[Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)], # 0 degrees
	[Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)], # 90 degrees
	[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2)], # 180 degrees
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2)]  # 270 degrees
]
 
var j_tetromino: Array = [
	[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)], # 0 degrees
	[Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(1, 2)], # 90 degrees
	[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)], # 180 degrees
	[Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2)]  # 270 degrees
]

var tetrominoes: Array = [o_tetromino, i_tetromino, t_tetromino, z_tetromino, s_tetromino, l_tetromino, j_tetromino ]
#godot says .duplicate() is a shallow copy. Modifything this modifys the original.
#so idk how the code works later when it reassigns after modifying the tetrominoes variable
var all_tetrominoes: Array = tetrominoes.duplicate() 

#our tetris board is 10x20 for the area in which the pieces can exist
const COLS: int = 10
const ROWS: int = 20
var is_game_running: bool = true

const START_POSITION: Vector2i = Vector2i(5,1) #I think this is used as the spawn location when a new piece is put at the top of the screen
const movement_directon: Array[Vector2i] = [Vector2i.LEFT, Vector2i.DOWN, Vector2i.RIGHT]
var current_position: Vector2i

var fall_timer: float = 0
var fall_interval: float = 1.0
var fast_fall_multiplier: float = 10.0

var active_tetromino: Array = []
var current_tetromino_type: Array
var rotation_index: int = 0

var score: int
const CLEAR_REWARD_1L: int = 40
const CLEAR_REWARD_2L: int = 100
const CLEAR_REWARD_3L: int = 300
const CLEAR_REWARD_4L: int = 1200

var line_clear_1: int = 0
var line_clear_2: int = 0
var line_clear_3: int = 0
var line_clear_4: int = 0

var tile_id: int = 0
var piece_atlas: Vector2i 	#when we imported the tetrominoes.png as a TileSet, this is how we reference what color we want from it
							#tetrominoes.png has to be imported as TileSet on each TileMapLayer. Otherwise even if you call it, sprites won't appear for that layer.
var next_tetromino_type: Array
var next_piece_atlas: Vector2i

@onready var board_layer: TileMapLayer = $Board
@onready var active_area_layer: TileMapLayer = $ActiveArea

#called once at startup - mostly used for set up
func _ready() -> void:
	start_new_game()
	pass

func start_new_game() -> void:
	$GameHUD/StartGameButton.visible = false
	$"GameHUD/Label-GameOver".visible = false
	is_game_running = true
	
	score = 0
	line_clear_1 = 0
	line_clear_2 = 0
	line_clear_3 = 0
	line_clear_4 = 0
	update_HUD(0)
	
	clear_tetromino()
	clear_board()
	clear_next_tetromino_preview()
	current_tetromino_type = choose_tetromino()
	piece_atlas = Vector2i(all_tetrominoes.find(current_tetromino_type), 0)
	next_tetromino_type = choose_tetromino()
	next_piece_atlas = Vector2i(all_tetrominoes.find(next_tetromino_type), 0)
	initialize_tetromino()
	return

#called every frame update - used for continuously updating values
func _physics_process(delta: float) -> void:
	if is_game_running:
		var move_direction = Vector2i.ZERO
		
		if Input.is_action_just_pressed("ui_left"):
			move_direction = Vector2i.LEFT
		elif Input.is_action_just_pressed("ui_right"):
			move_direction = Vector2i.RIGHT
		
		if move_direction != Vector2i.ZERO:
			move_tetromino(move_direction)
		
		if Input.is_action_just_pressed("ui_up"):
			rotate_tetromino()
		
		var current_fall_interval = fall_interval
		if Input.is_action_pressed("ui_down"):
			current_fall_interval /= fast_fall_multiplier
		
		fall_timer += delta
		if fall_timer >= current_fall_interval:
			move_tetromino(Vector2i.DOWN)
			fall_timer = 0
	pass

func initialize_tetromino() -> void:
	current_position = START_POSITION
	rotation_index = 0 #in tetris, all pieces spawn in the same orientation, every time
	active_tetromino = current_tetromino_type[rotation_index]
	render_tetromino(active_tetromino, current_position, piece_atlas)
	render_tetromino(next_tetromino_type[0], Vector2i(14,3), next_piece_atlas)
	return
		
func render_tetromino(tetromino: Array, position: Vector2i, atlas: Vector2i) -> void:
	for block in tetromino:
		active_area_layer.set_cell(position + block, tile_id, atlas)
	return

func choose_tetromino() -> Array:
	var selected_tetromino: Array
	if not tetrominoes.is_empty():
		tetrominoes.shuffle()
		selected_tetromino = tetrominoes.pop_front()
	else:
		#TODO: How tf does this work? - The original definition of all_tetrominoes was:
		#all_tetrominoes: Array = tetrominoes.duplicate()
		#This is a shallow copy, so doing tetrominoes.pop_front() should edit both tetrominoes and all_tetrominoes
		#Meaning when we want to run this line, both tetrominoes and all_tetromineos should be empty arrays...
		tetrominoes = all_tetrominoes.duplicate()
		tetrominoes.shuffle()
		selected_tetromino = tetrominoes.pop_front()
	return selected_tetromino

func clear_tetromino() -> void:
	for block in active_tetromino:
		active_area_layer.erase_cell(current_position + block)
	return

func rotate_tetromino() -> void:
	if is_valid_rotation():
		clear_tetromino()
		rotation_index = (rotation_index - 1) % 4
		active_tetromino = current_tetromino_type[rotation_index]
		render_tetromino(active_tetromino, current_position, piece_atlas)
	return

func move_tetromino(direction: Vector2i) -> void:
	if is_valid_move(direction):
		clear_tetromino()
		current_position += direction
		render_tetromino(active_tetromino, current_position, piece_atlas)
	else:
		if direction == Vector2i.DOWN:
			land_tetromino()
			check_rows()
			current_tetromino_type	= next_tetromino_type
			piece_atlas = next_piece_atlas
			next_tetromino_type = choose_tetromino()
			next_piece_atlas = Vector2i(all_tetrominoes.find(next_tetromino_type), 0)
			clear_next_tetromino_preview()
			initialize_tetromino()
			is_game_over()
	return

func land_tetromino() -> void:
	for ii in active_tetromino:
		active_area_layer.erase_cell(current_position + ii)
		board_layer.set_cell(current_position + ii, tile_id, piece_atlas)
	return

func clear_next_tetromino_preview() -> void:
	for ii in range(13,18): #14,3
		for jj in range(3,7): #15,2 ->15,6
			active_area_layer.erase_cell(Vector2i(ii,jj))

func check_rows() -> void:
	var row: int = ROWS
	var rows_cleared: int = 0
	while row > 0:
		var cells_filled: int = 0
		for ii in range(COLS):
			if not is_within_bounds(Vector2i(ii + 1, row)):
				cells_filled += 1
		if cells_filled == COLS:
			shift_rows(row)
			rows_cleared += 1
		else:
			row -= 1
	update_HUD(rows_cleared)
	return
	
func update_HUD(rows_cleared) -> void:
	if rows_cleared == 1:
		score += CLEAR_REWARD_1L
		line_clear_1 += 1
	elif rows_cleared == 2:
		score += CLEAR_REWARD_2L
		line_clear_2 += 1
	elif rows_cleared == 3:
		score += CLEAR_REWARD_3L
		line_clear_3 += 1
	elif rows_cleared == 4:
		score += CLEAR_REWARD_4L
		line_clear_4 += 1
	$"GameHUD/Label-LineClears".text = "Line Clears: \n1L: " + str(line_clear_1) + "\n2L: " + str(line_clear_2) + "\n3L: " + str(line_clear_3) + "\n4L: " + str(line_clear_4)
	$"GameHUD/Label-Score".text = "Score: \n" + str(score)
	return

func shift_rows(row) -> void:
	var atlas: Vector2i
	for ii in range(row, 1, -1):
		for jj in range(COLS):
			atlas = board_layer.get_cell_atlas_coords(Vector2i(jj + 1, ii - 1))
			if atlas == Vector2i(-1,-1):
				board_layer.erase_cell(Vector2i(jj + 1, ii))
			else:
				board_layer.set_cell(Vector2i(jj + 1, ii), tile_id, atlas)
	return

func clear_board() -> void:
	for ii in range(ROWS):
		for jj in range(COLS):
			board_layer.erase_cell(Vector2i(jj + 1, ii + 1))
	return

func is_valid_move(new_position: Vector2i) -> bool:
	for block in active_tetromino:
		if not is_within_bounds(current_position + block + new_position):
			#stack more "if" statemetns in here to handle SRS "kick" before returning false
			#would still have to figure out how to update where to draw the sprite on screen
			#since this function has return type: bool
			return false
	return true

func is_valid_rotation() -> bool:
	var next_rotation = (rotation_index + 1) % 4
	var rotated_tetromino = current_tetromino_type[next_rotation]
	
	for block in rotated_tetromino:
		if not is_within_bounds(current_position + block):
			return false
	return true

func is_within_bounds(pos: Vector2i) -> bool:
	if pos.x < 0 or pos.x >= COLS+1 or pos.y < 0 or pos.y >= ROWS+1:
		return false
	
	var tile_id = board_layer.get_cell_source_id(pos)
	return tile_id == -1

func is_game_over() -> void:
	for ii in active_tetromino:
		if not is_within_bounds(ii + current_position):
			land_tetromino()
			$"GameHUD/Label-GameOver".visible = true
			$GameHUD/StartGameButton.visible = true
			$GameHUD/StartGameButton.pressed.connect(start_new_game)
			is_game_running = false
	return
	
