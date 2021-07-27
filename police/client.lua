local isInService = false
local rank = "inconnu"
local checkpoints = {}
local existingVeh = nil
local handCuffed = false
local isMedic = false
isCop = false
local isDoctor = false
local isDead = false
local isNews = false
local currentCallSign = ""
local shotRecently = false
local currentUIJob = "unemployed"
local canBeTackled = true
local disableRagdoll = false

-- Location to enable an officer service
local escorting = false

otherid = 0
escort = false
keystroke = 49
triggerkey = false

dragging = false
beingDragged = false

escortStart = false
shitson = false

exports("getCurrentJob", function()
  return currentUIJob
end)


function DrawText3DVehicle(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())

    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end


local rankService = 0
RegisterNetEvent('uiTest:setRank')
AddEventHandler('uiTest:setRank', function(result)
    rankService = result
end)

Citizen.CreateThread(function()
	while true do
		local coords = GetEntityCoords(PlayerPedId())
		TriggerServerEvent("np-base:updatecoords",coords.x,coords.y,coords.z)
		Wait(13000)
	end
end)

RegisterNetEvent('pd:deathcheck')
AddEventHandler('pd:deathcheck', function()
  if not isDead then
    isDead = true
  else
    isDead = false
  end
end)

RegisterNetEvent('evidence:container')
AddEventHandler('evidence:container', function(arg)
	if tonumber(arg) == nil then
		return
	end
	local cid = exports["isPed"]:isPed("cid")
	TriggerServerEvent("server-inventory-open", GetEntityCoords(PlayerPedId()), cid, "1", "Case-"..arg);
end)

function vehCruise()
	if not handCuffed and GetLastInputMethod(2) then
		local isInVeh = IsPedInAnyVehicle(PlayerPedId(), false)
		if isInVeh then
			TriggerEvent("toggle:cruisecontrol")
		end
	end
end

function plyTackel()
	if not handCuffed and GetLastInputMethod(2) then
		local isInVeh = IsPedInAnyVehicle(PlayerPedId(), false)
		if not isInVeh and GetEntitySpeed(PlayerPedId()) > 2.5 then
			TryTackle()
		end
	end
end

Citizen.CreateThread(function()
  exports["np-keybinds"]:registerKeyMapping("", "Vehicle", "Cruise Control", "+vehCruise", "-vehCruise", "X")
  RegisterCommand('+vehCruise', vehCruise, false)
  RegisterCommand('-vehCruise', function() end, false)
  
  exports["np-keybinds"]:registerKeyMapping("", "Player", "Tackle", "+plyTackel", "-plyTackel")
  RegisterCommand('+plyTackel', plyTackel, false)
  RegisterCommand('-plyTackel', function() end, false)
end)

function getIsCop()
	return isCop
end

function getIsInService()
	return isCop or isMedic
end

function getIsCuffed()
	return handCuffed
end

RegisterNetEvent("np-jobmanager:playerBecameJob")
AddEventHandler("np-jobmanager:playerBecameJob", function(job, name, notify)
	if isMedic and job ~= "ems" then isMedic = false isInService = false end
	if isCop and job ~= "police" or job ~= "doc" then isCop = false isInService = false end
	if isNews and job ~= "news" then isNews = false isInService = false end
	if job == "police" then isCop = true TriggerServerEvent('police:getRank',"police") isInService = true end
	if job == "doc" then isCop = true TriggerServerEvent('police:getRank',"doc") isInService = true end
	if job == "ems" then isMedic = true TriggerServerEvent('police:getRank',"ems") isInService = true end
	if job == "doctor" then isDoctor = true TriggerServerEvent('police:getRank',"doctor") isInService = true end
	if job == "news" then isNews = true isInService = false end
  currentUIJob = job
end)

RegisterNetEvent("fire:stopClientFires")
AddEventHandler("fire:stopClientFires", function(x,y,z,rad)
	if #(vector3(x,y,z) - GetEntityCoords(PlayerPedId())) < 100 then
		StopFireInRange(x,y,z,rad)
	end
end)


local inmenus = false

RegisterNetEvent('inmenu')
AddEventHandler('inmenu', function(change)
	inmenus = change
end)


TimerEnabled = false



function policeCuff()
	if not inmenus and isCop then
		local isInVeh = IsPedInAnyVehicle(PlayerPedId(), false)
		if isInVeh then
			TriggerEvent("platecheck:frontradar")
		else
			if not IsControlPressed(0,19) then
				TriggerEvent("police:cuffFromMenu",false)
			end
		end
	end
end

function medicRevive()
	if not inmenus and (isMedic or isDoctor or isDoc) then
		TriggerEvent("revive")
	end
end

function emsHeal()
	if not inmenus and (isMedic or isDoctor or isDoc) then
		TriggerEvent("ems:heal")
	end
end

function policeEscort()
	if not inmenus and (isMedic or isDoctor or isCop) then
		local isInVeh = IsPedInAnyVehicle(PlayerPedId(), false)
		if isInVeh and isCop then
			TriggerEvent("startSpeedo")
		else
			TriggerEvent("escortPlayer") 
		end
	end
end

function policeSeat()
	if not inmenus and (isMedic or isCop) then
		TriggerEvent("police:forceEnter")
	end
end

function policeUnCuff()
	if not inmenus and isCop then
		local isInVeh = IsPedInAnyVehicle(PlayerPedId(), false)
		if isInVeh then
			TriggerEvent("platecheck:rearradar")
		else
			TriggerEvent("police:uncuffMenu")
		end
	end
end

function policeSoft()
	if not inmenus and isCop then
		local isInVeh = IsPedInAnyVehicle(PlayerPedId(), false)
		if not isInVeh then
			TriggerEvent("police:cuffFromMenu",true)
		end
	end
end

Citizen.CreateThread( function()
	RegisterCommand('+policeCuff', policeCuff, false)
	RegisterCommand('-policeCuff', function() end, false)
	exports["np-keybinds"]:registerKeyMapping("", "Gov", "Cuff / Radar Front", "+policeCuff", "-policeCuff", "UP")

	RegisterCommand('+medicRevive', medicRevive, false)
	RegisterCommand('-medicRevive', function() end, false)
	exports["np-keybinds"]:registerKeyMapping("", "Gov", "EMS Revive", "+medicRevive", "-medicRevive")

	RegisterCommand('+emsHeal', emsHeal, false)
	RegisterCommand('-emsHeal', function() end, false)
	exports["np-keybinds"]:registerKeyMapping("", "Gov", "EMS Heal", "+emsHeal", "-emsHeal")

	RegisterCommand('+policeEscort', policeEscort, false)
	RegisterCommand('-policeEscort', function() end, false)
	exports["np-keybinds"]:registerKeyMapping("", "Gov", "Escort / Speedo", "+policeEscort", "-policeEscort", "LEFT")

	RegisterCommand('+policeSeat', policeSeat, false)
	RegisterCommand('-policeSeat', function() end, false)
	exports["np-keybinds"]:registerKeyMapping("", "Gov", "Force into Vehicle", "+policeSeat", "-policeSeat", "RIGHT")

	RegisterCommand('+policeUnCuff', policeUnCuff, false)
	RegisterCommand('-policeUnCuff', function() end, false)
	exports["np-keybinds"]:registerKeyMapping("", "Gov", "UnCuff / Radar Rear", "+policeUnCuff", "-policeUnCuff", "DOWN")

	RegisterCommand('+policeSoft', policeSoft, false)
	RegisterCommand('-policeSoft', function() end, false)
	exports["np-keybinds"]:registerKeyMapping("", "Gov", "Soft Cuff", "+policeSoft", "-policeSoft")
end)



Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		
		if escort and IsEntityDead(GetPlayerPed(GetPlayerFromServerId(otherid))) then
			DetachEntity(PlayerPedId(), true, false)
			shitson = false
			escort = false
			local pos = GetOffsetFromEntityInWorldCoords(GetPlayerPed(GetPlayerFromServerId(otherid)), 0.0, 0.8, 2.8)
			SetEntityCoords(PlayerPedId(),pos)
		end

		if escort or beingDragged then
			local ped = GetPlayerPed(GetPlayerFromServerId(otherid))
			local myped = PlayerPedId()
			if escort then
				x,y,z = 0.54, 0.44, 0.0
			else
				x,y,z = 0.0, 0.44, 0.0
			end
			if not beingDragged then
				AttachEntityToEntity(myped, ped, 11816, x, y, z, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
			else
				AttachEntityToEntity(myped, ped, 1, -0.68, -0.2, 0.94, 180.0, 180.0, 60.0, 1, 1, 0, 1, 0, 1)
			end
			shitson = true
		else
			if not beingDragged and not escort and shitson then
				DetachEntity(PlayerPedId(), true, false)
				shitson = false
				Citizen.Trace("no escort or drag")
				ClearPedTasksImmediately(PlayerPedId())
			end
		end
		if dragging then
			if not IsEntityPlayingAnim(PlayerPedId(), "missfinale_c2mcs_1", "fin_c2_mcs_1_camman", 3) then
				LoadAnimationDictionary( "missfinale_c2mcs_1" )
				TaskPlayAnim(PlayerPedId(), "missfinale_c2mcs_1", "fin_c2_mcs_1_camman", 1.0, 1.0, -1, 50, 0, 0, 0, 0)
			end
			local dead = exports["isPed"]:isPed("dead")
			if dead or IsControlJustPressed(0, 38) or (`WEAPON_UNARMED` ~= GetSelectedPedWeapon(PlayerPedId())) then
				dragging = false
				ClearPedTasks(PlayerPedId())
				TriggerServerEvent("dragPlayer:disable")
			end

		end
		if beingDragged then
			if not IsEntityPlayingAnim(PlayerPedId(), "amb@world_human_bum_slumped@male@laying_on_left_side@base", "base", 3) then
				LoadAnimationDictionary( "amb@world_human_bum_slumped@male@laying_on_left_side@base" )
				TaskPlayAnim(PlayerPedId(), "amb@world_human_bum_slumped@male@laying_on_left_side@base", "base", 8.0, 8.0, -1, 1, 999.0, 0, 0, 0)
      end
      if IsControlJustPressed(0, 38) then
				TriggerServerEvent("dragPlayer:disable", otherid)
			end
		end
		if disabledWeapons then
			DisableControlAction(1, 37, true) --Disables INPUT_SELECT_WEAPON (tab) Actions
			DisablePlayerFiring(PlayerPedId(), true) -- Disable weapon firing
		end
		if beingDragged or escort then
			DisableControlAction(1, 23, true)  -- F
			DisableControlAction(1, 106, true) -- VehicleMouseControlOverride
			DisableControlAction(1, 140, true) --Disables Melee Actions
			DisableControlAction(1, 141, true) --Disables Melee Actions
			DisableControlAction(1, 142, true) --Disables Melee Actions
			DisableControlAction(1, 37, true) --Disables INPUT_SELECT_WEAPON (tab) Actions
			DisablePlayerFiring(PlayerPedId(), true) -- Disable weapon firing
			DisableControlAction(2, 32, true)
			DisableControlAction(1, 33, true)
			DisableControlAction(1, 34, true)
			DisableControlAction(1, 35, true)
			DisableControlAction(1, 37, true) --Disables INPUT_SELECT_WEAPON (tab) Actions
			DisableControlAction(0, 59)
			DisableControlAction(0, 60)
			DisableControlAction(2, 31, true)
			SetCurrentPedWeapon(PlayerPedId(), `WEAPON_UNARMED`, true)
		end
		if TimerEnabled then
			DisableControlAction(1, 140, true) --Disables Melee Actions
			DisableControlAction(1, 141, true) --Disables Melee Actions
			DisableControlAction(1, 142, true) --Disables Melee Actions
			DisableControlAction(1, 37, true) --Disables INPUT_SELECT_WEAPON (tab) Actions
			DisablePlayerFiring(PlayerPedId(), true) -- Disable weapon firing
		end
	end
end)

