GLOBAL_LIST_INIT(bitfields, generate_bitfields())

/// Specifies a bitfield for smarter debugging
/datum/bitfield
	/// The variable name that contains the bitfield
	var/variable

	/// An associative list of the readable flag and its true value
	var/list/flags

/// Turns /datum/bitfield subtypes into a list for use in debugging
/proc/generate_bitfields()
	var/list/bitfields = list()
	for (var/_bitfield in subtypesof(/datum/bitfield))
		var/datum/bitfield/bitfield = new _bitfield
		bitfields[bitfield.variable] = bitfield.flags
	return bitfields

DEFINE_BITFIELD(rights, list(
	"BUILDMODE" = R_BUILDMODE,
	"ADMIN" = R_ADMIN,
	"BAN" = R_BAN,
	"SERVER" = R_SERVER,
	"DEBUG" = R_DEBUG,
	"POSSESS" = R_POSSESS,
	"PERMISSIONS" = R_PERMISSIONS,
	"STEALTH" = R_STEALTH,
	"COLOR" = R_COLOR,
	"VAREDIT" = R_VAREDIT,
	"SOUNDS" = R_SOUNDS,
	"SPAWN" = R_SPAWN,
	"MOD" = R_MOD,
	"MENTOR" = R_MENTOR,
	"HOST" = R_HOST,
	"PROFILER" = R_PROFILER,
	"NOLOCK" = R_NOLOCK,
	"EVENT" = R_EVENT,
))

DEFINE_BITFIELD(appearance_flags, list(
	"KEEP_APART" = KEEP_APART,
	"KEEP_TOGETHER" = KEEP_TOGETHER,
	"LONG_GLIDE" = LONG_GLIDE,
	"NO_CLIENT_COLOR" = NO_CLIENT_COLOR,
	"PIXEL_SCALE" = PIXEL_SCALE,
	"PLANE_MASTER" = PLANE_MASTER,
	"RESET_ALPHA" = RESET_ALPHA,
	"RESET_COLOR" = RESET_COLOR,
	"RESET_TRANSFORM" = RESET_TRANSFORM,
	"TILE_BOUND" = TILE_BOUND,
	"PASS_MOUSE" = PASS_MOUSE,
	"TILE_MOVER" = TILE_MOVER,
))

DEFINE_BITFIELD(blood_flags, list(
	"BLOOD_BODY" = BLOOD_BODY,
	"BLOOD_HANDS" = BLOOD_HANDS,
	"BLOOD_FEET" = BLOOD_FEET,
))

DEFINE_BITFIELD(flags_gun_lever_action, list(
	"USES_STREAKS" = USES_STREAKS,
	"DANGEROUS_TO_ONEHAND_LEVER" = DANGEROUS_TO_ONEHAND_LEVER,
	"MOVES_WHEN_LEVERING" = MOVES_WHEN_LEVERING,
))

// chem_effect_flags
DEFINE_BITFIELD(chem_effect_flags, list(
	"CHEM_EFFECT_RESIST_FRACTURE" = CHEM_EFFECT_RESIST_FRACTURE,
	"CHEM_EFFECT_RESIST_NEURO" = CHEM_EFFECT_RESIST_NEURO,
	"CHEM_EFFECT_HYPER_THROTTLE" = CHEM_EFFECT_HYPER_THROTTLE,
	"CHEM_EFFECT_ORGAN_STASIS" = CHEM_EFFECT_ORGAN_STASIS,
	"CHEM_EFFECT_NO_BLEEDING" = CHEM_EFFECT_NO_BLEEDING,
))

