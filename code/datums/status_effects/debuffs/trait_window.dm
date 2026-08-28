/// Sets up a time window during which traits CAN BE applied to the target
/// The traits are applied on/off during the window based on individual
/// instances, but are capped to the window duration and removed when it expires
/datum/status_effect/trait_window
	tick_interval = 0.2 SECONDS
	status_type = STATUS_EFFECT_REPLACE
	/// Traits that will be applied to the target
	var/list/applied_traits
	/// How much duration is stacked to apply the traits within the window
	VAR_PRIVATE/in_window_duration = 0
	/// If we have applied traits to the target
	VAR_PRIVATE/owner_has_traits = FALSE

/datum/status_effect/trait_window/on_creation(mob/living/new_owner, initial_duration)
	. = ..()
	if(. && initial_duration)
		refresh_traits(initial_duration)

/// Returns TRUE if effects stacked in the window go past its end, aka. you can't apply them any more
/datum/status_effect/trait_window/proc/is_overflowing()
	return (in_window_duration >= duration)

/// Refreshes the effect for the given duration
/datum/status_effect/trait_window/proc/refresh_traits(additional_duration)
	if(additional_duration > 0 && in_window_duration < world.time)
		owner?.add_traits(applied_traits, TRAIT_STATUS_EFFECT(id))
		owner_has_traits = TRUE
	// No need to clamp, the effect will be removed when [duration] runs out
	in_window_duration = max(in_window_duration, world.time + additional_duration)

/datum/status_effect/trait_window/tick(seconds_between_ticks)
	. = ..()
	if(owner_has_traits && world.time > in_window_duration)
		owner?.remove_traits(applied_traits, TRAIT_STATUS_EFFECT(id))
		owner_has_traits = FALSE

/datum/status_effect/trait_window/on_remove()
	owner?.remove_traits(applied_traits, TRAIT_STATUS_EFFECT(id))
	return ..()


/// Applied when tackled by a Xeno for up to the given time maximum
/datum/status_effect/trait_window/tackle
	id = "window_tackle"
	remove_on_fullheal = TRUE
	applied_traits = list(TRAIT_FLOORED, TRAIT_INCAPACITATED, TRAIT_IMMOBILIZED)
	duration = 20 SECONDS
