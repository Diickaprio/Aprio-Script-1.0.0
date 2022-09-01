--- Credit :  Len's
--            Jay Montana              

util.keep_running()
util.require_natives("natives-1661270988")

------------------Local

uncageMe = true
deleteMissionEnts = false
notification = true

local unreleased_vehicles = {
    "Kanjosj",
    "Postlude",
    "Rhinehart",
    "Tenf",
    "Tenf2",
    "Sentinel4",
    "Weevil2",
}
local modded_weapons = {
    "weapon_railgun",
    "weapon_stungun",
    "weapon_digiscanner",
}
local colors = {
	green = 184,
	red = 6,
	yellow = 190,
	black = 2,
	white = 1,
	gray = 3,
	pink = 201,
	purple = 49, --, 21, 96
	blue = 11
}
selectedplayer = {}
for b = 0, 31 do
	selectedplayer[b] = false
end
excludeselected = false

     --::: op Lua Crash :::

local begcrash = {
	"Hey bro, it would be pretty poggers to close your game for me",
	"Close your game. I'm not asking.",
	"Please close your game, please please please please please",
}

-------------------function

function notification(message, color)
	HUD._THEFEED_SET_NEXT_POST_BACKGROUND_COLOR(color)
	util.BEGIN_TEXT_COMMAND_THEFEED_POST(message)
	if color == colors.green or color == colors.red then
		subtitle = "~u~Notification"
	elseif color == colors.black then
		subtitle = "~c~Notification"
	else
		subtitle = "~u~Notification"
	end

	HUD.END_TEXT_COMMAND_THEFEED_POST_TICKER(true, false)
	util.log(message)
end
function send_script_event(first_arg, receiver, args)
	table.insert(args, 1, first_arg)
	util.trigger_script_event(1 << receiver, args)
end
function uncage()
	entity = players.user_ped()
	unarmed = not WEAPON.IS_PED_ARMED(ped, -1)
	weapon = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(entity, 0)
	objects = entities.get_all_objects_as_handles()
	for key, value in pairs(objects) do
		if ENTITY.GET_ENTITY_POPULATION_TYPE(value) == 7
		and (unarmed or (value != weapon and ENTITY.GET_ENTITY_ATTACHED_TO(value) != weapon))
		and ((dist(ENTITY.GET_ENTITY_COORDS(entity), ENTITY.GET_ENTITY_COORDS(value)) < 0.5) or (ENTITY.IS_ENTITY_TOUCHING_ENTITY(entity,value))
		and not ENTITY.IS_ENTITY_ATTACHED_TO_ENTITY(value,entity)) then
			if deleteMissionEnts or not ENTITY.IS_ENTITY_A_MISSION_ENTITY(entity) then
				if notification then util.toast("Deleting cage(s) with model " .. ENTITY.GET_ENTITY_MODEL(value)) end
				for key2, value2 in pairs(objects) do
					if (ENTITY.GET_ENTITY_MODEL(value2) == ENTITY.GET_ENTITY_MODEL(value)) then 
						entities.delete_by_handle(value2) 
					end
				end
			end
		end
	end
end
function dist(pos1, pos2)
	return math.sqrt((pos1.x - pos2.x)*(pos1.x - pos2.x)+(pos1.y - pos2.y)*(pos1.y - pos2.y)+(pos1.z - pos2.z)*(pos1.z - pos2.z))
end

--------------------menu

protex = menu.list(menu.my_root(), "Protections", {}, "", function(); end)

menu.toggle(protex, "Cage Protection", {}, "Automatically deletes cages you are in", function(toggle)
	uncageMe = toggle
	if toggle then 
		notification("Automatic removal of cages enabled!", colors.green)
	end
end, true)

menu.toggle(protex, "Block all Network Events", {}, "This breaks the game!!!", function(on_toggle)
	local BlockNetEvents = menu.ref_by_path("Online>Protections>Events>Raw Network Events>Any Event>Block>Enabled")
	local UnblockNetEvents = menu.ref_by_path("Online>Protections>Events>Raw Network Events>Any Event>Block>Disabled")
	if on_toggle then
		menu.trigger_command(BlockNetEvents)
		notification("block all network events stay safe :)))", colors.green)
	else
		menu.trigger_command(UnblockNetEvents)
		notification("Unblock all network events", colors.red)
	end
end)

