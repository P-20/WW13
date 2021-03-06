/* SURGERY STEPS */

/datum/surgery_step
	var/priority = FALSE	//steps with higher priority would be attempted first

	// type path referencing tools that can be used for this step, and how well are they suited for it
	var/list/allowed_tools = null
	// type paths referencing races that this step applies to.
	var/list/allowed_species = null
	var/list/disallowed_species = null

	// duration of the step
	var/min_duration = FALSE
	var/max_duration = FALSE

	// evil infection stuff that will make everyone hate me
	var/can_infect = FALSE
	//How much blood this step can get on surgeon. TRUE - hands, 2 - full body.
	var/blood_level = FALSE

	//returns how well tool is suited for this step
	proc/tool_quality(obj/item/tool, var/mob/living/carbon/human/user)
		. = FALSE
		for (var/T in allowed_tools)
			if (istype(tool,T))
				. = min(allowed_tools[T], 72)
		if (istype(user))
			. *= user.getStatCoeff("medical")

	// Checks if this step applies to the user mob at all
	proc/is_valid_target(mob/living/carbon/human/target)
		if(!hasorgans(target))
			return FALSE

		if(allowed_species)
			for(var/species in allowed_species)
				if(target.species.get_bodytype() == species)
					return TRUE

		if(disallowed_species)
			for(var/species in disallowed_species)
				if(target.species.get_bodytype() == species)
					return FALSE

		return TRUE


	// checks whether this step can be applied with the given user and target
	proc/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return FALSE

	// does stuff to begin the step, usually just printing messages. Moved germs transfering and bloodying here too
	proc/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if (can_infect && affected)
			spread_germs_to_organ(affected, user)
		if (ishuman(user) && prob(60))
			var/mob/living/carbon/human/H = user
			if (blood_level)
				H.bloody_hands(target,0)
			if (blood_level > 1)
				H.bloody_body(target,0)
		return

	// does stuff to end the step, which is normally print a message + do whatever this step changes
	proc/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return

	// stuff that happens when the step fails
	proc/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return null

proc/spread_germs_to_organ(var/obj/item/organ/external/E, var/mob/living/carbon/human/user)
	if(!istype(user) || !istype(E)) return

	var/germ_level = user.germ_level
	if(user.gloves)
		germ_level = user.gloves.germ_level

	E.germ_level = max(germ_level,E.germ_level) //as funny as scrubbing microbes out with clean gloves is - no.

proc/do_surgery(mob/living/carbon/M, mob/living/user, obj/item/tool)
	if(!istype(M))
		return FALSE
	if (user.a_intent == I_HURT)	//check for Hippocratic Oath
		return FALSE
	var/zone = user.targeted_organ
	if(zone in M.op_stage.in_progress) //Can't operate on someone repeatedly.
		user << "<span class='warning'>You can't operate on this area while surgery is already in progress.</span>"
		return TRUE
	for(var/datum/surgery_step/S in surgery_steps)
		//check if tool is right or close enough and if this step is possible
		if(S.tool_quality(tool, user))
			var/step_is_valid = S.can_use(user, M, zone, tool)
			if(step_is_valid && S.is_valid_target(M))
				if(step_is_valid == SURGERY_FAILURE) // This is a failure that already has a message for failing.
					return TRUE
				M.op_stage.in_progress += zone
				S.begin_step(user, M, zone, tool)		//start on it
				//We had proper tools! (or RNG smiled.) and user did not move or change hands.
				if(prob(S.tool_quality(tool, user)) &&  do_mob(user, M, rand(S.min_duration, S.max_duration)))
					S.end_step(user, M, zone, tool)		//finish successfully
					if (ishuman(user))
						var/mob/living/carbon/human/H = user
						H.adaptStat("medical", 1)
				else if ((tool in user.contents) && user.Adjacent(M))			//or
					S.fail_step(user, M, zone, tool)		//malpractice~
				else // This failing silently was a pain.
					user << "<span class='warning'>You must remain close to your patient to conduct surgery.</span>"
				M.op_stage.in_progress -= zone 									// Clear the in-progress flag.
				if (ishuman(M))
					var/mob/living/carbon/human/H = M
					H.update_surgery()
				return	1	  												//don't want to do weapony things after surgery

// this gets called for every item attack now
//	if (user.a_intent == I_HELP)
//		user << "<span class='warning'>You can't see any useful way to use [tool] on [M].</span>"
	return FALSE

proc/sort_surgeries()
	var/gap = surgery_steps.len
	var/swapped = TRUE
	while (gap > 1 || swapped)
		swapped = FALSE
		if(gap > 1)
			gap = round(gap / 1.247330950103979)
		if(gap < 1)
			gap = TRUE
		for(var/i = TRUE; gap + i <= surgery_steps.len; i++)
			var/datum/surgery_step/l = surgery_steps[i]		//Fucking hate
			var/datum/surgery_step/r = surgery_steps[gap+i]	//how lists work here
			if(l.priority < r.priority)
				surgery_steps.Swap(i, gap + i)
				swapped = TRUE

/datum/surgery_status/
	var/eyes	=	0
	var/face	=	0
	var/head_reattach = FALSE
	var/current_organ = "organ"
	var/list/in_progress = list()