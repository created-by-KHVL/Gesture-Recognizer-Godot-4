extends Node

const RESAMPLE_POINTS = 16 # amount of resample points

@export var template_name_line_edit: LineEdit
@export var draw_status_label: Label

var templates_saver: TemplateSaver = TemplateSaver.new()
var gesture_recognizer: GestureRecognizer = GestureRecognizer.new()

var curve: Curve2D = Curve2D.new()
var path: Path2D = Path2D.new()

var current_shape_name: String

var is_can_draw: bool = false

var current_template_data: Array[Array] = [] # array with shape vectors

func _ready() -> void:
	add_child(gesture_recognizer)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("is_can_draw"):
		is_can_draw = true
		draw_status_label.text = "Can draw"
	
	if Input.is_action_just_pressed("save_gesture"):
		save_template_button_pressed()
	
	if is_can_draw && event is InputEventMouse:
		if Input.is_action_just_pressed("draw_gesture"):
			var new_path: Path2D = Path2D.new()
			add_child(new_path)
			
			path = new_path
			path.curve = curve
		
		if Input.is_action_pressed("draw_gesture") && !curve.get_baked_points().has(event.position):
				curve.add_point(event.position) # add point if curve hasn't current event.position
		
		if Input.is_action_just_released("draw_gesture"):
			gesture_recognizer.curve = curve
			gesture_recognizer.draw_shape_from_curve(Color.RED, 5.0, gesture_recognizer.get_resampled_curve(RESAMPLE_POINTS))
			
			var shape_vectors_array: Array = gesture_recognizer.get_shape_vectors(gesture_recognizer.get_resampled_curve(RESAMPLE_POINTS))
			if !shape_vectors_array.is_empty(): # check if array is not empty
				current_template_data.append(shape_vectors_array)
			
			is_can_draw = false
			draw_status_label.text = "Can't draw"
			
			
			curve.clear_points() # clear curve data


func draw_button_pressed() -> void:
	is_can_draw = true
	draw_status_label.text = "Can draw"

func save_template_button_pressed() -> void:
	var current_template_name: String = template_name_line_edit.text # get template name from LineEdit node
	templates_saver.save_data(current_template_name, gesture_recognizer.get_avarage_shape_vectors(current_template_data)) # save data
	current_template_data.clear() # clear previous data to prevent adding wrong points

func _on_line_edit_text_submitted(new_text: String) -> void:
	current_shape_name = new_text
	