menu.toggle(protex, "Block all Incoming Syncs", {}, "This breaks the game!!!", function(on_toggle)
	local BlockIncSyncs = menu.ref_by_path("Online>Protections>Syncs>Incoming>Any Incoming Sync>Block>Enabled")
	local UnblockIncSyncs = menu.ref_by_path("Online>Protections>Syncs>Incoming>Any Incoming Sync>Block>Disabled")
	if on_toggle then
		menu.trigger_command(BlockIncSyncs)
		notification("block all incoming syncs stay safe ;)))", colors.green)
	else
		menu.trigger_command(UnblockIncSyncs)
		notification("Unblock all incoming syncs", colors.red)
	end
end)

menu.toggle(protex, "Block all Outgoing Syncs", {}, "This breaks the game!!!", function(on_toggle)
	if on_toggle then
		notification("block all outgoing syncs", colors.green)
		menu.trigger_commands("desyncall on")
	else
		notification("Unblock all outgoing syncs", colors.red)
		menu.trigger_commands("desyncall off")
	end
end)

menu.toggle(protex, "Anti Crash", {}, "This will render you uncrashable, Block All", function(on_toggle)
	local BlockNetEvents = menu.ref_by_path("Online>Protections>Events>Raw Network Events>Any Event>Block>Enabled")
	local UnblockNetEvents = menu.ref_by_path("Online>Protections>Events>Raw Network Events>Any Event>Block>Disabled")
	local BlockIncSyncs = menu.ref_by_path("Online>Protections>Syncs>Incoming>Any Incoming Sync>Block>Enabled")
	local UnblockIncSyncs = menu.ref_by_path("Online>Protections>Syncs>Incoming>Any Incoming Sync>Block>Disabled")
	if on_toggle then
		notification("toggling anti crash on... stay safe homie", colors.green)
		menu.trigger_commands("desyncall on")
		menu.trigger_command(BlockIncSyncs)
		menu.trigger_command(BlockNetEvents)
		menu.trigger_commands("anticrashcamera on")
	else
		notification("toggling anti crash off...", colors.red)
		menu.trigger_commands("desyncall off")
		menu.trigger_command(UnblockIncSyncs)
		menu.trigger_command(UnblockNetEvents)
		menu.trigger_commands("anticrashcamera off")
	end
end)

menu.click_slider(protex,"Clear Entities", {"cleararea"}, "1 = peds, 2 = vehicles, 3 = objects, 4 = pickups, 5 = all", 1, 5, 1, 1, function(on_change)
	if on_change == 1 then
		local count = 0
		for k,ent in pairs(entities.get_all_peds_as_handles()) do
			if not PED.IS_PED_A_PLAYER(ent) then
				ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ent, false, false)
				entities.delete_by_handle(ent)
				util.yield()
				count = count + 1
			end
		end
		notification(count .. "Clear Area Managed", colors.green)
	end
	if on_change == 2 then
		local count = 0
		for k, ent in pairs(entities.get_all_vehicles_as_handles()) do
			local PedInSeat = VEHICLE.GET_PED_IN_VEHICLE_SEAT(ent, -1, false)
			if not PED.IS_PED_A_PLAYER(PedInSeat) then
				ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ent, false, false)
				entities.delete_by_handle(ent)
				util.yield()
				count = count + 1
			end
		end
		notification(count .. "Clear Area Managed", colors.green)
		return
	end
	if on_change == 3 then
		local count = 0
		for k,ent in pairs(entities.get_all_objects_as_handles()) do
			ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ent, false, false)
			entities.delete_by_handle(ent)
			count = count + 1
			util.yield()
		end
		notification(count .. "Clear Area Managed", colors.green)
		return
	end
	if on_change == 4 then
		local count = 0
		for k, ent in pairs(entities.get_all_pickups_as_handles()) do
			ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ent, false, false)
			entities.delete_by_handle(ent)
			count = count + 1
			util.yield()
		end
		notification(count .. "Clear Area Managed", colors.green)
		return
	end
	if on_change == 5 then
		local count = 0
		for k, ent in pairs(entities.get_all_peds_as_handles()) do
			if not PED.IS_PED_A_PLAYER(ent) then
				ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ent, false, false)
				entities.delete_by_handle(ent)
				util.yield()
				count = count + 1
			end
		end

		for k, ent in pairs(entities.get_all_vehicles_as_handles()) do
			local PedInSeat = VEHICLE.GET_PED_IN_VEHICLE_SEAT(ent, -1, false)
			if not PED.IS_PED_A_PLAYER(PedInSeat) then
				ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ent, false, false)
				entities.delete_by_handle(ent)
				util.yield()
				count = count + 1
			end
		end

		for k,ent in pairs(entities.get_all_objects_as_handles()) do
			ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ent, false, false)
			entities.delete_by_handle(ent)
			count = count + 1
			util.yield()
		end
	


		for k,ent in pairs(entities.get_all_pickups_as_handles()) do
			ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ent, false, false)
			entities.delete_by_handle(ent)
			count = count + 1
			util.yield()
		end
		notification(count .. "Clear Area Managed", colors.green)
		return
	end