-- INFO: HANDCUFF ANIMATION THREAD
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
			
		if handCuffedWalking or handCuffed then
			if handCuffedWalking and IsPedClimbing(PlayerPedId()) then
				Wait(500)
				SetPedToRagdoll(PlayerPedId(), 3000, 1000, 0, 0, 0, 0)
			end
			if handCuffed and CanPedRagdoll(PlayerPedId()) then
				SetPedCanRagdoll(PlayerPedId(), false)
			end

			number = 49

			if handCuffed then
				number = 17
			else
				number = 49
			end

			DisableControlAction(1, 23, true)  -- F
			DisableControlAction(1, 106, true) -- VehicleMouseControlOverride
			DisableControlAction(1, 140, true) --Disables Melee Actions
			DisableControlAction(1, 141, true) --Disables Melee Actions
			DisableControlAction(1, 142, true) --Disables Melee Actions
			DisableControlAction(1, 37, true) --Disables INPUT_SELECT_WEAPON (tab) Actions
			DisablePlayerFiring(PlayerPedId(), true) -- Disable weapon firing
			local dead = exports["isPed"]:isPed("dead")
			local intrunk = exports["isPed"]:isPed("intrunk")
			local isInBeatMode = exports["police"]:getIsInBeatmode()

			if (not IsEntityPlayingAnim(PlayerPedId(), "mp_arresting", "idle", 3) and not dead and not intrunk and not isInBeatMode) or (IsPedRagdoll(PlayerPedId()) and not dead and not intrunk and not isInBeatMode) then
					RequestAnimDict('mp_arresting')
				while not HasAnimDictLoaded("mp_arresting") do
					Citizen.Wait(1)
				end
				TaskPlayAnim(PlayerPedId(), "mp_arresting", "idle", 8.0, 8.0, -1, number, 0.0, 0, 0, 0)
			end
			if dead or intrunk or isInBeatMode then
				Citizen.Wait(1000)
			end
		end
	end
end)


Citizen.CreateThread(function()
	while true do
		Citizen.Wait(4000)

		if not handCuffed and not CanPedRagdoll(PlayerPedId()) then
			SetPedCanRagdoll(PlayerPedId(), true)
		end

	end
end)

local hasBeenOnFire = 0
local ShouldBeOnFire = 0
Citizen.CreateThread( function()
	while true do
		Citizen.Wait(600)
		local player = PlayerPedId()
		local playerPos = GetEntityCoords(player)
		local isInVeh = IsPedInVehicle(player,GetVehiclePedIsIn(player, false),false)
		if not isInVeh then ShouldBeOnFire = 0 end
		if GetNumberOfFiresInRange(playerPos,1.7) > 1 and hasBeenOnFire < 4 then

			local b, closestFire = GetClosestFirePos(playerPos)
			local zDist = math.abs(closestFire.z - playerPos.z)

			if zDist <= 1.0 then
				if isInVeh then
					ShouldBeOnFire = ShouldBeOnFire + 1
					if ShouldBeOnFire >= 7 then
						playerOnFire(player)
					end
				else
					playerOnFire(player)
				end
			end
		elseif hasBeenOnFire >= 4 then
			ShouldBeOnFire = 0
			hasBeenOnFire = 0
			StopEntityFire(player)
		end
	end
end)

function playerOnFire(player)
	ShouldBeOnFire = 0
	hasBeenOnFire = hasBeenOnFire + 1
	StartEntityFire(player)
	local health = (GetEntityHealth(player) - 25)
	SetEntityHealth(player,health)
end

isDoctor = false
RegisterNetEvent("isDoctor")
AddEventHandler("isDoctor", function()
	TriggerServerEvent("jobssystem:jobs", "doctor")
	isDoctor = true
end)

RegisterNetEvent("np-signin:signoff")
AddEventHandler("np-signin:signoff", function()
	isDoctor = false
	isTher = false
end)

isTher = false
RegisterNetEvent("isTherapist")
AddEventHandler("isTherapist", function()
	TriggerServerEvent("jobssystem:jobs", "therapist")
	isTher = true
end)

isJudge = false
RegisterNetEvent("isJudge")
AddEventHandler("isJudge", function()
	TriggerServerEvent("jobssystem:jobs", "judge")
	TriggerServerEvent('police:getRank',"judge")
	isJudge = true
end)

RegisterNetEvent("isJudgeOff")
AddEventHandler("isJudgeOff", function()
    isJudge = false
end)


RegisterNetEvent("nowIsCop")
AddEventHandler("nowIsCop", function(cb)
	cb(isCop)
end)

RegisterNetEvent('police:noLongerCop')
AddEventHandler('police:noLongerCop', function()
	isCop = false
	isInService = false
	currentCallSign = ""

	local playerPed = PlayerPedId()

	TriggerServerEvent("myskin_customization:wearSkin")
  TriggerServerEvent("police:officerOffDuty")
	TriggerServerEvent('tattoos:retrieve')
	TriggerServerEvent('Blemishes:retrieve')
	RemoveAllPedWeapons(playerPed)

	TriggerEvent("attachWeapons")
	if(existingVeh ~= nil) then

		Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(existingVeh))
		existingVeh = nil
	end
end)



RegisterNetEvent('police:checkPhone')
AddEventHandler('police:checkPhone', function()
	t, distance = GetClosestPlayer()
	if(distance ~= -1 and distance < 5) then
		TriggerServerEvent("phone:getSMSOther",GetPlayerServerId(t))
	else
		TriggerEvent("DoLongHudText", "No player near you!",2)
	end
end)

RegisterNetEvent('police:checkLicensePlate')
AddEventHandler('police:checkLicensePlate', function(plate)
	if isCop then
		TriggerServerEvent('np:vehicles:plateCheck', plate)
	else
		TriggerEvent("DoLongHudText", "Please take your service first!",2)
	end
end)

RegisterNetEvent('police:deletecrimesciv')
AddEventHandler('police:deletecrimesciv', function()
	if(isJudge) then
		t, distance = GetClosestPlayer()
		if(distance ~= -1 and distance < 7) then
			TriggerServerEvent("police:deletecrimes", GetPlayerServerId(t))
		else
			TriggerEvent("DoLongHudText", "No player near you!",2)
		end
	else
		TriggerEvent("DoLongHudText", "Please take your service first!",2)
	end
end)

RegisterNetEvent('police:checkBank')
AddEventHandler('police:checkBank', function(pArgs, pEntity)
	TriggerServerEvent("police:targetCheckBank", GetPlayerServerId(NetworkGetPlayerIndexFromPed(pEntity)))
end)

RegisterNetEvent('police:checkInventory')
AddEventHandler('police:checkInventory', function(pArgs, pEntity)
  TriggerServerEvent("police:targetCheckInventory", GetPlayerServerId(NetworkGetPlayerIndexFromPed(pEntity)), pArgs[1])
end)

RegisterNetEvent("police:rob")
AddEventHandler("police:rob", function(pArgs, pEntity)
  RequestAnimDict("random@shop_robbery")
  while not HasAnimDictLoaded("random@shop_robbery") do
    Citizen.Wait(0)
  end

  local lPed = PlayerPedId()
  ClearPedTasksImmediately(lPed)

  TaskPlayAnim(lPed, "random@shop_robbery", "robbery_action_b", 8.0, -8, -1, 16, 0, 0, 0, 0)
  local finished = exports["np-taskbar"]:taskBar(15000,"Robbing",false,true,nil,false,nil,5,pEntity)

  if finished == 100 then
    ClearPedTasksImmediately(lPed)
    TriggerServerEvent("police:rob", GetPlayerServerId(NetworkGetPlayerIndexFromPed(pEntity)))
    TriggerServerEvent("police:targetCheckInventory", GetPlayerServerId(NetworkGetPlayerIndexFromPed(pEntity)), false)
  end
end)

RegisterNetEvent("police:seizeCash")
AddEventHandler("police:seizeCash", function()

		t, distance, closestPed = GetClosestPlayer()

		if distance ~= -1 and distance < 5 then
			TriggerServerEvent("police:SeizeCash", GetPlayerServerId(t))
		else
			TriggerEvent("DoLongHudText", "No player near you!",2)
		end

end)

RegisterNetEvent('police:seizeInventory')
AddEventHandler('police:seizeInventory', function()
		t, distance = GetClosestPlayer()
		if(distance ~= -1 and distance < 5) then
			TriggerServerEvent("police:targetseizeInventory", GetPlayerServerId(t))
		else

			TriggerEvent("DoLongHudText", "No player near you!",2)
		end
end)

function loadAnimDict( dict )
	while ( not HasAnimDictLoaded( dict ) ) do
		RequestAnimDict( dict )
		Citizen.Wait(0)
	end
end

inanim = false
cancelled = false
RegisterNetEvent( 'KneelHU' )
AddEventHandler( 'KneelHU', function()
	local player = GetPlayerPed( -1 )
	if ( DoesEntityExist( player ) and not IsEntityDead( player )) then
		loadAnimDict( "random@arrests" )
		loadAnimDict( "random@arrests@busted" )
		TaskPlayAnim( player, "random@arrests@busted", "enter", 8.0, 1.0, -1, 2, 0, 0, 0, 0 )
		local finished = exports["np-taskbar"]:taskBar(2500,"Surrendering")
	end
end )

