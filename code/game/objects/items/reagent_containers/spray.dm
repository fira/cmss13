/obj/item/reagent_container/spray
	name = "spray bottle"
	desc = "A spray bottle, with an unscrewable top."
	icon = 'icons/obj/items/spray.dmi'
	icon_state = "cleaner"
	item_state = "cleaner"
	flags_atom = OPENCONTAINER|FPRINT
	flags_item = NOBLUDGEON
	flags_equip_slot = SLOT_WAIST
	throwforce = 3
	w_class = SIZE_SMALL
	throw_speed = SPEED_SLOW
	throw_range = 10
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10) //Set to null instead of list, if there is only one.
	var/spray_size = 3
	var/list/spray_sizes = list(1,3)
	var/safety = FALSE
	volume = 250


/obj/item/reagent_container/spray/New()
	..()
	src.verbs -= /obj/item/reagent_container/verb/set_APTFT

/obj/item/reagent_container/spray/afterattack(atom/A, mob/user, proximity)
	//this is what you get for using afterattack() TODO: make is so this is only called if attackby() returns 0 or something
	if(istype(A, /obj/item/storage) || istype(A, /obj/structure/table) || istype(A, /obj/structure/rack) || istype(A, /obj/structure/closet) \
	|| istype(A, /obj/item/reagent_container) || istype(A, /obj/structure/sink) || istype(A, /obj/structure/janitorialcart || istype(A, /obj/structure/ladder)))
		return

	if(istype(A, /obj/structure/reagent_dispensers) && get_dist(src,A) <= 1) //this block copypasted from reagent_containers/glass, for lack of a better solution
		if(!A.reagents.total_volume && A.reagents)
			to_chat(user, SPAN_NOTICE("\The [A] is empty."))
			return

		if(reagents.total_volume >= reagents.maximum_volume)
			to_chat(user, SPAN_NOTICE("\The [src] is full."))
			return

		var/trans = A.reagents.trans_to(src, A:amount_per_transfer_from_this)
		to_chat(user, SPAN_NOTICE("You fill \the [src] with [trans] units of the contents of \the [A]."))
		return

	if(reagents.total_volume < amount_per_transfer_from_this)
		to_chat(user, SPAN_NOTICE("\The [src] is empty!"))
		return

	if(safety)
		to_chat(user, SPAN_WARNING("The safety is on!"))
		return

	Spray_at(A, user)

	playsound(src.loc, 'sound/effects/spray2.ogg', 25, 1, 3)

/obj/item/reagent_container/spray/proc/Spray_at(atom/A, var/mob/user)
	var/obj/effect/decal/chempuff/D = new/obj/effect/decal/chempuff(get_turf(src))
	D.create_reagents(amount_per_transfer_from_this)
	reagents.trans_to(D, amount_per_transfer_from_this, 1/spray_size)
	D.color = mix_color_from_reagents(D.reagents.reagent_list)

	var/turf/A_turf = get_turf(A)//BS12

	var/spray_dist = spray_size
	spawn(0)
		for(var/i=0, i<spray_dist, i++)
			step_towards(D,A)
			D.reagents.reaction(get_turf(D))
			for(var/atom/T in get_turf(D))
				D.reagents.reaction(T)
				
				// Are we hitting someone?
				if(ishuman(T))
					// Check what they are hit with
					var/reagent_list_text		// The list of reagents
					var/counter = 0;			// Used for formatting
					var/log_spraying = FALSE;	// If it worths logging
					for(var/X in reagents.reagent_list)
						var/datum/reagent/R = X
						// Is it a chemical we should log?
						if(R.spray_warning)
							if(counter == 0)
								reagent_list_text += "[R.name]"
							else
								reagent_list_text += ", [R.name]"

					// One or more bad reagents means we log it
					if(!counter)
						log_spraying = TRUE;

					// Did we have a log-worthy spray? Then we log it
					if(log_spraying)
						var/mob/living/carbon/human/M = T
						M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been sprayed with [src.name] (REAGENT: [reagent_list_text]) by [user.name] ([user.ckey])</font>")
						user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used \a [src.name] (REAGENT: [reagent_list_text]) to spray [M.name] ([M.ckey])</font>")
						msg_admin_attack("[user.name] ([user.ckey]) used \a [src.name] to spray [M.name] ([M.ckey]) with [src.name] (REAGENT: [reagent_list_text]) in [get_area(src)] ([src.loc.x],[src.loc.y],[src.loc.z]).", src.loc.x, src.loc.y, src.loc.z)

				if(istype(T,/obj/structure/machinery/portable_atmospherics/hydroponics) || istype(T, /obj/item/reagent_container/glass))
					reagents.trans_to(T)

				// When spraying against the wall, also react with the wall, but
				// not its contents. BS12
				if(get_dist(D, A_turf) == 1 && A_turf.density)
					D.reagents.reaction(A_turf)
				sleep(2)
			sleep(3)
		qdel(D)


/obj/item/reagent_container/spray/attack_self(var/mob/user)
	if(!possible_transfer_amounts)
		return
	amount_per_transfer_from_this = next_in_list(amount_per_transfer_from_this, possible_transfer_amounts)
	spray_size = next_in_list(spray_size, spray_sizes)
	to_chat(user, SPAN_NOTICE("You adjusted the pressure nozzle. You'll now use [amount_per_transfer_from_this] units per spray."))


