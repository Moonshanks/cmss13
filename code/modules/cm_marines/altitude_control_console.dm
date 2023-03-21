//Defines what to times the OB and transport shuttle timers by based on the altitude
#define SHIP_ALT_LOW 0.5
#define SHIP_ALT_MED 1
#define SHIP_ALT_HIGH 1.5

//List of available heights
GLOBAL_VAR_INIT(ship_alt_list, list("Low Altitude" = SHIP_ALT_LOW, "Optimal Altitude" = SHIP_ALT_MED, "High Altitude" = SHIP_ALT_HIGH))

//Handles whether or not hijack has disabled the system
GLOBAL_VAR_INIT(alt_ctrl_disabled, FALSE)

//Defines how much to heat the engines or cool them by, and when to overheat
#define COOLING -10
#define OVERHEAT_COOLING -5
#define HEATING 15
#define OVERHEAT 100

//Has the ships temperature set to 0 on startup, sets the global default var to med
GLOBAL_VAR_INIT(ship_temp, 0)
GLOBAL_VAR_INIT(ship_alt, SHIP_ALT_MED)

//Handles how close to the MAXIMUM values the: heating, cooldowns, and fuel use, are based on how well the nav officer has completed their minigame, bound between 0.5 - 2 (with 0.5 being 50% better and 2 being 100% worse so that a shit navigations officer is worse than NO navigations officer.)
var/engine_efficiency = 1


//Handles the minigame for the nav officer making the engines more "efficient"

var/primary_engine_freq = 0
var/secondary_engine_freq = 0
var/primary_engine_freq_guess = 0
var/secondary_engine_freq_guess = 0

//Handles whether or not the ship can overheat - enables and disables the Navigation Officers controls
var/safety_on = TRUE

//Handles if the console has totally broken down (reached 200% overheat)
var/total_overheat = FALSE
/obj/structure/machinery/computer/engine_control_console
	icon_state = "overwatch"
	name = "Engine Control Console"
	desc = "The E.C.C console monitors, regulates, and updates the ships thrust vectors and engine perameters. It's only rocket science."

/obj/structure/machinery/computer/engine_control_console/attack_hand()
	. = ..()
	if(total_overheat)
		to_chat(usr, SPAN_WARNING("ARES has locked this console due to total malfunction of the vessles engine cooling pumps."))
		return
	if(!skillcheck(usr, SKILL_NAVIGATIONS, SKILL_NAVIGATIONS_MASTER))
		to_chat(usr, SPAN_WARNING("A window of complex engine thrust calculations opens up. You have no idea what you are doing and quickly close it."))
		return
	if(GLOB.alt_ctrl_disabled)
		to_chat(usr, SPAN_WARNING("The Engine Control Console has been locked by ARES due to Delta Alert."))
		return
	if(safety_on)
		to_chat(usr, SPAN_WARNING("You cannot modify the engines thrust profiles without first disabling the safety overrides."))
		return
	tgui_interact(usr)

//the next bit handles the logic for the navigations minigame. It takes how close the two "frequencies" are to the true frequency as a percentage, and uses the average of these two percentages to edit the "engine_efficiency" var.
/obj/structure/machinery/computer/engine_control_console/process()
	. = ..()
	if(GLOB.ship_temp == 200)
		total_overheat = TRUE
		ai_announcement("ALERT: Total Failure of engine cooling systems. Boosting to higher orbit. Restricting all orbital manouvers")
		GLOB.ship_alt = SHIP_ALT_HIGH
	for(var/mob/living/carbon/current_mob in GLOB.living_mob_list)
		if(!is_mainship_level(current_mob.z))
			continue
		current_mob.apply_effect(3, WEAKEN)
		shake_camera(current_mob, 10, 2)
	ai_silent_announcement("Attention performing high-G maneuverer", ";", TRUE)

/obj/structure/machinery/computer/altitude_control_console
	icon_state = "overwatch"
	name = "Altitude Control Console"
	desc = "The A.C.C console monitors, regulates, and updates the ships attitude and altitude in relation to the AO. It's not rocket science."

