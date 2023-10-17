#define MARINE_CONDUCT_MEDAL "distinguished conduct medal"
#define MARINE_BRONZE_HEART_MEDAL "bronze heart medal"
#define MARINE_VALOR_MEDAL "medal of valor"
#define MARINE_HEROISM_MEDAL "medal of exceptional heroism"

#define XENO_SLAUGHTER_MEDAL "royal jelly of slaughter"
#define XENO_RESILIENCE_MEDAL "royal jelly of resilience"
#define XENO_SABOTAGE_MEDAL "royal jelly of sabotage"
#define XENO_PROLIFERATION_MEDAL "royal jelly of proliferation"
#define XENO_REJUVENATION_MEDAL "royal jelly of rejuvenation"

GLOBAL_LIST_EMPTY(medal_awards)
GLOBAL_LIST_EMPTY(jelly_awards)

/datum/recipient_awards
	var/list/medal_names
	var/list/medal_citations
	var/list/medal_items
	var/list/posthumous
	var/recipient_rank
	var/recipient_ckey
	var/list/giver_name // Designation for xenos
	var/list/giver_rank // "Name" for xenos
	var/list/giver_ckey

/datum/recipient_awards/New()
	medal_names = list()
	medal_citations = list()
	medal_items = list()
	posthumous = list()
	giver_name = list()
	giver_rank = list()
	giver_ckey = list()

/proc/give_medal_award(turf/medal_location, as_admin = FALSE, faction = FACTION_USCM)
	if(as_admin && !check_rights(R_ADMIN))
		as_admin = FALSE

	var/list/datum/player_legacy/living_legacies = list()
	var/list/datum/player_legacy/mob_cache = list() // temporary mob reference cache, used solely below to target the recipient directly
	// snapshot all mobs to legacies for common handling
	for(var/mob/living/existing as anything in GLOB.living_mob_list)
		var/datum/player_legacy/legacy = new /datum/player_legacy(existing)
		living_legacies += legacy
		mob_cache[legacy] = existing

	// now join both up and filter relevant members into a list we can send to tgui_input_list
	var/list/selections = list()
	for(var/datum/player_legacy/legacy as anything in living_legacies + GLOB.player_legacies)
		if(legacy.faction != faction)
			continue
		if(!legacy.medal_eligible)
			continue
		selections[legacy.name] = legacy

	// Pick a marine
	var/datum/player_legacy/chosen_recipient = tgui_input_list(usr, "Who do you want to award a medal to?", "Medal Recipient", selections)
	if(!chosen_recipient)
		return FALSE

	// Pick a medal
	var/medal_type = tgui_input_list(usr, "What type of medal do you want to award?", "Medal Type", list(MARINE_CONDUCT_MEDAL, MARINE_BRONZE_HEART_MEDAL, MARINE_VALOR_MEDAL, MARINE_HEROISM_MEDAL))
	if(!medal_type)
		return FALSE

	// Write a citation
	var/citation = strip_html(input("What should the medal citation read?", "Medal Citation", null, null) as message|null, MAX_PAPER_MESSAGE_LEN)
	if(!citation)
		return FALSE

	// Get mob information
	var/posthumous = chosen_recipient.dead
	if(!as_admin && usr)
		usr.count_niche_stat(STATISTICS_NICHE_MEDALS_GIVE)

	// Admin: Offer a medal_location if missing
	if(as_admin && !medal_location)
		var/medal_override = tgui_input_list(usr, "Spawn a medal? Press cancel for no item.", "Medal Location", list("On Recipient", "On Me"))
		if(medal_override == "On Recipient")
			var/mob/living/tentative_recipient = mob_cache[chosen_recipient]
			if(tentative_recipient)
				medal_location = get_turf(tentative_recipient)
				playsound(tentative_recipient, 'sound/items/trayhit1.ogg', 15, FALSE)
				tentative_recipient.visible_message(SPAN_DANGER("[tentative_recipient] has been hit in the head by the [medal_type]."), null, null, 5)
		else if(medal_override == "On Me")
			medal_location = get_turf(usr)

	// Create the recipient_award
	if(!GLOB.medal_awards[chosen_recipient])
		GLOB.medal_awards[chosen_recipient] = new /datum/recipient_awards()
	var/datum/recipient_awards/recipient_award = GLOB.medal_awards[chosen_recipient]
	recipient_award.recipient_rank = chosen_recipient.rank
	recipient_award.recipient_ckey = chosen_recipient.ckey
	recipient_award.medal_names += medal_type
	recipient_award.medal_citations += citation
	recipient_award.posthumous += posthumous
	recipient_award.giver_ckey += usr.ckey

	if(!as_admin && isliving(usr))
		var/mob/living/user = usr
		if(isxeno(user))
			var/mob/living/carbon/xenomorph/xeno_user = user
			recipient_award.giver_rank += xeno_user.caste_type // Currently not used in marine award message
		else
			recipient_award.giver_rank += user.job // Currently not used in marine award message
		recipient_award.giver_name += user.real_name // Currently not used in marine award message
	else
		recipient_award.giver_rank += null
		recipient_award.giver_name += null

	// Create an actual medal item
	if(medal_location)
		var/obj/item/clothing/accessory/medal/medal
		switch(medal_type)
			if(MARINE_CONDUCT_MEDAL)
				medal = new /obj/item/clothing/accessory/medal/bronze/conduct(medal_location)
			if(MARINE_BRONZE_HEART_MEDAL)
				medal = new /obj/item/clothing/accessory/medal/bronze/heart(medal_location)
			if(MARINE_VALOR_MEDAL)
				medal = new /obj/item/clothing/accessory/medal/silver/valor(medal_location)
			if(MARINE_HEROISM_MEDAL)
				medal = new /obj/item/clothing/accessory/medal/gold/heroism(medal_location)
			else
				return FALSE
		medal.recipient_name = chosen_recipient
		medal.medal_citation = citation
		medal.recipient_rank = chosen_recipient.rank
		recipient_award.medal_items += medal
	else
		recipient_award.medal_items += null

	// Recipient: Add the medal to the player's stats
	if(chosen_recipient.ckey)
		var/datum/entity/player_entity/recipient_player = setup_player_entity(chosen_recipient.ckey)
		if(recipient_player)
			recipient_player.track_medal_earned(medal_type, chosen_recipient, citation, usr)

	// Inform staff of success
	message_admins("[key_name_admin(usr)] awarded a <a href='?medals_panel=1'>[medal_type]</a> to [chosen_recipient.name] for: \'[citation]\'.")

	return TRUE

