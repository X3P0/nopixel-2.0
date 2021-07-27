local drugEffectTime

-- Cocaine Effects
RegisterNetEvent('hadcocaine')
AddEventHandler('hadcocaine', function(quality)
  TriggerEvent("addiction:drugTaken", "cocaine")
  drugEffectTime = 0

  TriggerEvent("fx:run", "cocaine", 8, 0.0, false, false)

  local addictionFactor = getFactor("cocaine")

  local drugEffectApplyArmorMulti = 0.0
  local drugEffectQualityMulti = 1.0
  local sprintEffectFactor = 1.0
  local drugEffectQuality = quality and quality or 20
  if drugEffectQuality > 25 and drugEffectQuality <= 50 then
    drugEffectQualityMulti = 2.0
    sprintEffectFactor = 1.05
  elseif drugEffectQuality > 50 and drugEffectQuality <= 62.5 then
    drugEffectQualityMulti = 3.0
    sprintEffectFactor = 1.1
  elseif drugEffectQuality > 62.5 and drugEffectQuality <= 75 then
    drugEffectQualityMulti = 6.0
    sprintEffectFactor = 1.15
  elseif drugEffectQuality > 75 and drugEffectQuality <= 90 then
    drugEffectQualityMulti = 12.0
    drugEffectApplyArmorMulti = 1.0
    sprintEffectFactor = 1.15
  elseif drugEffectQuality > 90 and drugEffectQuality <= 99 then
    drugEffectQualityMulti = 18.0
    drugEffectApplyArmorMulti = 2.0
    sprintEffectFactor = 1.2
  elseif drugEffectQuality > 99 then
    drugEffectQualityMulti = 30.0
    drugEffectApplyArmorMulti = 3.0
    sprintEffectFactor = 1.2
  end

  -- sets the sprint multipler based on the addictionfactor... if your addiction is higher then 5.0, you start slowing down. max sprint speep is 1.25
  local sprintfactor = map_range(addictionFactor, 0.0, 5.0, sprintEffectFactor, 1.00)
  if sprintfactor < 1.0 then
    sprintfactor = 1.0
  end
  SetRunSprintMultiplierForPlayer(PlayerId(), sprintfactor)

  drugEffectTime = drugEffectQualityMulti * 6
  if quality and quality < 40 then
    TriggerEvent("DoLongHudText", "This is some poor quality shit", 2)
  end

  TriggerEvent("client:newStress", false, math.random(150, 300))

  local loops = 0
  while drugEffectTime > 0 do
    loops = loops + 1
    if loops > 20 then
      SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    end
    Citizen.Wait(1000)
    RestorePlayerStamina(PlayerId(), 1.0)
    drugEffectTime = drugEffectTime - 1

    if IsPedRagdoll(PlayerPedId()) then
      SetPedToRagdoll(PlayerPedId(), math.random(5), math.random(5), 3, 0, 0, 0)
    end

    if drugEffectApplyArmorMulti > 0 then
      local armor = GetPedArmour(PlayerPedId())
      SetPedArmour(PlayerPedId(), math.floor(armor + drugEffectApplyArmorMulti))
    end

    if math.random() < 0.04 then
      TriggerEvent("fx:run", "cocaine", 8, 0.0, false, false)
    end

    if math.random(100) > 92 and IsPedRunning(PlayerPedId()) then
      SetPedToRagdoll(PlayerPedId(), math.random(1000), math.random(1000), 3, 0, 0, 0)
    end
  end

  drugEffectTime = 0

  if IsPedRunning(PlayerPedId()) then
    SetPedToRagdoll(PlayerPedId(), 1000, 1000, 3, 0, 0, 0)
  end

  SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
  exports["carandplayerhud"]:revertToStress()
end)

RegisterNetEvent('hadnitrous')
AddEventHandler('hadnitrous', function()
  drugEffectTime = 0

  TriggerEvent("fx:run", "cocaine", 8, 0.0, false, false)

  SetRunSprintMultiplierForPlayer(PlayerId(), 1.01)

  drugEffectTime = 200

  -- TriggerEvent("client:newStress", false, math.random(250))

  while drugEffectTime > 0 do
    Citizen.Wait(1000)
    drugEffectTime = drugEffectTime - 1

    if IsPedRagdoll(PlayerPedId()) then
      SetPedToRagdoll(PlayerPedId(), math.random(5), math.random(5), 3, 0, 0, 0)
    end
  end

  drugEffectTime = 0

  if IsPedRunning(PlayerPedId()) then
    SetPedToRagdoll(PlayerPedId(), 1000, 1000, 3, 0, 0, 0)
  end

  SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
  exports["carandplayerhud"]:revertToStress()
end)

