GLOBAL_SUBTYPE_PATHS_LIST_INDEXED(nightmare_node_map, /datum/nmnode, id)

SUBSYSTEM_DEF(nightmare)
	// Used during round start, then disables
	// Yes this is basically a proxy to MC, but handling dynamic tasks,
	// not static subsystems, as they depend upon config files.
	// Not SS_TICKER because that defeats the point of smooth in-lobby loading
	name       = "Nightmare"
	init_order = SS_INIT_NIGHTMARE
	priority   = SS_PRIORITY_NIGHTMARE
	runlevels  = RUNLEVEL_INIT | RUNLEVEL_LOBBY | RUNLEVEL_SETUP
	wait       = 1 // set automatically to world.tick_lag

	/// Current status of the subsystem (execution, etc)
	var/status = NM_STATUS_INIT
	/// World Date processing was started at
	var/startdate = 0
	/// In rush mode, used for sudden verb starts, the subsystem speeds up by using normal pause mechanisms
	var/rush = FALSE
	/// List of root level loaded nightmare trees with their tag
	var/list/roots = list()
	/// List of contexts in use
	var/list/contexts = list()
	/// Global statistics for debug & accounting
	var/list/stats = list()

	/// Helper task handling scheduling the tasks we'll execute
	var/datum/nmtask/scheduler/scheduler
	/// Scheduler handling map loading tasks and global init for them
	var/datum/nmtask/scheduler/mapload/mapscheduler

/datum/controller/subsystem/nightmare/Initialize(start_timeofday)
	if(!CONFIG_GET(flag/nightmare_enabled))
		can_fire = FALSE
		return
	for(var/stat in list("resolved", "nodes", "tasks_ok", "tasks_err", "mapload"))
		stats[stat] = 0
	initialize_contexts()
	scheduler = new
	mapscheduler = new
	status = NM_STATUS_WAIT
	return ..()

/datum/controller/subsystem/nightmare/stat_entry(msg)
	msg = ""
	switch(status)
		if(NM_STATUS_INIT) msg += "INIT..."
		if(NM_STATUS_WAIT) msg += "STANDBY"
		if(NM_STATUS_BUSY) msg += "WORKING..."
		if(NM_STATUS_READY) msg += "READY!"
		if(NM_STATUS_ABORT) msg += "ABORTED"
	msg += " C:[contexts.len] R:[roots.len]"
	if(CONFIG_GET(flag/nightmare_debug))
		for(var/entry in stats)
			msg += " | [entry]=[stats[entry]]"
	return ..()

/datum/controller/subsystem/nightmare/fire(resumed = FALSE)
	// Contingencies in the off chance things fail to avoid hanging game start
	if(SSticker.current_state > GAME_STATE_SETTING_UP \
	|| (status >= NM_STATUS_ABORT)  \
	|| (startdate && (REALTIMEOFDAY > startdate + CONFIG_GET(number/nightmare_timeout) * 10))
	)
		status = NM_STATUS_ABORT
		can_fire = FALSE
		nmlog(NM_LOG_CRIT, "Nightmare EMERGENCY DISABLED due to taking too long. Game might not be in a fully consistent state. Good luck!", "Controller")
		return

	// Disable ticking after round start
	if(SSticker.current_state > GAME_STATE_SETTING_UP || status > NM_STATUS_BUSY)
		can_fire = FALSE
		return

	// Update tickrate if it changed at global level
	wait = world.tick_lag

	var/summary = FALSE
	while(status == NM_STATUS_BUSY)
		if(rush)
			if(MC_TICK_CHECK) return // Traditional pause mode, MC will resume us
		else if(TICK_CHECK)   return // Best effort mode, just pretend we're done

		var/list/statsmap = list()
		var/retval = scheduler.invoke(null, statsmap)
		mergeListsSum(stats, statsmap)
		switch(retval)
			if(NM_TASK_OK)
				summary = TRUE
				status = NM_STATUS_READY
				nmlog(NM_LOG_CRIT, "Nightmare READY in [(REALTIMEOFDAY-startdate)/10] seconds!", "Controller")
			if(NM_TASK_CONTINUE)
				// Nothing to do, we loop and pause as needed
			if(NM_TASK_PAUSE)
				return
			else // Assume an error
				summary = TRUE
				status = NM_STATUS_ABORT
				nmlog(NM_LOG_CRIT, "Nightmare execution FAILED after [(REALTIMEOFDAY-startdate)/10] seconds", "Controller", "FATAL")
	if(summary)
		nmlog(NM_LOG_WARN, "Nightmare Summary: [stats["resolved"]] out of [stats["nodes"]] nodes resolved. [stats["tasks_ok"]] tasks executed with [stats["tasks_err"]] errors. [stats["mapload"]] map files have been inserted.", "Controller")