DEFINE_BITFIELD(flags_ammo_behaviour, list(
	"AMMO_EXPLOSIVE" = AMMO_EXPLOSIVE,
	"AMMO_ACIDIC" = AMMO_ACIDIC,
	"AMMO_XENO" = AMMO_XENO,
	"AMMO_LASER" = AMMO_LASER,
	"AMMO_ENERGY" = AMMO_ENERGY,
	"AMMO_ROCKET" = AMMO_ROCKET,
	"AMMO_SNIPER" = AMMO_SNIPER,
	"AMMO_ANTISTRUCT" = AMMO_ANTISTRUCT,
	"AMMO_SKIPS_ALIENS" = AMMO_SKIPS_ALIENS,
	"AMMO_IGNORE_ARMOR" = AMMO_IGNORE_ARMOR,
	"AMMO_IGNORE_RESIST" = AMMO_IGNORE_RESIST,
	"AMMO_BALLISTIC" = AMMO_BALLISTIC,
	"AMMO_IGNORE_COVER" = AMMO_IGNORE_COVER,
	"AMMO_STOPPED_BY_COVER" = AMMO_STOPPED_BY_COVER,
	"AMMO_SPECIAL_EMBED" = AMMO_SPECIAL_EMBED,
	"AMMO_STRIKES_SURFACE" = AMMO_STRIKES_SURFACE,
	"AMMO_HITS_TARGET_TURF" = AMMO_HITS_TARGET_TURF,
	"AMMO_ALWAYS_FF" = AMMO_ALWAYS_FF,
	"AMMO_NO_DEFLECT" = AMMO_NO_DEFLECT,
	"AMMO_MP" = AMMO_MP,
	"AMMO_FLAME" = AMMO_FLAME,
))


DEFINE_BITFIELD(projectile_flags, list(
	"PROJECTILE_SHRAPNEL" = PROJECTILE_SHRAPNEL,
	"PROJECTILE_BULLSEYE" = PROJECTILE_BULLSEYE,
))

DEFINE_BITFIELD(flags_gun_features, list(
	"GUN_CAN_POINTBLANK" = GUN_CAN_POINTBLANK,
	"GUN_TRIGGER_SAFETY" = GUN_TRIGGER_SAFETY,
	"GUN_UNUSUAL_DESIGN" = GUN_UNUSUAL_DESIGN,
	"GUN_SILENCED" = GUN_SILENCED,
	"GUN_INTERNAL_MAG" = GUN_INTERNAL_MAG,
	"GUN_AUTO_EJECTOR" = GUN_AUTO_EJECTOR,
	"GUN_AMMO_COUNTER" = GUN_AMMO_COUNTER,
	"GUN_BURST_FIRING" = GUN_BURST_FIRING,
	"GUN_FLASHLIGHT_ON" = GUN_FLASHLIGHT_ON,
	"GUN_WY_RESTRICTED" = GUN_WY_RESTRICTED,
	"GUN_SPECIALIST" = GUN_SPECIALIST,
	"GUN_WIELDED_FIRING_ONLY" = GUN_WIELDED_FIRING_ONLY,
	"GUN_ONE_HAND_WIELDED" = GUN_ONE_HAND_WIELDED,
	"GUN_ANTIQUE" = GUN_ANTIQUE,
	"GUN_RECOIL_BUILDUP" = GUN_RECOIL_BUILDUP,
	"GUN_SUPPORT_PLATFORM" = GUN_SUPPORT_PLATFORM,
))

DEFINE_BITFIELD(flags_magazine, list(
	"AMMUNITION_REFILLABLE" = AMMUNITION_REFILLABLE,
	"AMMUNITION_HANDFUL" = AMMUNITION_HANDFUL,
	"AMMUNITION_HANDFUL_BOX" = AMMUNITION_HANDFUL_BOX,
	"AMMUNITION_HIDE_AMMO" = AMMUNITION_HIDE_AMMO,
	"AMMUNITION_CANNOT_REMOVE_BULLETS" = AMMUNITION_CANNOT_REMOVE_BULLETS,
	"AMMUNITION_SLAP_TRANSFER" = AMMUNITION_SLAP_TRANSFER,
))

