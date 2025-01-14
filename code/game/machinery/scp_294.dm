//////////////////////////////////////////
//				SCP 294					//
//										//
//	This is a child of a chemistry		//
//	dispenser. Info of how it works at	//
//	http://www.scp-wiki.net/scp-294		//
//										//
//////////////////////////////////////////

/obj/machinery/chem_dispenser/scp_294
	name = "\improper strange coffee machine"
	desc = "It appears to be a standard coffee vending machine, the only noticeable difference being an entry touchpad with buttons corresponding to a Galactic Common QWERTY keyboard."
	icon = 	'icons/obj/vending.dmi'
	icon_state = COFFEE
	energy = 10
	max_energy = 10
	amount = 10
	dispensable_reagents = null
	var/list/prohibited_reagents = list(ADMINORDRAZINE)

	machine_flags = FIXED2WORK
	mech_flags = MECH_SCAN_FAIL

/obj/machinery/chem_dispenser/scp_294/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open=NANOUI_FOCUS)
	if(stat & (BROKEN|NOPOWER))
		return
	if((user.stat && !isobserver(user)) || user.restrained())
		return
	if(!chemical_reagents_list || !chemical_reagents_list.len)
		return
	// this is the data which will be sent to the ui
	var/data[0]
	data["isBeakerLoaded"] = container ? 1 : 0

	var containerContents[0]
	var containerCurrentVolume = 0
	if(container && container.reagents && container.reagents.reagent_list.len)
		for(var/datum/reagent/R in container.reagents.reagent_list)
			containerContents.Add(list(list("name" = R.name, "volume" = R.volume))) // list in a list because Byond merges the first list...
			containerCurrentVolume += R.volume
	data["beakerContents"] = containerContents

	if (container)
		data["beakerCurrentVolume"] = containerCurrentVolume
		data["beakerMaxVolume"] = container.volume
	else
		data["beakerCurrentVolume"] = null
		data["beakerMaxVolume"] = null

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "scp_294.tmpl", "[src.name]", 390, 315)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()

/obj/machinery/chem_dispenser/scp_294/Topic(href, href_list)
	if(stat & (NOPOWER|BROKEN))
		return 0 // don't update UIs attached to this object

	if(href_list["ejectBeaker"])
		if(container)
			detach()

	if(href_list["input"])
		if(container)
			var/input_reagent = input("Enter the name of any liquid", "Input") as text
			if (input_reagent in prohibited_reagents)
				say("OUT OF RANGE")
				return
			else
				var/obj/item/weapon/reagent_containers/glass/X = src.container
				var/datum/reagents/U = X.reagents
				if(!U)
					if(!X.gcDestroyed)
						X.create_reagents(X.volume)
					else
						qdel(X)
						X = null
						return
				var/space = U.maximum_volume - U.total_volume

				// so we get no runtimes
				try
					U.add_reagent(input_reagent, min(amount, energy * 10, space))
					energy = max(energy - min(amount, energy * 10, space) / 10, 0)
				catch
					say("OUT OF RANGE")

	add_fingerprint(usr)
	return 1 // update UIs attached to this object

/obj/machinery/chem_dispenser/scp_294/update_icon()
	return

/obj/machinery/chem_dispenser/scp_294/stop_mapping_this_shit
	machine_flags = WRENCHMOVE | FIXED2WORK
