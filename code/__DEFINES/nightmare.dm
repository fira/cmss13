// Status of SSnightmare

/// INIT: Initialisation is in progress
#define NM_STATUS_INIT 1
/// WAIT: Inactive, but not ready yet (early lobby)
#define NM_STATUS_WAIT 2
/// BUSY: Executing main tasks
#define NM_STATUS_BUSY 3
/// READY: Ready for round start
#define NM_STATUS_READY 4
/// ABORT: Something went wrong
#define NM_STATUS_ABORT 5


// Return status of a nmtask

/// NONE: Nightmare task wasn't ran yet
#define NM_TASK_NONE        0
/// ASYNC: Nightmare task is running asynchronously
#define NM_TASK_ASYNC        1
/// SYNC: Nightmare task async call finished synchronously (ie. you probably already have the result)
#define NM_TASK_SYNC         2
/// OK: Nightmare task completed successfully
#define NM_TASK_OK           3
/// ERROR: Nightmare task completed with an error
#define NM_TASK_ERROR        4
/// CONTINUE: Not done yet - Continue the execution when available
#define NM_TASK_CONTINUE     5
/// PAUSE: Not done yet - but force sleep for a moment
#define NM_TASK_PAUSE        6


// Built-in Nightmare contexts

/// Global Nightmare context: Performs any global game setup
#define NM_CTX_GLOBAL "global"
/// Ground Map Context: Performs actions relevant to the ground map
#define NM_CTX_GROUND "ground"
/// Ship Map Context: Performs actions relevant to the ship map
#define NM_CTX_SHIP "ship"


// Built-in Nightmare config names

/// Scenario nightmare configuration: prepare global variables and logic for use by actions
#define NM_ACT_SCENARIO "scenario"
/// Default nightmare actions configuration, performing arbitary actions
#define NM_ACT_DEFAULT "default"


// Log levels for the logging wrapper
/// Log level info: Output to debug log only if nightmare debug is enabled
#define NM_LOG_INFO  0
/// Log level warning: Output to debug all the time
#define NM_LOG_WARN 1
/// Log level crit: Output to debug + send a staff log
#define NM_LOG_CRIT 2

// Relative filenames for Nightmare config

#define NM_FILE_SCENARIO "scenario.json"
#define NM_FILE_BASE "nightmare.json"

/// Log helper for usage in nightmare datums
#define NMLOG(severity, message) SSnightmare.nmlog(severity, message, src.name)
/// Log helper for usage in nihgtmare datums
#define NMDEBUG(message) SSnightmare.nmlog(NM_LOG_INFO, message, src.name)