/proc/print_medal(mob/living/carbon/human/user, obj/printer)
	var/obj/item/card/id/card = user.wear_id
	if(!card)
		to_chat(user, SPAN_WARNING("You must have an authenticated ID Card to award medals."))
		return

	if(!((card.paygrade in GLOB.co_paygrades) || (card.paygrade in GLOB.highcom_paygrades)))
		to_chat(user, SPAN_WARNING("Only a Senior Officer can award medals!"))
		return

	if(!card.registered_ref)
		user.visible_message("ERROR: ID card not registered in USCM registry. Potential medal fraud detected.")
		return

	var/real_owner_ref = card.registered_ref

	if(real_owner_ref != WEAKREF(user))
		user.visible_message("ERROR: ID card not registered for [user.real_name] in USCM registry. Potential medal fraud detected.")
		return

	if(give_medal_award(get_turf(printer)))
		user.visible_message(SPAN_NOTICE("[printer] prints a medal."))

/proc/give_jelly_award(datum/hive_status/hive, as_admin = FALSE)
	if(!hive)
		return FALSE

	if(as_admin && !check_rights(R_ADMIN))
		as_admin = FALSE

	var/list/datum/player_legacy/living_legacies = list()
	var/list/datum/player_legacy/mob_cache = list() // temporary mob reference cache, used solely below to target the recipient directly
	// snapshot all mobs to legacies for common handling
	for(var/mob/living/existing as anything in GLOB.living_mob_list)
		var/datum/player_legacy/legacy = new /datum/player_legacy(existing)
		living_legacies += legacy
		mob_cache[legacy] = existing

	// now join both up and filter relevant members into a list we can send to tgui_input_list
	var/list/selections = list()
	for(var/datum/player_legacy/legacy as anything in living_legacies + GLOB.player_legacies)
		if(legacy.hivenumber != hive)
			continue
		if(!legacy.medal_eligible)
			continue
		if(!as_admin && legacy.rank == XENO_CASTE_QUEEN)
			continue
		selections[legacy.name] = legacy

	var/datum/player_legacy/chosen_recipient = tgui_input_list(usr, "Who do you want to award jelly to?", "Jelly Recipient", selections, theme="hive_status")
	if(!chosen_recipient)
		return FALSE

	// Pick a jelly
	var/medal_type = tgui_input_list(usr, "What type of jelly do you want to award?", "Jelly Type", list(XENO_SLAUGHTER_MEDAL, XENO_RESILIENCE_MEDAL, XENO_SABOTAGE_MEDAL, XENO_PROLIFERATION_MEDAL, XENO_REJUVENATION_MEDAL), theme="hive_status")
	if(!medal_type)
		return FALSE

	// Write the pheromone
	var/citation = strip_html(input("What should the pheromone read?", "Jelly Pheromone", null, null) as message|null, MAX_PAPER_MESSAGE_LEN)
	if(!citation)
		return FALSE

	// Admin: Override attribution
	var/admin_attribution = null
	if(as_admin)
		admin_attribution = strip_html(input("Override the jelly attribution? Press cancel for no attribution.", "Jelly Attribution", "Queen Mother", null) as text|null, MAX_NAME_LEN)
		if(!admin_attribution) // Its actually "" but this also seems to check that
			admin_attribution = "none"

	// Get mob information
	if(!as_admin && usr)
		usr.count_niche_stat(STATISTICS_NICHE_MEDALS_GIVE)

	// Create the recipient_award
	if(!GLOB.jelly_awards[chosen_recipient])
		GLOB.jelly_awards[chosen_recipient] = new /datum/recipient_awards()
	var/datum/recipient_awards/recipient_award = GLOB.jelly_awards[chosen_recipient]
	recipient_award.recipient_rank = chosen_recipient.rank
	recipient_award.recipient_ckey = chosen_recipient.ckey
	recipient_award.medal_names += medal_type
	recipient_award.medal_citations += citation
	recipient_award.posthumous += chosen_recipient.dead
	recipient_award.giver_ckey += usr.ckey

	if(!admin_attribution)
		recipient_award.giver_rank += chosen_recipient.rank
		recipient_award.giver_name += chosen_recipient.name
	else if(admin_attribution == "none")
		recipient_award.giver_rank += null
		recipient_award.giver_name += null
	else
		recipient_award.giver_rank += admin_attribution
		recipient_award.giver_name += null

	recipient_award.medal_items += null // TODO: Xeno award item?

	// Recipient: Add the medal to the player's stats
	if(chosen_recipient.ckey)
		var/datum/entity/player_entity/recipient_player = setup_player_entity(chosen_recipient.ckey)
		if(recipient_player)
			recipient_player.track_medal_earned(medal_type, chosen_recipient, citation, usr)

	// Inform staff of success
	message_admins("[key_name_admin(usr)] awarded a <a href='?medals_panel=1'>[medal_type]</a> to [chosen_recipient] for: \'[citation]\'.")

	return TRUE

