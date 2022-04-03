/**
 * Map Loading task
 * Replaces the location at a landmark by contents of a new map file
 */

/datum/nmtask/mapload
	name = "mapload"
	var/filepath
	var/replace = TRUE
	var/turf/target_turf
	var/datum/parsed_map/pmap
	var/loaded = FALSE

/datum/nmtask/mapload/New(filepath, landmark, keep = FALSE)
	. = ..()
	src.filepath = filepath
	name += ": [filepath]"
	target_turf = GLOB.nightmare_landmarks[landmark]
	replace = !keep

/datum/nmtask/mapload/Destroy()
	target_turf = null
	pmap = null
	return ..()

/datum/nmtask/mapload/execute()
	if(!target_turf?.z || !fexists(filepath))
		NMLOG(NM_LOG_WARN, "File not found: [filepath]", "Mapload")
		return NM_TASK_ERROR
	if(!pmap)
		pmap = new(file(filepath))
		if(!pmap?.bounds)
			NMLOG(NM_LOG_WARN, "File loading failed: [filepath]", "Mapload")
			return NM_TASK_ERROR
		if(isnull(pmap.bounds[1]))
			NMLOG(NM_LOG_CRIT, "Failed to parse map file: [filepath]", "Mapload")
			return NM_TASK_ERROR
		if(TICK_CHECK)
			return NM_TASK_PAUSE
	if(Master.map_loading)
		return NM_TASK_PAUSE
	if(!loaded)
		var/result = pmap.load(target_turf.x, target_turf.y, target_turf.z, cropMap = TRUE, no_changeturf = FALSE, placeOnTop = FALSE, delete = replace)
		if(!result || !pmap.bounds)
			NMLOG(NM_LOG_WARN, "Map loading failed for [filepath]", "Mapload")
			return NM_TASK_ERROR
		else
			loaded = TRUE
			if(initialize_boundary_contents())
				NMLOG(NM_LOG_INFO, "Loaded at ([target_turf.x], [target_turf.y], [target_turf.z])", "Mapload")
			else
				NMLOG(NM_LOG_CRIT, "Loaded map at ([target_turf.x], [target_turf.y], [target_turf.z]) but INIT FAILED!", "Mapload")
	return NM_TASK_OK

/// Initialize atoms/areas in bounds - we can't afford to do this later since game is half-running
/datum/nmtask/mapload/proc/initialize_boundary_contents()
	var/list/bounds = pmap.bounds
	if(length(bounds) < 6)
		return
	var/list/TT = 	block(	locate(bounds[MAP_MINX], bounds[MAP_MINY], bounds[MAP_MINZ]),
							locate(bounds[MAP_MAXX], bounds[MAP_MAXY], bounds[MAP_MAXZ]))
	var/list/area/arealist = list()
	var/list/atom/atomlist = list()
	for(var/i in TT)
		var/turf/T = i
		atomlist |= T // a turf is an atom too
		if(T.loc) arealist |= T.loc
		for(var/A in T)
			atomlist |= A
	log_debug("Registering areas...")
	SSmapping.reg_in_areas_in_z(arealist)
	log_debug("Initializing Atoms..")
	SSatoms.InitializeAtoms(atomlist)
	// We still defer lighting, area sorting, etc
	return TRUE
