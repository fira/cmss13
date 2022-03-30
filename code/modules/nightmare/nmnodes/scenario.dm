/// Sets a value in scenario variables
/datum/nmnode/def
	id = "def"
	name = "Scenario Def"
	var/pname
	var/pval
/datum/nmnode/def/New(list/spec)
	. = ..()
	pname = spec["param"]
	pval = spec["value"]
	if(islist(pval))
		var/list/pval_list = pval
		pval = pval_list.Copy()
/datum/nmnode/def/Destroy()
	pname = null
	pval = null
	return ..()
/datum/nmnode/def/resolve(datum/nmcontext/context)
	. = ..()
	if(!.) return
	if(context.scenario[pname])
		NMLOG(NM_LOG_WARN, "Definition is redefining parameter '[pname]' !")
	context.scenario[pname] = get_initialization_value()
/datum/nmnode/def/proc/get_initialization_value()
	return pval

/datum/nmnode/def/pick
	id = "def-pick"
/datum/nmnode/def/pick/get_initialization_value()
	return pick(pval)

/datum/nmnode/def/range
	id = "def-range"
/datum/nmnode/def/range/get_initialization_value()
	var/upper = pval[2]
	var/lower = pval[1]
	return lower + round((upper-lower+1) * rand())