end)

menu.action(protex, "Force Stop sound events", {"stopsounds"}, "", function()
	for i=-1,100 do
		AUDIO.STOP_SOUND(i)
		AUDIO.RELEASE_SOUND_ID(i)
	end
end)

menu.action(protex, "Remove Attachments", {"remove attachments"}, "Cleans your ped of all attachments by regenerating it", function()
	notification("Removing Attachments", colors.green)
	if PED.IS_PED_MALE(PLAYER.PLAYER_PED_ID()) then
		menu.trigger_commands("mpmale")
	else
		menu.trigger_commands("mpfemale")
	end
end)

menu.action(protex, "Ban Voice Chat", {}, "May lag your game when in progress, BETA", function()
	for pids = 0, 31 do
		if excludeselected then
			if pids ~= players.user() and not selectedplayer[pids] and players.exists(pids) then
				for i = 1, 30 do
					menu.trigger_commands("reportvcannoying " .. PLAYER.GET_PLAYER_NAME(pids))
					menu.trigger_commands("reportvchate " .. PLAYER.GET_PLAYER_NAME(pids))
					util.yield()
				end
				notification("Ban Voice Chat has been sent to " .. PLAYER.GET_PLAYER_NAME(pids), colors.black)
			end
		else
			if pids ~= players.user() and selectedplayer[pids] and players.exists(pids) then
				for i = 1, 30 do
					menu.trigger_commands("reportvcannoying " .. PLAYER.GET_PLAYER_NAME(pids))
					menu.trigger_commands("reportvchate " .. PLAYER.GET_PLAYER_NAME(pids))
					util.yield()
				end
				notification("Ban Voice Chat has been sent to " .. PLAYER.GET_PLAYER_NAME(pids), colors.black)
			end
		end
	end
end)

Detex = menu.list(menu.my_root(), "Detections", {}, "", function(); end)

menu.toggle_loop(Detex, "Bypass Drip Feed Vehicle", {}, "", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        local modelHash = players.get_vehicle_model(pid)
        for i, name in ipairs(unreleased_vehicles) do
            if modelHash == util.joaat(name) then
                notification("Is Driving An Unreleased Vehicle" .. PLAYER.GET_PLAYER_NAME(pid), colors.yellow)
            end
        end
    end
end)

menu.toggle_loop(Detex, "Modded Weapon", {}, "", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        for i, hash in ipairs(modded_weapons) do
            local weapon_hash = util.joaat(hash)
            if WEAPON.HAS_PED_GOT_WEAPON(player, weapon_hash, false) then
				notification("Is Using A Modded Weapon" .. PLAYER.GET_PLAYER_NAME(pid), colors.yellow)
                break
            end
        end
    end
end)

menu.toggle_loop(Detex, "Weapon In Interior", {}, "", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        if players.is_in_interior(pid) and WEAPON.IS_PED_ARMED(player, 7) then
			notification("Has A Weapon In An Interior" .. PLAYER.GET_PLAYER_NAME(pid), colors.yellow)
            break
        end
    end
end)

menu.toggle_loop(Detex, "Modded Animation", {}, "", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        if PED.IS_PED_USING_ANY_SCENARIO(player) then
			notification("Is In A Modded Scenario" .. PLAYER.GET_PLAYER_NAME(pid), colors.yellow)
        end
    end 
end)

---------------------------Online Player

