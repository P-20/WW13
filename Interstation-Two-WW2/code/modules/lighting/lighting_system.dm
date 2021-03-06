var/max_lighting_z = TRUE // no lighting in the sky anymore

/var/list/all_lighting_overlays   = list()    // Global list of lighting overlays.
/var/lighting_corners_initialised = FALSE

/proc/create_all_lighting_overlays()
	for(var/zlevel = TRUE to max_lighting_z)
		create_lighting_overlays_zlevel(zlevel)

/proc/create_lighting_overlays_zlevel(var/zlevel)
	ASSERT(zlevel)

	for(var/turf/T in block(locate(1, TRUE, zlevel), locate(world.maxx, world.maxy, zlevel)))
		if (!locate(/atom/movable/lighting_overlay) in T && !locate(/obj/train_track) in T)
			var/area/T_area = get_area(T)
			// prevent mass deletion of these later
			if (T_area.is_train_area)
				continue

			else if (T_area.is_void_area)
				if (istype(T, /turf/wall/rockwall))
					T.icon_state = "black"
					continue
				else if (istype(T, /turf/wall/indestructable))
					var/turf/wall/W = T
					W.icon = 'icons/turf/walls.dmi'
					W.icon_state = "black"
					qdel_list(W.overlays)
					qdel_list(W.damage_overlays)
					continue

			PoolOrNew(/atom/movable/lighting_overlay, T, TRUE)

/proc/create_all_lighting_corners()
	for(var/zlevel = TRUE to max_lighting_z)
		create_lighting_corners_zlevel(zlevel)
	global.lighting_corners_initialised = TRUE

/proc/create_lighting_corners_zlevel(var/zlevel)
	for(var/turf/T in block(locate(1, TRUE, zlevel), locate(world.maxx, world.maxy, zlevel)))

		if (locate(/obj/train_track) in T)
			continue

		var/area/T_area = get_area(T)
		if (T_area.is_void_area && istype(T, /turf/wall/rockwall))
			continue

		for(var/i = 1 to 4)
			if(T.corners[i]) // Already have a corner on this direction.
				continue

			T.corners[i] = new/datum/lighting_corner(T, LIGHTING_CORNER_DIAGONAL[i])

/hook/startup/proc/setup_lighting()
	create_lighting()

var/created_lighting_corners_and_overlays = FALSE
/proc/create_lighting(_time_of_day)

	if (_time_of_day)
		time_of_day = _time_of_day
	else
		time_of_day = pick_TOD()

	create_all_lighting_corners()
	create_all_lighting_overlays()

	created_lighting_corners_and_overlays = TRUE

/proc/update_lighting(_time_of_day, var/client/admincaller = null, var/announce = TRUE)

	while (!created_lighting_corners_and_overlays)
		sleep(1)

	var/O_time_of_day = time_of_day

	if (_time_of_day)
		time_of_day = _time_of_day

	// change lighting over 12 seconds & 120 loops

	spawn (1)
		var/max_v = 120
		for (var/v in 1 to max_v)
			var/iterations_per_loop = ceil(turfs.len/max_v)
			for (var/vv in 1+(iterations_per_loop*(v-1)) to iterations_per_loop*v)
				if (turfs.len >= vv && turfs[vv])
					var/turf/t = turfs[vv]
					if (t.z <= max_lighting_z)
						if (!locate(/obj/train_track) in t)
							if (t.uses_daylight_dynamic_lighting || locate(/obj/structure/catwalk) in t)
								var/area/a = t.loc
								if (!a.dynamic_lighting)
									if (!istype(a, /area/prishtina/soviet/bunker) && !istype(a, /area/prishtina/soviet/bunker_entrance) && !a.is_void_area)
										t.adjust_lighting_overlay_to_daylight()

						else
							// You have to do this instead of deleting t.lighting_overlay.
							for (var/atom/movable/lighting_overlay/LO in t.contents)
								qdel(LO)
							var/TOD_2_rgb = min(255, round(time_of_day2luminosity[time_of_day] * 255) * 1.25)
							t.color = rgb(TOD_2_rgb, TOD_2_rgb, TOD_2_rgb)
							for (var/obj/train_track/TT in t.contents)
								TT.color = t.color

					// regardless of whether or not we use dynamic lighting here
					// we still need to change the TOD to prevent Vampire dusting
					for (var/atom/movable/lighting_overlay/LO in t.contents)
						LO.TOD = time_of_day

			sleep(1)

	if (admincaller)
		spawn (125)
			admincaller << "<span class = 'notice'>Updated lights for [time_of_day].</span>"
			var/M = "[key_name(admincaller)] changed the time of day from [O_time_of_day] to [time_of_day]."
			log_admin(M)
			message_admins(M)

	if (announce)
		spawn (130)
			for (var/mob/M in player_list)
				var/area/M_area = get_area(M)
				if (M_area.location == AREA_OUTSIDE || M_area.z == 1 || istype(M, /mob/observer) || istype(M, /mob/new_player))
					M << "<font size=3><span class = 'notice'>It's <b>[lowertext(capitalize(time_of_day))]</b>.</span></font>"
