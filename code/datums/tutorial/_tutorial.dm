GLOBAL_LIST_EMPTY(ongoing_tutorials)

/// A tutorial datum contains a set of instructions for a player tutorial, such as what to spawn, what's scripted to occur, and so on.
/datum/tutorial
	/// What the tutorial is called, is player facing
	var/name = "Base"
	/// Internal ID of the tutorial, kept for save files
	var/tutorial_id = "base"
	/// A short 1-2 sentence description of the tutorial itself
	var/desc = ""
	/// What the tutorial's icon in the UI should look like
	var/icon_state = ""
	/// What category the tutorial should be under
	var/category = TUTORIAL_CATEGORY_BASE
	/// Ref to the bottom-left corner tile of the tutorial room
	var/turf/bottom_left_corner
	/// Ref to the turf reservation for this tutorial
	var/datum/turf_reservation/reservation
	/// Ref to the player who is doing the tutorial
	var/mob/tutorial_mob
	/// If the tutorial will be ending soon
	var/tutorial_ending = FALSE
	/// A dict of type:atom ref for some important junk that should be trackable
	var/list/tracking_atoms = list()
	/// What map template should be used for the tutorial
	var/datum/map_template/tutorial/tutorial_template = /datum/map_template/tutorial/s12x12
	/// What is the parent path of this, to exclude from the tutorial menu
	var/parent_path = /datum/tutorial

/datum/tutorial/Destroy(force, ...)
	GLOB.ongoing_tutorials -= src
	QDEL_NULL(reservation) // Its Destroy() handles releasing reserved turfs

	if(!QDELETED(tutorial_mob))
		QDEL_NULL(tutorial_mob)

	for(var/path in tracking_atoms)
		QDEL_NULL(tracking_atoms[path])

	tracking_atoms.Cut()

	return ..()

/// The proc to begin doing everything related to the tutorial
/datum/tutorial/proc/start_tutorial(mob/starting_mob)
	SHOULD_CALL_PARENT(TRUE)

	if(!starting_mob?.client)
		return FALSE

	ADD_TRAIT(starting_mob, TRAIT_IN_TUTORIAL, TRAIT_SOURCE_TUTORIAL)

	tutorial_mob = starting_mob

	reservation = SSmapping.RequestBlockReservation(initial(tutorial_template.width), initial(tutorial_template.height))
	if(!reservation)
		return FALSE

	var/turf/bottom_left_corner_reservation = locate(reservation.bottom_left_coords[1], reservation.bottom_left_coords[2], reservation.bottom_left_coords[3])
	var/datum/map_template/tutorial/template = new tutorial_template
	template.load(bottom_left_corner_reservation, FALSE, TRUE)

	GLOB.ongoing_tutorials |= src
	var/obj/landmark = locate(/obj/effect/landmark/tutorial_bottom_left) in GLOB.landmarks_list
	bottom_left_corner = get_turf(landmark)
	qdel(landmark)
	var/area/tutorial_area = get_area(bottom_left_corner)
	tutorial_area.update_base_lighting() // this will be entirely dark otherwise
	init_map()
	if(!tutorial_mob)
		end_tutorial()

	return TRUE

/// The proc used to end and clean up the tutorial
/datum/tutorial/proc/end_tutorial(completed = FALSE)
	SHOULD_CALL_PARENT(TRUE)
	SIGNAL_HANDLER

	if(tutorial_mob)
		remove_action(tutorial_mob, /datum/action/tutorial_end)
		var/datum/component/status = tutorial_mob.GetComponent(/datum/component/tutorial_status)
		qdel(status)
		REMOVE_TRAIT(tutorial_mob, TRAIT_IN_TUTORIAL, TRAIT_SOURCE_TUTORIAL)
		if(tutorial_mob.client?.prefs && completed)
			tutorial_mob.client.prefs.completed_tutorials |= tutorial_id
			tutorial_mob.client.prefs.save_character()
		var/mob/new_player/new_player = new
		if(!tutorial_mob.mind)
			tutorial_mob.mind_initialize()

		tutorial_mob.mind.transfer_to(new_player)

	if(!QDELETED(src))
		qdel(src)

