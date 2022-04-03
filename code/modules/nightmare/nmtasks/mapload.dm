/// Loads a chunk of map at the specified position
/datum/nmtask/mapload
	name = "mapload task"
	var/filepath
	var/landmark
	var/datum/parsed_map/pmap
	var/loaded = FALSE
	var/replace = TRUE
	var/turf/target_turf
	var/step = 1

	var/debugcounter = 0
	var/running = FALSE

/datum/nmtask/mapload/New(name, filepath, landmark, keep = FALSE)
	. = ..()
	src.filepath = filepath
	src.landmark = landmark
	name += ": [filepath]"
	replace = !keep

/datum/nmtask/mapload/cleanup()
	QDEL_NULL(pmap)
	return ..()

/datum/nmtask/mapload/Destroy()
	cleanup()
	return ..()

/datum/nmtask/mapload/execute(list/statsmap)
	log_debug("<[debugcounter]> before step=[step] loaded=[loaded]")
	if(running)
		pass() // DUPLICATE CALL?????
	running = TRUE
	switch(step)
		if(1) . = step_parse(statsmap)
		if(2) . = step_loadmap(statsmap)
		if(3) . = step_init(statsmap)
		else
			. = NM_TASK_ERROR
	running = FALSE
	log_debug("<[debugcounter]> now step=[step] loaded=[loaded] return=[.]")
	debugcounter++

/datum/nmtask/mapload/proc/step_parse(list/statsmap)
	. = NM_TASK_ERROR
	if(!fexists(filepath))
		NMLOG(NM_LOG_WARN, "File does not exist: [filepath]")
		return
	if(!pmap)
		pmap = new(file(filepath))
		if(!pmap?.bounds)
			NMLOG(NM_LOG_WARN, "File loading failed: [filepath]")
			return
		if(isnull(pmap.bounds[1]))
			NMLOG(NM_LOG_WARN, "Map Parsing failed: [filepath]")
			return
	step++
	return NM_TASK_CONTINUE

/datum/nmtask/mapload/proc/step_loadmap(list/statsmap)
	. = NM_TASK_ERROR
	log_debug("w")
	if(Master.map_loading) // Something is already loading
		return NM_TASK_PAUSE

	log_debug("A")
	target_turf = GLOB.nightmare_landmarks[landmark]
	if(!target_turf?.z)
		NMLOG(NM_LOG_WARN, "Could not find insertion landmark: [landmark]")
		return // This might/not be normal due to chained insers deleting others landmarks, TODO decide

	log_debug("B")
	var/result = pmap.load(target_turf.x, target_turf.y, target_turf.z, cropMap = TRUE, no_changeturf = FALSE, placeOnTop = FALSE, delete = replace)
	if(!result || !pmap.bounds)
		NMLOG(NM_LOG_CRIT, "Map loading failed unexpectedly for file: [filepath]")
		return

	log_debug("C")
	loaded = TRUE
	LAZYINC(statsmap, "mapload", 1)
	step++
	return NM_TASK_CONTINUE

/datum/nmtask/mapload/proc/step_init(list/statsmap)
	. = NM_TASK_ERROR
	log_debug("1")
	if(initialize_boundary_contents())
		NMLOG(NM_LOG_INFO, "Loaded '[filepath]' at '[landmark]' ([target_turf.x], [target_turf.y], [target_turf.z])")
	else
		NMLOG(NM_LOG_CRIT, "Map loaded but FAILED TO INITIALIZE: [filepath]")
		LAZYINC(statsmap, "init_err", 1)
		return
	step++
	return NM_TASK_OK

/// Initialize atoms/areas in bounds - we can't afford to do this later since game is half-running
/datum/nmtask/mapload/proc/initialize_boundary_contents()
	log_debug("2")
	var/list/bounds = pmap.bounds
	if(length(bounds) < 6)
		return
	var/list/TT = 	block(	locate(bounds[MAP_MINX], bounds[MAP_MINY], bounds[MAP_MINZ]),
							locate(bounds[MAP_MAXX], bounds[MAP_MAXY], bounds[MAP_MAXZ]))
	var/list/area/arealist = list()
	var/list/atom/atomlist = list()
	for(var/turf/T as anything in TT)
		atomlist |= T // a turf is an atom too
		if(T.loc) arealist |= T.loc
		for(var/A in T)
			atomlist |= A
	log_debug("3")
	SSmapping.reg_in_areas_in_z(arealist)
	log_debug("4")
	SSatoms.InitializeAtoms(atomlist, debug = TRUE)
	log_debug("5")
	// We still defer lighting, area sorting, etc
	return TRUE