function KneelMedic()
	local player = GetPlayerPed( -1 )
	if ( DoesEntityExist( player ) and not IsEntityDead( player )) then
		loadAnimDict( "amb@medic@standing@tendtodead@enter" )
		loadAnimDict( "amb@medic@standing@timeofdeath@enter" )
		loadAnimDict( "amb@medic@standing@tendtodead@idle_a" )
		loadAnimDict( "random@crash_rescue@help_victim_up" )
		TaskPlayAnim( player, "amb@medic@standing@tendtodead@enter", "enter", 8.0, 1.0, -1, 2, 0, 0, 0, 0 )
		Wait (1000)
		TaskPlayAnim( player, "amb@medic@standing@tendtodead@idle_a", "idle_b", 8.0, 1.0, -1, 9, 0, 0, 0, 0 )
		Wait (3000)
		TaskPlayAnim( player, "amb@medic@standing@tendtodead@exit", "exit_flee", 8.0, 1.0, -1, 2, 0, 0, 0, 0 )
		Wait (1000)
		TaskPlayAnim( player, "amb@medic@standing@timeofdeath@enter", "enter", 8.0, 1.0, -1, 128, 0, 0, 0, 0 )
		Wait (500)
		TaskPlayAnim( player, "amb@medic@standing@timeofdeath@enter", "helping_victim_to_feet_player", 8.0, 1.0, -1, 128, 0, 0, 0, 0 )
	end
end

RegisterNetEvent('revive')
AddEventHandler('revive', function(t)

	t, distance = GetClosestPlayer()
	if(t and (distance ~= -1 and distance < 10)) then
		TriggerServerEvent("reviveGranted", GetPlayerServerId(t))
		KneelMedic()
		local removed = RPC.execute("take100", GetPlayerServerId(t))
		if removed then
			TriggerServerEvent("job:Pay", "Player Revival", 50)
		end
	else
		TriggerEvent("DoLongHudText", "No player near you (maybe get closer)!",2)
	end

end)


function VehicleInFront()
    local pos = GetEntityCoords(PlayerPedId())
    local entityWorld = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 3.0, 0.0)
    local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10, PlayerPedId(), 0)
    local a, b, c, d, result = GetRaycastResult(rayHandle)
    return result
end


RegisterNetEvent('police:woxy')
AddEventHandler('police:woxy', function()
	local vehFront = VehicleInFront()
	if vehFront > 0 then
  		loadAnimDict('anim@narcotics@trash')
		TaskPlayAnim(PlayerPedId(),'anim@narcotics@trash', 'drop_front',0.9, -8, 3800, 49, 3.0, 0, 0, 0)
		local finished = exports["np-taskbar"]:taskBar(4000,"Grabbing Scuba Gear")
	  	if finished == 100 then
	  		loadAnimDict('anim@narcotics@trash')
    		TaskPlayAnim(PlayerPedId(),'anim@narcotics@trash', 'drop_front',0.9, -8, 1900, 49, 3.0, 0, 0, 0)
			TriggerEvent("UseOxygenTank")
		end
	end
end)

frozenEnabled = false
FreezeEntityPosition(PlayerPedId(), false)
RegisterNetEvent('police:freeze')
AddEventHandler('police:freeze', function(ped)
	if(isCop) then
		ped, distance = GetClosestPlayer()
		if(distance ~= -1 and distance < 5) then
	      	if frozenEnabled then
				FreezeEntityPosition(ped, false)
				SetPlayerInvincible(ped, false)
				SetEntityCollision(ped, true)
				TriggerEvent("DoLongHudText", "Target Unshackled!",1)
				frozenEnabled = false
	      	else
				SetEntityCollision(ped, false)
				FreezeEntityPosition(ped, true)
				SetPlayerInvincible(ped, true)
				frozenEnabled = true
				TriggerEvent("DoLongHudText", "Target Shackled!",1)
	      	end
	    end
	else
		TriggerEvent("DoLongHudText", "Please take your service first!",2)
	end
end)

function isOppositeDir(a,b)
	local result = 0
	if a < 90 then
		a = 360 + a
	end
	if b < 90 then
		b = 360 + b
	end
	if a > b then
		result = a - b
	else
		result = b - a
	end
	if result > 110 then
		return true
	else
		return false
	end
end

RegisterNetEvent('police:remmaskAccepted')
AddEventHandler('police:remmaskAccepted', function()
	TriggerEvent("facewear:adjust", {
		{
			id = 1,
			shouldRemove = true
		},
		{
			id = 2,
			shouldRemove = true
		},
		{
			id = 3,
			shouldRemove = true
		},
		{
			id = 4,
			shouldRemove = true
		}
	}, 0, true)
end)





RegisterNetEvent('police:remmask')
AddEventHandler('police:remmask', function(t)
	t, distance = GetClosestPlayer()
	if (distance ~= -1 and distance < 5) then
		if not IsPedInVehicle(t,GetVehiclePedIsIn(t, false),false) then
			TriggerServerEvent("police:remmaskGranted", GetPlayerServerId(t))
			AnimSet = "mp_missheist_ornatebank"
			AnimationOn = "stand_cash_in_bag_intro"
			AnimationOff = "stand_cash_in_bag_intro"
			loadAnimDict( AnimSet )
			TaskPlayAnim( PlayerPedId(), AnimSet, AnimationOn, 8.0, -8, -1, 49, 0, 0, 0, 0 )
			Citizen.Wait(500)
			ClearPedTasks(PlayerPedId())
		end
	else
		TriggerEvent("DoLongHudText", "No player near you (maybe get closer)!",2)
	end
end)


tryingcuff = false
RegisterNetEvent('police:cuff2')
AddEventHandler('police:cuff2', function(t,softcuff)
	if not tryingcuff then
		tryingcuff = true
		t, distance, ped = GetClosestPlayer()
		Citizen.Wait(1500)
		if(distance ~= -1 and #(GetEntityCoords(ped) - GetEntityCoords(PlayerPedId())) < 2.5 and GetEntitySpeed(ped) < 1.0) then
			TriggerServerEvent("police:cuffGranted2", GetPlayerServerId(t), softcuff)
		else
			ClearPedSecondaryTask(PlayerPedId())
			TriggerEvent("DoLongHudText", "No player near you (maybe get closer)!",2)
		end
		tryingcuff = false
	end
end)

RegisterNetEvent('police:cuff')
AddEventHandler('police:cuff', function(t)
	if not tryingcuff then
		TriggerEvent("Police:ArrestingAnim")
		tryingcuff = true
		t, distance = GetClosestPlayer()
		if(distance ~= -1 and distance < 1.5) then
			TriggerServerEvent("police:cuffGranted", GetPlayerServerId(t))
		else
			TriggerEvent("DoLongHudText", "No player near you (maybe get closer)!",2)
		end
		tryingcuff = false
	end
end)

local cuffstate = false


RegisterNetEvent('civ:cuffFromMenu')
AddEventHandler('civ:cuffFromMenu', function()
	TriggerEvent("police:cuffFromMenu",false)
end)

RegisterNetEvent('police:cuffFromMenu')
AddEventHandler('police:cuffFromMenu', function(softcuff)
	if not cuffstate and not handCuffed and not IsPedRagdoll(PlayerPedId()) and not IsPlayerFreeAiming(PlayerId()) and not IsPedInAnyVehicle(PlayerPedId(), false) then
		cuffstate = true

		t, distance = GetClosestPlayer()
		if(distance ~= -1 and distance < 2 and not IsPedRagdoll(PlayerPedId())) then
			if softcuff then
				TriggerEvent("DoLongHudText", "You soft cuffed a player!",1)
			else
				TriggerEvent("DoLongHudText", "You hard cuffed a player!",1)
			end

			TriggerEvent("police:cuff2", GetPlayerServerId(t),softcuff)
		end

		cuffstate = false
	end
end)

RegisterNetEvent('police:gsr')
AddEventHandler('police:gsr', function(pArgs, pEntity)
	TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_STAND_MOBILE", 0, 1)
	local finished = exports["np-taskbar"]:taskBar(15000, "GSR Testing")
	if finished == 100 then
		TriggerServerEvent("police:gsrGranted", GetPlayerServerId(NetworkGetPlayerIndexFromPed(pEntity)))
	end
end)

RegisterNetEvent('police:uncuffMenu')
AddEventHandler('police:uncuffMenu', function()
	t, distance = GetClosestPlayer()
	if(distance ~= -1 and distance < 2) then
		TriggerEvent("animation:PlayAnimation","uncuff")
		Wait(3000)
		TriggerServerEvent("falseCuffs", GetPlayerServerId(t))
		TriggerEvent("DoLongHudText", "You uncuffed a player!",1)
		TriggerServerEvent('police:setCuffState', GetPlayerServerId(t), false)
	else
		TriggerEvent("DoLongHudText", "No player near you (maybe get closer)!",2)
	end
end)

-- hopefully resolve the death / revive restrain bug.

RegisterNetEvent('resetCuffs')
AddEventHandler('resetCuffs', function()
	ClearPedTasksImmediately(PlayerPedId())
	handcuffType = 49
	handCuffed = false
	handCuffedWalking = false
	TriggerEvent("police:currentHandCuffedState",handCuffed,handCuffedWalking)
	TriggerEvent("handcuffed",false)
end)

RegisterNetEvent('falseCuffs')
AddEventHandler('falseCuffs', function()
	ClearPedTasksImmediately(PlayerPedId())
	handcuffType = 49
	handCuffed = false
	handCuffedWalking = false
	exports["police"]:setIsInBeatmode(false)
	TriggerEvent("police:currentHandCuffedState",handCuffed,handCuffedWalking)
	TriggerEvent("handcuffed",false)
end)




local cuffAttemptCount = 0
local lastCuffAttemptTime = 0
local lastCuffBreakoutTime = 0

RPC.register("police:canBeCuffed", function(pSource)
	if lastCuffBreakoutTime + 15000 < GetGameTimer() then
		return true
	end

	return false
end)

RegisterNetEvent('police:getArrested2')
AddEventHandler('police:getArrested2', function(cuffer)

	ClearPedTasksImmediately(PlayerPedId())
	CuffAnimation(cuffer)

	local cuffPed = GetPlayerPed(GetPlayerFromServerId(tonumber(cuffer)))
	local finished = 0
	if lastCuffAttemptTime + 60000 < GetGameTimer() then
		cuffAttemptCount = 0
		lastCuffAttemptTime = 0
	end
	if not isDead and cuffAttemptCount < 4 then
		cuffAttemptCount = cuffAttemptCount + 1
		lastCuffAttemptTime = GetGameTimer()
		TriggerEvent("police:recentlyAttemptedCuffed", GetGameTimer())
		finished = exports["np-ui"]:taskBarSkill(1000, 15)
	end


	local inRange = #(GetEntityCoords( PlayerPedId()) - GetEntityCoords(cuffPed)) < 2.5
	if inRange and finished ~= 100 then
		TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 3.0, 'handcuff', 0.4)
		handcuffType = 16
		handCuffed = true
		handCuffedWalking = false
		TriggerEvent("police:currentHandCuffedState",handCuffed,handCuffedWalking)
		TriggerEvent("DoLongHudText", "Cuffed!",1)
		TriggerEvent("handcuffed",true)

	elseif inRange and finished == 100 then
		canBeTackled = false
		disableRagdoll = true
		lastCuffBreakoutTime = GetGameTimer()

		Wait(15000)
		canBeTackled = true
		disableRagdoll = false
		SetPedCanRagdoll(PlayerPedId(), true)
	end

end)

