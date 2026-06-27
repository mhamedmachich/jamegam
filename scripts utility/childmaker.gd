@tool
extends EditorScript

func _run():
	var selection = EditorInterface.get_selection().get_selected_nodes()
	var scene_root = EditorInterface.get_edited_scene_root()
	
	if selection.is_empty():
		print("ERROR: You must select your mesh nodes in the Scene Tree first!")
		return
		
	var created_count = 0
	
	for parent_node in selection:
		# 1. Safely find the actual mesh data (works even if node is a custom class or container)
		var mesh_instance = find_mesh_instance(parent_node)
		if not mesh_instance or not mesh_instance.mesh:
			print("Skipping ", parent_node.name, " (No mesh data found inside).")
			continue
			
		# 2. Create the brand new StaticBody3D from scratch
		var static_body = StaticBody3D.new()
		static_body.name = parent_node.name + "_StaticBody"
		
		# Add it as a child of your selected node
		parent_node.add_child(static_body)
		static_body.owner = scene_root
		
		# 3. Generate the simplified convex math profile from the mesh data
		# create_convex_shape(clean_mesh, simplify_mesh)
		var convex_profile = mesh_instance.mesh.create_convex_shape(true, true)
		
		# 4. Create the CollisionShape3D container
		var collision_shape = CollisionShape3D.new()
		collision_shape.name = "CollisionShape3D"
		collision_shape.shape = convex_profile
		
		# Add the collision shape as a child of the newly created static body
		static_body.add_child(collision_shape)
		collision_shape.owner = scene_root
		
		created_count += 1
		
	print("SUCCESS: Created ", created_count, " Static Bodies with convex profiles.")

# Helper function to dig up mesh data even if you selected a parent container node
func find_mesh_instance(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node
	for child in node.get_children():
		if child is MeshInstance3D:
			return child
	return null
