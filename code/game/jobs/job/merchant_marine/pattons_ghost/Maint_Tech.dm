/datum/job/merchant_marine/maint_tech/patton
	title = JOB_MM_MAINTENANCE_TECH_PATTON
	supervisors = "your ships Chief Engineer"
	selection_class = "job_cl"
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADMIN_NOTIFY|ROLE_WHITELISTED
	gear_preset = /datum/equipment_preset/merchant_marine/css/mt/patton

/obj/effect/landmark/start/ship_mt/pattons_ghost
	name = JOB_MM_MAINTENANCE_TECH_PATTON
	icon_state = "x"
	job = /datum/job/merchant_marine/maint_tech/patton
