
/obj/item/clothing/suit/armor
	allowed = list(/obj/item/weapon/gun/energy,/obj/item/device/radio,/obj/item/weapon/reagent_containers/spray/pepper,/obj/item/weapon/gun/projectile,/obj/item/ammo_magazine,/obj/item/ammo_casing,/*/obj/item/weapon/melee/baton,*//obj/item/weapon/handcuffs)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	item_flags = THICKMATERIAL

	cold_protection = UPPER_TORSO|LOWER_TORSO
	min_cold_protection_temperature = ARMOR_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = UPPER_TORSO|LOWER_TORSO
	max_heat_protection_temperature = ARMOR_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.6


/obj/item/clothing/suit/armor/vest
	name = "armor"
	desc = "An armored vest that protects against some damage. Not designed for serious operations."
	icon_state = "armor"
	item_state = "armor"
	blood_overlay_type = "armor"
	armor = list(melee = 50, bullet = 15, laser = 50, energy = 10, bomb = 25, bio = FALSE, rad = FALSE)

/obj/item/clothing/suit/armor/vest/security
	name = "security armor"
	desc = "An armored vest that protects against some damage. This one have Ironhammer Security signs. Not designed for serious operations."
	icon_state = "armorsec"
	item_state = "armorsec"

/obj/item/clothing/suit/armor/vest/serg
	name = "Gunnery Sergeant's light armor"
	desc = "Light armor of Ironhammer Security forces. Not designed for serious operations."
	icon_state = "serg_armor"
	item_state = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS


/obj/item/clothing/suit/armor/riot
	name = "Riot Suit"
	desc = "A suit of armor with heavy padding to protect against melee attacks. Looks like it might impair movement."
	icon_state = "riot"
	item_state = "swat_suit"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	slowdown = TRUE
	armor = list(melee = 80, bullet = 10, laser = 10, energy = 10, bomb = FALSE, bio = FALSE, rad = FALSE)
	flags_inv = HIDEJUMPSUIT
	siemens_coefficient = 0.5


/obj/item/clothing/suit/armor/bulletproof
	name = "Bulletproof Vest"
	desc = "A vest that excels in protecting the wearer against high-velocity solid projectiles."
	icon_state = "bulletproof"
	item_state = "armor"
	blood_overlay_type = "armor"
	armor = list(melee = 10, bullet = 80, laser = 10, energy = 10, bomb = FALSE, bio = FALSE, rad = FALSE)
	siemens_coefficient = 0.7

/obj/item/clothing/suit/armor/laserproof
	name = "Ablative Armor Vest"
	desc = "A vest that excels in protecting the wearer against energy projectiles."
	icon_state = "armor_reflec"
	item_state = "armor_reflec"
	blood_overlay_type = "armor"
	armor = list(melee = 10, bullet = 10, laser = 80, energy = 50, bomb = FALSE, bio = FALSE, rad = FALSE)
	siemens_coefficient = FALSE

/obj/item/clothing/suit/armor/laserproof/handle_shield(mob/user, var/damage, atom/damage_source = null, mob/attacker = null, var/def_zone = null, var/attack_text = "the attack")
	if(istype(damage_source, /obj/item/projectile/energy) || istype(damage_source, /obj/item/projectile/beam))
		var/obj/item/projectile/P = damage_source

		var/reflectchance = 40 - round(damage/3)
		if(!(def_zone in list("chest", "groin")))
			reflectchance /= 2
		if(P.starting && prob(reflectchance))
			visible_message("<span class='danger'>\The [user]'s [name] reflects [attack_text]!</span>")

			// Find a turf near or on the original location to bounce to
			var/new_x = P.starting.x + pick(0, FALSE, FALSE, FALSE, FALSE, -1, TRUE, -2, 2)
			var/new_y = P.starting.y + pick(0, FALSE, FALSE, FALSE, FALSE, -1, TRUE, -2, 2)
			var/turf/curloc = get_turf(user)

			// redirect the projectile
			P.redirect(new_x, new_y, curloc, user)

			return PROJECTILE_CONTINUE // complete projectile permutation

/obj/item/clothing/suit/armor/swat
	name = "swat suit"
	desc = "A heavily armored suit that protects against moderate damage. Used in special operations."
	icon_state = "deathsquad"
	item_state = "swat_suit"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	item_flags = STOPPRESSUREDAMAGE | THICKMATERIAL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_magazine,/obj/item/ammo_casing,/*/obj/item/weapon/melee/baton,*//obj/item/weapon/handcuffs,/obj/item/weapon/tank/emergency_oxygen)
	slowdown = TRUE
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 25, bomb = 50, bio = 100, rad = 100)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.6


/obj/item/clothing/suit/armor/swat/officer
	name = "officer jacket"
	desc = "An armored jacket used in special operations."
	icon_state = "detective"
	item_state = "det_suit"
	blood_overlay_type = "coat"
	flags_inv = FALSE
	body_parts_covered = UPPER_TORSO|ARMS

//Reactive armor
//When the wearer gets hit, this armor will teleport the user a short distance away (to safety or to more danger, no one knows. That's the fun of it!)
/obj/item/clothing/suit/armor/reactive
	name = "Reactive Teleport Armor"
	desc = "Someone separated our Research Director from their own head!"
	var/active = 0.0
	icon_state = "reactiveoff"
	item_state = "reactiveoff"
	blood_overlay_type = "armor"
	slowdown = TRUE
	armor = list(melee = FALSE, bullet = FALSE, laser = FALSE, energy = FALSE, bomb = FALSE, bio = FALSE, rad = FALSE)

