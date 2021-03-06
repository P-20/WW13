/obj/item/weapon/gun/projectile/revolver
	name = "revolver"
	desc = "The Lumoco Arms HE Colt is a choice revolver for when you absolutely, positively need to put a hole in the other guy. Uses .357 ammo."
	icon_state = "revolver"
	item_state = "revolver"
	caliber = "357"
//	origin_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 2)
	handle_casings = CYCLE_CASINGS
	max_shells = 7
	ammo_type = /obj/item/ammo_casing/a357
	unload_sound 	= 'sound/weapons/guns/interact/rev_magout.ogg'
	reload_sound 	= 'sound/weapons/guns/interact/rev_magin.ogg'
	cocked_sound 	= 'sound/weapons/guns/interact/rev_cock.ogg'
	fire_sound = 'sound/weapons/guns/fire/revolver_fire.ogg'
	var/chamber_offset = FALSE //how many empty chambers in the cylinder until you hit a round
	magazine_based = FALSE


/obj/item/weapon/gun/projectile/revolver/verb/spin_cylinder()
	set name = "Spin cylinder"
	set desc = "Fun when you're bored out of your skull."
	set category = null

	chamber_offset = FALSE
	visible_message("<span class='warning'>\The [usr] spins the cylinder of \the [src]!</span>", \
	"<span class='notice'>You hear something metallic spin and click.</span>")
	playsound(loc, 'sound/weapons/revolver_spin.ogg', 100, TRUE)
	loaded = shuffle(loaded)
	if(rand(1,max_shells) > loaded.len)
		chamber_offset = rand(0,max_shells - loaded.len)

/obj/item/weapon/gun/projectile/revolver/consume_next_projectile()
	if(chamber_offset)
		chamber_offset--
		return
	return ..()

/obj/item/weapon/gun/projectile/revolver/load_ammo(var/obj/item/A, mob/user)
	chamber_offset = FALSE
	return ..()

/obj/item/weapon/gun/projectile/revolver/mateba
	name = "mateba"
	icon_state = "mateba"
//	origin_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 2)

/obj/item/weapon/gun/projectile/revolver/detective
	name = "revolver"
	desc = "A cheap knock-off of a Smith & Wesson Model 10. Uses .38-Special rounds."
	icon_state = "detective"
	max_shells = 6
	caliber = "38"
//	origin_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 2)
	fire_sound = 'sound/weapons/Gunshot_light.ogg'
	ammo_type = /obj/item/ammo_casing/c38

/obj/item/weapon/gun/projectile/revolver/detective/verb/rename_gun()
	set name = "Name Gun"
	set category = null
	set desc = "Click to rename your gun. If you're the detective."

	var/mob/M = usr
	if(!M.mind)	return FALSE
	if(!M.mind.assigned_role == "Inspector")
		M << "<span class='notice'>You don't feel cool enough to name this gun, chump.</span>"
		return FALSE

	var/input = sanitizeSafe(input("What do you want to name the gun?", ,""), MAX_NAME_LEN)

	if(src && input && !M.stat && in_range(M,src))
		name = input
		M << "You name the gun [input]. Say hello to your new friend."
		return TRUE

// Blade Runner pistol.
/obj/item/weapon/gun/projectile/revolver/deckard
	name = "Deckard .44"
	desc = "A custom-built revolver, based off the semi-popular Detective Special model."
	icon_state = "deckard-empty"
	ammo_type = /obj/item/ammo_magazine/c38/rubber

/obj/item/weapon/gun/projectile/revolver/deckard/update_icon()
	..()
	if(loaded.len)
		icon_state = "deckard-loaded"
	else
		icon_state = "deckard-empty"

/obj/item/weapon/gun/projectile/revolver/deckard/load_ammo(var/obj/item/A, mob/user)
	if(istype(A, /obj/item/ammo_magazine))
		flick("deckard-reload",src)
	..()

/obj/item/weapon/gun/projectile/revolver/capgun
	name = "cap gun"
	desc = "Looks almost like the real thing! Ages 8 and up."
	icon_state = "revolver"
	item_state = "revolver"
	caliber = "caps"
//	origin_tech = list(TECH_COMBAT = TRUE, TECH_MATERIAL = TRUE)
	handle_casings = CYCLE_CASINGS
	max_shells = 7
	ammo_type = /obj/item/ammo_casing/cap


/* Ironhammer stuff */

/obj/item/weapon/gun/projectile/revolver/consul
	name = "FS REV .44 \"Consul\""
	desc = "FS REV .44 \"Consul\" is a choice revolver for when you absolutely, positively need to put a hole in the other guy. Uses .44 ammo."
	icon_state = "inspector"
	item_state = "revolver"
	caliber = ".44"
//	origin_tech = list(TECH_COMBAT = 3, TECH_MATERIAL = 3)
	handle_casings = CYCLE_CASINGS
	max_shells = 6
	ammo_type = /obj/item/ammo_casing/cl44/rubber

/obj/item/weapon/gun/projectile/revolver/consul/proc/update_charge()
	if(loaded.len==0)
		overlays += "inspector_off"
	else
		overlays += "inspector_on"


/obj/item/weapon/gun/projectile/revolver/consul/update_icon()
	overlays.Cut()
	update_charge()