DEFINE_BITFIELD(flags_atom, list(
	"NOINTERACT" = NOINTERACT,
	"FPRINT" = FPRINT,
	"CONDUCT" = CONDUCT,
	"ON_BORDER" = ON_BORDER,
	"NOBLOODY" = NOBLOODY,
	"DIRLOCK" = DIRLOCK,
	"NOREACT" = NOREACT,
	"OPENCONTAINER" = OPENCONTAINER,
	"RELAY_CLICK" = RELAY_CLICK,
	"ITEM_UNCATCHABLE" = ITEM_UNCATCHABLE,
	"NO_NAME_OVERRIDE" = NO_NAME_OVERRIDE,
	"NO_SNOW_TYPE" = NO_SNOW_TYPE,
	"INVULNERABLE" = INVULNERABLE,
	"CAN_BE_SYRINGED" = CAN_BE_SYRINGED,
	"CAN_BE_DISPENSED_INTO" = CAN_BE_DISPENSED_INTO,
	"INITIALIZED" = INITIALIZED,
	"ATOM_DECORATED" = ATOM_DECORATED,
	"USES_HEARING" = USES_HEARING,
))

DEFINE_BITFIELD(flags_item, list(
	"NODROP" = NODROP,
	"NOBLUDGEON" = NOBLUDGEON,
	"NOSHIELD" = NOSHIELD,
	"DELONDROP" = DELONDROP,
	"TWOHANDED" = TWOHANDED,
	"WIELDED" = WIELDED,
	"ITEM_ABSTRACT" = ITEM_ABSTRACT,
	"ITEM_PREDATOR" = ITEM_PREDATOR,
	"MOB_LOCK_ON_EQUIP" = MOB_LOCK_ON_EQUIP,
	"NO_CRYO_STORE" = NO_CRYO_STORE,
	"ITEM_OVERRIDE_NORTHFACE" = ITEM_OVERRIDE_NORTHFACE,
	"CAN_DIG_SHRAPNEL" = CAN_DIG_SHRAPNEL,
	"ANIMATED_SURGICAL_TOOL" = ANIMATED_SURGICAL_TOOL,
	"IGNITING_ITEM" = IGNITING_ITEM,
))

DEFINE_BITFIELD(flags_inv_hide, list(
	"HIDEGLOVES" = HIDEGLOVES,
	"HIDESUITSTORAGE" = HIDESUITSTORAGE,
	"HIDEJUMPSUIT" = HIDEJUMPSUIT,
	"HIDESHOES" = HIDESHOES,
	"HIDEMASK" = HIDEMASK,
	"HIDEEARS" = HIDEEARS,
	"HIDEEYES" = HIDEEYES,
	"HIDELOWHAIR" = HIDELOWHAIR,
	"HIDETOPHAIR" = HIDETOPHAIR,
	"HIDEALLHAIR" = HIDEALLHAIR,
	"HIDETAIL" = HIDETAIL,
	"HIDEFACE" = HIDEFACE
))

DEFINE_BITFIELD(flags_inventory, list(
	"CANTSTRIP" = CANTSTRIP,
	"NOSLIPPING" = NOSLIPPING,
	"COVEREYES" = COVEREYES,
	"COVERMOUTH" = COVERMOUTH,
	"ALLOWINTERNALS" = ALLOWINTERNALS,
	"ALLOWREBREATH" = ALLOWREBREATH,
	"BLOCKGASEFFECT" = BLOCKGASEFFECT,
	"ALLOWCPR" = ALLOWCPR,
	"FULL_DECAP_PROTECTION" = FULL_DECAP_PROTECTION,
	"BLOCKSHARPOBJ" = BLOCKSHARPOBJ,
	"NOPRESSUREDMAGE" = NOPRESSUREDMAGE,
	"BLOCK_KNOCKDOWN" = BLOCK_KNOCKDOWN,
	"SMARTGUN_HARNESS" = SMARTGUN_HARNESS,
))

DEFINE_BITFIELD(flags_jumpsuit, list(
	"UNIFORM_SLEEVE_ROLLABLE" = UNIFORM_SLEEVE_ROLLABLE,
	"UNIFORM_SLEEVE_ROLLED" = UNIFORM_SLEEVE_ROLLED,
	"UNIFORM_SLEEVE_CUTTABLE" = UNIFORM_SLEEVE_CUTTABLE,
	"UNIFORM_SLEEVE_CUT" = UNIFORM_SLEEVE_CUT,
	"UNIFORM_JACKET_REMOVABLE" = UNIFORM_JACKET_REMOVABLE,
	"UNIFORM_JACKET_REMOVED" = UNIFORM_JACKET_REMOVED,
	"UNIFORM_DO_NOT_HIDE_ACCESSORIES" = UNIFORM_DO_NOT_HIDE_ACCESSORIES,
))

