local isBlindfolded = false
local headobject = nil

RegisterNetEvent("blindfold:blindfold")
AddEventHandler("blindfold:blindfold", function(pArgs, pEntity)
  local ped = PlayerPedId()
  local tPed = pEntity

  isBlindfolded = exports["np-flags"]:HasPedFlag(tPed, "isBlindfolded")

  local time, string = 10000, "Putting On Blindfold"

  if isBlindfolded then
    time = 2000
    string = "Removing Blindfold"
  end

  RequestAnimDict("random@shop_robbery")
  while not HasAnimDictLoaded("random@shop_robbery") do
    Citizen.Wait(0)
  end

  ClearPedTasksImmediately(ped)
  TaskPlayAnim(ped, "random@shop_robbery", "robbery_action_b", 8.0, -8, -1, 16, 0, 0, 0, 0)

  local blindfoldtask = exports["np-taskbar"]:taskBar(time, string)

  if blindfoldtask == 100 then
    if isBlindfolded then
      exports['np-flags']:SetPedFlag(tPed, 'isBlindfolded', false)
    else
      exports['np-flags']:SetPedFlag(tPed, 'isBlindfolded', true)
    end
  end
  ClearPedSecondaryTask(ped)
end)

RegisterNetEvent("blindfold:apply")
AddEventHandler("blindfold:apply", function(pIsBlindfolded)
  isBlindfolded = pIsBlindfolded
  SendNUIMessage({blind = isBlindfolded})

  if isBlindfolded then
    AddHeadObject()
    TriggerEvent('InteractSound_CL:PlayOnOne', 'headbagon', 1.0)
  else
    RemoveHeadObject()
    TriggerEvent('InteractSound_CL:PlayOnOne', 'headbagoff', 1.0)
  end
end)

function AddHeadObject()
  local ped = PlayerPedId()
  local model = `np_blindfold_hood`

  if not IsModelValid(model) then
    print("INVALID PROP")
    return
  end

  RequestModel(model)

  while not HasModelLoaded(model) do
    Wait(0)
  end

  local coords = GetEntityCoords(ped)

  headobject = CreateObjectNoOffset(model, coords, true, false, false)

  while not DoesEntityExist(headobject) do
    Wait(0)
  end

  SetModelAsNoLongerNeeded(model)

  boneid = GetPedBoneIndex(ped, 12844)

  AttachEntityToEntity(headobject, ped, boneid, 0.32, 0.01, 0.0, 0.0, 270.0, 0.0, 0, 0, 0, 1, 0, 1)

  SetFollowPedCamViewMode(4)

  Citizen.CreateThread(function ()
    SetFollowPedCamViewMode(4)
      while isBlindfolded do
        SetEntityLocallyInvisible(headobject)
        DisableControlAction(0, 0, true)
        Citizen.Wait(0)
      end
  end)
end

function RemoveHeadObject()
  DeleteObject(headobject)
end

AddEventHandler('onResourceStop', function (resource)
  if resource == GetCurrentResourceName() then
    RemoveHeadObject()
  end
end)