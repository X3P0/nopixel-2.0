local BlipHandlers = {}

function GetBlipSettings(pServerId)
  local settings = {}

  settings.short = true
  settings.sprite = 1
  settings.category = 7
  settings.color = 1
  settings.heading =  true
  settings.text = tostring(pServerId)

  return settings
end

function CreateBlipHandler(pServerId)
	local serverId = pServerId

	local settings = GetBlipSettings(serverId)

	local handler = EntityBlip:new('player', serverId, settings)

	handler:enable(true)

	BlipHandlers[serverId] = handler
end

function DeleteBlipHandler(pServerId)
	BlipHandlers[pServerId]:disable()
	BlipHandlers[pServerId] = nil
end

function RegisterBlipsForAllPlayers()
  local players = exports['np-infinity']:GetPlayerList()

  for plySrvId, _ in pairs(players) do
    CreateBlipHandler(plySrvId)
  end
end

function UnregisterBlipsForAllPlayers()
	for serverId, pData in pairs(BlipHandlers) do
		if pData then
			DeleteBlipHandler(serverId)
		end
	end

	BlipHandlers = {}
end

RegisterNetEvent('np-admin:togglePlayerBlips')
AddEventHandler('np-admin:togglePlayerBlips', function(pToggle)
	drawNames(pToggle)
  if pToggle then
    RegisterBlipsForAllPlayers()
  else
    UnregisterBlipsForAllPlayers()
  end
end)

RegisterNetEvent('np:infinity:player:coords')
AddEventHandler('np:infinity:player:coords', function (pCoords)
	for serverId, handler in pairs(BlipHandlers) do
		if handler and handler.mode == 'coords' and pCoords[serverId] then
			handler:onUpdateCoords(pCoords[serverId])

			if handler:entityExistLocally() then
				handler:onModeChange('entity')
			end
		end
	end
end)

local namesEnabled = false
local drawData = {}
RegisterNetEvent('onPlayerJoining')
AddEventHandler('onPlayerJoining', function(player)
	if BlipHandlers[player] then
		BlipHandlers[player]['inScope'] = true
		Citizen.Wait(1000)
		if BlipHandlers[player]['inScope'] then
			BlipHandlers[player]:onModeChange('entity')
		end
	end
	if namesEnabled and not drawData[player] then
		local srvId = GetPlayerFromServerId(player)
		drawData[player] = {plyPed = GetPlayerPed(srvId), id = player, name = GetPlayerName(srvId)}
	end
end)

RegisterNetEvent('onPlayerDropped')
AddEventHandler('onPlayerDropped', function(player)
	if BlipHandlers[player] then
		BlipHandlers[player]['inScope'] = false
		BlipHandlers[player]:onModeChange('coords')
	end
	if namesEnabled and drawData[player] then
		drawData[player] = nil
	end
end)

local function DrawText3D(x,y,z, text) -- some useful function, use it if you want!
	local onScreen, _x, _y = World3dToScreen2d(x , y, z)
	
	if onScreen then
			SetTextFont(0)
			SetTextProportional(1)
			SetTextScale(0.0, 1.0)
			SetTextColour(255, 0, 0, 255)
			SetTextDropshadow(0, 0, 0, 0, 55)
			SetTextEdge(2, 0, 0, 0, 150)
			SetTextDropShadow()
			SetTextOutline()
			SetTextEntry("STRING")
			SetTextCentre(1)
			AddTextComponentString(text)
			DrawText(_x, _y)
	end
end

function drawNames(pEnabled)
	namesEnabled = pEnabled

	if namesEnabled then
		for _, player in ipairs(GetActivePlayers()) do
			local srvId = GetPlayerServerId(player)
			drawData[srvId] = {plyPed = GetPlayerPed(player), id = srvId, name = GetPlayerName(player)}
		end
	end

	CreateThread(function()
		while namesEnabled do
			for ply, _ in pairs(drawData) do
				if drawData[ply] ~= nil then
					local plyCoords = GetEntityCoords(drawData[ply].plyPed)

					DrawText3D(plyCoords.x, plyCoords.y, plyCoords.z + 1.15, string.format("[%d] - %s", drawData[ply].id, drawData[ply].name))
				end
			end
			Wait(0)
		end
		drawData = {}
	end)
end