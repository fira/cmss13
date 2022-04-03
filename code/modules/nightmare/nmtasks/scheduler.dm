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
				last_result = NM_TASK_NONE // Resume after
				return NM_TASK_CONTINUE
			if(NM_TASK_NONE) // Go to next task
				last_result = NM_TASK_ASYNC // Locking until we get the real result of launching task
				start_task(statsmap)
			else // Anything else is a stop condition
				var/ret = last_result
				if(ret != NM_TASK_OK)
					ret = NM_TASK_ERROR
				var/front = tasks[1]
				tasks -= front
				done[front] = ret
				last_result = NM_TASK_NONE
				log_debug("Sched: Going next task (length=[length(tasks)])")
	if(!length(tasks))
		return NM_TASK_OK

/// Proxies calls to next subtask
/datum/nmtask/scheduler/proc/start_task(list/statsmap)
	PROTECTED_PROC(TRUE)
	SHOULD_NOT_SLEEP(TRUE)
	var/datum/nmtask/task = tasks[1]
	task.invoke(CALLBACK(src, .proc/task_callback, task, statsmap), statsmap)

/// Receives return value for a subtask via callback
/datum/nmtask/scheduler/proc/task_callback(datum/nmtask/task, list/statsmap, retval)
	if(task == tasks[1])
		tasks[task] = retval
		last_result = retval
	else
		CRASH("Something went wrong in nmtask/scheduler, possible out of order execution")

/datum/nmtask/scheduler/proc/add_task(datum/nmtask/task)
	tasks[task] = NM_TASK_NONE
	return TRUE