function CuffAnimation(cuffer)
	loadAnimDict("mp_arrest_paired")
	local cuffer = GetPlayerPed(GetPlayerFromServerId(tonumber(cuffer)))
	local dir = GetEntityHeading(cuffer)
	--TriggerEvent('police:cuffAttach',cuffer)
	SetEntityCoords(PlayerPedId(), GetOffsetFromEntityInWorldCoords(cuffer, 0.0, 0.45, 0.0))
	Citizen.Wait(100)
	SetEntityHeading(PlayerPedId(),dir)
	TaskPlayAnim(PlayerPedId(), "mp_arrest_paired", "crook_p2_back_right", 8.0, -8, -1, 32, 0, 0, 0, 0)
end

RegisterNetEvent('police:cuffAttach')
AddEventHandler('police:cuffAttach', function(cuffer)
	local count = 350
	while count > 0 do
		Citizen.Wait(1)
		count = count - 1
		AttachEntityToEntity(PlayerPedId(), cuffer, 11816, 0.0, 0.45, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
	end
	DetachEntity(PlayerPedId(), true, false)
end)

RegisterNetEvent('police:cuffTransition')
AddEventHandler('police:cuffTransition', function()
	loadAnimDict("mp_arrest_paired")
	Citizen.Wait(100)
	TaskPlayAnim(PlayerPedId(), "mp_arrest_paired", "cop_p2_back_right", 8.0, -8, -1, 48, 0, 0, 0, 0)
	Citizen.Wait(3500)
	ClearPedTasksImmediately(PlayerPedId())
end)

RegisterNetEvent('police:getArrested')
AddEventHandler('police:getArrested', function(cuffer)

		if(handCuffed) then
			Citizen.Wait(3500)
			ClearPedTasksImmediately(PlayerPedId())
			handCuffed = false
			handcuffType = 49
			TriggerEvent("police:currentHandCuffedState",handCuffed,handCuffedWalking)
			TriggerEvent("handcuffed",true)
		else
			ClearPedTasksImmediately(PlayerPedId())
			CuffAnimation(cuffer)

			local cuffPed = GetPlayerPed(GetPlayerFromServerId(tonumber(cuffer)))
			if Vdist2( GetEntityCoords( GetPlayerPed(-1) , GetEntityCoords(cuffPed) ) ) < 1.5 then
				handcuffType = 49
				handCuffed = true
				TriggerEvent("police:currentHandCuffedState",handCuffed,handCuffedWalking)
				TriggerEvent("handcuffed",false)
			end
		end
end)


RegisterNetEvent('police:jailing')
AddEventHandler('police:jailing', function(args)
	TriggerServerEvent('police:jailGranted', args )
end)

RegisterNetEvent('police:payFines')
AddEventHandler('police:payFines', function(amount)
	local success, message = RPC.execute("DoStateForfeiture", amount)
	
	if not success then
		TriggerEvent('chatMessage', "BILL ", {255, 140, 0}, message)
		return
	end

	TriggerEvent('chatMessage', "BILL ", {255, 140, 0}, "You were billed for ^2" .. tonumber(amount) .. " ^0dollar(s).")
end)

RegisterNetEvent('police:undoFines')
AddEventHandler('police:undoFines', function(amount)
	local success, message = RPC.execute("UndoStateForfeiture", amount)
	
	if not success then
		TriggerEvent('chatMessage', "BILL ", {255, 140, 0}, message)
		return
	end

	TriggerEvent('chatMessage', "BILL ", {255, 140, 0}, "You were reimbursed for ^2" .. tonumber(amount) .. " ^0dollar(s).")
end)

RegisterNetEvent('police:forceEnter')
AddEventHandler('police:forceEnter', function()
	local plyPed = PlayerPedId()

	if IsEntityAttachedToAnyPed(plyPed) then
		TriggerEvent("DoLongHudText", "You cannot seat while being escorted!", 2)
		return
	end

	local tPed, tPly, tServerId = getClosestPlayer(GetEntityCoords(plyPed), 3.0)

	if tPed == nil or tPed < 0 then
		TriggerEvent("DoLongHudText", "No player near you (maybe get closer)!", 2)
		return
	end

	local isInVeh = IsPedInAnyVehicle(tPed, true)

	if isInVeh then
		TriggerEvent("unseatPlayer")
		return
	else
		local veh = exports['np-target']:GetCurrentEntity()

		if not IsEntityAVehicle(veh) then
			TriggerEvent("DoLongHudText", "Please look at a vehicle!", 2)
			return
		end

		if GetVehicleEngineHealth(veh) < 100.0 then
			TriggerEvent("DoLongHudText", "That vehicle is too damaged!", 2)
			return
		end

		if not AreAnyVehicleSeatsFree(veh) then
			TriggerEvent("DoLongHudText", "No seats available in the vehicle!", 2)
			return
		end

		local seat = findFirstVehicleSeat(veh, false, false, false)

		if seat then
			local vehNet = NetworkGetNetworkIdFromEntity(veh)

			TriggerEvent("dr:releaseEscort")
			TriggerServerEvent("police:tellSitInVehicle", tServerId, vehNet, seat)
		end
	end
end)

RegisterNetEvent("police:forceSeatPlayer")
AddEventHandler("police:forceSeatPlayer", function(vehNet, seat)
	local veh = NetworkGetEntityFromNetworkId(vehNet)

	if not IsEntityAVehicle(veh) then
		return
	end

	TriggerEvent("unEscortPlayer")
	Citizen.Wait(100)
	TaskWarpPedIntoVehicle(PlayerPedId(), veh, seat)
end)

function findFirstVehicleSeat(vehicle, checkFull, startAtFront, checkDriver)
	local model = GetEntityModel(vehicle)
	local numofseats = GetVehicleModelNumberOfSeats(model)
	local actualnumofseats = numofseats - 2

	local startingValue = actualnumofseats
	local iterator = -1
	local loopcount = 0

	if checkDriver then
		loopcount = -1
	end

	if startAtFront then
		iterator = 1
		loopcount = actualnumofseats

		if checkDriver then
			startingValue = -1
		else
			startingValue = 0
		end
	end

	for i=startingValue, loopcount, iterator do
		if checkFull then
			if not IsVehicleSeatFree(vehicle, i) then
				return i
			end
		else
			if IsVehicleSeatFree(vehicle, i) then
				return i
			end
		end
	end
end

local tenthirteenACooldown = 0
local tenthirteenBCooldown = 0
local fifteenMinutes = 60000 * 15
RegisterNetEvent('police:tenThirteenA')
AddEventHandler('police:tenThirteenA', function()
  if tenthirteenACooldown ~= 0 and tenthirteenACooldown + fifteenMinutes > GetGameTimer() then return end
  tenthirteenACooldown = GetGameTimer()
	if(isCop) then
		local pos = GetEntityCoords(PlayerPedId(),  true)
		TriggerServerEvent("dispatch:svNotify", {
			dispatchCode = "10-13A",
			firstStreet = GetStreetAndZone(),
			callSign = currentCallSign,
			cid = exports["isPed"]:isPed("cid"),
			origin = {
				x = pos.x,
				y = pos.y,
				z = pos.z
			  }
		})
	end
end)

RegisterNetEvent('police:tenThirteenB')
AddEventHandler('police:tenThirteenB', function()
  if tenthirteenBCooldown ~= 0 and tenthirteenBCooldown + fifteenMinutes > GetGameTimer() then return end
  tenthirteenBCooldown = GetGameTimer()
	if(isCop) then
		local pos = GetEntityCoords(PlayerPedId(),  true)
		TriggerServerEvent("dispatch:svNotify", {
			dispatchCode = "10-13B",
			firstStreet = GetStreetAndZone(),
			callSign = currentCallSign,
			cid = exports["isPed"]:isPed("cid"),
			origin = {
				x = pos.x,
				y = pos.y,
				z = pos.z
			}
		})
	end
end)

RegisterNetEvent("police:tenForteenA")
AddEventHandler("police:tenForteenA", function()
	local pos = GetEntityCoords(PlayerPedId(),  true)
	TriggerServerEvent("dispatch:svNotify", {
		dispatchCode = "10-14A",
		firstStreet = GetStreetAndZone(),
		callSign = currentCallSign,
		cid = exports["isPed"]:isPed("cid"),
		origin = {
			x = pos.x,
			y = pos.y,
			z = pos.z
		}
	})
end)

RegisterNetEvent("police:tenForteenB")
AddEventHandler("police:tenForteenB", function()
	local pos = GetEntityCoords(PlayerPedId(),  true)
	TriggerServerEvent("dispatch:svNotify", {
		dispatchCode = "10-14B",
		firstStreet = GetStreetAndZone(),
		callSign = currentCallSign,
		cid = exports["isPed"]:isPed("cid"),
		origin = {
			x = pos.x,
			y = pos.y,
			z = pos.z
		}
	})
end)

RegisterNetEvent("police:setCallSign")
AddEventHandler("police:setCallSign", function(pCallSign)
	if pCallSign ~= nil then currentCallSign = pCallSign end
end)

function GetStreetAndZone()
    local plyPos = GetEntityCoords(PlayerPedId(),  true)
    local s1, s2 = Citizen.InvokeNative( 0x2EB41072B4C1E4C0, plyPos.x, plyPos.y, plyPos.z, Citizen.PointerValueInt(), Citizen.PointerValueInt() )
    local street1 = GetStreetNameFromHashKey(s1)
    local street2 = GetStreetNameFromHashKey(s2)
    zone = tostring(GetNameOfZone(plyPos.x, plyPos.y, plyPos.z))
    local playerStreetsLocation = GetLabelText(zone)
    local street = street1 .. ", " .. playerStreetsLocation
    return street
end

function GetPlayers()
    local players = {}

    for i = 0, 255 do
        if NetworkIsPlayerActive(i) then
            players[#players+1]= i
        end
    end

    return players
end

function GetClosestPlayers(targetVector,dist)
	local players = GetPlayers()
	local ply = PlayerPedId()
	local plyCoords = targetVector
	local closestplayers = {}
	local closestdistance = {}
	local closestcoords = {}

	for index,value in ipairs(players) do
		local target = GetPlayerPed(value)
		if(target ~= ply) then
			local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
			local distance = #(vector3(targetCoords["x"], targetCoords["y"], targetCoords["z"]) - vector3(plyCoords["x"], plyCoords["y"], plyCoords["z"]))
			if(distance < dist) then
				valueID = GetPlayerServerId(value)
				closestplayers[#closestplayers+1]= valueID
				closestdistance[#closestdistance+1]= distance
				closestcoords[#closestcoords+1]= {targetCoords["x"], targetCoords["y"], targetCoords["z"]}

			end
		end
	end
	return closestplayers, closestdistance, closestcoords
end

function GetClosestPlayerVehicleToo()
	local players = GetPlayers()
	local closestDistance = -1
	local closestPlayer = -1
	local ply = PlayerPedId()
	local plyCoords = GetEntityCoords(ply, 0)
	if not IsPedInAnyVehicle(PlayerPedId(), false) then
		for index,value in ipairs(players) do
			local target = GetPlayerPed(value)
			if(target ~= ply) then
				local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
				local distance = #(vector3(targetCoords["x"], targetCoords["y"], targetCoords["z"]) - vector3(plyCoords["x"], plyCoords["y"], plyCoords["z"]))
				if(closestDistance == -1 or closestDistance > distance) then
					closestPlayer = value
					closestDistance = distance
				end
			end
		end
		return closestPlayer, closestDistance
	else
		TriggerEvent("DoShortHudText","Inside Vehicle.",2)
	end
end

function GetClosestPlayerAny()
	local players = GetPlayers()
	local closestDistance = -1
	local closestPlayer = -1
	local ply = PlayerPedId()
	local plyCoords = GetEntityCoords(ply, 0)


	for index,value in ipairs(players) do
		local target = GetPlayerPed(value)
		if(target ~= ply) then
			local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
			local distance = #(vector3(targetCoords["x"], targetCoords["y"], targetCoords["z"]) - vector3(plyCoords["x"], plyCoords["y"], plyCoords["z"]))
			if(closestDistance == -1 or closestDistance > distance) and not IsPedInAnyVehicle(target, false) then
				closestPlayer = value
				closestDistance = distance
			end
		end
	end

	return closestPlayer, closestDistance



end



function GetClosestPlayer()
	local players = GetPlayers()
	local closestDistance = -1
	local closestPlayer = -1
	local closestPed = -1
	local ply = PlayerPedId()
	local plyCoords = GetEntityCoords(ply, 0)
	if not IsPedInAnyVehicle(PlayerPedId(), false) then

		for index,value in ipairs(players) do
			local target = GetPlayerPed(value)
			if(target ~= ply) then
				local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
				local distance = #(vector3(targetCoords["x"], targetCoords["y"], targetCoords["z"]) - vector3(plyCoords["x"], plyCoords["y"], plyCoords["z"]))
				if(closestDistance == -1 or closestDistance > distance) and not IsPedInAnyVehicle(target, false) then
					closestPlayer = value
					closestPed = target
					closestDistance = distance
				end
			end
		end

		return closestPlayer, closestDistance, closestPed

	else
		TriggerEvent("DoShortHudText","Inside Vehicle.",2)
	end

end
function GetClosestPedIgnoreCar()
	local players = GetPlayers()
	local closestDistance = -1
	local closestPlayer = -1
	local closestPlayerId = -1
	local ply = PlayerPedId()
	local plyCoords = GetEntityCoords(ply, 0)
	for index,value in ipairs(players) do
		local target = GetPlayerPed(value)
		if(target ~= ply) then
			local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
			local distance = #(vector3(targetCoords["x"], targetCoords["y"], targetCoords["z"]) - vector3(plyCoords["x"], plyCoords["y"], plyCoords["z"]))
			if(closestDistance == -1 or closestDistance > distance) then
				closestPlayer = target
				closestPlayerId = value
				closestDistance = distance
			end
		end
	end

	return closestPlayer, closestDistance, closestPlayerId
end

function GetClosestPlayerIgnoreCar()
	local players = GetPlayers()
	local closestDistance = -1
	local closestPlayer = -1
	local ply = PlayerPedId()
	local plyCoords = GetEntityCoords(ply, 0)
	for index,value in ipairs(players) do
		local target = GetPlayerPed(value)
		if(target ~= ply) then
			local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
			local distance = #(vector3(targetCoords["x"], targetCoords["y"], targetCoords["z"]) - vector3(plyCoords["x"], plyCoords["y"], plyCoords["z"]))
			if(closestDistance == -1 or closestDistance > distance) then
				closestPlayer = value
				closestDistance = distance
			end
		end
	end

	return closestPlayer, closestDistance
end

function getClosestPlayer(coords, pDist)
  local closestPlyPed
  local closestPly
  local dist = -1

  for _, player in ipairs(GetActivePlayers()) do
    if player ~= PlayerId() then
      local ped = GetPlayerPed(player)
      local pedcoords = GetEntityCoords(ped)
      local newdist = #(coords - pedcoords)

      if (newdist <= pDist) then
        if (newdist < dist) or dist == -1 then
          dist = newdist
          closestPlyPed = ped
          closestPly = player
        end
      end
    end
  end

  return closestPlyPed, closestPly, GetPlayerServerId(closestPly)
end


function drawTxt(text,font,centre,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextDropShadow(0, 0, 0, 0,255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(centre)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x , y)
end


function isNearTakeService()
	for i = 1, #takingService do
		local ply = PlayerPedId()
		local plyCoords = GetEntityCoords(ply, 0)
		local distance = #(vector3(takingService[i].x, takingService[i].y, takingService[i].z) - vector3(plyCoords["x"], plyCoords["y"], plyCoords["z"]))
		if(distance < 30.0) then
			DrawMarker(27, takingService[i].x, takingService[i].y, takingService[i].z-1, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.5, 0, 0, 255, 155, 0, 0, 2, 0, 0, 0, 0)
		end
		if(distance < 3.0) then
			return true
		end
	end
end

function ShowRadarMessage(message)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(message)
	DrawNotification(0,1)
end

function DisplayHelpText(str)
  SetTextComponentFormat("STRING")
  AddTextComponentString(str)
  DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

handCuffedWalking = false
RegisterNetEvent('handCuffedWalking')
AddEventHandler('handCuffedWalking', function()

	if handCuffedWalking then
		handCuffedWalking = false
		TriggerEvent("handcuffed",false)
		TriggerEvent("animation:PlayAnimation","cancel")
		TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 3.0, 'handcuff', 0.4)
		TriggerEvent("police:currentHandCuffedState",false,false)
		return
	end
	handCuffedWalking = true
	handCuffed = false
	TriggerEvent("handcuffed",true)
	TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 3.0, 'handcuff', 0.4)
	TriggerEvent("police:currentHandCuffedState",handCuffed,handCuffedWalking)

end)

function DrawText3DTest(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())

    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)

    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

local notified = false
local disabledWeapons = false
RegisterNetEvent("disabledWeapons")
AddEventHandler("disabledWeapons", function(sentinfo)
	SetCurrentPedWeapon(PlayerPedId(), `weapon_unarmed`, 1)
	disabledWeapons = sentinfo
end)

function loadAnimDict( dict )
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Citizen.Wait( 5 )
    end
end

intmenuopen = false
handcuffType = 16


local isTargetCuffed = false

function cuffCheck()
	if not handCuffed and not IsPedRagdoll(PlayerPedId()) and not IsPlayerFreeAiming(PlayerId()) and not IsPedInAnyVehicle(PlayerPedId(), false) then
		t, distance = GetClosestPlayer()
		if(distance ~= -1 and distance < 3 and not IsPedRagdoll(PlayerPedId())) then
			TriggerServerEvent("police:IsTargetCuffed", GetPlayerServerId(t))
		end
	end
end

RegisterNetEvent('police:isPlayerCuffed')
AddEventHandler('police:isPlayerCuffed', function(requestedID)
	TriggerServerEvent("police:confirmIsCuffed",requestedID,handCuffed)
end)


RegisterNetEvent('police:TargetIsCuffed')
AddEventHandler('police:TargetIsCuffed', function(result)
	isTargetCuffed = result
	if isTargetCuffed then
		TriggerEvent("openSubMenu","handcuffer")
	else
		TriggerEvent("police:cuffFromMenu")
	end
	isTargetCuffed = false
end)

RegisterNetEvent('police:AttemptCuffFromInventory')
AddEventHandler('police:AttemptCuffFromInventory', function()
	cuffCheck()
end)

RegisterNetEvent('table:enable')
AddEventHandler('table:enable', function()
	TriggerServerEvent("blackjack:table_open",true)
end)

RegisterNetEvent('table:disable')
AddEventHandler('table:disable', function()
	TriggerServerEvent("blackjack:table_open",false)
end)

RegisterNetEvent('requestWounds')
AddEventHandler('requestWounds', function(pArgs, pEntity)
	local targetPed = nil
	if not pEntity then
		targetPed = exports['np-target']:GetCurrentEntity()
	else
		targetPed = pEntity
	end 

	if not targetPed and not IsPedAPlayer(targetPed) then
		return
	end

	local plySrvId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetPed))

	TriggerServerEvent("Evidence:GetWounds", plySrvId)
end)

RegisterCommand("+examineTarget", function()
	if isInService and not inmenus then
		TriggerEvent("requestWounds")
	end
end, false)
RegisterCommand("-examineTarget", function() end, false)
Citizen.CreateThread(function()
  exports["np-keybinds"]:registerKeyMapping("", "Gov", "(EMS) Examine Target", "+examineTarget", "-examineTarget")
end)

RegisterNetEvent("ems:heal")
AddEventHandler("ems:heal", function()
	t, distance = GetClosestPlayerAny()
	if t ~= nil and t ~= -1 then
		if(distance ~= -1 and distance < 5) then

			local myjob = exports["isPed"]:isPed("myjob")
			if myjob ~= "ems" and myjob ~= "doctor" and myjob ~= "doc" then
				local bandages = exports["np-inventory"]:getQuantity("bandage")
				if bandages == 0 then
					return
				else
					TriggerEvent('inventory:removeItem',"bandage", 1)
				end
			end

			TriggerEvent("animation:PlayAnimation","layspike")
			TriggerServerEvent("ems:healplayer", GetPlayerServerId(t))
		end
	end
end)

RegisterNetEvent("ems:stomachpump")
AddEventHandler("ems:stomachpump", function()
	t, distance = GetClosestPlayerAny()
	if t ~= nil and t ~= -1 then
		if(distance ~= -1 and distance < 5) then
			local finished = exports["np-taskbar"]:taskBar(10000,"Inserting stomach pump 🤢", false, true)
			TriggerEvent("animation:PlayAnimation","cpr")
			if finished == 100 then
				TriggerServerEvent("fx:puke", GetPlayerServerId(t))
			end
			TriggerEvent("animation:cancel")
		end
	end
end)

RegisterNetEvent("ems:bloodtest")
AddEventHandler("ems:bloodtest", function()
	t, distance = GetClosestPlayerAny()
	if t ~= nil and t ~= -1 then
		if(distance ~= -1 and distance < 5) then
			local finished = exports["np-taskbar"]:taskBar(10000,"Taking blood test", false, true)
			if finished == 100 then
				TriggerServerEvent("ems:bloodtesttarget", GetPlayerServerId(t))
			end
		end
	end
end)

RegisterNetEvent('binoculars:Activate')
AddEventHandler('binoculars:Activate', function()
	if not handCuffed and not handCuffedWalking then
	   TriggerEvent("binoculars:Activate2")
	end
end)

RegisterNetEvent('camera:Activate')
AddEventHandler('camera:Activate', function()
	if not handCuffed and not handCuffedWalking then
	   TriggerEvent("camera:Activate2")
	end
end)

RegisterNetEvent('car:swapseat')
AddEventHandler('car:swapseat', function(num)
	local veh = GetVehiclePedIsUsing(PlayerPedId())
	SetPedIntoVehicle(PlayerPedId(),veh,num)
end)


RegisterNetEvent('car:swapdriver')
AddEventHandler('car:swapdriver', function()
	local veh = GetVehiclePedIsUsing(PlayerPedId())
	SetPedIntoVehicle(PlayerPedId(), veh, -1)
end)

RegisterNetEvent('car:swapfp')
AddEventHandler('car:swapfp', function()
	local veh = GetVehiclePedIsUsing(PlayerPedId())
	SetPedIntoVehicle(PlayerPedId(), veh, 0)
end)

RegisterNetEvent('car:swapbl')
AddEventHandler('car:swapbl', function()
	local veh = GetVehiclePedIsUsing(PlayerPedId())
	SetPedIntoVehicle(PlayerPedId(), veh, 1)
end)

RegisterNetEvent('car:swapbr')
AddEventHandler('car:swapbr', function()
	local veh = GetVehiclePedIsUsing(PlayerPedId())
	SetPedIntoVehicle(PlayerPedId(), veh, 2)
end)

imdead = 0
RegisterNetEvent('pd:deathcheck')
AddEventHandler('pd:deathcheck', function()
	if imdead == 0 then
		imdead = 1
	else
		beingDragged = false
		dragging = false
		imdead = 0
	end
    lightbleed = false
    heavybleed = false
    lightestbleed = false
	lasthealth = GetEntityHealth(PlayerPedId())
end)

RegisterNetEvent('checkmyPH')
AddEventHandler('checkmyPH', function()
	TriggerServerEvent("police:showPH")
end)

RegisterNetEvent('police:vaftermarkets')
AddEventHandler('police:vaftermarkets', function()
	if isCop then
		playerped = PlayerPedId()
		coordA = GetEntityCoords(playerped, 1)
		coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, 100.0, 0.0)
		targetVehicle = getVehicleInDirection(coordA, coordB)
		licensePlate = GetVehicleNumberPlateText(targetVehicle)

		if licensePlate == nil then
			TriggerEvent("DoLongHudText", 'Can not target vehicle',2)
		else
			TriggerServerEvent('checkVehAfterMarkets',licensePlate)
		end
	end
end)

