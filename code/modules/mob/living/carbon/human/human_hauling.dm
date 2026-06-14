
// Adding traits, etc after xeno restrains and hauls us
/mob/living/carbon/human/proc/handle_haul(mob/living/carbon/xenomorph/xeno)
	SetStun(0, ignore_canstun=TRUE)
	SetKnockDown(0, ignore_canstun=TRUE)

	ADD_TRAIT(src, TRAIT_FLOORED, TRAIT_SOURCE_XENO_HAUL)
	ADD_TRAIT(src, TRAIT_HAULED, TRAIT_SOURCE_XENO_HAUL)
	ADD_TRAIT(src, TRAIT_NO_STRAY, TRAIT_SOURCE_XENO_HAUL)

	hauling_xeno = xeno
	RegisterSignal(xeno, COMSIG_MOB_DEATH, PROC_REF(release_haul_death))
	RegisterSignal(src, COMSIG_ATTEMPT_MOB_PULL, PROC_REF(haul_grab_attempt))
	RegisterSignal(src, COMSIG_LIVING_PREIGNITION, PROC_REF(haul_fire_shield))
	RegisterSignal(src, list(COMSIG_LIVING_FLAMER_CROSSED, COMSIG_LIVING_FLAMER_FLAMED), PROC_REF(haul_fire_shield_callback))
	layer = LYING_BETWEEN_MOB_LAYER
	add_filter("hauled_shadow", 1, color_matrix_filter(rgb(95, 95, 95)))
	pixel_y = -7
	next_haul_resist = 0

/mob/living/carbon/human/proc/release_haul_death()
	SIGNAL_HANDLER
	handle_unhaul()

/mob/living/carbon/human/proc/haul_grab_attempt()
	SIGNAL_HANDLER
	return COMPONENT_CANCEL_MOB_PULL

/mob/living/carbon/human/proc/haul_fire_shield(mob/living/burning_mob) //Stealing it from the pyro spec armor, xenos shield us from fire
	SIGNAL_HANDLER
	return COMPONENT_CANCEL_IGNITION

/mob/living/carbon/human/proc/haul_fire_shield_callback(mob/living/burning_mob)
	SIGNAL_HANDLER
	return COMPONENT_NO_IGNITE|COMPONENT_NO_BURN

// Removing traits and other stuff after xeno releases us from haul
/mob/living/carbon/human/proc/handle_unhaul()
	var/location = get_turf(loc)
	remove_traits(list(TRAIT_HAULED, TRAIT_NO_STRAY, TRAIT_FLOORED, TRAIT_IMMOBILIZED), TRAIT_SOURCE_XENO_HAUL)
	pixel_y = 0
	UnregisterSignal(src, list(COMSIG_ATTEMPT_MOB_PULL, COMSIG_LIVING_PREIGNITION, COMSIG_LIVING_FLAMER_CROSSED, COMSIG_LIVING_FLAMER_FLAMED))
	UnregisterSignal(hauling_xeno, COMSIG_MOB_DEATH)
	hauling_xeno = null
	layer = MOB_LAYER
	remove_filter("hauled_shadow")
	forceMove(location)
	for(var/obj/object in location)
		if(istype(object, /obj/effect/alien/resin/trap) || istype(object, /obj/effect/alien/egg) || istype(object, /obj/effect/alien/resin/special/eggmorph))
			object.HasProximity(src)
		if(istype(object, /obj/effect/egg_trigger))
			object.Crossed(src)
	next_haul_resist = 0
	SEND_SIGNAL(src, COMSIG_MOB_UNHAULED)

