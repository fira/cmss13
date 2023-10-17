GLOBAL_LIST_EMPTY(player_legacies)

/// Stores data about a player that disappeared from the round (deletion)
/// Also serves as a common interface to snapshot data from mobs for example for statistics and medals
/datum/player_legacy
	var/name
	var/ckey
	var/job
	var/rank
	var/faction
	var/dead = TRUE
	var/mob_type //! Type of mob, exists primarily for database statistics which are stored in different entities for xeno/human
	var/datum/hive_status/hivenumber
	var/medal_eligible = TRUE

	//var/turf/last_position //optional
	//var/datum/cause_data/cause //optional

/// Snapshots a still existing player into legacy datum
/datum/player_legacy/New(mob/living/user)
	. = ..()
	refresh(user)

/// Refreshes the snapshotted data to update it
/datum/player_legacy/proc/refresh(mob/living/user)
	if(!QDELETED(user) && user.stat < DEAD)
		dead = FALSE

	src.mob_type = user.type

	if(user.statistic_exempt)
		medal_eligible = FALSE

	src.job = user.job
	if(isxeno(user))
		var/mob/living/carbon/xenomorph/xeno_user = user
		src.name = xeno_user.full_designation
		src.rank = xeno_user.caste_type
	else
		src.name = user.real_name
		src.rank = user.job

	src.faction = user.faction
	if(!src.faction)
		src.faction = FACTION_NEUTRAL

	src.ckey = user.persistent_ckey
	src.hivenumber = user.hivenumber

// Add to global store. Leave this to /mob/living/Destroy()
/datum/player_legacy/proc/register()
	LAZYINITLIST(GLOB.player_legacies)
	GLOB.player_legacies |= src
