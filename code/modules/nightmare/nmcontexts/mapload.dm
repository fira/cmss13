/// Global context for map loading operations
/datum/nmcontext/mapload
	name = "mapload context"

/datum/nmcontext/mapload/execute_tasks()
	. = ..()
	initmap()

/datum/nmcontext/mapload/proc/initmap()
	makepowernets()
	repopulate_sorted_areas()
	var/list/turf/tainted = list()
	for(var/datum/nmtask/mapload/LT in tasks)
		if(LT.status != NM_TASK_OK)
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
