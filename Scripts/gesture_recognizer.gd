class_name GestureRecognizer
extends Node

const RESAMPLE_POINTS = 16

var template_saver: TemplateSaver = TemplateSaver.new()
var curve: Curve2D = Curve2D.new()

func draw_shape_from_curve(line_color: Color, line_width: float, points_array: PackedVector2Array) -> void:
	var line_node: Line2D = Line2D.new() # instantiate Line2D node
	add_child(line_node)
	
	line_node.default_color = line_color # set Line2D color
	line_node.width = line_width # set Line2D width
	line_node.points = points_array # set add points to Line2D node

func get_resampled_curve(resample_points_count: int) -> Array[Vector2]:
	var resampled_points_array: Array[Vector2] = []
	
	if curve.get_baked_length() > 0:
		var distance_between_points: float = curve.get_baked_length() / (resample_points_count - 1) # d = l/(n-1)
		
		for point in resample_points_count:
			var distance_offset: float = distance_between_points * point
			resampled_points_array.append(curve.sample_baked(distance_offset))
	
	return resampled_points_array

func get_shape_vectors(resampled_points_array: Array[Vector2]) -> Array[Vector2]:
	var shape_vectors_array: Array[Vector2] = []
	for point in resampled_points_array.size():
		if point != 0:
			var direction_to_previous: Vector2 = resampled_points_array[point].direction_to(resampled_points_array[point - 1])
			shape_vectors_array.append(direction_to_previous.snappedf(0.01))
	
	return shape_vectors_array

func get_avarage_shape_vectors(shapes_vectors_array: Array[Array]) -> Array[Vector2]:
	var average_shape_vectors_array: Array[Vector2] = []
	
	var united_shape_vectors_array: Array[Vector2] = [] # unite arrays in function setter array
	for array: Array in shapes_vectors_array:
		united_shape_vectors_array.append_array(array)
	# Slice united array and get average value of arrays elements
	for i in united_shape_vectors_array.size():
		var sliced_array: Array = united_shape_vectors_array.slice(i, united_shape_vectors_array.size(), shapes_vectors_array[0].size())
		if sliced_array.size() == shapes_vectors_array.size():
			var average_vector: Vector2 = Vector2.ZERO
			for vector in sliced_array:
				average_vector += vector
			average_vector = (average_vector / sliced_array.size()).snappedf(0.01)
			
			average_shape_vectors_array.append(average_vector)
	
	return average_shape_vectors_array

func get_saved_shape_templates() -> Dictionary:
	var saved_data_dict: Dictionary = template_saver.load_data() # loaded data from JSON
	var saved_templates_dictionary: Dictionary = {} # cleaned loaded data from JSON
	
	for key in saved_data_dict:
		var cleaned_data: Array = [] # array with data without ""
		for data: String in saved_data_dict[key]:
			cleaned_data.append(str_to_var("Vector2" + data)) # convert Vector2 string to Vector2
		saved_templates_dictionary[key] = cleaned_data # save it to dictionary with cleaned data
	
	return saved_templates_dictionary

func compare_shape_with_template(saved_templates: Dictionary) -> String:
	var shape_vectors_array: Array[Vector2] = get_shape_vectors(get_resampled_curve(RESAMPLE_POINTS))
	
	var shape_name: String
	var matches: int = 0
	var vector_compare_offset: float = 0.2 # this parameter is show how close compared vectors must be for matching
	
	var similar_shapes_dict: Dictionary = {} # dictionary for similar matches count with shape
	
	for template: String in saved_templates:
		var current_shape_matches: int = 0
		
		for point_index: int in saved_templates[template].size():
			var template_vector: Vector2 = str_to_var("Vector2" + saved_templates[template][point_index]) # convert Vector2 string to Vector2
			
			if abs(template_vector.x - shape_vectors_array[point_index].x) <= vector_compare_offset && abs(
				template_vector.y - shape_vectors_array[point_index].y) <= vector_compare_offset:
				current_shape_matches += 1
		matches = current_shape_matches
		
		var resampled_points_size: int = shape_vectors_array.size()
		var compare_accuracy: float = snappedf((float(matches) / float(resampled_points_size)) * 100, 0.01)
		var accuracy_percent: float = 50
		if compare_accuracy >= accuracy_percent:
			similar_shapes_dict[template] = compare_accuracy
		#similar_shapes_dict[template] = compare_accuracy # UNCOMMENT IF YOU WANT GET COMPARE ACCURACY WITH ALL TEMPLATES
	
	var max_similarity_value: float = -1.0
	for template_name: String in similar_shapes_dict:
		if similar_shapes_dict[template_name] > max_similarity_value:
			max_similarity_value = similar_shapes_dict[template_name]
			shape_name = template_name
	#print(shape_name, " ", max_similarity_value, "%")
	
	return shape_name
