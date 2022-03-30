/// Branch toward all other nodes
/datum/nmnode/branch
	id = "branch"
	name = "branch node"
	/// Child nodes
	var/list/datum/nmnode/nodes

/datum/nmnode/branch/New(list/spec)
	. = ..()
	if(!nodes)
		nodes = SSnightmare.parse_tree(spec["nodes"])

/datum/nmnode/branch/Destroy()
	QDEL_NULL_LIST(nodes)
	return ..()

/datum/nmnode/branch/resolve(datum/nmcontext/context, list/statsmap)
	. = ..()
	if(!. || !length(nodes))
		return FALSE
	for(var/datum/nmnode/N as anything in nodes)
		var/ret = N.resolve(context, statsmap)
		if(ret)
			LAZYINC(statsmap, "resolved", 1)
		LAZYINC(statsmap, "nodes", 1)
	return TRUE

/// Same but load them from another file
/datum/nmnode/branch/include
	id = "include"
	name = "include node"
	var/filepath
/datum/nmnode/branch/include/New(list/spec)
	. = ..()
	if(spec["file"])
		filepath = spec["file"]
	if(!spec["name"])
		name += ": [filepath]"
	nodes = SSnightmare.parse_file(filepath)
	if(!nodes)
		NMLOG(NM_LOG_WARN, "failed to load file: [filepath]")
		return
	NMDEBUG("included file successfully: [filepath]")
/datum/nmnode/branch/include/resolve(datum/nmcontext/context, list/statsmap)
	return ..()

/**
 * Pick between weighted random options
 * weights: array of weights for each option
 * amount:  how many to get in total
 */
/datum/nmnode/picker
	id = "pick"
	name = "Picker"
	var/amount = 1
	var/list/weights
	var/list/datum/nmnode/nodes

/datum/nmnode/picker/New(list/spec)
	. = ..()
	if(spec["amount"])
		amount = spec["amount"]
	if(spec["weights"])
		var/list/json_weights = spec["weights"]
		weights = json_weights.Copy()
	else weights = list()
	nodes = SSnightmare.parse_tree(spec["choices"])
	weights.len = nodes.len
	for(var/i in 1 to length(nodes))
		if(!isnum(weights[i]) || weights[i] < 0)
			weights[i] = 1
		weights[i] = round(weights[i])

/datum/nmnode/picker/Destroy()
	QDEL_NULL_LIST(nodes)
	weights = null
	return ..()

/// Just a classic weighted pick
/datum/nmnode/picker/resolve(datum/nmcontext/context, list/statsmap)
	. = ..()
	if(!.) return
	var/remaining = amount
	var/wtotal = 0
	for(var/w in weights)
		wtotal += w
	if(wtotal < 1)
		return
	while(length(nodes) && remaining)
		var/runtotal = 0
		var/rolled = rand(1, wtotal)
		for(var/i in 1 to length(nodes))
			runtotal += weights[i]
			if(rolled > runtotal)
				continue
			var/datum/nmnode/N = nodes[i]
			remaining--
			wtotal -= weights[i]
			nodes.Cut(i, i+1)
			weights.Cut(i, i+1)
			N.resolve(context, statsmap)
			LAZYINC(statsmap, "resolved", 1)
			break
