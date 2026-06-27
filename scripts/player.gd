extends RigidBody3D


func _ready() -> void:
		pass #
		
		
		
		
		
func _process(delta: float) -> void:
	var input = Input.get_action_strength("ui_up")
	apply_central_force(input * Vector3.FORWARD * 1200.0 * delta)
