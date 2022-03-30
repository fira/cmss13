/// Toggle for nightmare system
/datum/config_entry/flag/nightmare_enabled
	config_entry_value = TRUE

/// Enables verbose debug messages
/datum/config_entry/flag/nightmare_debug
	config_entry_value = TRUE

/// Relative path for global nightmare scenario
/datum/config_entry/string/nightmare_global_scenario
	config_entry_value = "config/nightmare-scenario.json"

/// Relative path for global nightmare actions
/datum/config_entry/string/nightmare_global_actions
	config_entry_value = "config/nightmare-actions.json"

/// How long before game start to kick off nightmare processing, in seconds
/datum/config_entry/number/nightmare_lobby_init_time
	config_entry_value = 30

/// Timeout after which to give up on nightmare for game start

/datum/config_entry/number/nightmare_timeout
	config_entry_value = 60
