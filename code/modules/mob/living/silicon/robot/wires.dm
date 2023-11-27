#define BORG_WIRE_LAWCHECK 1
#define BORG_WIRE_MAIN_POWER1 2
#define BORG_WIRE_MAIN_POWER2 3
#define BORG_WIRE_AI_CONTROL 4
#define BORG_WIRE_CAMERA 5

/proc/RandomBorgWires()
	//to make this not randomize the wires, just set index to 1 and increment it in the flag for loop (after doing everything else).
	var/list/Borgwires = list(0, 0, 0, 0, 0)
	GLOB.BorgIndexToFlag = list(0, 0, 0, 0, 0)
	GLOB.BorgIndexToWireColor = list(0, 0, 0, 0, 0)
	GLOB.BorgWireColorToIndex = list(0, 0, 0, 0, 0)
	var/flagIndex = 1
	//I think it's easier to read this way, also doesn't rely on the random number generator to land on a new wire.
	var/list/colorIndexList = list(BORG_WIRE_LAWCHECK, BORG_WIRE_MAIN_POWER1, BORG_WIRE_MAIN_POWER2, BORG_WIRE_AI_CONTROL, BORG_WIRE_CAMERA)
	for (var/flag=1, flag<=16, flag+=flag)
		var/colorIndex = pick(colorIndexList)
		if (Borgwires[colorIndex]==0)
			Borgwires[colorIndex] = flag
			GLOB.BorgIndexToFlag[flagIndex] = flag
			GLOB.BorgIndexToWireColor[flagIndex] = colorIndex
			GLOB.BorgWireColorToIndex[colorIndex] = flagIndex
			colorIndexList -= colorIndex // Shortens the list.
		//world.log << "Flag: [flag], CIndex: [colorIndex], FIndex: [flagIndex]"
		flagIndex+=1
	return Borgwires

/mob/living/silicon/robot/proc/isWireColorCut(wireColor)
	var/wireFlag = GLOB.BorgWireColorToFlag[wireColor]
	return ((src.borgwires & wireFlag) == 0)

/mob/living/silicon/robot/proc/isWireCut(wireIndex)
	var/wireFlag = GLOB.BorgIndexToFlag[wireIndex]
	return ((src.borgwires & wireFlag) == 0)

/mob/living/silicon/robot/proc/cut(wireColor)
	var/wireFlag = GLOB.BorgWireColorToFlag[wireColor]
	var/wireIndex = GLOB.BorgWireColorToIndex[wireColor]
	borgwires &= ~wireFlag
	switch(wireIndex)
		if(BORG_WIRE_LAWCHECK) //Cut the law wire, and the borg will no longer receive law updates from its AI
			if (src.lawupdate == 1)
				to_chat(src, "LawSync protocol engaged.")
				src.show_laws()
		if (BORG_WIRE_AI_CONTROL) //Cut the AI wire to reset AI control
			if (src.connected_ai)
				src.connected_ai = null
		if (BORG_WIRE_CAMERA)
			if(camera && camera.status && !scrambledcodes)
				camera.toggle_cam_status(usr, TRUE) // Will kick anyone who is watching the Cyborg's camera.

	src.interact(usr)

/mob/living/silicon/robot/proc/mend(wireColor)
	var/wireFlag = GLOB.BorgWireColorToFlag[wireColor]
	var/wireIndex = GLOB.BorgWireColorToIndex[wireColor]
	borgwires |= wireFlag
	switch(wireIndex)
		if(BORG_WIRE_LAWCHECK) //turns law updates back on assuming the borg hasn't been emagged
			if (src.lawupdate == 0)
				src.lawupdate = 1
		if(BORG_WIRE_CAMERA)
			if(camera && !camera.status && !scrambledcodes)
				camera.toggle_cam_status(usr, TRUE) // Will kick anyone who is watching the Cyborg's camera.

	src.interact(usr)


