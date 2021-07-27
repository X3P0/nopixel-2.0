local originalHudPosition = config.nui.hud.position

function createPendingRace(id, options)
  if curRace then return end
  local err = RPC.execute("mkr_racing:createPendingRace", id, options)
  return err
end
exports("createPendingRace", createPendingRace)

function clearPreview()
  currentlyEnabledPreview = nil
  clearBlips()
end

function previewRace(id)
  local race = races[id]
  if race == nil then return end
  if id == currentlyEnabledPreview then
    clearPreview()
    return
  end
  clearPreview()
  SetWaypointOff()
  race.start.pos = tableToVector3(race.start.pos)
  for i=1, #race.checkpoints do
    race.checkpoints[i].pos = tableToVector3(race.checkpoints[i].pos)
  end
  local checkpoints = race.checkpoints
  for i=1, #checkpoints do
    addCheckpointBlip(checkpoints, i)
  end
  if race.type == "Point" then
    addBlip(race.start.pos, 0, true)
  end
  currentlyEnabledPreview = id
  local enabledPreview = currentlyEnabledPreview
  -- Thread to continously render the route
  Citizen.CreateThread(function()
    while currentlyEnabledPreview and currentlyEnabledPreview == enabledPreview do
      -- If a race has been started, or waypoint has been placed, preview is disabled and cleared
      if IsWaypointActive() or curRace then
        clearPreview()
      end
      Citizen.Wait(0)
    end
  end)
end
exports("previewRace", previewRace)

function locateRace(id, reverse)
  local race = races[id]
  if race == nil then return end
  local start = race.start.pos
  if reverse then start = race.checkpoints[#race.checkpoints].pos end
  clearPreview()
  SetNewWaypoint(start.x, start.y, start.z)
end
exports("locateRace", locateRace)

function getHudPosition()
  return config.nui.hud.position
end
exports("getHudPosition", getHudPosition)

function setHudPosition(position)
  config.nui.hud.position = {
    top = position.top,
    bottom = position.bottom,
    left = position.left,
    right = position.right
  }
  SendNUIMessage({ hudPosition = config.nui.hud.position })
end
exports("setHudPosition", setHudPosition)

function resetHudPosition()
  config.nui.hud.position = originalHudPosition
  SendNUIMessage({ hudPosition = config.nui.hud.position })
end
exports("resetHudPosition", resetHudPosition)

function startRace(countdown)
  local characterId = getCharacterId()
  for k, v in pairs(pendingRaces) do
    if v.owner == characterId then
      local err = RPC.execute("mkr_racing:startRace", v.eventId, countdown or v.countdown)
      return err
    end
  end
end
exports("startRace", startRace)

function endRace()
  if curRace then
    RPC.execute("mkr_racing:endRace")
  else
    RPC.execute("mkr_racing:leaveRace")
  end
end
exports("endRace", endRace)

function joinRace(id, alias, characterId)
  local err = RPC.execute("mkr_racing:joinRace", id, alias, characterId)
  return err
end
exports("joinRace", joinRace)

function leaveRace()
  SendNUIMessage({showHUD=false})
  if curRace then
    RPC.execute("mkr_racing:dnfRace", curRace.eventId)
    cleanupRace()
  else
    RPC.execute("mkr_racing:leaveRace")
  end
end
exports("leaveRace", leaveRace)

function getAllRaces()
  if races then
    return {races=races, pendingRaces=pendingRaces, activeRaces=activeRaces}
  end
  local res = RPC.execute("mkr_racing:getAllRaces")
  races = res.races
  pendingRaces = res.pendingRaces
  activeRaces = res.activeRaces
  finishedRaces = RPC.execute("mkr_racing:getFinishedRaces")
  return res
end
exports("getAllRaces", getAllRaces)