/obj/item/clothing/suit/armor/reactive/handle_shield(mob/user, var/damage, atom/damage_source = null, mob/attacker = null, var/def_zone = null, var/attack_text = "the attack")
	if(prob(50))
		user.visible_message("<span class='danger'>The reactive teleport system flings [user] clear of the attack!</span>")
		var/list/turfs = new/list()
		for(var/turf/T in orange(6, user))
			if(istype(T,/turf/space)) continue
			if(T.density) continue
			if(T.x>world.maxx-6 || T.x<6)	continue
			if(T.y>world.maxy-6 || T.y<6)	continue
			turfs += T
		if(!turfs.len) turfs += pick(/turf in orange(6))
		var/turf/picked = pick(turfs)
		if(!isturf(picked)) return

		var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
		spark_system.set_up(5, FALSE, user.loc)
		spark_system.start()
		playsound(user.loc, "sparks", 50, TRUE)

		user.loc = picked
		return PROJECTILE_FORCE_MISS
	return FALSE

/obj/item/clothing/suit/armor/reactive/attack_self(mob/user as mob)
	active = !( active )
	if (active)
		user << "<span class = 'notice'>The reactive armor is now active.</span>"
		icon_state = "reactive"
		item_state = "reactive"
	else
		user << "<span class = 'notice'>The reactive armor is now inactive.</span>"
		icon_state = "reactiveoff"
		item_state = "reactiveoff"
		add_fingerprint(user)
	return

/obj/item/clothing/suit/armor/reactive/emp_act(severity)
	active = FALSE
	icon_state = "reactiveoff"
	item_state = "reactiveoff"
	..()

/obj/item/clothing/suit/armor/tactical
	name = "tactical armor"
	desc = "A suit of armor most often used by Special Weapons and Tactics squads. Includes padded vest with pockets along with shoulder and kneeguards."
	icon_state = "swatarmor"
	item_state = "armor"
	var/obj/item/weapon/gun/holstered = null
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	slowdown = TRUE
	armor = list(melee = 60, bullet = 60, laser = 60, energy = 40, bomb = 20, bio = FALSE, rad = FALSE)
	siemens_coefficient = 0.7
	var/obj/item/clothing/accessory/holster/holster

/obj/item/clothing/suit/armor/tactical/New()
	..()
	holster = new(src)

/obj/item/clothing/suit/armor/tactical/attackby(obj/item/W as obj, mob/user as mob)
	..()
	holster.attackby(W, user)

/obj/item/clothing/suit/armor/tactical/verb/holster()
	set name = "Holster"
	set category = null
	set src in usr
	if(!istype(usr, /mob/living)) return
	if(usr.stat) return

	if(!holster.holstered)
		var/obj/item/W = usr.get_active_hand()
		if(!istype(W, /obj/item))
			usr << "<span class='warning'>You need your gun equiped to holster it.</span>"
			return
		holster.holster(W, usr)
	else
		holster.unholster(usr)

/obj/item/clothing/suit/armor/vest/detective
	name = "inspector armor vest"
	desc = "An synthetic armor vest colored in a vintage brown."
	icon_state = "detvest"

/obj/item/clothing/suit/storage/vest
	name = "webbed armor vest"
	desc = "A synthetic armor vest. This one has added webbing and ballistic plates."
	icon_state = "webvest"
	armor = list(melee = 50, bullet = 40, laser = 50, energy = 25, bomb = 30, bio = FALSE, rad = FALSE)
	allowed = list(/obj/item/weapon/gun/energy,/obj/item/device/radio,/obj/item/weapon/reagent_containers/spray/pepper,/obj/item/weapon/gun/projectile,/obj/item/ammo_magazine,/obj/item/ammo_casing,/*/obj/item/weapon/melee/baton,*//obj/item/weapon/handcuffs)

	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	item_flags = THICKMATERIAL

	cold_protection = UPPER_TORSO|LOWER_TORSO
	min_cold_protection_temperature = ARMOR_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = UPPER_TORSO|LOWER_TORSO
	max_heat_protection_temperature = ARMOR_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.6

//Provides the protection of a merc voidsuit, but only covers the chest/groin, and also takes up a suit slot. In exchange it has no slowdown and provides storage.
/obj/item/clothing/suit/storage/vest/merc
	name = "heavy armor vest"
	desc = "A high-quality armor vest in a fetching tan. It is surprisingly flexible and light, even with the added webbing and armor plating."
	icon_state = "mercwebvest"
	item_state = "mercwebvest"
	armor = list(melee = 60, bullet = 60, laser = 60, energy = 40, bomb = 40, bio = FALSE, rad = FALSE)


//All of the armor below is mostly unused

/obj/item/clothing/suit/armor/heavy
	name = "heavy armor"
	desc = "A heavily armored suit that protects against moderate damage."
	icon_state = "heavy"
	item_state = "swat_suit"
	w_class = 4//bulky item
	gas_transfer_coefficient = 0.90
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	slowdown = 3
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	siemens_coefficient = FALSE

/obj/item/clothing/suit/armor/tdome
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT

/obj/item/clothing/suit/armor/tdome/red
	name = "Thunderdome suit (red)"
	desc = "Reddish armor."
	icon_state = "tdred"
	item_state = "tdred"
	siemens_coefficient = TRUE

/obj/item/clothing/suit/armor/tdome/green
	name = "Thunderdome suit (green)"
	desc = "Pukish armor."
	icon_state = "tdgreen"
	item_state = "tdgreen"
	siemens_coefficient = TRUE