/obj/item/reagent_container/spray/examine(mob/user)
	..()
	to_chat(user, "[round(reagents.total_volume)] units left.")

/obj/item/reagent_container/spray/verb/empty()

	set name = "Empty Spray Bottle"
	set category = "Object"
	set src in usr

	if (alert(usr, "Are you sure you want to empty that?", "Empty Bottle:", "Yes", "No") != "Yes")
		return
	if(isturf(usr.loc))
		to_chat(usr, SPAN_NOTICE("You empty \the [src] onto the floor."))
		reagents.reaction(usr.loc)
		spawn(5) src.reagents.clear_reagents()

//space cleaner
/obj/item/reagent_container/spray/cleaner
	name = "space cleaner"
	desc = "BLAM!-brand non-foaming space cleaner!"

/obj/item/reagent_container/spray/cleaner/drone
	name = "space cleaner"
	desc = "BLAM!-brand non-foaming space cleaner!"
	volume = 50

/obj/item/reagent_container/spray/cleaner/New()
	..()
	reagents.add_reagent("cleaner", src.volume)
//pepperspray
/obj/item/reagent_container/spray/pepper
	name = "pepperspray"
	desc = "Manufactured by UhangInc, used to blind and down an opponent quickly."
	icon_state = "pepperspray"
	item_state = "pepperspray"
	possible_transfer_amounts = null
	volume = 40
	safety = TRUE


/obj/item/reagent_container/spray/pepper/New()
	..()
	reagents.add_reagent("condensedcapsaicin", 40)

/obj/item/reagent_container/spray/pepper/examine(mob/user)
	..()
	if(get_dist(user,src) <= 1)
		to_chat(user, "The safety is [safety ? "on" : "off"].")

/obj/item/reagent_container/spray/pepper/attack_self(mob/user)
	safety = !safety
	to_chat(user, SPAN_NOTICE("You switch the safety [safety ? "on" : "off"]."))

//water flower
/obj/item/reagent_container/spray/waterflower
	name = "water flower"
	desc = "A seemingly innocent sunflower...with a twist."
	icon = 'icons/obj/items/harvest.dmi'
	icon_state = "sunflower"
	item_state = "sunflower"
	amount_per_transfer_from_this = 1
	possible_transfer_amounts = null
	volume = 10

/obj/item/reagent_container/spray/waterflower/New()
	..()
	reagents.add_reagent("water", 10)

//chemsprayer
/obj/item/reagent_container/spray/chemsprayer
	name = "chem sprayer"
	desc = "A utility used to spray large amounts of reagent in a given area."
	icon_state = "chemsprayer"
	item_state = "chemsprayer"
	throwforce = 3
	w_class = SIZE_MEDIUM
	possible_transfer_amounts = null
	volume = 600
	


//this is a big copypasta clusterfuck, but it's still better than it used to be!
/obj/item/reagent_container/spray/chemsprayer/Spray_at(atom/A as mob|obj)
	var/Sprays[3]
	for(var/i=1, i<=3, i++) // intialize sprays
		if(src.reagents.total_volume < 1) break
		var/obj/effect/decal/chempuff/D = new/obj/effect/decal/chempuff(get_turf(src))
		D.create_reagents(amount_per_transfer_from_this)
		src.reagents.trans_to(D, amount_per_transfer_from_this)

		D.color = mix_color_from_reagents(D.reagents.reagent_list)

		Sprays[i] = D

	var/direction = get_dir(src, A)
	var/turf/T = get_turf(A)
	var/turf/T1 = get_step(T,turn(direction, 90))
	var/turf/T2 = get_step(T,turn(direction, -90))
	var/list/the_targets = list(T,T1,T2)

	for(var/i=1, i<=Sprays.len, i++)
		spawn()
			var/obj/effect/decal/chempuff/D = Sprays[i]
			if(!D) continue

			// Spreads the sprays a little bit
			var/turf/my_target = pick(the_targets)
			the_targets -= my_target

			for(var/j=1, j<=rand(6,8), j++)
				step_towards(D, my_target)
				D.reagents.reaction(get_turf(D))
				for(var/atom/t in get_turf(D))
					D.reagents.reaction(t)
				sleep(2)
			qdel(D)

	return

// Plant-B-Gone
/obj/item/reagent_container/spray/plantbgone // -- Skie
	name = "Plant-B-Gone"
	desc = "Kills those pesky weeds!"
	icon_state = "plantbgone"
	item_state = "plantbgone"
	volume = 100


/obj/item/reagent_container/spray/plantbgone/New()
	..()
	reagents.add_reagent("plantbgone", 100)


/obj/item/reagent_container/spray/plantbgone/afterattack(atom/A, mob/user, proximity)
	if(!proximity) return
	..()

//ammonia spray
/obj/item/reagent_container/spray/hydro
	name = "hydroponics spray"
	desc = "A spray used in hydroponics initially containing ammonia."
	icon_state = "hydrospray"

/obj/item/reagent_container/spray/hydro/New()
	..()
	reagents.add_reagent("ammonia", src.volume)