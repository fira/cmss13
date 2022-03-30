/// Nightmare Configuration Entry, which can result in an action, just be control flow, etc
/datum/nmnode
	/// Unique identifier for referencing in JSON configuration
	var/id = "abstract"
	/// Node identifier for debug & display
	var/name = "abstract node"
	/// Probability to take effect in percent upon resolve - otherwise the node is skipped and has no effect
	var/proba = 100
	/// Required scenario values for this to apply under the form: list(PARAMETER NAME, OPERATOR TYPE, VALUE)
	var/list/list/conditions

/datum/nmnode/Destroy()
	conditions = null
	return ..()

/datum/nmnode/New(list/spec)
	. = ..()
	if(spec["name"])
		name  = spec["name"]
	if(isnum(spec["prob"]))
		proba = spec["prob"]
	if(spec["if"])
		var/list/jsondata = spec["if"]
		conditions = jsondata.Copy()

/// Resolves node within the environment, affecting context - usually by queuing tasks
/datum/nmnode/proc/resolve(datum/nmcontext/context, list/statsmap)
	SHOULD_NOT_SLEEP(TRUE)
	if(!prob(proba))
		return FALSE
	if(!check(context))
		return FALSE
	return TRUE

/// Helper to get relevant scenario value from input
/datum/nmnode/proc/get_scenario_value(datum/nmcontext/context, parameter_name)
	var/modifier = copytext(parameter_name, 1, 2)
	var/datum/nmcontext/relevant_context = context
	if(modifier == "$") // Get value from global context instead
		parameter_name = copytext(parameter_name, 2)
		relevant_context = SSnightmare.contexts[NM_CTX_GLOBAL]
	return relevant_context?.scenario[parameter_name]

/// Check whether this node applies in a given context
/datum/nmnode/proc/check(datum/nmcontext/context)
	for(var/list/cond as anything in conditions)
		var/param = cond[1]
		var/op = cond[2]
		var/value = cond[3]
		var/sval = context.scenario[param]
		var/negate = FALSE
		var/result = FALSE
		if(op[1] == "!")
			negate = TRUE
			op = splicetext(op, 1, 2)
		switch(op)
			if("defined") if(sval == null) result = FALSE
			if(">") if(sval > value) result = TRUE
			if("<") if(sval < value) result = TRUE
			if("in") if(sval in value) result = TRUE
			if("==") if(sval == value) result = TRUE
		if(negate)
			result = !result
		if(!result)
			NMLOG(NM_LOG_INFO, "Node [name] skipped by condition: [param] [op] [value]")
			return FALSE
	return TRUE
