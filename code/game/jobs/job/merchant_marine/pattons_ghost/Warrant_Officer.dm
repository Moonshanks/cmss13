/datum/job/merchant_marine/warrant_officer/patton
	title = JOB_MM_WARRANT_OFFICER_PATTON
	supervisors = "your ships Captain"
	selection_class = "job_cl"
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADMIN_NOTIFY|ROLE_WHITELISTED
	gear_preset = /datum/equipment_preset/merchant_marine/css/warrant/patton

/obj/effect/landmark/start/ship_wo/pattons_ghost
	name = JOB_MM_QUATERMASTER_PATTON
	icon_state = "x"
	job = /datum/job/merchant_marine/warrant_officer/patton