/mob/living/silicon/robot/proc/pulse(wireColor)
	var/wireIndex = GLOB.BorgWireColorToIndex[wireColor]
	switch(wireIndex)
		if(BORG_WIRE_LAWCHECK) //Forces a law update if the borg is set to receive them. Since an update would happen when the borg checks its laws anyway, not much use, but eh
			if (src.lawupdate)
				src.photosync()

		if (BORG_WIRE_AI_CONTROL) //pulse the AI wire to make the borg reselect an AI
			src.connected_ai = select_active_ai()

		if (BORG_WIRE_CAMERA)
			if(camera && camera.status && !scrambledcodes)
				camera.toggle_cam_status(src, TRUE) // Kick anyone watching the Cyborg's camera, doesn't display you disconnecting the camera.
				to_chat(usr, "[src]'s camera lens focuses loudly.")
				to_chat(src, "Your camera lens focuses loudly.")

	src.interact(usr)

/mob/living/silicon/robot/proc/interact(mob/user)
	if(wiresexposed && (!isRemoteControlling(user)))
		user.set_interaction(src)
		var/t1 = text("<B>Access Panel</B><br>\n")
		var/list/Borgwires = list(
			"Orange" = 1,
			"Dark red" = 2,
			"White" = 3,
			"Yellow" = 4,
			"Blue" = 5,
		)
		for(var/wiredesc in Borgwires)
			var/is_uncut = src.borgwires & GLOB.BorgWireColorToFlag[Borgwires[wiredesc]]
			t1 += "[wiredesc] wire: "
			if(!is_uncut)
				t1 += "<a href='?src=\ref[src];borgwires=[Borgwires[wiredesc]]'>Mend</a>"
			else
				t1 += "<a href='?src=\ref[src];borgwires=[Borgwires[wiredesc]]'>Cut</a> "
				t1 += "<a href='?src=\ref[src];pulse=[Borgwires[wiredesc]]'>Pulse</a> "
			t1 += "<br>"
		t1 += text("<br>\n[(src.lawupdate ? "The LawSync light is on." : "The LawSync light is off.")]<br>\n[(src.connected_ai ? "The AI link light is on." : "The AI link light is off.")]")
		t1 += text("<br>\n[((!isnull(src.camera) && src.camera.status == 1) ? "The Camera light is on." : "The Camera light is off.")]<br>\n")
		t1 += text("<p><a href='?src=\ref[src];close2=1'>Close</a></p>\n")
		user << browse(t1, "window=borgwires")
		onclose(user, "borgwires")

/mob/living/silicon/robot/Topic(href, href_list)
	..()
	if (((in_range(src, usr) && istype(src.loc, /turf))) && !isRemoteControlling(usr))
		usr.set_interaction(src)
		if (href_list["borgwires"])
			var/t1 = text2num(href_list["borgwires"])
			var/obj/item/held_item = usr.get_held_item()
			if (!held_item || !HAS_TRAIT(held_item, TRAIT_TOOL_WIRECUTTERS))
				to_chat(usr, SPAN_WARNING("You need wirecutters!"))
				return
			if (src.isWireColorCut(t1))
				src.mend(t1)
			else
				src.cut(t1)
		else if (href_list["pulse"])
			var/t1 = text2num(href_list["pulse"])
			var/obj/item/held_item = usr.get_held_item()
			if (!held_item || !HAS_TRAIT(held_item, TRAIT_TOOL_MULTITOOL))
				to_chat(usr, SPAN_WARNING("You need a multitool!"))
				return
			if (src.isWireColorCut(t1))
				to_chat(usr, SPAN_WARNING("You can't pulse a cut wire."))
				return
			else
				src.pulse(t1)
		else if (href_list["close2"])
			close_browser(usr, "borgwires")
			usr.unset_interaction()
			return

#undef BORG_WIRE_LAWCHECK
#undef BORG_WIRE_MAIN_POWER1
#undef BORG_WIRE_MAIN_POWER2
#undef BORG_WIRE_AI_CONTROL
#undef BORG_WIRE_CAMERA
