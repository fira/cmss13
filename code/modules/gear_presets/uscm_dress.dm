/datum/equipment_preset/uscm_event/dress
	name = "Dress Blues - (E-2) Private First Class"
	flags = EQUIPMENT_PRESET_EXTRA
	assignment = JOB_MARINE
	rank = JOB_MARINE
	access = list(ACCESS_MARINE_PREP)
	minimum_age = 18
	paygrade = PAY_SHORT_ME2
	role_comm_title = "Mar"
	skills = /datum/skills/pfc

	dress_under = list(/obj/item/clothing/under/marine/dress/blues)
	dress_over = list(/obj/item/clothing/suit/storage/jacket/marine/dress/blues)
	dress_hat = list(/obj/item/clothing/head/marine/dress_cover)
	dress_gloves = list(/obj/item/clothing/gloves/marine/dress)
	dress_shoes = list(/obj/item/clothing/shoes/dress)

/datum/equipment_preset/uscm_event/dress/load_gear(mob/living/carbon/human/new_human)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/dress/blues(new_human), WEAR_BODY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/dress(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/dress(new_human), WEAR_HANDS)
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer(new_human), WEAR_L_EAR)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/marine/dress_cover(new_human), WEAR_HEAD)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/jacket/marine/dress/blues(new_human), WEAR_JACKET)

/datum/equipment_preset/uscm_event/dress/lcpl
	name = "Dress Blues - (E-3) Lance Corporal"
	paygrade = PAY_SHORT_ME3

//NCOs/SNCOs//

/datum/equipment_preset/uscm_event/dress/nco
	name = "Dress Blues - (E-4) Corporal"
	paygrade = PAY_SHORT_ME4
	skills = /datum/skills/SL

	dress_under = list(/obj/item/clothing/under/marine/dress/blues/senior)
	dress_over = list(/obj/item/clothing/suit/storage/jacket/marine/dress/blues/nco)

/datum/equipment_preset/uscm_event/dress/nco/load_gear(mob/living/carbon/human/new_human)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/dress/blues/senior(new_human), WEAR_BODY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/jacket/marine/dress/blues/nco(new_human), WEAR_JACKET)
	. = ..()

/datum/equipment_preset/uscm_event/dress/nco/sgt
	name = "Dress Blues - (E-5) Sergeant"
	paygrade = PAY_SHORT_ME5

/datum/equipment_preset/uscm_event/dress/nco/snco
	name = "Dress Blues - (E-6) Staff Sergeant"
	paygrade = PAY_SHORT_ME6
	skills = /datum/skills/SEA
	access = list(ACCESS_MARINE_COMMAND, ACCESS_MARINE_DROPSHIP)

/datum/equipment_preset/uscm_event/dress/nco/snco/load_gear(mob/living/carbon/human/new_human)
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/mcom(new_human), WEAR_L_EAR)
	. = ..()

/datum/equipment_preset/uscm_event/dress/nco/snco/gysgt
	name = "Dress Blues - (E-7) Gunnery Sergeant"
	paygrade = PAY_SHORT_ME7

/datum/equipment_preset/uscm_event/dress/nco/snco/msgt
	name = "Dress Blues - (E-8) Master Sergeant"
	paygrade = PAY_SHORT_ME8

/datum/equipment_preset/uscm_event/dress/nco/snco/firstsgt
	name = "Dress Blues - (E-8E) First Sergeant"
	paygrade = PAY_SHORT_ME8E

/datum/equipment_preset/uscm_event/dress/nco/snco/mgysgt
	name = "Dress Blues - (E-9) Master Gunnery Sergeant"
	paygrade = PAY_SHORT_ME9

/datum/equipment_preset/uscm_event/dress/nco/snco/sgtmaj
	name = "Dress Blues - (E-9E) Sergeant Major"
	paygrade = PAY_SHORT_ME9E

//FIELD OFFICERS//

/datum/equipment_preset/uscm_event/dress/officer
	name = "Dress Blues - (O-1) 2nd Lieutenant"
	paygrade = PAY_SHORT_MO1
	idtype = /obj/item/card/id/silver
	skills = /datum/skills/SO
	access = list(ACCESS_MARINE_COMMAND, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_DATABASE, ACCESS_MARINE_MEDBAY)

	dress_under = list(/obj/item/clothing/under/marine/dress/blues/senior)
	dress_over = list(/obj/item/clothing/suit/storage/jacket/marine/dress/blues/officer)
	dress_hat = list(/obj/item/clothing/head/marine/dress_cover/officer)
	dress_gloves = list(/obj/item/clothing/gloves/marine/dress)
	dress_shoes = list(/obj/item/clothing/shoes/dress)

/datum/equipment_preset/uscm_event/dress/officer/load_gear(mob/living/carbon/human/new_human)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/dress/blues/senior(new_human), WEAR_BODY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/jacket/marine/dress/blues/officer(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/marine/dress_cover/officer(new_human), WEAR_HEAD)
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/mcom/cdrcom(new_human), WEAR_L_EAR)
	. = ..()

/datum/equipment_preset/uscm_event/dress/officer/firstlt
	name = "Dress Blues - (O-2) 1st Lieutenant"
	paygrade = PAY_SHORT_MO2

/datum/equipment_preset/uscm_event/dress/officer/capt
	name = "Dress Blues - (O-3) Captain"
	paygrade = PAY_SHORT_MO3
	idtype = /obj/item/card/id/gold
	skills = /datum/skills/XO


/datum/equipment_preset/uscm_event/dress/officer/capt/New()
	. = ..()
	access = get_access(ACCESS_LIST_MARINE_MAIN)

/datum/equipment_preset/uscm_event/dress/officer/co
	name = "Dress Blues - (O-4) Major"
	paygrade = PAY_SHORT_MO4
	idtype = /obj/item/card/id/gold
	skills = /datum/skills/commander

/datum/equipment_preset/uscm_event/dress/officer/co/New()
	. = ..()
	access = get_access(ACCESS_LIST_MARINE_ALL)

/datum/equipment_preset/uscm_event/dress/officer/co/ltcol
	name = "Dress Blues - (O-5) Lieutenant Colonel"
	paygrade = PAY_SHORT_MO5
	idtype = /obj/item/card/id/gold/council

/datum/equipment_preset/uscm_event/dress/officer/co/col
	name = "Dress Blues - (O-6) Colonel"
	paygrade = PAY_SHORT_MO6
	idtype = /obj/item/card/id/general

//GENERAL OFFICERS//

/datum/equipment_preset/uscm_event/dress/officer/general
	name = "Dress Blues - (O-8) Major General"
	paygrade = PAY_SHORT_MO8
	idtype = /obj/item/card/id/general
	skills = /datum/skills/general

	dress_under = list(/obj/item/clothing/under/marine/dress/blues/general)

/datum/equipment_preset/uscm_event/dress/officer/general/New()
	. = ..()
	access = get_access(ACCESS_LIST_MARINE_ALL)

/datum/equipment_preset/uscm_event/dress/officer/general/load_gear(mob/living/carbon/human/new_human)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/dress/blues/general(new_human), WEAR_BODY)
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/highcom(new_human), WEAR_L_EAR)
	. = ..()


/datum/equipment_preset/uscm_event/dress/officer/general/ltgen
	name = "Dress Blues - (O-9) Lieutenant General"
	paygrade = PAY_SHORT_MO9

/datum/equipment_preset/uscm_event/dress/officer/general/gen
	name = "Dress Blues - (O-10) General"
	paygrade = PAY_SHORT_MO10