/obj/structure/machinery/computer/altitude_control_console/attack_hand()
	. = ..()
	if(total_overheat)
		to_chat(usr, SPAN_WARNING("ARES has locked this console due to total malfunction of the vessles engine cooling pumps."))
		return
	if(!skillcheck(usr, SKILL_NAVIGATIONS, SKILL_NAVIGATIONS_TRAINED))
		to_chat(usr, SPAN_WARNING("A window of complex orbital math opens up. You have no idea what you are doing and quickly close it."))
		return
	if(GLOB.alt_ctrl_disabled)
		to_chat(usr, SPAN_WARNING("The Altitude Control Console has been locked by ARES due to Delta Alert."))
		return
	if(GLOB.alt_ctrl_disabled)
		to_chat(usr, SPAN_WARNING("The Altitude Control Console has been locked by ARES due to Delta Alert."))
		return
	tgui_interact(usr)
	tgui_interact(usr)

/obj/structure/machinery/computer/altitude_control_console/Initialize()
	. = ..()
	START_PROCESSING(SSslowobj, src)

/obj/structure/machinery/computer/altitude_control_console/process()
	. = ..()
	if(GLOB.ship_temp >= OVERHEAT)
		landmark_explosions((GLOB.ship_temp - 80)/10, GLOB.ship_temp, 25)
	var/temperature_change
	if(safety_on)
		if(GLOB.ship_temp >= OVERHEAT)
			TIMER_COOLDOWN_START(src, COOLDOWN_ALTITUDE_CHANGE, 180 SECONDS)
			GLOB.ship_temp += 30
			ai_silent_announcement("Attention: orbital correction no longer sustainable, moving to geo-synchronous orbit until engine cooloff.", ";", TRUE)
			GLOB.ship_alt = SHIP_ALT_HIGH
			temperature_change = OVERHEAT_COOLING
			for(var/mob/living/carbon/current_mob in GLOB.living_mob_list)
				if(!is_mainship_level(current_mob.z))
					continue
				current_mob.apply_effect(3, WEAKEN)
				shake_camera(current_mob, 10, 2)
			ai_silent_announcement("Attention performing high-G maneuverer", ";", TRUE)
	if(!temperature_change)
		switch(GLOB.ship_alt)
			if(SHIP_ALT_LOW)
				temperature_change = (HEATING * engine_efficiency)
			if(SHIP_ALT_MED)
				temperature_change = (COOLING / engine_efficiency)
			if(SHIP_ALT_HIGH)
				temperature_change = (COOLING / engine_efficiency)
	GLOB.ship_temp = Clamp(GLOB.ship_temp += temperature_change, 0, 180)
	if(prob(50))
		return
	if(GLOB.ship_alt == SHIP_ALT_LOW)
		for(var/mob/living/carbon/current_mob in GLOB.living_mob_list)
			if(!is_mainship_level(current_mob.z))
				continue
			shake_camera(current_mob, 10, 1)
		ai_silent_announcement("Performing Attitude Control", ";", TRUE)

//TGUI.... fun... years have gone by, I am dying of old age
/obj/structure/machinery/computer/altitude_control_console/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AltitudeControlConsole", "[src.name]")
		ui.open()

/obj/structure/machinery/computer/altitude_control_console/ui_state(mob/user)
	return GLOB.not_incapacitated_and_adjacent_state

/obj/structure/machinery/computer/altitude_control_console/ui_status(mob/user, datum/ui_state/state)
	. = ..()
	if(inoperable())
		return UI_CLOSE

/obj/structure/machinery/computer/altitude_control_console/ui_data(mob/user)
	var/list/data = list()
	data["alt"] = GLOB.ship_alt
	data["temp"] = GLOB.ship_temp

	return data