-- Adrenaline (Swat) Effects
RegisterNetEvent('inventory:adrenaline')
AddEventHandler('inventory:adrenaline', function()
  local ped = PlayerId()

  drugEffectTime = 0

  local armor = GetPedArmour(PlayerPedId())
  SetPedArmour(PlayerPedId(), math.floor(armor + 50.0))
  SetRunSprintMultiplierForPlayer(ped, 1.2)

  drugEffectTime = 18000

  while drugEffectTime > 0 do
    -- one in 2 frames head shot disable for "helmet armor"
    Citizen.Wait(1)
    if math.random(500) == 69 then
      -- slow armor regen
      local armor = GetPedArmour(PlayerPedId())
      SetPedArmour(PlayerPedId(), math.floor(armor + 5))
    end
    SetPedSuffersCriticalHits(PlayerPedId(), false)
    RestorePlayerStamina(ped, 1.0)
    drugEffectTime = drugEffectTime - 1
  end
  drugEffectTime = 0
  SetRunSprintMultiplierForPlayer(ped, 1.0)
  SetPedSuffersCriticalHits(PlayerPedId(), true)

end)



-- Crack Effects
RegisterNetEvent('hadcrack')
AddEventHandler('hadcrack', function()
  TriggerEvent("addiction:drugTaken", "crack")
  drugEffectTime = 0
  Citizen.Wait(1000)

  TriggerEvent("fx:run", "crack", 8, 0.0, false, false)

  local addictionFactor = getFactor("crack")

  local sprintfactor = map_range(addictionFactor, 0.0, 5.0, 1.35, 1.00)

  if sprintfactor < 1.0 then
    sprintfactor = 1.0
  end

  SetRunSprintMultiplierForPlayer(PlayerId(), sprintfactor)

  drugEffectTime = 30

  TriggerEvent("client:newStress", true, math.random(750, 1250))

  while drugEffectTime > 0 do
    Citizen.Wait(1000)
    RestorePlayerStamina(PlayerId(), 1.0)
    drugEffectTime = drugEffectTime - 1

    if IsPedRagdoll(PlayerPedId()) then
      SetPedToRagdoll(PlayerPedId(), math.random(5), math.random(5), 3, 0, 0, 0)
    end

    if math.random(500) < 100 then
      TriggerEvent("fx:run", "crack", 8, 0.0, false, false)
      Citizen.Wait(math.random(30000))
    end

    if math.random(100) > 91 and IsPedRunning(PlayerPedId()) then
      SetPedToRagdoll(PlayerPedId(), math.random(1000), math.random(1000), 3, 0, 0, 0)
    end
  end

  drugEffectTime = 0

  if IsPedRunning(PlayerPedId()) then
    SetPedToRagdoll(PlayerPedId(), 6000, 6000, 3, 0, 0, 0)
  end

  SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
  exports["carandplayerhud"]:revertToStress()
end)

RegisterNetEvent("weed")
AddEventHandler("weed", function(alteredValue, scenario, multiply)
  local timeout = 500
  if not multiply then multiply = 1.0 end

  while not IsPedUsingScenario(PlayerPedId(), scenario) do
    Wait(0)

    timeout = timeout - 1

    if timeout == 0 then
      print("WEED ANIMATION TIMED OUT")
      return
    end
  end

  TriggerEvent("addiction:drugTaken", "weed")
  local removedStress = 0

  TriggerEvent("DoShortHudText", 'Stress is being relieved', 6)

  SetPlayerMaxArmour(PlayerId(), 60)

  local addictionFactor = getFactor("weed")

  -- Addiction will scale the amount of armor you get over time between 0 and 3 dependiong on how addicted you are
  local armorchange = map_range(addictionFactor, 0.0, 5.0, 3.0, 0.0)

  if armorchange < 0 then
    armorchange = 0
  end

  while removedStress <= alteredValue do
    removedStress = removedStress + 100

    local armor = GetPedArmour(PlayerPedId())
    SetPedArmour(PlayerPedId(), math.ceil(armor + (multiply * armorchange)))

    if scenario ~= "None" then
      if not IsPedUsingScenario(PlayerPedId(), scenario) then
        TriggerEvent("animation:cancel")
        break
      end
    end

    Citizen.Wait(1000)
  end

  TriggerServerEvent("server:alterStress", false, removedStress)
end)

function map_range(s, a1, a2, b1, b2)
  return b1 + (s - a1) * (b2 - b1) / (a2 - a1)
end
