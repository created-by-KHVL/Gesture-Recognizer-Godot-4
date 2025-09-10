extends Node

const RESAMPLE_POINTS = 16

var template_saver: TemplateSaver = TemplateSaver.new()
var gesture_recognizer: GestureRecognizer = GestureRecognizer.new()

var curve: Curve2D = Curve2D.new()
var path: Path2D = Path2D.new()

func _ready() -> void:
	add_child(gesture_recognizer)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("draw_gesture"):
		var new_path: Path2D = Path2D.new()
		add_child(new_path)
		
		path = new_path
		path.curve = curve
	
	if Input.is_action_pressed("draw_gesture") && !curve.get_baked_points().has(event.position):
			curve.add_point(event.position) # add point if curve hasn't current event.position
	
	if Input.is_action_just_released("draw_gesture"):
		gesture_recognizer.curve = curve
		
		if curve.get_baked_length() > 0:
			if template_saver.is_save_file_exists:
				var saved_gesture_templates: Dictionary = template_saver.load_data()
				
				gesture_recognizer.draw_shape_from_curve(Color.RED, 5.0, gesture_recognizer.get_resampled_curve(RESAMPLE_POINTS)) # draw shape
				
				var recognized_shape_name: String = gesture_recognizer.compare_shape_with_template(saved_gesture_templates)
				if !recognized_shape_name.is_empty(): # check if recognized shape name is not empty 
					print("Shape name is " + recognized_shape_name)
				else:
					print("Unrecognized shape")
			else:
				print("Gesture templates for recognition is empty. Check README")
			
		curve.clear_points() # clear curve data