/// Init default contexts for use and load related config files
/datum/controller/subsystem/nightmare/proc/initialize_contexts()
	// Create contexts
	for(var/context in list(NM_CTX_GLOBAL, NM_CTX_GROUND, NM_CTX_SHIP))
		contexts[context] = new /datum/nmcontext
	// Load config files
	load_file(CONFIG_GET(string/nightmare_global_scenario), "[NM_CTX_GLOBAL]-[NM_ACT_SCENARIO]")
	load_file(CONFIG_GET(string/nightmare_global_actions), "[NM_CTX_GLOBAL]-[NM_ACT_DEFAULT]")
	load_map_config(NM_CTX_GROUND, GROUND_MAP)
	load_map_config(NM_CTX_SHIP, SHIP_MAP)
	// Resolve scenario nodes
	for(var/context in contexts)
		try_resolve_nodes(context, NM_ACT_SCENARIO)

/// Load nightmare steps relevant to a map
/datum/controller/subsystem/nightmare/proc/load_map_config(context_name, map_type)
	var/datum/map_config/MC = SSmapping.configs[map_type]
	var/datum/nmcontext/CTX = contexts[context_name]
	CTX.values["map_path"] = "maps/[MC.map_path]"
	CTX.values["nightmare_path"] = MC.nightmare_path
	load_file("[MC.nightmare_path]/[NM_FILE_SCENARIO]", "[context_name]-[NM_ACT_SCENARIO]")
	load_file("[MC.nightmare_path]/[NM_FILE_BASE]", "[context_name]-[NM_ACT_DEFAULT]")
	nmlog(NM_LOG_INFO, "Processed map environment {[context_name],{[map_type]}", "Controller", "Init")

/// Attempt to resolve a nmnode config tree into tasks
/datum/controller/subsystem/nightmare/proc/try_resolve_nodes(context_name, config_name)
	var/datum/nmcontext/CTX = contexts[context_name]
	if(!CTX)
		nmlog(NM_LOG_WARN, "Tried to resove nodes in unknown context, ignored: [context_name]", "Controller", "Exec")
		return
	var/datum/nmnode/nodes = roots["[context_name]-[config_name]"]
	if(!nodes)
		nmlog(NM_LOG_WARN, "Tried to resove unknown set of nodes, ignored: [config_name]", "Controller", "Exec")
		return
	var/list/statsmap = list()
	. = nodes.resolve(CTX, statsmap)
	mergeListsSum(stats, statsmap)
	nmlog(NM_LOG_INFO, "Resolved nodes for {[context_name],[config_name]}", "Controller", "Exec")
	if(.)
		LAZYINC(stats, "resolved", 1)
	LAZYINC(stats, "nodes", 1)