DEFINE_BITFIELD(flags_marine_armor, list(
	"ARMOR_SQUAD_OVERLAY" = ARMOR_SQUAD_OVERLAY,
	"ARMOR_LAMP_OVERLAY" = ARMOR_LAMP_OVERLAY,
	"ARMOR_LAMP_ON" = ARMOR_LAMP_ON,
	"ARMOR_IS_REINFORCED" = ARMOR_IS_REINFORCED,
	"SYNTH_ALLOWED" = SYNTH_ALLOWED,
))

DEFINE_BITFIELD(flags_marine_helmet, list(
	"HELMET_SQUAD_OVERLAY" = HELMET_SQUAD_OVERLAY,
	"HELMET_GARB_OVERLAY" = HELMET_GARB_OVERLAY,
	"HELMET_DAMAGE_OVERLAY" = HELMET_DAMAGE_OVERLAY,
	"HELMET_IS_DAMAGED" = HELMET_IS_DAMAGED,
))

DEFINE_BITFIELD(flags_marine_hat, list(
	"HAT_GARB_OVERLAY" = HAT_GARB_OVERLAY,
	"HAT_CAN_FLIP" = HAT_CAN_FLIP,
	"HAT_FLIPPED" = HAT_FLIPPED,
))

DEFINE_BITFIELD(valid_equip_slots, list(
	"SLOT_OCLOTHING" = SLOT_OCLOTHING,
	"SLOT_ICLOTHING" = SLOT_ICLOTHING,
	"SLOT_HANDS" = SLOT_HANDS,
	"SLOT_EYES" = SLOT_EYES,
	"SLOT_EAR" = SLOT_EAR,
	"SLOT_FACE" = SLOT_FACE,
	"SLOT_HEAD" = SLOT_HEAD,
	"SLOT_FEET" = SLOT_FEET,
	"SLOT_ID" = SLOT_ID,
	"SLOT_WAIST" = SLOT_WAIST,
	"SLOT_BACK" = SLOT_BACK,
	"SLOT_STORE" = SLOT_STORE,
	"SLOT_NO_STORE" = SLOT_NO_STORE,
	"SLOT_LEGS" = SLOT_LEGS,
	"SLOT_ACCESSORY" = SLOT_ACCESSORY,
	"SLOT_SUIT_STORE" = SLOT_SUIT_STORE,
	"SLOT_BLOCK_SUIT_STORE" = SLOT_BLOCK_SUIT_STORE,
))

DEFINE_BITFIELD(flags_alarm_state, list(
	"ALARM_WARNING_FIRE" = ALARM_WARNING_FIRE,
	"ALARM_WARNING_ATMOS" = ALARM_WARNING_ATMOS,
	"ALARM_WARNING_EVAC" = ALARM_WARNING_EVAC,
	"ALARM_WARNING_READY" = ALARM_WARNING_READY,
	"ALARM_WARNING_DOWN" = ALARM_WARNING_DOWN,
	"ALARM_LOCKDOWN" = ALARM_LOCKDOWN,
))

DEFINE_BITFIELD(flags_armor_protection, list(
	"BODY_FLAG_NO_BODY" = BODY_FLAG_NO_BODY,
	"BODY_FLAG_HEAD" = BODY_FLAG_HEAD,
	"BODY_FLAG_FACE" = BODY_FLAG_FACE,
	"BODY_FLAG_EYES" = BODY_FLAG_EYES,
	"BODY_FLAG_CHEST" = BODY_FLAG_CHEST,
	"BODY_FLAG_GROIN" = BODY_FLAG_GROIN,
	"BODY_FLAG_LEG_LEFT" = BODY_FLAG_LEG_LEFT,
	"BODY_FLAG_LEG_RIGHT" = BODY_FLAG_LEG_RIGHT,
	"BODY_FLAG_FOOT_LEFT" = BODY_FLAG_FOOT_LEFT,
	"BODY_FLAG_FOOT_RIGHT" = BODY_FLAG_FOOT_RIGHT,
	"BODY_FLAG_ARM_LEFT" = BODY_FLAG_ARM_LEFT,
	"BODY_FLAG_ARM_RIGHT" = BODY_FLAG_ARM_RIGHT,
	"BODY_FLAG_HAND_LEFT" = BODY_FLAG_HAND_LEFT,
	"BODY_FLAG_HAND_RIGHT" = BODY_FLAG_HAND_RIGHT,
))

