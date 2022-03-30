/// Abstract node to queue a map insertion task
/datum/nmnode/mapload
	id = "abstract-mapload"
	name = "mapload node"
	/// Base Path parameter as defined in configuration
	var/file_path

/datum/nmnode/mapload/New(list/spec)
	. = ..()
	file_path = spec["path"]

/// Helper to queue map insertion tasks
/datum/nmnode/mapload/proc/queue_map_insertion(datum/nmcontext/context, path, target_landmark, keep = FALSE, absolute = FALSE)
	if(!absolute)
		path = resolve_path(context, path)
	var/datum/nmtask/mapload/load_task = new(null, path, target_landmark, keep)
	SSnightmare.mapscheduler.add_task(load_task)
	NMLOG(NM_LOG_INFO, "Queued insert at \[[target_landmark]\]: [path]")
	return TRUE

/// Resolve map path in context
/datum/nmnode/mapload/proc/resolve_path(datum/nmcontext/context, path)
	var/modifier = copytext(path, 1, 2)
	if(modifier == "$") // Relative to game dir
		path = copytext(path, 2)
	else // Relative to map dir
		var/base_path = context.values["map_path"]
		if(base_path)
			path = "[base_path]/[path]"
	return path

/// Direct map load to a specified landmark
/datum/nmnode/mapload/landmark
	id = "map_insert"
	name = "landmark mapload"
	var/landmark
	var/keep = FALSE
/datum/nmnode/mapload/landmark/New(list/spec)
	. = ..()
	if(spec["landmark"])
		landmark = spec["landmark"]
	if(spec["keep"])
		keep = TRUE
/datum/nmnode/mapload/landmark/resolve(datum/nmcontext/context, list/statsmap)
	. = ..()
	if(.)
		queue_map_insertion(context, file_path, landmark, keep)

/**
 * Inserts a map file among a set of variations in a folder
 * param: path: some/folder/, landmark
 * files within should be named with a prefix indicating weighting:
 *    some/folder/20.destroyed.dmm
 *    some/folder/50.spaced.dmm
 * using + instead of dot means to keep map contents, eg.
 *    some/folder/20+extras.dmm is added on top
 */
/datum/nmnode/mapload/variations
	id = "map_variations"
	name = "Map Variations"
	var/landmark
/datum/nmnode/mapload/variations/New(list/spec)
	. = ..()
	if(spec["landmark"])
		landmark = spec["landmark"]
		if(!spec["name"])
			name += ": [landmark]"
/datum/nmnode/mapload/variations/resolve(datum/nmcontext/context, list/statsmap)
	. = ..()
	if(!. || !landmark)
		return
	var/dir_path = resolve_path(context, file_path)
	var/regex/matcher = new(@"^([0-9]+)([\.\+]).*?\.dmm$", "i")
	var/list/filelist = list()
	var/list/weights = list()
	var/sum = 0
	for(var/filename in flist(dir_path))
		if(!matcher.Find(filename))
			continue
		filelist += filename
		var/w = text2num(matcher.group[1])
		weights  += w
		sum      += w
	var/roll = rand(1, sum)
	sum = 0
	for(var/i in 1 to length(filelist))
		sum += weights[i]
		if(sum >= roll && matcher.Find(filelist[i]))
			var/keep = (matcher.group[2] == "+")
			if(queue_map_insertion(context, "[dir_path][matcher.match]", landmark, keep = keep, absolute = TRUE))
				break

/**
 * Similar to variations mode, but rolls all files individually rather
 * than picking one, using name for landmark. The prefix number is used
 * as a percentage chance. You can add extra text with an underscore.
 *
 * Example:
 *   some/folder/10.something_funny.dmm
 * would have 10% chance to insert at 'something' landmark
 */
/datum/nmnode/mapload/sprinkles
	id = "map_sprinkle"
	name = "Map Sprinkles"
/datum/nmnode/mapload/sprinkles/resolve(datum/nmcontext/context, list/statsmap)
	. = ..()
	if(!.) return
	var/successes = 0
	var/dir_path = resolve_path(context, file_path)
	var/regex/matcher = new(@"^([0-9]+)([\.\+])([^_]+)(_.*)?\.dmm$", "i")
	var/list/dircontents = flist(dir_path)
	for(var/filename in dircontents)
		if(!matcher.Find(filename))
			continue
		var/fprob = Clamp(text2num(matcher.group[1]) / 100, 0, 1)
		if(fprob < rand())
			continue
		var/keep = (matcher.group[2] == "+")
		var/landmark = matcher.group[3]
		if(queue_map_insertion(context, "[dir_path][matcher.match]", landmark, keep = keep, absolute = TRUE))
			successes++
	if(!successes)
		NMDEBUG("Didn't queue any maps for insertion")
	else
		NMDEBUG("Sprinkling [successes] maps for insertion")
