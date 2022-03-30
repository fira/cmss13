/** Simple Nightmare Sequential Scheduler
 * Not actually a scheduler, proxys info from the executor Subsystem
 * that is scheduled by Master Controller, to achieve similar goals.
*/
/datum/nmtask/scheduler
	name = "scheduler"
	/// Queue of tasks still yet to run with status
	var/list/datum/nmtask/tasks = list()
	/// Finished tasks with status
	var/list/datum/nmtask/done = list()
	/// Last return value
	VAR_PROTECTED/last_result = NM_TASK_NONE

/datum/nmtask/scheduler/Destroy()
	tasks = null
	return ..()

/datum/nmtask/scheduler/cleanup()
	tasks = null
	return ..()

/datum/nmtask/scheduler/execute(list/statsmap)
	if(!length(tasks))
		return NM_TASK_OK
	. = NM_TASK_PAUSE
	while(length(tasks) && !TICK_CHECK)
		switch(last_result)
			if(NM_TASK_PAUSE, NM_TASK_ASYNC) // Need to wait for result
				return NM_TASK_PAUSE
			if(NM_TASK_CONTINUE) // Yield execution (or not, or switch task, etc, implem dependant)
				last_result = NM_TASK_NONE
				return NM_TASK_CONTINUE
		last_result = NM_TASK_NONE
		start_task(statsmap)
	if(!length(tasks))
		return NM_TASK_OK
	return NM_TASK_CONTINUE

/// Proxies calls to next subtask
/datum/nmtask/scheduler/proc/start_task(list/statsmap)
	PROTECTED_PROC(TRUE)
	SHOULD_NOT_SLEEP(TRUE)
	var/datum/nmtask/task = tasks[1]
	var/retval = task.invoke(CALLBACK(src, .proc/task_callback, task, statsmap), statsmap)

/// Receives return value for a subtask via callback
/datum/nmtask/scheduler/proc/task_callback(datum/nmtask/task, list/statsmap, retval)
	last_result = retval
	switch(retval)
		if(NM_TASK_ASYNC, NM_TASK_CONTINUE, NM_TASK_PAUSE)
			if(task in tasks)
				tasks[task] = retval
		else
			if(retval == NM_TASK_NONE)
				retval = NM_TASK_ERROR
			tasks -= task
			last_result = NM_TASK_NONE
			done[task] = retval

/datum/nmtask/scheduler/proc/add_task(datum/nmtask/task)
	tasks[task] = NM_TASK_NONE
	return TRUE