RegisterNetEvent('police:vaftermarkets:print')
AddEventHandler('police:vaftermarkets:print', function(parts)
	if parts ~= false then
		local msg_str = "Aftermarket Parts Installed:"
		for k,v in pairs(parts) do
			msg_str = msg_str.."\n"..k..": "..tostring(v)
		end
		TriggerEvent("chatMessage", "SYSTEM ", 2, msg_str)
	else
		TriggerEvent("chatMessage", "SYSTEM ", 2, "Car has no Aftermarket Parts Installed")
	end
end)

RegisterNetEvent('clientcheckLicensePlate')
AddEventHandler('clientcheckLicensePlate', function(pDummy, pEntity)
  if isCop then
    local licensePlate = GetVehicleNumberPlateText(pEntity)
    if licensePlate == nil then
      TriggerEvent("DoLongHudText", 'Can not target vehicle', 2)
    else
      TriggerServerEvent('np:vehicles:plateCheck', licensePlate, vehicleClass)
    end
  end
end)

RegisterNetEvent('sniffVehicle')
AddEventHandler('sniffVehicle', function()
	if isCop then
	  playerped = PlayerPedId()
      coordA = GetEntityCoords(playerped, 1)
      coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, 100.0, 0.0)
      targetVehicle = getVehicleInDirection(coordA, coordB)
     	targetspeed = GetEntitySpeed(targetVehicle) * 3.6
     	herSpeedMph = GetEntitySpeed(targetVehicle) * 2.236936
      licensePlate = GetVehicleNumberPlateText(targetVehicle)

      if licensePlate == nil then
      	TriggerEvent("DoLongHudText", 'Can not target vehicle',2)
      else
			TriggerServerEvent('sniffLicensePlateCheck',licensePlate)
		end
	end
