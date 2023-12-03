/*!
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/client/var/datum/tgui_panel/tgui_panel

/**
 * tgui panel / chat troubleshooting verb
 */
/client/verb/fix_tgui_panel()
	set name = "Fix chat"
	set category = "OOC.Fix"
	var/action
	log_tgui(src, "Started fixing.", context = "verb/fix_tgui_panel")

	nuke_chat()

	// Failed to fix
	action = alert(src, "Did that work?", "", "Yes", "No, switch to old ui")
	if (action == "No, switch to old ui")
		winset(src, "output", "on-show=&is-disabled=0&is-visible=1")
		winset(src, "browseroutput", "is-disabled=1;is-visible=0")
		log_tgui(src, "Failed to fix.", context = "verb/fix_tgui_panel")

/client/verb/bounce_tgui_message(message as text)
	set name = "Bounce"
	log_debug("at [world.time] : [message]")
	log_debug("[world.time] | browseroutput is-visible: [winget(src, "browseroutput", "is-visible")]")
	log_debug("[world.time] | browseroutput is-disabled: [winget(src, "browseroutput", "is-disabled")]")
	log_debug("[world.time] | output is-visible: [winget(src, "output", "is-visible")]")
	log_debug("[world.time] | output is-disabled: [winget(src, "output", "is-disabled")]")
	log_debug("[world.time] | output size: [winget(src, "output", "size")]")

/client/verb/zzA1(text as text)
	set name = "zzSet Disabled Output"
	winset(src, "output", "is-disabled=[text]")
	bounce_tgui_message("setting output.is-disabled=[text]")
/client/verb/zzA2(text as text)
	set name = "zzSet Visible Output"
	winset(src, "output", "is-visible=[text]")
	bounce_tgui_message("setting output.is-visible=[text]")
/client/verb/zzB1(text as text)
	set name = "zzSet Disabled Browseroutput"
	winset(src, "browseroutput", "is-disabled=[text]")
	bounce_tgui_message("setting browseroutput.is-disabled=[text]")
/client/verb/zzB2(text as text)
	set name = "zzSet Visible Browseroutput"
	winset(src, "browseroutput", "is-visible=[text]")
	bounce_tgui_message("setting browseroutput.is-visible=[text]")
/client/verb/zzB3(text as text)
	set name = "zzSet Size Browseroutput"
	winset(src, "browseroutput", "size=[text]")
	bounce_tgui_message("setting browseroutput.size=[text]")

/client/verb/switch_to_output()
	set name = "Switch Output"
	winset(src, "output", "on-show=&is-disabled=0&is-visible=1")
	winset(src, "browseroutput", "is-disabled=1;is-visible=0")
	bounce_tgui_message("After siwtching to output")

/client/proc/nuke_chat()
	// Catch all solution (kick the whole thing in the pants)
	winset(src, "output", "on-show=&is-disabled=0&is-visible=1")
	winset(src, "browseroutput", "is-disabled=1;is-visible=0")
	if(!tgui_panel || !istype(tgui_panel))
		log_tgui(src, "tgui_panel datum is missing",
			context = "verb/fix_tgui_panel")
		tgui_panel = new(src)
	tgui_panel.initialize(force = TRUE)
	// Force show the panel to see if there are any errors
	winset(src, "output", "is-disabled=1&is-visible=0")
	winset(src, "browseroutput", "is-disabled=0;is-visible=1")

/client/verb/refresh_tgui()
	set name = "Refresh TGUI"
	set category = "OOC.Fix"

	for(var/window_id in tgui_windows)
		var/datum/tgui_window/window = tgui_windows[window_id]
		window.reinitialize()
