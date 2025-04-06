extends Area2D

# Define a signal to notify when the submarine enters or exits the surface
signal surface_reached(entered: bool)

@onready var surface_collision_shape = $CollisionShape2D  # Reference to the collision shape of the surface

func _on_Surface_body_entered(body: Node) -> void:
    if body.is_in_group("Player"):  # Check if the body is the submarine
        emit_signal("surface_reached", true)  # Emit signal when submarine enters

func _on_Surface_body_exited(body: Node) -> void:
    if body.is_in_group("Player"):  # Check if the body is the submarine
        emit_signal("surface_reached", false)  # Emit signal when submarine exits
