@tool
extends Node2D

# thanks chatgpt

# Define the seaweed variants as flags (bitmask-style, allowing multiple selections)
@export_flags("Pink", "Blue", "Green") var seaweed_variants_flags : int  # Multiple flags can be selected

@export var seaweed_scene : PackedScene  # Drag your Seaweed.tscn here
@export var spawn_area_size : Vector2 = Vector2(100, 6)  # Default spawn area size (width, height)
@export var density : float = 1  # Customizable density: number of seaweeds per 10 pixels horizontally
@export var spacing_jitter : float = 2  # Randomized offset for seaweed placement (max offset in pixels)

var spawn_area_rect : Rect2  # The rectangular spawn area

# A dictionary mapping the flags to the actual variant strings
var seaweed_variants = {
	0: "pink",  # Pink variant (Flag 0)
	1: "blue",  # Blue variant (Flag 1)
	2: "green"  # Green variant (Flag 2)
}

# Called when the node enters the scene tree.
func _ready():
	spawn_area_rect = Rect2(Vector2.ZERO, spawn_area_size)  # Set up the default spawn area
	randomize()  # Ensure randomness on spawn
	spawn_seaweed()

# Called to draw gizmos in the editor for visualizing the spawn area
func _draw():
	if Engine.is_editor_hint():  # Only draw the rectangle in the editor
		# Draw the rectangle spawn area in the editor
		draw_rect(spawn_area_rect, Color(0, 1, 0, 0.5), true)  # Green semi-transparent rectangle


# Update the spawn area dimensions when scaling in the editor
func _process(_delta):
	if Engine.is_editor_hint():  # Only update in the editor, not during gameplay
		if spawn_area_rect.size != spawn_area_size:
			spawn_area_rect.size = spawn_area_size  # Keep the size updated for spawn logic
			queue_redraw()  # Force the gizmo to update in real-time when the size changes

# Method to spawn seaweed instances randomly inside the spawn area
func spawn_seaweed():
	# Calculate the number of seaweed instances based on the density (1 seaweed every 10 pixels * density)
	var seaweed_count = int(spawn_area_size.x / (10 / density))  # Density controls how many seaweeds per 10 pixels horizontally

	# Ensure at least 1 seaweed is spawned for every area
	if seaweed_count < 1:
		seaweed_count = 1
	
	for i in range(seaweed_count):  # Spawn based on the calculated number
		var seaweed_instance = seaweed_scene.instantiate()

		# Pick a random variant from the selected flags
		var selected_variants = []
		for flag_index in seaweed_variants.keys():
			if seaweed_variants_flags & (1 << flag_index):  # Check if the flag is selected
				selected_variants.append(seaweed_variants[flag_index])

		# Randomly pick a variant from the selected ones
		var random_variant = selected_variants[randi() % selected_variants.size()]
		seaweed_instance.variant = random_variant  # Assign the texture variant

		# Calculate the base x position for seaweed along the width of the spawn area
		var base_pos_x = spawn_area_rect.position.x + (i * (10 / density))  # Spread them out horizontally based on density
		
		# Add jitter (random offset) to the position
		var jitter = randf_range(-spacing_jitter, spacing_jitter)  # Random offset within the specified range
		var pos_x = base_pos_x + jitter  # Apply the jitter to the base x position

		var pos = Vector2(pos_x, spawn_area_rect.position.y)  # Place seaweed at the top of the spawn area

		seaweed_instance.position = pos

		add_child(seaweed_instance)