GenerateFeatures = function(pid)

    menu.divider(menu.player_root(pid),"Aprio Script")
    parent  = menu.list(menu.player_root(pid), "Online Player" ,{}, "Online Player.", function();end)

	Trolling_Options = menu.list(parent, "Trolling Options", {}, "", function(); end)

	menu.action(Trolling_Options,"Explode player", {"explode"}, "", function()
		local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId))
		pos.z = pos.z - 1.0
		FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, 7, 1.0, true, false, 0, false)
	end)

	menu.action(Trolling_Options,"40.000 kw player", {"electrocute"}, "", function()
		local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId))
		pos.z = pos.z - 1.0
		FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, 70, 1.0, true, false, 0, false)
	end)

	menu.toggle_loop(Trolling_Options,"Water Loop", {}, "", function()
		local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId))
		pos.z = pos.z - 1.0
		FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, 13, 1.0, true, false, 0, false)
	end)

	menu.toggle_loop(Trolling_Options,"Flame Loop", {}, "", function()
		local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId))
		pos.z = pos.z - 1.0
		FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, 12, 1.0, true, false, 0, false)
	end)

	SE_Options = menu.list(parent, "Script Event", {}, "", function(); end)

	passivemode = menu.list(SE_Options, "Passive Mode", {}, "", function(); end)

	menu.action(passivemode,"Block", {}, "", function()
		if players.exists(pid) then
			send_script_event(65268844, pid, {pid, 1})
		end
	end)

	menu.action(passivemode,"Unblock", {}, "", function()
		if players.exists(pid) then
			send_script_event(65268844, pid, {pid, 0})
		end
	end)

	Collectibles = menu.list(SE_Options, "Collectibles", {}, "", function(); end)

	menu.action(Collectibles, "Give RP", {}, "Gives them ~175k RP.", function()
        util.trigger_script_event(1 << pid, {-1178972880, pid, 5, 0, 1, 1, 1})
        for i = 0, 9 do
            util.trigger_script_event(1 << pid, {-1178972880, pid, 0, i, 1, 1, 1})
            util.trigger_script_event(1 << pid, {-1178972880, pid, 1, i, 1, 1, 1})
            util.trigger_script_event(1 << pid, {-1178972880, pid, 3, i, 1, 1, 1})
            util.trigger_script_event(1 << pid, {-1178972880, pid, 10, i, 1, 1, 1})
        end
        for i = 0, 1 do
            util.trigger_script_event(1 << pid, {-1178972880, pid, 2, i, 1, 1, 1})
            util.trigger_script_event(1 << pid, {-1178972880, pid, 6, i, 1, 1, 1})
        end
        for i = 0, 19 do
            util.trigger_script_event(1 << pid, {-1178972880, pid, 4, i, 1, 1, 1})
        end
        for i = 0, 99 do
            util.trigger_script_event(1 << pid, {-1178972880, pid, 9, i, 1, 1, 1})
            util.yield()
        end
    end)

	local toggled = false    
    local animal_toggle
    animal_toggle = menu.toggle(Collectibles, "Turn Into Animal", {}, "Experimental", function(toggle)
        toggled = toggle
        while toggled do
            local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            if not PED.IS_PED_MODEL(player, 0x9C9EFFD8) and not PED.IS_PED_MODEL(player, 0x705E61F2) then
                util.toast("Player is already an animal.")
                menu.set_value(animal_toggle, false);
            break end
            util.trigger_script_event(1 << pid, {-1178972880, pid, 8, -1, 1, 1, 1})
            util.yield()
        end
    end)

	menu.action(SE_Options, "Force Casino CutScene", {}, "", function()
		if players.exists(pid) then
			send_script_event(2131601101, pid, {0, pid})
		end
	end)

	menu.action(SE_Options, "Send To Perico", {}, "", function()
		if players.exists(pid) then
			send_script_event(1361475530, pid, {1, pid})
		end
	end)
	
	menu.click_slider(SE_Options,"Send To Perico V2", {"Party Time"}, "1 = Beach Party (Plane), 2 = Beach Party (Instant), 3 = Back Home (Airport), 4 = Back Home (Beach)", 1, 4, 1, 1, function(on_change)
		if on_change == 1 then
			send_script_event(1214823473, pid, {0, 0, 3, 1, pid})
		end
		if on_change == 2 then
			send_script_event(1214823473, pid, {0, 0, 4, 1, pid})
		end
		if on_change == 3 then
			send_script_event(1214823473, pid, {0, 0, 3, 0, pid})
		end
		if on_change == 4 then
			send_script_event(1214823473, pid, {0, 0, 4, 0, pid})
		end
	end)

	menu.action(SE_Options, "Send To Warehouse", {}, "", function()
		if players.exists(pid) then
			send_script_event(2130458390, pid, {0, 1, math.random(1, 22), pid})
		end
	end)

	menu.action(SE_Options, "Force Freemode Mission", {}, "", function()
		if players.exists(pid) then
			send_script_event(1280542040, pid, {263, 4294967295, pid})
		end
	end)

	menu.action(SE_Options, "Infinite Loading Screen", {}, "", function()
        util.trigger_script_event(1 << pid, {-555356783, pid, 0, 32, NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
    end)

	menu.toggle(SE_Options, "Script Freeze", {}, "", function(toggle)
		util.trigger_script_event(1 << pid, {2130458390, pid, 0, 1, 0, 0, 0})
        util.yield(500)
	end)

	menu.toggle(SE_Options, "Hard Freeze", {}, "", function(toggle)
		util.trigger_script_event(1 << pid, {1214823473, pid, 0, 0, 0, 0, 0})
        util.yield(500)
    end)

	menu.toggle(SE_Options, "BlackScreen", {}, "", function(toggle)
        util.trigger_script_event(1 << pid, {-555356783, pid, math.random(1, 32), 32, NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
        util.yield(1000)
    end)

	entity = menu.list(parent, "Entity Manager", {}, "", function(); end)

	menu.action(entity,"Volatol Spam", {}, "spams volatols on target player, ", function()
		while not STREAMING.HAS_MODEL_LOADED(447548909) do
			STREAMING.REQUEST_MODEL(447548909)
			util.yield(10)
		end
		local self_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user())
        local OldCoords = ENTITY.GET_ENTITY_COORDS(self_ped) 
		ENTITY.SET_ENTITY_COORDS_NO_OFFSET(self_ped, 24, 7643.5, 19, true, true, true)
		notification("Started lagging", colors.black)
		local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
		local PlayerPedCoords = ENTITY.GET_ENTITY_COORDS(player_ped, true)
		spam_amount = 300
		while spam_amount >= 1 do
			entities.create_vehicle(447548909, PlayerPedCoords, 0)
			spam_amount = spam_amount - 1
			util.yield(10)
		end
		notification("Done", colors.green) 
	end)

	malicious = menu.list(parent, "Malicious", {}, "", function(); end)

	menu.action(malicious, "Aprio SE Kick", {}, "", function()
		if players.exists(pid) then
		util.trigger_script_event(1 << pid, {-1178972880, pid, 4, -1, 1, 1, 1})
		util.trigger_script_event(1 << pid, {111242367, pid, memory.script_global(2689235 + 1 + (pid * 453) + 318 + 7)})
		util.trigger_script_event(1 << pid, {1674887089, players.user(), memory.read_int(memory.script_global(1892703 + 1 + (pid * 599) + 510))})
		end
		notification("SE Kick Complet!!!", colors.green)
	end)

	menu.action(malicious, "Gentleman Crash", {}, "", function()
		menu.trigger_commands("smstext" .. PLAYER.GET_PLAYER_NAME(pid).. " " .. begcrash[math.random(1, #begcrash)])
		util.yield()
		menu.trigger_commands("smssend" .. PLAYER.GET_PLAYER_NAME(pid))
		util.yield(1500)
		if players.exists(pid) then
	 		send_script_event(495813132, pid, {pid, 2147483647, 2147483647, 2147483647, 1, 1})
			send_script_event(526822748, pid, {0, math.random(2000000000, 2147483647), pid})	
			send_script_event(-555356783, pid, {0, math.random(2000000000, 2147483647), pid})
		end
		notification("Crash Complet!!!", colors.green)
	end)

	menu.action(malicious, "Parachute Crash", {}, "NF Skid Parachute Crash", function()
        local user = players.user()
        local user_ped = players.user_ped()
        local model = util.joaat("h4_prop_bush_mang_ad") 
            util.yield(100)
            ENTITY.SET_ENTITY_VISIBLE(user_ped, false)
            for i = 0, 110 do
                PLAYER.SET_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(user, model)
                PED.SET_PED_COMPONENT_VARIATION(user_ped, 5, i, 0, 0)
                util.yield(50)
                PLAYER.CLEAR_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(user)
            end
            util.yield(250)
            ENTITY.SET_ENTITY_HEALTH(user_ped, 0) 
            local pos = players.get_position(user)
            NETWORK.NETWORK_RESURRECT_LOCAL_PLAYER(pos.x, pos.y, pos.z, 0, false, false, 0)
            ENTITY.SET_ENTITY_VISIBLE(user_ped, true)
    end)

	menu.toggle(malicious,"Report Spam", {}, "May lag your game when in progress", function(on)
		while on do
			if pid ~= players.user() then
				menu.trigger_commands("reportvcannoying " .. PLAYER.GET_PLAYER_NAME(pid))
				menu.trigger_commands("reportvchate " .. PLAYER.GET_PLAYER_NAME(pid))
				menu.trigger_commands("reportannoying " .. PLAYER.GET_PLAYER_NAME(pid))
				menu.trigger_commands("reporthate " .. PLAYER.GET_PLAYER_NAME(pid))
				menu.trigger_commands("reportexploits " .. PLAYER.GET_PLAYER_NAME(pid))
				menu.trigger_commands("reportbugabuse " .. PLAYER.GET_PLAYER_NAME(pid))
			end
			util.yield()
		end
	end)

end

---------------listener

players.on_join(GenerateFeatures)
for pid = 0,30 do 
	if players.exists(pid) then
		GenerateFeatures(pid)
	end
end

while true do
	if uncageMe then 
		uncage(players.user_ped())
	end
	util.yield(10)
end