// storage_flags
DEFINE_BITFIELD(storage_flags, list(
	"STORAGE_ALLOW_EMPTY" = STORAGE_ALLOW_EMPTY,
	"STORAGE_QUICK_EMPTY" = STORAGE_QUICK_EMPTY,
	"STORAGE_QUICK_GATHER" = STORAGE_QUICK_GATHER,
	"STORAGE_ALLOW_DRAWING_METHOD_TOGGLE" = STORAGE_ALLOW_DRAWING_METHOD_TOGGLE,
	"STORAGE_USING_DRAWING_METHOD" = STORAGE_USING_DRAWING_METHOD,
	"STORAGE_USING_FIFO_DRAWING" = STORAGE_USING_FIFO_DRAWING,
	"STORAGE_CLICK_EMPTY" = STORAGE_CLICK_EMPTY,
	"STORAGE_CLICK_GATHER" = STORAGE_CLICK_GATHER,
	"STORAGE_SHOW_FULLNESS" = STORAGE_SHOW_FULLNESS,
	"STORAGE_CONTENT_NUM_DISPLAY" = STORAGE_CONTENT_NUM_DISPLAY,
	"STORAGE_GATHER_SIMULTAENOUSLY" = STORAGE_GATHER_SIMULTAENOUSLY,
	"STORAGE_ALLOW_QUICKDRAW" = STORAGE_ALLOW_QUICKDRAW,
))

DEFINE_BITFIELD(datum_flags, list(
	"DF_USE_TAG" = DF_USE_TAG,
	"DF_VAR_EDITED" = DF_VAR_EDITED,
	"DF_ISPROCESSING" = DF_ISPROCESSING,
))

DEFINE_BITFIELD(status, list(
	"LIMB_ORGANIC" = LIMB_ORGANIC,
	"LIMB_ROBOT" = LIMB_ROBOT,
	"LIMB_SYNTHSKIN" = LIMB_SYNTHSKIN,
	"LIMB_BROKEN" = LIMB_BROKEN,
	"LIMB_DESTROYED" = LIMB_DESTROYED,
	"LIMB_SPLINTED" = LIMB_SPLINTED,
	"LIMB_MUTATED" = LIMB_MUTATED,
	"LIMB_AMPUTATED" = LIMB_AMPUTATED,
	"LIMB_SPLINTED_INDESTRUCTIBLE" = LIMB_SPLINTED_INDESTRUCTIBLE,
	"LIMB_UNCALIBRATED_PROSTHETIC" = LIMB_UNCALIBRATED_PROSTHETIC,
))

DEFINE_BITFIELD(added_sutures, list(
	"SUTURED" = SUTURED,
	"SUTURED_FULLY" = SUTURED_FULLY,
))

DEFINE_BITFIELD(flags_area, list(
	"AREA_AVOID_BIOSCAN" = AREA_AVOID_BIOSCAN,
	"AREA_NOTUNNEL" = AREA_NOTUNNEL,
	"AREA_ALLOW_XENO_JOIN" = AREA_ALLOW_XENO_JOIN,
	"AREA_CONTAINMENT" = AREA_CONTAINMENT,
	"ARES_UNWEEDABLE" = AREA_UNWEEDABLE,
))

DEFINE_BITFIELD(disabilities, list(
	"NEARSIGHTED" = NEARSIGHTED,
	"EPILEPSY" = EPILEPSY,
	"COUGHING" = COUGHING,
	"TOURETTES" = TOURETTES,
	"NERVOUS" = NERVOUS,
	"OPIATE_RECEPTOR_DEFICIENCY" = OPIATE_RECEPTOR_DEFICIENCY,
))

