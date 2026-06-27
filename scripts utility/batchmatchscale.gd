@tool
extends EditorScript

# STEP 1: Set this to true, select your source object, and click File -> Run
# STEP 2: Set this to false, select your target objects, and click File -> Run
const SET_SOURCE_MODE = false

const META_KEY = "saved_target_scale"

func _run():
	# CHANGED: Grabs nodes from active viewports to fix the empty focus bug
	var selection = EditorInterface.get_selection().get_transformable_selected_nodes()
	var scene_root = EditorInterface.get_edited_scene_root()
	
	# Fallback if viewport hook fails: try the baseline Scene Tree array hook
	if selection.is_empty():
		selection = EditorInterface.get_selection().get_selected_nodes()
		
	if selection.is_empty():
		print("ERROR: Selection is still empty! Make sure you clicked an object inside your 3D Viewport or Scene Tree before hitting Run.")
		return
		
	if SET_SOURCE_MODE:
		var source_node = selection[0]
		if not source_node is Node3D:
			print("ERROR: Chosen source node is not a 3D object.")
			return
			
		scene_root.set_meta(META_KEY, source_node.scale)
		print("SUCCESS: Locked in scale profile: ", source_node.scale, " from '", source_node.name, "'")
		print("👉 NOW: Change SET_SOURCE_MODE to false, select your target nodes, and run again!")
		
	else:
		if not scene_root.has_meta(META_KEY):
			print("ERROR: No scale profile locked in yet! Run with SET_SOURCE_MODE = true first.")
			return
			
		var target_scale = scene_root.get_meta(META_KEY)
		var updated_count = 0
		
		for target_node in selection:
			if target_node is Node3D:
				# Apply scale matrix safely
				target_node.global_transform.basis = target_node.global_transform.basis.orthonormalized() * target_scale
				updated_count += 1
				
		print("SUCCESS: Scaled ", updated_count, " target objects to match your template size.")
