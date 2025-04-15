extends Ship_Component

@export var ping_range := 100.0

func _input(_delta) -> void:
	if is_active && Input.is_action_just_pressed("ACTIVATE_COMPONENT"):
		perform_sonar_ping(ping_range)


# The bitwise value for the ray query confuses the hell out of me
# so this just takes an array of layers and returns the wacky bullshit
func make_bitwise(layers: Array) -> int:
	var bitmask = 0
	for layer in layers:
		# Shift for 0-based layer indexing
		bitmask |= (1 << (layer - 1))
	return bitmask

func perform_sonar_ping(max_radius: float):
	var origin = global_position
	var space_state = get_world_2d().direct_space_state

	var groups_to_check = ["Enemy", "Junk"]

	for group in groups_to_check:
		for node in get_tree().get_nodes_in_group(group):
			# Skip if node is no longer in the scene or doesn't have a position
			if not node.is_inside_tree() or not node.has_method("get_global_position"):
				continue

			var target_pos = node.global_position
			var _distance := origin.distance_to(target_pos)
			if _distance <= max_radius:
				# Check line of sight using a ray
				var query = PhysicsRayQueryParameters2D.create(origin, target_pos)
				query.exclude = [self]

				# choose walls, floor, etc to not pass through
				# query.collision_mask = make_bitwise([4, 5])
				query.collision_mask = 4
				query.collide_with_areas = false
				query.collide_with_bodies = true

				var result = space_state.intersect_ray(query)
				if result and result.collider != node:
					# Something is blocking the sonar (like terrain)
					continue

				# Successfully pinged target
				print("Pinged: ", node.name, " in group: ", group)
				node.on_ping(_distance)