/proc/remove_award(recipient_name, ckey, is_marine_medal, index = 1)
	if(!check_rights(R_MOD))
		return FALSE

	// Because the DB is slow, give an early message so there aren't two jumping on it
	message_admins("[key_name_admin(usr)] is deleting one of [recipient_name]'s medals...")

	// Find the award in the glob list
	var/datum/recipient_awards/recipient_award
	if(is_marine_medal)
		recipient_award = GLOB.medal_awards[recipient_name]
	else
		recipient_award = GLOB.jelly_awards[recipient_name]
	if(!recipient_award)
		to_chat(usr, "Error: Could not find the [is_marine_medal ? "marine" : "xeno"] awards for '[recipient_name]'!")
		return FALSE

	if(index < 1 || index > recipient_award.medal_names.len)
		to_chat(usr, "Error: Index [index] is out of bounds!")
		return FALSE

	// Delete the physical award item
	var/obj/item/medal_item = recipient_award.medal_items[index]
	if(medal_item)
		// Marine medals
		if(istype(medal_item, /obj/item/clothing/accessory))
			var/obj/item/clothing/accessory/marine_accessory = medal_item
			if(marine_accessory.has_suit)
				var/obj/item/clothing/attached_clothing = marine_accessory.has_suit
				attached_clothing.remove_accessory(usr, marine_accessory)
		// Update any container
		if(istype(medal_item.loc, /obj/item/storage))
			var/obj/item/storage/container = medal_item.loc
			container.update_icon()
		// Now delete it
		qdel(medal_item)

	// Either entirely delete the award from the list, or just remove the entry if there are multiple
	var/medal_type = recipient_award.medal_names[index]
	var/citation = recipient_award.medal_citations[index]
	if(recipient_award.medal_names.len == 1)
		if(is_marine_medal)
			GLOB.medal_awards.Remove(recipient_name)
		else
			GLOB.jelly_awards.Remove(recipient_name)
	else
		recipient_award.medal_names.Cut(index, index + 1)
		recipient_award.medal_citations.Cut(index, index + 1)
		recipient_award.posthumous.Cut(index, index + 1)
		recipient_award.giver_name.Cut(index, index + 1)
		recipient_award.giver_rank.Cut(index, index + 1)
		recipient_award.giver_ckey.Cut(index, index + 1)
		recipient_award.medal_items.Cut(index, index + 1)

	// Remove stats for recipient
	if(ckey)
		var/datum/entity/player_entity/recipient_player = setup_player_entity(ckey)
		if(recipient_player)
			recipient_player.untrack_medal_earned(medal_type, ckey, citation)

	// Inform staff of success
	message_admins("[key_name_admin(usr)] deleted [ckey]'s <a href='?medals_panel=1'>[medal_type]</a> for: \'[citation]\'.")

	return TRUE