/// Starts execution of nightmare tasks
/datum/controller/subsystem/nightmare/proc/run_nightmare()
	PRIVATE_PROC(TRUE)
	SHOULD_NOT_SLEEP(TRUE)
	startdate = REALTIMEOFDAY
	try_resolve_nodes(NM_CTX_GLOBAL, NM_ACT_DEFAULT)
	try_resolve_nodes(NM_CTX_GROUND, NM_ACT_DEFAULT)
	try_resolve_nodes(NM_CTX_SHIP, NM_ACT_DEFAULT)
	// Build our task queue
	for(var/name in contexts)
		var/datum/nmcontext/context = contexts[name]
		scheduler.add_task(context.scheduler)
	scheduler.add_task(mapscheduler)
	status = NM_STATUS_BUSY

/// Perform setup as needed and return if ready
/datum/controller/subsystem/nightmare/proc/start_nightmare()
	set waitfor = FALSE
	if(!CONFIG_GET(flag/nightmare_enabled))
		return TRUE
	if(status >= NM_STATUS_READY)
		return TRUE
	if(startdate && (REALTIMEOFDAY > startdate + CONFIG_GET(number/nightmare_timeout) * 10))
		status = NM_STATUS_ABORT
		return TRUE // Pretend it's done
	. = FALSE
	if(status == NM_STATUS_WAIT)
		nmlog(NM_LOG_CRIT, "Starting nightmare, please stay seated and do not touch scenario...", "Controller", "INFO")
		run_nightmare()

/// Reads a JSON file, returns a branch nmnode representing contents of file
/datum/controller/subsystem/nightmare/proc/load_file(filename, tag)
	RETURN_TYPE(/datum/nmnode/branch)
	if(tag && roots[tag])
		nmlog(NM_LOG_WARN, "Loading a duplicate nodes definition for [tag]", "Controller", "Reader")
	var/datum/nmnode/branch/root = new(list())
	var/list/datum/nmnode/nodes = parse_file(filename)
	root.nodes = nodes
	if(root && tag)
		roots[tag] = root
	return root

/// Reads a JSON file, returns list of config nodes in the file
/datum/controller/subsystem/nightmare/proc/parse_file(filename)
	RETURN_TYPE(/list/datum/nmnode)
	. = list()
	var/data = file(filename)
	if(!data)
		nmlog(NM_LOG_CRIT, "Failed to read config file: [filename]", "Controller", "Reader")
		CRASH("Could not get requested nightmare config file!")
	LAZYINC(stats, "files", 1)
	if(data) data = file2text(data)
	if(data) data = json_decode(data)
	return parse_tree(data)

/// Instanciates nmnodes from parsed JSON
/datum/controller/subsystem/nightmare/proc/parse_tree(list/parsed)
	RETURN_TYPE(/list/datum/nmnode)
	if(!islist(parsed)) return
	var/list/datum/nmnode/nodes = list()
	if(!parsed["type"]) // This is a JSON array
		for(var/list/spec as anything in parsed)
			var/datum/nmnode/N = read_node(spec)
			if(N) nodes += N
	else // This is a JSON hash
		var/datum/nmnode/N = read_node(parsed)
		if(N) nodes += N
	return nodes

/// Instanciate a single nmnode from its JSON definition
/datum/controller/subsystem/nightmare/proc/read_node(list/parsed)
	RETURN_TYPE(/datum/nmnode)
	var/jsontype = parsed["type"]
	var/nodetype = GLOB.nightmare_node_map[jsontype]
	if(nodetype)
		LAZYINC(stats, "parse_ok", 1)
		return new nodetype(parsed)
	else
		LAZYINC(stats, "parse_err", 1)
		CRASH("Tried to instanciate an invalid node type")

/datum/controller/subsystem/nightmare/proc/nmlog(severity = NM_LOG_INFO, message, name = "unknown")
	if(CONFIG_GET(flag/nightmare_debug) && severity == NM_LOG_INFO)
		severity = NM_LOG_WARN
	var/header
	header = "Nightmare"
	message = "[header] \[[name]\]: [message]"
	if(severity >= NM_LOG_CRIT)
		message_staff(message)
	if(severity >= NM_LOG_WARN)
		log_debug(message)