end)

inanimation = false


cruisecontrol = false
RegisterNetEvent('toggle:cruisecontrol')
AddEventHandler('toggle:cruisecontrol', function()
	local currentVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
	local driverPed = GetPedInVehicleSeat(currentVehicle, -1)
	if driverPed == PlayerPedId() then
		if cruisecontrol then
			SetEntityMaxSpeed(currentVehicle, 999.0)
			cruisecontrol = false
			TriggerEvent("DoLongHudText","Speed Limiter Inactive",5)
		else
			speed = GetEntitySpeed(currentVehicle)
			if speed > 13.3 then
			SetEntityMaxSpeed(currentVehicle, speed)
			cruisecontrol = true
				TriggerEvent("DoLongHudText","Speed Limiter Active",5)
			else
				TriggerEvent("DoLongHudText","Speed Limiter can only activate over 35mph",2)
			end
		end
	end
end)

RegisterNetEvent('animation:tacklelol')
AddEventHandler('animation:tacklelol', function()
		if not handCuffed and not IsPedRagdoll(PlayerPedId()) then
			local lPed = PlayerPedId()

			RequestAnimDict("swimming@first_person@diving")
			while not HasAnimDictLoaded("swimming@first_person@diving") do
				Citizen.Wait(1)
			end

			if IsEntityPlayingAnim(lPed, "swimming@first_person@diving", "dive_run_fwd_-45_loop", 3) then
				ClearPedSecondaryTask(lPed)

			else
				TaskPlayAnim(lPed, "swimming@first_person@diving", "dive_run_fwd_-45_loop", 8.0, -8, -1, 49, 0, 0, 0, 0)
				seccount = 3
				while seccount > 0 do
					Citizen.Wait(100)
					seccount = seccount - 1
				end
				ClearPedSecondaryTask(lPed)
				SetPedToRagdoll(PlayerPedId(), 150, 150, 0, 0, 0, 0)
			end

		end

end)


RegisterNetEvent('animation:wave')
AddEventHandler('animation:wave', function()
		if not handCuffed then
			local lPed = PlayerPedId()

			RequestAnimDict("friends@frj@ig_1")
			while not HasAnimDictLoaded("friends@frj@ig_1") do
				Citizen.Wait(0)
			end

			if IsEntityPlayingAnim(lPed, "friends@frj@ig_1", "wave_a", 3) then
				ClearPedSecondaryTask(lPed)
			else
				TaskPlayAnim(lPed, "friends@frj@ig_1", "wave_a", 8.0, -8, -1, 49, 0, 0, 0, 0)
				seccount = 5
				while seccount > 0 do
					Citizen.Wait(1000)
					seccount = seccount - 1
				end
				ClearPedSecondaryTask(lPed)
			end
		else
			ClearPedSecondaryTask(lPed)
		end

end)

RegisterNetEvent('animation:nod')
AddEventHandler('animation:nod', function()
	if not handCuffed then
		local lPed = PlayerPedId()
		RequestAnimDict("random@getawaydriver")
		while not HasAnimDictLoaded("random@getawaydriver") do
			Citizen.Wait(0)
		end

		if IsEntityPlayingAnim(lPed, "random@getawaydriver", "gesture_nod_yes_hard", 3) then
			ClearPedSecondaryTask(lPed)
		else
			TaskPlayAnim(lPed, "random@getawaydriver", "gesture_nod_yes_hard", 8.0, -8, -1, 49, 0, 0, 0, 0)
			seccount = 10
			while seccount > 0 do
				Citizen.Wait(1000)
				seccount = seccount - 1
			end
			ClearPedSecondaryTask(lPed)
		end
	else
		ClearPedSecondaryTask(lPed)
	end
end)



RegisterNetEvent('animation:phonecall')
AddEventHandler('animation:phonecall', function()
	inanimation = true
	if not handCuffed then
		local lPed = PlayerPedId()

		RequestAnimDict("random@arrests")
		while not HasAnimDictLoaded("random@arrests") do
			Citizen.Wait(0)
		end

		if IsEntityPlayingAnim(lPed, "random@arrests", "idle_c", 3) then
			ClearPedSecondaryTask(lPed)

		else
			TaskPlayAnim(lPed, "random@arrests", "idle_c", 8.0, -8, -1, 49, 0, 0, 0, 0)
			seccount = 10
			while seccount > 0 do
				Citizen.Wait(1000)
				seccount = seccount - 1

			end
			ClearPedSecondaryTask(lPed)
		end
	else
		ClearPedSecondaryTask(lPed)
	end
	inanimation = false
end)

RegisterNetEvent('unseatPlayer')
AddEventHandler('unseatPlayer', function()
	local veh = exports['np-target']:GetCurrentEntity()

	if not IsEntityAVehicle(veh) then
		TriggerEvent("DoLongHudText", "Please look at a vehicle!", 2)
		return
	end

	if IsEntityAttachedToAnyPed(PlayerPedId()) then
		TriggerEvent("DoLongHudText", "You cannot unseat while being escorted!", 2)
		return
	end

	local seat = findFirstVehicleSeat(veh, true, false, true)

	if seat then
		local tPed = GetPedInVehicleSeat(veh, seat)
		local tPly = NetworkGetPlayerIndexFromPed(tPed)

		if tPly < 0 then
			TriggerEvent("DoLongHudText", 'No Player Found', 1)
			return
		end

		local tServerId = GetPlayerServerId(tPly)

		local vehNet = NetworkGetNetworkIdFromEntity(veh)

		TriggerServerEvent("police:tellGetOutOfVehicle", tServerId, vehNet)

		while IsPedInAnyVehicle(tPed, false) do
			Citizen.Wait(0)
		end

		if not escorting then
			TriggerServerEvent("police:escortAsk", tServerId)
		end
	else
		TriggerEvent("DoLongHudText", 'No one is in this vehicle', 1)
	end
end)

