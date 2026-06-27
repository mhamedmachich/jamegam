extends Area3D

@export var launch_force: float = 25.0

func _ready() -> void:
	# Connect the collision signal to this script
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	# Check if the colliding object has a velocity property (like CharacterBody3D)
	if "velocity" in body:
		# Calculate direction based on where the top of the pad is facing
		var launch_direction = global_basis.y.normalized()
		
		# Override the player's velocity
		body.velocity = launch_direction * launch_force
		
		# Optional: Play audio or trigger an animation here! 🎬
