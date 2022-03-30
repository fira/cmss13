/// Stateful container for resolving nmnodes within a defined scope (a round, a z-level, etc)
/datum/nmcontext
	/// Context name
	var/name = "nmcontext"
	/// Working directory for files in this context
	var/workdir = ""
	/// Context parameters, eg. internal state, as KV - as used by code
	var/list/values
	/// Scenario parameters for the context, as KV - as used by user-provided logic
	var/list/scenario
	/// Task scheduler for this context
	var/datum/nmtask/scheduler/scheduler

/datum/nmcontext/New(name)
	if(name)
		src.name = name
	values = list()
	scenario = list()
	scheduler = new

/datum/nmcontext/Destroy()
	values = null
	scenario = null
	QDEL_NULL(scheduler)
	return ..()

/// Run scheduled tasks in this context
/datum/nmcontext/proc/run_tasks(list/statsmap)
	return scheduler.invoke(null, statsmap)
