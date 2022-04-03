/// Reads a file, use a branch nmnode to contain the list
/proc/nightmare_load_file(filename)
	RETURN_TYPE(/datum/nmnode/branch)
	var/datum/nmnode/branch/root = new(src, list())
	root.nodes = nightmare_parse_file(filename)
	return root

/// Reads a file, returns a list of nmnodes
/proc/nightmare_parse_file(filepath)
	RETURN_TYPE(/list/datum/nmnode)
	var/data = file(filepath)
	if(!data)
		CRASH("Failed to read [filepath] in nightmare parsing")
	if(data) data = file2text(data)
	if(data) data = json_decode(data)
	if(!data || !islist(data))
		return list()
	return nightmare_parse_tree(data)

/// Reads JSON, instanciates a list of nodes
/proc/nightmare_parse_tree(list/parsed)
	if(!islist(parsed)) return
	var/list/datum/nmnode/nodes = list()
	if(!parsed["type"]) // This is a JSON array
		for(var/list/nodespec in parsed)
			var/datum/nmnode/N = read_node(nodespec)
			if(N) nodes += N
	else // This is a JSON hash
		var/datum/nmnode/N = read_node(parsed)
		if(N) nodes += N
	return nodes
