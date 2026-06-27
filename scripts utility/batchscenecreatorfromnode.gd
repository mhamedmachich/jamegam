@tool
extends EditorScript

# DEFINE THE SAVE FOLDER PATH (Must end with a slash /)
const SAVE_FOLDER = "res://scenes/"

func _run():
	var selection = EditorInterface.get_selection().get_selected_nodes()
	var edited_scene_root = EditorInterface.get_edited_scene_root()
	
	if selection.is_empty():
		print("ERROR: Select the nodes you want to turn into scenes first!")
		return
		
	# Ensure the target folder exists so Godot doesn't crash
	if not DirAccess.dir_exists_absolute(SAVE_FOLDER):
		DirAccess.make_dir_absolute(SAVE_FOLDER)
		
	var saved_count = 0
	
	for target_node in selection:
		# Skip the main scene root node itself
		if target_node == edited_scene_root:
			continue
			
		# 1. Clean the name to prevent invalid file paths (removes spaces and special chars)
		var safe_name = target_node.name.validate_node_name()
		var file_path = SAVE_FOLDER + safe_name + ".tscn"
		
		# 2. Package the node branch into a scene file resource
		var packed_scene = PackedScene.new()
		
		# CRITICAL STEP: Temporarily make this node the root of its own hierarchy context 
		# so Godot packages all of its children properly.
		set_owner_recursive(target_node, target_node)
		
		var pack_result = packed_scene.pack(target_node)
		
		if pack_result == OK:
			# 3. Save the packaged scene resource to your disk
			var save_result = ResourceSaver.save(packed_scene, file_path)
			if save_result == OK:
				# 4. Turn the active node in your current editor into an Instance of the newly saved scene
				var instanced_scene = load(file_path).instantiate()
				instanced_scene.name = target_node.name
				
				# Swap out the old raw node branch for the new scene instance
				var parent_node = target_node.get_parent()
				var original_index = target_node.get_index()
				
				parent_node.add_child(instanced_scene)
				parent_node.move_child(instanced_scene, original_index)
				instanced_scene.owner = edited_scene_root
				
				target_node.free() # Safely deletes the old local branch
				saved_count += 1
			else:
				print("Failed to save file for: ", target_node.name)
		else:
			print("Failed to package branch for: ", target_node.name)
			
	print("SUCCESS: Batch saved and instanced ", saved_count, " scenes inside ", SAVE_FOLDER)

# Helper function to assign ownership downwards so children are saved inside the sub-scene
func set_owner_recursive(node: Node, root_node: Node):
	for child in node.get_children():
		child.owner = root_node
		set_owner_recursive(child, root_node)
