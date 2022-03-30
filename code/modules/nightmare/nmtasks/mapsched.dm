/// Handles map insertions sequentially and updating the game to match map insertions
/datum/nmtask/scheduler/mapload
	name = "mapload scheduler"
	var/step = 0

/datum/nmtask/scheduler/mapload/execute(list/statsmap)
	. = ..()
	if(. != NM_TASK_OK)
		return
	. = NM_TASK_CONTINUE
	switch(step)
		if(0)
			makepowernets()
		if(1)
			repopulate_sorted_areas()
		if(2)
			patch_lighting()
			return NM_TASK_OK
		else
			return NM_TASK_ERROR
	step++

/datum/nmtask/scheduler/mapload/proc/patch_lighting()
	var/list/turf/tainted = list()
	for(var/datum/nmtask/mapload/LT in done)
		if(done[LT] != NM_TASK_OK)
			continue
		if(!LT?.pmap || length(LT.pmap.bounds) < 6)
			continue
		var/list/bounds = LT.pmap.bounds
		var/list/TT = 	block(	locate(bounds[MAP_MINX], bounds[MAP_MINY], bounds[MAP_MINZ]),
								locate(bounds[MAP_MAXX], bounds[MAP_MAXY], bounds[MAP_MAXZ]))
		tainted |= TT

	for(var/turf/T as anything in tainted)
		var/area/A = T.loc
		if(!A?.lighting_use_dynamic)
			continue
		T.cached_lumcount = -1 // Invalidate lumcount to force update here
		T.lighting_changed = TRUE
		SSlighting.changed_turfs += T
