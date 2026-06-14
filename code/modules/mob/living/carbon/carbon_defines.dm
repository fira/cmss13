/mob/living/carbon
	gender = MALE
	mobility_flags = MOBILITY_FLAGS_CARBON_DEFAULT

	var/life_tick = 0   // The amount of life ticks that have processed on this mob.

	/// Whether or not the mob is handcuffed, and the item they are handcuffed with
	var/obj/item/restraint/handcuffs/handcuffed

	var/overeat_cooldown = 0

	/// Active emote/pose - this is custom and added to examine text
	var/pose

	var/pulse = PULSE_NORM //current pulse level
	var/butchery_progress = 0
	var/huggable = TRUE //can apply Facehuggers (still checks proc/can_hug())

	var/list/view_change_sources

	blood_volume = BLOOD_VOLUME_NORMAL
	var/special_blood = null

	///list of active transfusions from blood bags or iv stands
	var/list/active_transfusions = list()

	/// All internal organs - please note that /human subtype also store them by string index
	var/list/datum/internal_organ/internal_organs = list()

	/// Stores all information relating to Hunters for use with their HUD and other systems.
	var/datum/huntdata/hunter_data

/mob/living/carbon/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "-----CARBON-----")
	VV_DROPDOWN_OPTION(VV_HK_CHANGEHIVENUMBER, "Change Hive Number")

/mob/living/carbon/vv_do_topic(list/href_list)
	. = ..()

	if(href_list[VV_HK_CHANGEHIVENUMBER])
		if(!check_rights(R_DEBUG|R_ADMIN))
			return

		usr.client.cmd_admin_change_their_hivenumber(src)