/datum/tutorial/proc/add_highlight(atom/target, color = "#d19a02")
	target.add_filter("tutorial_highlight", 2, list("type" = "outline", "color" = color, "size" = 1))

/datum/tutorial/proc/remove_highlight(atom/target)
	target.remove_filter("tutorial_highlight")

/datum/tutorial/proc/add_to_tracking_atoms(atom/reference)
	tracking_atoms[reference.type] = reference

/datum/tutorial/proc/remove_from_tracking_atoms(atom/reference)
	tracking_atoms -= reference.type

/// Broadcast a message to the player's screen
/datum/tutorial/proc/message_to_player(message)
	playsound_client(tutorial_mob.client, 'sound/effects/radiostatic.ogg', tutorial_mob.loc, 25, FALSE)
	tutorial_mob.play_screen_text(message, /atom/movable/screen/text/screen_text/command_order/tutorial, rgb(103, 214, 146))
	to_chat(tutorial_mob, SPAN_NOTICE(message))

/// Updates a player's objective in their status tab
/datum/tutorial/proc/update_objective(message)
	SEND_SIGNAL(tutorial_mob, COMSIG_MOB_TUTORIAL_UPDATE_OBJECTIVE, message)

/// Initialize the tutorial mob.
/datum/tutorial/proc/init_mob()
	tutorial_mob.AddComponent(/datum/component/tutorial_status)
	give_action(tutorial_mob, /datum/action/tutorial_end, null, null, src)

/// Ends the tutorial after a certain amount of time.
/datum/tutorial/proc/tutorial_end_in(time = 5 SECONDS, completed = TRUE)
	tutorial_ending = TRUE
	addtimer(CALLBACK(src, PROC_REF(end_tutorial), completed), time)

/// Initialize any objects that need to be in the tutorial area from the beginning.
/datum/tutorial/proc/init_map()
	return

/// Returns a turf offset by offset_x (left-to-right) and offset_y (up-to-down)
/datum/tutorial/proc/loc_from_corner(offset_x = 0, offset_y = 0)
	RETURN_TYPE(/turf)
	return locate(bottom_left_corner.x + offset_x, bottom_left_corner.y + offset_y, bottom_left_corner.z)

/// Handle the player ghosting out
/datum/tutorial/proc/on_ghost(datum/source, mob/dead/observer/ghost)
	SIGNAL_HANDLER

	var/mob/new_player/new_player = new
	if(!ghost.mind)
		ghost.mind_initialize()

	ghost.mind.transfer_to(new_player)

	end_tutorial()

/datum/action/tutorial_end
	name = "Stop Tutorial"
	action_icon_state = "hologram_exit"
	/// Weakref to the tutorial this is related to
	var/datum/weakref/tutorial

/datum/action/tutorial_end/New(Target, override_icon_state, datum/tutorial/selected_tutorial)
	. = ..()
	tutorial = WEAKREF(selected_tutorial)

/datum/action/tutorial_end/action_activate()
	if(!tutorial)
		return

	var/datum/tutorial/selected_tutorial = tutorial.resolve()
	if(selected_tutorial.tutorial_ending)
		return

	selected_tutorial.end_tutorial()


/datum/map_template/tutorial
	name = "Tutorial Zone (12x12)"
	mappath = "maps/tutorial/tutorial_12x12.dmm"
	width = 12
	height = 12

/datum/map_template/tutorial/s12x12

/datum/map_template/tutorial/s8x9
	name = "Tutorial Zone (8x9)"
	mappath = "maps/tutorial/tutorial_8x9.dmm"
	width = 8
	height = 9

/datum/map_template/tutorial/s8x9/no_baselight
	name = "Tutorial Zone (8x9) (No Baselight)"
	mappath = "maps/tutorial/tutorial_8x9_nb.dmm"

/datum/map_template/tutorial/s7x7
	name = "Tutorial Zone (7x7)"
	mappath = "maps/tutorial/tutorial_7x7.dmm"
	width = 7
	height = 7
