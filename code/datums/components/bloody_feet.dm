/// Spreads bloody footprints on movement, for humans
/datum/component/bloody_feet
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	/// Deletion timer if active
	var/dry_timer

	/// The amount of steps still left to take with bloody steps
	var/steps_to_take
	/// Color of the tracks left behind
	var/color

	// We also store the values for the NEXT queued blood prints
	// This lets us apply the existing prints at the end of our current move, before we switch to new ones
	// This is neccessary because the component is attached through Crossed, so before the previous move is finished
	var/steps_to_take_next
	var/color_next

/datum/component/bloody_feet/Initialize(dry_time, steps, bcolor)
	. = ..()
	if(!ishuman(parent) || GLOB.perf_flags & PERF_TOGGLE_NOBLOODPRINTS)
		return COMPONENT_INCOMPATIBLE

	// See above - Note that we start with _next too, so stepping into the poodle doesnt create tracks, only moving out of it after
	src.steps_to_take_next = steps
	src.color_next = bcolor
	prime(dry_time)

/datum/component/bloody_feet/InheritComponent(datum/component/C, i_am_original, dry_time, steps, bcolor, active)
	. = ..()
	src.steps_to_take_next = steps
	src.color_next = bcolor
	prime(dry_time)

/// Starts drying process
/datum/component/bloody_feet/proc/prime(dry_time = 0)
	if(dry_timer)
		deltimer(dry_timer)
		dry_time = null
	if(dry_time)
		dry_timer = addtimer(CALLBACK(src, PROC_REF(clear_blood)), dry_time, TIMER_STOPPABLE)

/datum/component/bloody_feet/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(parent, COMSIG_MOB_ITEM_UNEQUIPPED, PROC_REF(check_shoes))

/datum/component/bloody_feet/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_MOVED, COMSIG_MOB_ITEM_UNEQUIPPED))

/datum/component/bloody_feet/proc/on_moved(mob/living/carbon/human/target, oldLoc, direction)
	SIGNAL_HANDLER
	var/turf/target_turf = target.loc
	if(!isturf(target_turf))
		return

	if(HAS_TRAIT(target_turf, TRAIT_TURF_CLEANS))
		clear_blood()
	else
		add_tracks(target, oldLoc, direction)

/datum/component/bloody_feet/proc/add_tracks(mob/living/carbon/human/target, oldLoc, direction)
	var/turf/T_in = target.loc
	var/turf/T_out = oldLoc

	if(steps_to_take)
		if(istype(T_in))
			var/obj/effect/decal/cleanable/blood/tracks/footprints/FP = LAZYACCESS(T_in.cleanables, CLEANABLE_TRACKS)
			if(FP)
				var/image/I = LAZYACCESS(FP.steps_in, "[direction]")
				if(!I)
					FP.add_tracks(direction, color, FALSE)
			else
				FP = new(T_in)
				FP.add_tracks(direction, color, FALSE)

		if(istype(T_out))
			var/obj/effect/decal/cleanable/blood/tracks/footprints/FP = LAZYACCESS(T_out.cleanables, CLEANABLE_TRACKS)
			if(FP)
				var/image/I = LAZYACCESS(FP.steps_out, "[direction]")
				if(!I)
					FP.add_tracks(direction, color, TRUE)
			else
				FP = new(T_out)
				FP.add_tracks(direction, color, TRUE)

		steps_to_take--

	if(steps_to_take_next) // Promote queued bloodprints to active
		steps_to_take = steps_to_take_next
		steps_to_take_next = 0
		color = color_next

	if(!steps_to_take)
		qdel(src)

/datum/component/bloody_feet/proc/clear_blood()
	SIGNAL_HANDLER
	qdel(src)

/datum/component/bloody_feet/proc/check_shoes(mob/source, obj/item/presumably_shoes, slot)
	SIGNAL_HANDLER
	if(slot == WEAR_FEET)
		qdel(src)