DEFINE_BITFIELD(sdisabilities, list(
	"DISABILITY_BLIND" = DISABILITY_BLIND,
	"DISABILITY_MUTE" = DISABILITY_MUTE,
	"DISABILITY_DEAF" = DISABILITY_DEAF,
))

// status_flags
DEFINE_BITFIELD(status_flags, list(
	"CANSTUN" = CANSTUN,
	"CANKNOCKDOWN" = CANKNOCKDOWN,
	"CANKNOCKOUT" = CANKNOCKOUT,
	"CANPUSH" = CANPUSH,
	"LEAPING" = LEAPING,
	"PASSEMOTES" = PASSEMOTES,
	"GODMODE" = GODMODE,
	"FAKEDEATH" = FAKEDEATH,
	"DISFIGURED" = DISFIGURED,
	"XENO_HOST" = XENO_HOST,
	"IMMOBILE_ACTION" = IMMOBILE_ACTION,
	"PERMANENTLY_DEAD" = PERMANENTLY_DEAD,
	"CANDAZE" = CANDAZE,
	"CANSLOW" = CANSLOW,
	"NO_PERMANENT_DAMAGE" = NO_PERMANENT_DAMAGE,
))

DEFINE_BITFIELD(mob_flags, list(
	"KNOWS_TECHNOLOGY" = KNOWS_TECHNOLOGY,
	"SQUEEZE_UNDER_VEHICLES" = SQUEEZE_UNDER_VEHICLES,
	"EASY_SURGERY" = EASY_SURGERY,
	"SURGERY_MODE_ON" = SURGERY_MODE_ON,
	"MUTINEER" = MUTINEER,
	"GIVING" = GIVING,
	"NOBIOSCAN" = NOBIOSCAN,
))

DEFINE_BITFIELD(mobility_flags, list(
	"MOVE" = MOBILITY_MOVE,
	"STAND" = MOBILITY_STAND,
	"REST" = MOBILITY_REST,
	"LIEDOWN" = MOBILITY_LIEDOWN
))

DEFINE_BITFIELD(flags, list(
	"NO_BLOOD" = NO_BLOOD,
	"NO_BREATHE" = NO_BREATHE,
	"NO_CLONE_LOSS" = NO_CLONE_LOSS,
	"NO_SLIP" = NO_SLIP,
	"NO_POISON" = NO_POISON,
	"NO_CHEM_METABOLIZATION" = NO_CHEM_METABOLIZATION,
	"HAS_SKIN_TONE" = HAS_SKIN_TONE,
	"HAS_SKIN_COLOR" = HAS_SKIN_COLOR,
	"HAS_LIPS" = HAS_LIPS,
	"HAS_UNDERWEAR" = HAS_UNDERWEAR,
	"IS_WHITELISTED" = IS_WHITELISTED,
	"IS_SYNTHETIC" = IS_SYNTHETIC,
	"NO_NEURO" = NO_NEURO,
	"SPECIAL_BONEBREAK" = SPECIAL_BONEBREAK,
	"NO_SHRAPNEL" = NO_SHRAPNEL,
	"HAS_HARDCRIT" = HAS_HARDCRIT,
))

DEFINE_BITFIELD(flags_round_type, list(
	"MODE_INFESTATION" = MODE_INFESTATION,
	"MODE_PREDATOR" = MODE_PREDATOR,
	"MODE_NO_LATEJOIN" = MODE_NO_LATEJOIN,
	"MODE_HAS_FINISHED" = MODE_HAS_FINISHED,
	"MODE_FOG_ACTIVATED" = MODE_FOG_ACTIVATED,
	"MODE_INFECTION" = MODE_INFECTION,
	"MODE_HUMAN_ANTAGS" = MODE_HUMAN_ANTAGS,
	"MODE_NO_SPAWN" = MODE_NO_SPAWN,
	"MODE_XVX" = MODE_XVX,
	"MODE_NEW_SPAWN" = MODE_NEW_SPAWN,
	"MODE_DS_LANDED" = MODE_DS_LANDED,
	"MODE_BASIC_RT" = MODE_BASIC_RT,
	"MODE_RANDOM_HIVE" = MODE_RANDOM_HIVE,
	"MODE_THUNDERSTORM" = MODE_THUNDERSTORM,
	"MODE_FACTION_CLASH" = MODE_FACTION_CLASH,
))