RegisterNetEvent("K9:Huntfind")
AddEventHandler("K9:Huntfind", function()

	players, distances, coords = GetClosestPlayers(GetEntityCoords(PlayerPedId(), 0),150)
	if(#players > 0) then
		TriggerServerEvent('huntAccepted', players, distances, coords)
		TriggerEvent("DoLongHudText", 'Hunting',1)
	else
		TriggerEvent("DoLongHudText", 'No Scent to pickup on..',2)
	end

end)


RegisterNetEvent("K9:Sniff")
AddEventHandler("K9:Sniff", function()

	t, distance = GetClosestPlayer()
	if(distance ~= -1 and distance < 10) then
		TriggerServerEvent('sniffAccepted',GetPlayerServerId(t))
	else
		TriggerEvent("DoLongHudText", 'No Player Found',2)
	end

end)

function TryTackle()
		if not TimerEnabled then
			t, distance = GetClosestPlayer()
			if(distance ~= -1 and distance < 2) then
				local maxheading = (GetEntityHeading(PlayerPedId()) + 15.0)
				local minheading = (GetEntityHeading(PlayerPedId()) - 15.0)
				local theading = (GetEntityHeading(t))
				TriggerServerEvent('CrashTackle',GetPlayerServerId(t))
				TriggerEvent("animation:tacklelol")
				TimerEnabled = true
				Citizen.Wait(6000)
				TimerEnabled = false
			else
				TimerEnabled = true
				Citizen.Wait(1000)
				TimerEnabled = false
			end
		end
end

RegisterNetEvent('playerTackled')
AddEventHandler('playerTackled', function()
	if not canBeTackled then
		return
	end
	
	SetPedToRagdoll(PlayerPedId(), math.random(3500,5000), math.random(3500,5000), 0, 0, 0, 0)
	TimerEnabled = true
	Citizen.Wait(6000)
	TimerEnabled = false
end)

RegisterNetEvent('police:forceUnseatPlayer')
AddEventHandler('police:forceUnseatPlayer', function(vehNet)
	local veh = NetworkGetEntityFromNetworkId(vehNet)
	local ped = PlayerPedId()

	TaskLeaveVehicle(ped, veh, 16)
end)

-- random@shop_robbery robbery_action_a
local lastRob = false

function LoadAnimationDictionary(animationD) -- Simple way to load animation dictionaries to save lines.
	while(not HasAnimDictLoaded(animationD)) do
		RequestAnimDict(animationD)
		Citizen.Wait(1)
	end
end

RegisterNetEvent('dragPlayer')
AddEventHandler('dragPlayer', function()
	local handcuffed = exports["isPed"]:isPed("handcuffed")
	if handcuffed then
		TriggerEvent("DoLongHudText","You are in handcuffs!",2)
		return
	end
	t, distance = GetClosestPlayer()

	if not distance then
		return
	end

	local targetServerId = GetPlayerServerId(t)

	local isTargetCarryingObject = RPC.execute('isPlayerCarryingObject', targetServerId)
	
	if(distance ~= -1 and distance < 1.0) then
		if not beingDragged and not isTargetCarryingObject then
			DetachEntity(PlayerPedId(), true, false)
			TriggerServerEvent("police:dragAsk", targetServerId)
		end
	end
end)

RegisterNetEvent('drag:stopped')
AddEventHandler('drag:stopped', function(sentid)
	if tonumber(sentid) == tonumber(otherid) and beingDragged then
		shitson = false
		beingDragged = false
		DetachEntity(PlayerPedId(), true, false)
    TriggerEvent("deathdrop",beingDragged)
  elseif dragging and sentid == GetPlayerServerId(PlayerId()) then
    dragging = false
    ClearPedTasks(PlayerPedId())
    TriggerServerEvent("dragPlayer:disable")
	end
end)

RegisterNetEvent('escortPlayer')
AddEventHandler('escortPlayer', function()
	local handcuffed = exports["isPed"]:isPed("handcuffed")
	if handcuffed then
		TriggerEvent("DoLongHudText","You are in handcuffs!",2)
		return
	end

	if IsEntityAttachedToAnyPed(PlayerPedId()) then
		TriggerEvent("DoLongHudText","You cannot escort someone while being escorted!",2)
		return
	end

	t, distance = GetClosestPlayer()
	if(t and (distance ~= -1 and distance < 5)) then
		if not escort then
			TriggerServerEvent("police:escortAsk", GetPlayerServerId(t))
		end
	else
		escorting = false
	end
end)

RegisterNetEvent("unEscortPlayer")
AddEventHandler("unEscortPlayer", function()
	escort = false
	beingDragged = false
	ClearPedTasks(PlayerPedId())
	DetachEntity(PlayerPedId(), true, false)
end)


RegisterNetEvent("dr:dragging")
AddEventHandler('dr:dragging', function()
	dragging = not dragging

	if not dragging and IsPedInAnyVehicle(PlayerPedId(), false) then
		return
	end

	if not dragging then
		ClearPedTasksImmediately(PlayerPedId())
		DetachEntity(PlayerPedId(), true, false)
	end
end)

RegisterNetEvent("dr:releaseEscort")
AddEventHandler("dr:releaseEscort", function()
	escorting = false
end)

RegisterNetEvent("dr:escort")
AddEventHandler('dr:escort', function(pl)
	otherid = tonumber(pl)
	if not escort and IsPedInAnyVehicle(PlayerPedId(), false) then
		return
	end
	escort = not escort
	if not escort then
		TriggerServerEvent("dr:releaseEscort",otherid)
	end

end)

RegisterNetEvent("dr:drag")
AddEventHandler('dr:drag', function(pl)
	otherid = tonumber(pl)
	beingDragged = not beingDragged
	if beingDragged then
		SetEntityCoords(PlayerPedId(),GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(otherid))))
	end
	Citizen.Wait(1000)
	TriggerEvent("deathdrop",beingDragged)
end)

RegisterNetEvent("dr:escortingEnabled")
AddEventHandler('dr:escortingEnabled', function()
	escorting = true
end)

Citizen.CreateThread(function()
	while true do

		if disableRagdoll then
			SetPedCanRagdoll(PlayerPedId(), false)
			SetPedMinGroundTimeForStungun(PlayerPedId(), 0)
		end
		
		if escorting or dragging then
			if IsPedRunning(PlayerPedId()) or IsPedSprinting(PlayerPedId()) then
				SetPlayerControl(PlayerId(), 0, 0)
				Citizen.Wait(1000)
				SetPlayerControl(PlayerId(), 1, 1)
			end
			if `WEAPON_UNARMED` ~= GetSelectedPedWeapon(PlayerPedId()) then
				DisableControlAction(2, 22, true) -- disable combat roll
			end
		else
			Citizen.Wait(1000)
		end
		Citizen.Wait(0)
	end
end)

local function flipVehicle(pVehicle, pPitch, pVRoll, pVYaw)
	SetEntityRotation(pVehicle, pPitch, pVRoll, pVYaw, 1, true)
	Wait(10)
	SetVehicleOnGroundProperly(pVehicle)
end

RegisterNetEvent("vehicle:flip")
AddEventHandler("vehicle:flip", function(pVehicle, pPitch, pVRoll, pVYaw)
	flipVehicle(NetToVeh(pVehicle), pPitch, pVRoll, pVYaw)
end)

RegisterNetEvent('FlipVehicle')
AddEventHandler('FlipVehicle', function(pDummy, pEntity)
  TriggerEvent("animation:PlayAnimation", "push")
  local finished = exports["np-taskbar"]:taskBar(30000, "Flipping Vehicle Over", false, true,nil,false,nil,10,pEntity)
  ClearPedTasks(PlayerPedId())

  if finished == 100 then
    local playerped = PlayerPedId()
    local coordA = GetEntityCoords(playerped, 1)
    local coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, 100.0, 0.0)
    local pPitch, pRoll, pYaw = GetEntityRotation(playerped)
    local vPitch, vRoll, vYaw = GetEntityRotation(pEntity)
    if targetVehicle ~= 0 then
      if not NetworkHasControlOfEntity(pEntity) then
        local vehicleOwnerId = NetworkGetEntityOwner(pEntity)
        TriggerServerEvent("vehicle:flip", GetPlayerServerId(vehicleOwnerId), VehToNet(pEntity), pPitch, vRoll, vYaw)
      else
        flipVehicle(pEntity, pPitch, vRoll, vYaw)
      end
    end
  end
end)

function deleteVeh(ent)
	SetVehicleHasBeenOwnedByPlayer(ent, true)
	NetworkRequestControlOfEntity(ent)
	local finished = exports["np-taskbar"]:taskBar(1000,"Impounding",false,true)
	Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(ent))
	DeleteEntity(ent)
	DeleteVehicle(ent)
	SetEntityAsNoLongerNeeded(ent)
end

RegisterNetEvent('impoundVehicle')
AddEventHandler('impoundVehicle', function()

	playerped = PlayerPedId()
  coordA = GetEntityCoords(playerped, 1)
  coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, 100.0, 0.0)
  targetVehicle, msg = getVehicleInDirection(coordA, coordB)

	if targetVehicle ~= 0 then
		licensePlate = GetVehicleNumberPlateText(targetVehicle)
		TriggerServerEvent("garages:SetVehImpounded",targetVehicle,licensePlate,false)
		TriggerEvent("DoLongHudText","Impounded with retrieval price of $500",1)
		deleteVeh(targetVehicle)
	else
		TriggerEvent("DoLongHudText", msg, 1)
	end
end)

RegisterNetEvent('fullimpoundVehicle')
AddEventHandler('fullimpoundVehicle', function()
	playerped = PlayerPedId()
    coordA = GetEntityCoords(playerped, 1)
    coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, 100.0, 0.0)
	targetVehicle, msg = getVehicleInDirection(coordA, coordB)
	if targetVehicle ~= 0 then
		licensePlate = GetVehicleNumberPlateText(targetVehicle)
		TriggerServerEvent("garages:SetVehImpounded",targetVehicle,licensePlate,true)
		TriggerEvent("DoLongHudText","Impounded with retrieval price of $1500",1)
		deleteVeh(targetVehicle)
	else
		TriggerEvent("DoLongHudText", msg, 1)
	end
end)

local function hasCarAnyPlayerPassengers(pVehicle)
	for i = -1, (GetVehicleMaxNumberOfPassengers(pVehicle) - 1) do
		local pedInSeat = GetPedInVehicleSeat(pVehicle, i)
		if pedInSeat ~= 0 and IsPedAPlayer(pedInSeat) then return true end
	end
	return false
end

function getVehicleInDirection(coordFrom, coordTo, isTrunking)
	local offset = 0
	local rayHandle
	local vehicle

	for i = 0, 100 do
		rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z + offset, 10, PlayerPedId(), 0)
		a, b, c, d, vehicle = GetRaycastResult(rayHandle)
		offset = offset - 1
		if vehicle ~= 0 then break end
	end

	local isVehicle = IsEntityAVehicle(vehicle)
	local distance = Vdist2(coordFrom, GetEntityCoords(vehicle))

	if distance > 25 then
		return 0, "Couldn't find a vehicle"
	else
		local vehDriver = GetPedInVehicleSeat(vehicle, -1)

		if not isTrunking and not IsPedAPlayer(vehDriver) and not hasCarAnyPlayerPassengers(vehicle) then
			return vehicle
		end

		if not isTrunking and isVehicle and (not IsVehicleSeatFree(vehicle, -1) or GetVehicleNumberOfPassengers(vehicle) ~= 0) then
			return 0, "This vehicle is currently occupied, dumbass."
		end

		if not isVehicle then
			return 0, "This isnt a vehicle, dumbass."
		end

		return vehicle
	end
end

RegisterNetEvent('animation:runtextanim')
AddEventHandler('animation:runtextanim', function(anim)
	if not handCuffed and not IsPedRagdoll(PlayerPedId()) then
		TriggerEvent('animation:runtextanim2', anim)
	end
end)

-- NOTE: Make sure to update the server-side list as well
local emsVehicleListWhite = {
	{"Search and Rescue Boat", "dinghy4"},
}