/obj/structure/machinery/computer/altitude_control_console/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	if(.)
		return
	var/mob/user = usr
	switch(action)
		if("low_alt")
			change_altitude(user, SHIP_ALT_LOW)
			message_admins("[key_name(user)] has changed the ship's altitude to [action].")
			. = TRUE
		if("med_alt")
			change_altitude(user, SHIP_ALT_MED)
			message_admins("[key_name(user)] has changed the ship's altitude to [action].")
			. = TRUE
		if("high_alt")
			change_altitude(user, SHIP_ALT_HIGH)
			message_admins("[key_name(user)] has changed the ship's altitude to [action].")
			. = TRUE
		if("safety")
			safety_on = !(safety_on)
			if(!safety_on)
				ai_silent_announcement("Engine Automated Safeguards Disabled", ";", TRUE)
			if(safety_on)
				ai_silent_announcement("Engine Automated Safeguards Enabled", ";", TRUE)
			message_admins("[key_name(user)] has changed the engines safety toggle to [safety_on].")
			. = TRUE

	add_fingerprint(usr)

/obj/structure/machinery/computer/altitude_control_console/proc/change_altitude(mob/user, new_altitude)
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_ALTITUDE_CHANGE))
		to_chat(user, SPAN_WARNING("The engines are not ready to burn yet."))
		return
	if(GLOB.ship_alt == new_altitude)
		return
	GLOB.ship_alt = new_altitude
	TIMER_COOLDOWN_START(src, COOLDOWN_ALTITUDE_CHANGE, 90 * engine_efficiency SECONDS)
	GLOB.ship_temp += (30 * engine_efficiency)
	for(var/mob/living/carbon/current_mob in GLOB.living_mob_list)
		if(!is_mainship_level(current_mob.z))
			continue
		current_mob.apply_effect(3, WEAKEN)
		shake_camera(current_mob, 10, 2)
	ai_silent_announcement("Attention: Performing high-G manoeuvre", ";", TRUE)
	if(!safety_on)
		primary_engine_freq = rand(0, 200)
		secondary_engine_freq = rand(0, 200)
	if(!skillcheck(usr, SKILL_NAVIGATIONS, SKILL_NAVIGATIONS_EXPERT))
		to_chat(usr, SPAN_WARNING("Your calcuations suggest the engine frequencies must be set to [primary_engine_freq] and [secondary_engine_freq]"))

//TGUI stuff for the engine_control_console

/obj/structure/machinery/computer/engine_control_console/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "EngineControlConsole", "[src.name]")
		ui.open()

/obj/structure/machinery/computer/engine_control_console/ui_state(mob/user)
	return GLOB.not_incapacitated_and_adjacent_state

/obj/structure/machinery/computer/engine_control_console/ui_status(mob/user, datum/ui_state/state)
	. = ..()
	if(inoperable())
		return UI_CLOSE

/obj/structure/machinery/computer/engine_control_console/ui_data(mob/user)
	var/list/data = list()
	data["freq1g"] = primary_engine_freq_guess
	data["freq2g"] = secondary_engine_freq_guess
	data["EngineEfficiency"] = engine_efficiency
	data["temp"] = GLOB.ship_temp

	return data

/obj/structure/machinery/computer/altitude_control_console/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	if(.)
		return
	switch(action)
		if("p_freq")
			primary_engine_freq = params["freq1g"]
		if("s_freq")

		if("calculate")
			engine_efficiency = ((abs(primary_engine_freq_guess / primary_engine_freq) + abs(secondary_engine_freq_guess / secondary_engine_freq)) / 100) / 2
	add_fingerprint(usr)


//sets explosion chance and size, recommend you have this equal to a glob variable or something that changes.
var/explosion_chance = 50
var/explosion_power = 50
var/explosion_falloff = 50

//for the record I have no idea why these global vars need to be set on init when they are.. already set on init. Just Elsehwere in the code.
GLOBAL_LIST_EMPTY(exploding_landmarks)
GLOBAL_LIST_EMPTY(shipside_apc_locations)


//This is just a proc so that anyone can explode a part of the ship whenever.

datum/proc/landmark_explosions(explosion_chance, explosion_power, explosion_falloff)
	if(prob(explosion_chance))
		cell_explosion(pick(GLOB.exploding_landmarks), explosion_power, explosion_falloff)
	return

#undef COOLING
#undef OVERHEAT_COOLING
#undef HEATING
#undef OVERHEAT
