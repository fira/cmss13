/// Nightmare task, executing code within a nightmare context
/datum/nmtask
	/// Task name
	var/name = "abstract task"

/datum/nmtask/New(name)
	. = ..()
	if(name)
		src.name = name

/datum/nmtask/Destroy()
	cleanup()
	return ..()

/// Free resources used by the task and its state, without deleting it
/datum/nmtask/proc/cleanup()
	return

/// Task implementation
/datum/nmtask/proc/execute(list/statsmap)
	PROTECTED_PROC(TRUE)
	return NM_TASK_OK

/// Wrapper Invoking the task synchronously while reporting if task is actually ran async
/datum/nmtask/proc/invoke_sync(list/statsmap = list())
	PRIVATE_PROC(TRUE)
	. = NM_TASK_ASYNC
	. = execute(statsmap)
	if(. == NM_TASK_ASYNC)
		. = NM_TASK_ERROR
	switch(.)
		if(NM_TASK_OK)
			LAZYINC(statsmap, "tasks_ok", 1)
		if(NM_TASK_CONTINUE, NM_TASK_PAUSE)
			return
		else
			LAZYINC(statsmap, "tasks_err", 1)

/// Wrapper to invoke the task asynchronously, reporting result by callback
/datum/nmtask/proc/invoke(datum/callback/async_callback, list/statsmap)
	set waitfor = FALSE
	. = wrap_async(async_callback, statsmap)

/// Internal Wrapper for asynchronous call
/datum/nmtask/proc/wrap_async(datum/callback/async_callback, list/statsmap)
	PRIVATE_PROC(TRUE)
	. = NM_TASK_ASYNC
	var/retval = invoke_sync(statsmap)
	// NM_TASK_SYNC is important here to report on ordering
	// if the task executes async, this returns, then the callback is invoked
	// if the task executes sync, the callback has -already- been invoked when this returns
	if(async_callback)
		. = NM_TASK_SYNC
		async_callback.Invoke(retval)
		return
	return retval