local emsVehicleList = {
	"ambulance"
}

local copVehicleList = {
	{"Predator Boat", "predator"},
}

local pullout = false

local function serviceVehicle(arg, livery, isEmsWhiteListed, cb)
	if not arg then cb("No argument was given") return end

	if GetInteriorFromEntity(PlayerPedId()) ~= 0 then return cb("Cannot be used here") end

	local function printHelp(list)
		copVehStrList = ""
		for i=1, #list do
			copVehStrList = copVehStrList.."["..i.."] "..list[i][1].."\n"
		end
		TriggerEvent("chatMessage", "SYSTEM ", 2, copVehStrList)
	end
	if arg == "help" then
		if isCop then
			printHelp(copVehicleList)
		elseif isEmsWhiteListed then
			printHelp(emsVehicleListWhite)
		end
		return
	end

	arg = tonumber(arg)
	if not arg then cb("Invalid argument") return end


	if isCop then
		if arg > #copVehicleList or arg <= 0 then
			TriggerEvent("DoLongHudText", "Invalid Service Vehicle", 2)
			return
		end

		selectedSkin = copVehicleList[arg][2]

	else
		if isEmsWhiteListed then
			if arg > #emsVehicleListWhite or arg <= 0 then
				TriggerEvent("DoLongHudText", "Invalid Service Vehicle", 2)
				return
			end
			selectedSkin = emsVehicleListWhite[arg][2]
		else
			if arg > #emsVehicleList or arg <= 0 then
				TriggerEvent("DoLongHudText", "Invalid Service Vehicle", 2)
				return
			end
			selectedSkin = emsVehicleList[arg]
		end
	end


	Citizen.CreateThread(function()
		if not pullout then
			pullout = true
		end

		local hash = GetHashKey(selectedSkin)

		if not IsModelAVehicle(hash) then cb("Model isn't a vehicle") return end
		if not IsModelInCdimage(hash) or not IsModelValid(hash) then cb("Model doesn't exist") return end

		TriggerServerEvent("police:spawnServiceVehicle",selectedSkin, livery)
	end)
end

function GroupRank(groupid)
  local rank = 0
  local mypasses = exports["isPed"]:isPed("passes")
  for i=1, #mypasses do
    if mypasses[i]["pass_type"] == groupid then
      rank = mypasses[i]["rank"]
    end
  end
  return rank
end

RegisterNetEvent("police:chatCommand")
AddEventHandler("police:chatCommand", function(args, cmd, isVehicleCmd,isEmsWhiteListed)
	-- remove the cmd itself from the args
	table.remove(args, 1)

	local function errorMsg(msg)
		TriggerEvent("chatMessage", "Error", {255, 0, 0}, msg)
	end

	--local _isCop = isCop
	--if not _isCop then errorMsg("You must be a police officer to use this command") return end

	if not args[1] and cmd ~= "fix" and cmd ~= "spikes" then errorMsg("No argument was given") return end

	local vehicle

	if isVehicleCmd then
		vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
		if vehicle == 0 then errorMsg("No vehicle target was found") return end
		SetVehicleModKit(vehicle, 0)
	end

	if cmd == "livery" then
		SetVehicleLivery(vehicle, tonumber(args[1]))
	end
	if cmd == "sv" then
		serviceVehicle(args[1], args[2], isEmsWhiteListed, errorMsg)
	end

	if cmd == "whitelist" then
		if rankService == 10 then
			local arg = args[1]
			local arg2 = tonumber(args[2])
			if not arg then errorMsg("Invalid argument") return end
			if not arg2 then errorMsg("Invalid Second argument") return end

			TriggerServerEvent("police:whitelist",arg2,arg)
		else
			errorMsg("You do not have the rank to do this action")
		end
	end

	if cmd == "remove" then
		if rankService == 10 then
			local arg = args[1]
			local arg2 = tonumber(args[2])
			if not arg then errorMsg("Invalid argument") return end
			if not arg2 then errorMsg("Invalid Second argument") return end

			TriggerServerEvent("police:remove",arg2,arg)
		else
			errorMsg("You do not have the rank to do this action")
		end
	end
end)

RegisterNetEvent("police:fingerprint")
AddEventHandler("police:fingerprint", function(pArgs, pEntity, pContext)
	TriggerServerEvent("police:fingerprint", GetPlayerServerId(NetworkGetPlayerIndexFromPed(pEntity)))
end)

RegisterNetEvent("police:seizeItems")
AddEventHandler("police:seizeItems", function(pArgs, pEntity, pContext)
	local serverId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(pEntity))
	TriggerEvent("DoLongHudText", "Seized Possessions.")
	TriggerServerEvent("police:seizeItems", serverId)
end)

Citizen.CreateThread(function()
  exports["np-polyzone"]:AddBoxZone("wheelchair_store", vector3(-803.48, -1248.7, 7.34), 1.6, 1.0, {
    heading=320,
    minZ=6.14,
    maxZ=8.74,
    data = {
      id = "1",
    },
  })

  exports["np-polyzone"]:AddBoxZone("police_station", vector3(461.91, -993.59, 30.69), 55.8, 54.8, {
	heading=0,
	minZ = 23.49,
	maxZ = 32.29,
	data = {
		id = "mrpd"
	}
  })

  exports["np-polyzone"]:AddBoxZone("police_station", vector3(-1084.8, -836.75, 13.52), 25.6, 11.2, {
	heading=309,
	minZ=12.32,
	maxZ=17.72,
	data = {
		id = "vspd"
	}
  })

  exports["np-polyzone"]:AddBoxZone("police_station", vector3(1844.54, 3685.35, 34.28), 14.4, 30.8, {
	heading=30,
	minZ=33.28,
	maxZ=37.28,
	data = {
		id = "sspd"
	}
  })

  exports["np-polyzone"]:AddBoxZone("police_station", vector3(-443.8, 6009.09, 31.71), 26.8, 9.55, {
	heading=45,
	minZ=30.71,
	maxZ=34.71,
	data = {
		id = "ppd"
	}
  })

  exports["np-polyzone"]:AddBoxZone("police_station", vector3(382.87, 796.83, 187.46), 8.0, 11.8, {
	heading=0,
	minZ=186.46,
	maxZ=193.26,
	data = {
		id = "prpd"
	}
  })

  exports["np-polyzone"]:AddBoxZone("possession_pickup", vector3(472.98, -1007.43, 26.27), 1.2, 2.6, {
	heading=0,
	minZ=25.27,
	maxZ=27.47,
	data = {
		id = "mrpdpickup"
	}
  })

  exports["np-polyzone"]:AddBoxZone("possession_pickup", vector3(-1088.5, -811.11, 19.3), 1.2, 2.6, {
	heading=40,
	minZ=18.3,
	maxZ=20.5,
	data = {
		id = "vspdpickup"
	}
  })

  exports["np-polyzone"]:AddBoxZone("possession_pickup", vector3(384.99, 799.86, 187.46), 1.2, 2.6, {
	heading=0,
	minZ=186.46,
	maxZ=188.66,
	data = {
		id = "prpdpickup"
	}
  })

  exports["np-polyzone"]:AddBoxZone("possession_pickup", vector3(1853.6, 3687.98, 34.28), 2.0, 1, {
	heading=120,
	minZ=33.28,
	maxZ=35.48,
	data = {
		id = "sspdpickup"
	}
  })

  exports["np-polyzone"]:AddBoxZone("possession_pickup", vector3(-447.56, 6013.49, 31.72), 2.0, 1, {
	heading=45,
	minZ=30.72,
	maxZ=32.92,
	data = {
		id = "ppdpickup"
	}
  })
  
  PolyZoneInteraction("possession_pickup", "[E] Re-claim Possessions", 38, function (data)
	local cid = exports["isPed"]:isPed("cid")
	TriggerServerEvent("server-jail-items", cid, false, GetPlayerServerId(PlayerId()))
	TriggerEvent("DoLongHudText", "Your possessions were returned.")
	exports["np-ui"]:hideInteraction()
	Citizen.Wait(15000)
  end)
end)
AddEventHandler("np-polyzone:enter", function(zone)
  if zone ~= "wheelchair_store" then return end
  local myjob = exports["isPed"]:isPed("myjob")
  if myjob == "ems" or myjob == "doctor" then
  	TriggerEvent("server-inventory-open", "43", "Shop")
  else
	showWheelChairMenu()
  end
end)



function showWheelChairMenu()
    local data = {
        {
            title = "Buy Wheelchair ($10,000)",
            description = "Buy a personal Wheelchair.",
            key = true,
            children = {
				{ title = "Confirm Purchase", action = "np-ui:wheelchairPurchase", key = true },
			},
        },
    }

    exports["np-ui"]:showContextMenu(data)
end

RegisterUICallback("np-ui:wheelchairPurchase", function(data, cb)

	local finished = exports["np-taskbar"]:taskBar(10000, "Purchasing...", true)
	if finished ~= 100 then
	  cb({ data = {}, meta = { ok = false, message = 'cancelled' } })
	  return
	end
	
	local success, message = RPC.execute("wheelchair:purchase")
	if not success then
		cb({ data = {}, meta = { ok = success, message = message } })
		TriggerEvent("DoLongHudText", message, 2)
		return
	end

	TriggerEvent("player:receiveItem","wheelchair",1)
	
	cb({ data = {}, meta = { ok = true, message = "done" } })
end)

RegisterUICallback("np-ui:police:flagPlate", function(data, cb)
	cb({ data = {}, meta = { ok = true, message = "done" } })
  exports['np-ui']:closeApplication('textbox')
  RPC.execute("police:flagPlate", data.values.plate, data.values.reason)
end)

local inHotel = false
RegisterNetEvent("inhotel", function(pInside)
	inHotel = pInside
end)

--afk timer
local afkCount = 0
local prevCoords = nil
Citizen.CreateThread(function()
  Citizen.Wait(60 * 60 * 1000)
  local isPublic = exports["np-config"]:IsPublic()
  while true do
    Citizen.Wait(60000)
    local _myJob = exports["isPed"]:isPed("myjob")
    if _myJob == "unemployed" then -- 1hr
	  local curCoords = GetEntityCoords(PlayerPedId())
	  local distance = prevCoords and #(prevCoords - curCoords) or 0
      if not prevCoords or (distance > 2.0 and not inHotel) or distance > 5.0 then
        afkCount = 0
      else
        afkCount = afkCount + 1
      end
      if afkCount == 30 then
		 afkCount = 0
		 if isPublic then
			RPC.execute("police:afk")
		 end
        RPC.execute("np-bugs:playerLogAction", {
          title = "30 minutes inactivity",
          content = "(" .. GetPlayerServerId(PlayerId()) .. ") "
            .. exports["isPed"]:isPed("cid") .. " - "
            .. exports["isPed"]:isPed("firstname") .. " "
            .. exports["isPed"]:isPed("lastname")
        })
      end
      prevCoords = curCoords
    end
  end
end)