DEFINE_BITFIELD(toggleable_flags, list(
	"MODE_NO_SNIPER_SENTRY" = MODE_NO_SNIPER_SENTRY,
	"MODE_NO_ATTACK_DEAD" = MODE_NO_ATTACK_DEAD,
	"MODE_NO_STRIPDRAG_ENEMY" = MODE_NO_STRIPDRAG_ENEMY,
	"MODE_STRIP_NONUNIFORM_ENEMY" = MODE_STRIP_NONUNIFORM_ENEMY,
	"MODE_STRONG_DEFIBS" = MODE_STRONG_DEFIBS,
	"MODE_BLOOD_OPTIMIZATION" = MODE_BLOOD_OPTIMIZATION,
	"MODE_NO_COMBAT_CAS" = MODE_NO_COMBAT_CAS,
	"MODE_LZ_PROTECTION" = MODE_LZ_PROTECTION,
	"MODE_SHIPSIDE_SD" = MODE_SHIPSIDE_SD,
	"MODE_DISPOSABLE_MOBS" = MODE_DISPOSABLE_MOBS,
	"MODE_BYPASS_JOE" = MODE_BYPASS_JOE,
))

DEFINE_BITFIELD(state, list(
	"OBJECTIVE_INACTIVE" = OBJECTIVE_INACTIVE,
	"OBJECTIVE_ACTIVE" = OBJECTIVE_ACTIVE,
	"OBJECTIVE_COMPLETE" = OBJECTIVE_COMPLETE,
))

DEFINE_BITFIELD(objective_flags, list(
	"OBJECTIVE_DO_NOT_TREE" = OBJECTIVE_DO_NOT_TREE,
	"OBJECTIVE_DEAD_END" = OBJECTIVE_DEAD_END,
	"OBJECTIVE_START_PROCESSING_ON_DISCOVERY" = OBJECTIVE_START_PROCESSING_ON_DISCOVERY,
))

DEFINE_BITFIELD(flags_obj, list(
	"OBJ_ORGANIC" = OBJ_ORGANIC,
	"OBJ_NO_HELMET_BAND" = OBJ_NO_HELMET_BAND,
	"OBJ_IS_HELMET_GARB" = OBJ_IS_HELMET_GARB,
	"OBJ_UNIQUE_RENAME" = OBJ_UNIQUE_RENAME,
))

DEFINE_BITFIELD(tool_flags, list(
	"REMOVE_CROWBAR" = REMOVE_CROWBAR,
	"BREAK_CROWBAR" = BREAK_CROWBAR,
	"REMOVE_SCREWDRIVER" = REMOVE_SCREWDRIVER,
))

DEFINE_BITFIELD(fire_immunity, list(
	"FIRE_IMMUNITY_NO_DAMAGE" = FIRE_IMMUNITY_NO_DAMAGE,
	"FIRE_IMMUNITY_NO_IGNITE" = FIRE_IMMUNITY_NO_IGNITE,
	"FIRE_IMMUNITY_XENO_FRENZY" = FIRE_IMMUNITY_XENO_FRENZY,
))
DEFINE_BITFIELD(vend_flags, list(
	"VEND_TO_HAND" = VEND_TO_HAND,
	"VEND_UNIFORM_RANKS" = VEND_UNIFORM_RANKS,
	"VEND_UNIFORM_AUTOEQUIP" = VEND_UNIFORM_AUTOEQUIP,
	"VEND_LIMITED_INVENTORY" = VEND_LIMITED_INVENTORY,
	"VEND_CLUTTER_PROTECTION" = VEND_CLUTTER_PROTECTION,
	"VEND_CATEGORY_CHECK" = VEND_CATEGORY_CHECK,
	"VEND_INSTANCED_CATEGORY" = VEND_INSTANCED_CATEGORY,
	"VEND_FACTION_THEMES" = VEND_FACTION_THEMES,
	"VEND_USE_VENDOR_FLAGS" = VEND_USE_VENDOR_FLAGS,
))
