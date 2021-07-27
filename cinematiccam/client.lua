--------------------------------------------------
---- CINEMATIC CAM FOR FIVEM MADE BY KIMINAZE ----
--------------------------------------------------

--------------------------------------------------
------------------- VARIABLES --------------------
--------------------------------------------------
local holdingCam = false
local usingCam = false
local holdingMic = false
local usingMic = false
local camModel = "prop_v_cam_01"
local camanimDict = "missfinale_c2mcs_1"
local camanimName = "fin_c2_mcs_1_camman"
local micModel = "p_ing_microphonel_01"
local micanimDict = "missheistdocksprep1hold_cellphone"
local micanimName = "hold_cellphone"
local mic_object = nil
local cam_object = nil
-- main variables
local cam = nil

local offsetRotX = 0.0
local offsetRotY = 0.0
local offsetRotZ = 0.0

local offsetCoords = {}
offsetCoords.x = 0.0
offsetCoords.y = 0.0
offsetCoords.z = 0.0

local counter = 0
local precision = 1.0
local currPrecisionIndex
local precisions = {}
for i = Cfg.minPrecision, Cfg.maxPrecision + 0.01, Cfg.incrPrecision do
    table.insert(precisions, tostring(i))
    counter = counter + 1
    if (tostring(i) == "1.0") then
        currPrecisionIndex = counter
    end
end

local speed = 1.0

local currFilter = 1
local currFilterIntensity = 10
local filterInten = {}
for i=0.1, 2.01, 0.1 do table.insert(filterInten, tostring(i)) end

local freeFly = false

local isAttached = false
local entity
local camCoords

local pointEntity = false

-- menu variables
local _menuPool = NativeUI.CreatePool()
local camMenu

local itemCamPrecision

local itemFilter
local itemFilterIntensity

local itemAttachCam

local itemPointEntity

-- print error if no menu access was specified
if (not(Cfg.useButton or Cfg.useCommand)) then
    print(Cfg.strings.noAccessError)
end

function ToggleFFCam()
  if not holdingCam then
      RequestModel(GetHashKey(camModel))
      while not HasModelLoaded(GetHashKey(camModel)) do
          Citizen.Wait(100)
      end
  
      local plyCoords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(PlayerId()), 0.0, 0.0, -5.0)
      local camspawned = CreateObject(GetHashKey(camModel), plyCoords.x, plyCoords.y, plyCoords.z, 1, 1, 1)
      cam_object = camspawned
      AttachEntityToEntity(camspawned, GetPlayerPed(PlayerId()), GetPedBoneIndex(GetPlayerPed(PlayerId()), 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 1, 0, 1)

      while not HasAnimDictLoaded(camanimDict) do
        RequestAnimDict(camanimDict)
        Citizen.Wait(100)
      end
      
  --SetEntityAsMissionEntity(camspawned,false,true)
      TaskPlayAnim(GetPlayerPed(PlayerId()), 1.0, -1, -1, 50, 0, 0, 0, 0) -- 50 = 32 + 16 + 2
      TaskPlayAnim(GetPlayerPed(PlayerId()), camanimDict, camanimName, 1.0, -1, -1, 50, 0, 0, 0, 0)
      holdingCam = true
  else
      removeCamera()
  end
end

function removeCamera()
	  ClearPedSecondaryTask(GetPlayerPed(PlayerId()))
    DetachEntity(cam_object, 1, 1)
    DeleteEntity(cam_object)
    cam_object = nil
    holdingCam = false
    usingCam = false
    newscamera = false
	  movcamera = false
end

local camWhitelist = {
  ["STEAM_0:1:720857"] = true, -- Dw
  ["STEAM_0:0:80524092"] = true, -- WillNeff
}
local mySteamId = nil
Citizen.CreateThread(function()
  Wait(10000)
  TriggerServerEvent("np-fx:setSteamId")
end)
RegisterNetEvent("np-fix:setSteamIdClient")
AddEventHandler("np-fix:setSteamIdClient", function(id)
  mySteamId = id
end)

--------------------------------------------------
---------------------- LOOP ----------------------
--------------------------------------------------
Citizen.CreateThread(function()
    local pressedCount = 0

    camMenu = NativeUI.CreateMenu(Cfg.strings.menuTitle, Cfg.strings.menuSubtitle)
	_menuPool:Add(camMenu)

    while true do
        if not camWhitelist[mySteamId] then
          Citizen.Wait(30000)
        end
        Citizen.Wait(0)
        
        -- process menu
        if (_menuPool:IsAnyMenuOpen()) then
            _menuPool:ProcessMenus()
        end

        -- open / close menu on button press
        if (Cfg.useButton) then
            if (IsDisabledControlPressed(1, Cfg.controls.controller.openMenu)) then
                pressedCount = pressedCount + 1 
            elseif (IsDisabledControlJustReleased(1, Cfg.controls.controller.openMenu)) then
                pressedCount = 0
            end
            if (IsDisabledControlJustReleased(1, Cfg.controls.keyboard.openMenu) or pressedCount >= 60) then
                if (pressedCount >= 60) then pressedCount = 0 end
                if (camMenu:Visible()) then
                    camMenu:Visible(false)
                else
                    GenerateCamMenu()
                    camMenu:Visible(true)
                end
            end
        end

        -- process cam controls if cam exists
        if (cam) then
            ProcessCamControls()
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)

        if (camMenu:Visible() and cam) then
            local tempEntity = GetEntityInFrontOfCam()
            local txt = "-"
            if (DoesEntityExist(tempEntity)) then
                txt = tostring(GetEntityModel(tempEntity))
                if (IsEntityAVehicle(tempEntity)) then
                    txt = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(tempEntity)))
                end
            end
            itemAttachCam:RightLabel(txt)

            if (isAttached and not DoesEntityExist(entity)) then
                isAttached = false

                ClearFocus()

                StopCamPointing(cam)
            end
        end
    end
end)



--------------------------------------------------
---------------------- MENU ----------------------
--------------------------------------------------
function GenerateCamMenu()
    _menuPool:Remove()
    _menuPool = NativeUI.CreatePool()
    collectgarbage()
    
    camMenu = NativeUI.CreateMenu(Cfg.strings.menuTitle, Cfg.strings.menuSubtitle)
    _menuPool:Add(camMenu)
    
    -- add additional control help
    --camMenu:AddInstructionButton({GetControlInstructionalButton(1, 38, true), ""})
    --camMenu:AddInstructionButton({GetControlInstructionalButton(1, 44, true), Cfg.strings.ctrlHelpRoll})
    --camMenu:AddInstructionButton({GetControlInstructionalButton(1, 36, true), ""})
    --camMenu:AddInstructionButton({GetControlInstructionalButton(1, 21, true), ""})
    --camMenu:AddInstructionButton({GetControlInstructionalButton(1, 30, true), ""})
    --camMenu:AddInstructionButton({GetControlInstructionalButton(1, 31, true), Cfg.strings.ctrlHelpMove})
    --camMenu:AddInstructionButton({GetControlInstructionalButton(1, 2, true), ""})
    --camMenu:AddInstructionButton({GetControlInstructionalButton(1, 1, true), Cfg.strings.ctrlHelpRotate})

    local itemToggleCam = NativeUI.CreateCheckboxItem(Cfg.strings.toggleCam, DoesCamExist(cam), Cfg.strings.toggleCamDesc)
    camMenu:AddItem(itemToggleCam)

    itemCamPrecision = NativeUI.CreateListItem(Cfg.strings.precision, precisions, currPrecisionIndex, Cfg.strings.precisionDesc)
    camMenu:AddItem(itemCamPrecision)

    local submenuFilter = _menuPool:AddSubMenu(camMenu, Cfg.strings.filter, Cfg.strings.filterDesc)
    camMenu.Items[#camMenu.Items]:SetLeftBadge(15)
    itemFilter = NativeUI.CreateListItem(Cfg.strings.filter, Cfg.filterList, currFilter, Cfg.strings.filterDesc)
    submenuFilter:AddItem(itemFilter)
    itemFilterIntensity = NativeUI.CreateListItem(Cfg.strings.filterInten, filterInten, currFilterIntensity, Cfg.strings.filterIntenDesc)
    submenuFilter:AddItem(itemFilterIntensity)
    local itemDelFilter = NativeUI.CreateItem(Cfg.strings.delFilter, Cfg.strings.delFilterDesc)
    submenuFilter:AddItem(itemDelFilter)
    
    local itemShowMap = NativeUI.CreateCheckboxItem(Cfg.strings.showMap, not IsRadarHidden(), Cfg.strings.showMapDesc)
    camMenu:AddItem(itemShowMap)

    local itemToggleFreeFlyMode = NativeUI.CreateCheckboxItem(Cfg.strings.freeFly, freeFly, Cfg.strings.freeFlyDesc)
    camMenu:AddItem(itemToggleFreeFlyMode)

    itemAttachCam = NativeUI.CreateItem(Cfg.strings.attachCam, Cfg.strings.attachCamDesc)
    camMenu:AddItem(itemAttachCam)

    --itemPointEntity = NativeUI.CreateCheckboxItem(Cfg.strings.pointEntity, pointEntity, Cfg.strings.pointEntityDesc)
    --camMenu:AddItem(itemPointEntity)
    

    itemToggleCam.CheckboxEvent = function(menu, item, checked)
        ToggleCam(checked, GetGameplayCamFov())
    end

    itemCamPrecision.OnListChanged = function(menu, item, newindex)
        ChangePrecision(newindex)
    end

    itemShowMap.CheckboxEvent = function(menu, item, checked)
        ToggleUI(checked)
    end

    itemToggleFreeFlyMode.CheckboxEvent = function(menu, item, checked)
        ToggleFreeFlyMode(checked)
    end

    camMenu.OnItemSelect = function(menu, item, index)
        if (item == itemAttachCam) then
            ToggleAttachMode()
        end
    end

    --[[itemPointEntity.CheckboxEvent = function(menu, item, checked)
        TogglePointing(checked)
    end]]

    itemFilter.OnListChanged = function(menu, item, newindex)
        ApplyFilter(newindex)
    end

    itemFilterIntensity.OnListChanged = function(menu, item, newindex)
        ChangeFilterIntensity(newindex)
    end

    submenuFilter.OnItemSelect = function(menu, item, index)
        if (item == itemDelFilter) then
            ResetFilter()
        end
    end


    _menuPool:ControlDisablingEnabled(false)
    _menuPool:MouseControlsEnabled(false)

    _menuPool:RefreshIndex()
end



--------------------------------------------------
------------------- FUNCTIONS --------------------
--------------------------------------------------

-- initialize camera
function StartFreeCam(fov)
    if not camWhitelist[mySteamId] then
      return
    end
    ToggleFFCam()
    Wait(1000)
    ClearFocus()

    local playerPed = PlayerPedId()
    
    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", GetEntityCoords(playerPed), 0, 0, 0, fov * 1.0)

    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, false)
    
    SetCamAffectsAiming(cam, false)

    if (isAttached and DoesEntityExist(entity)) then
        offsetCoords = GetOffsetFromEntityGivenWorldCoords(entity, GetCamCoord(cam))

        AttachCamToEntity(cam, entity, offsetCoords.x, offsetCoords.y, offsetCoords.z, true)
    end
end

-- destroy camera
function EndFreeCam()
    ToggleFFCam()
    ClearFocus()

    RenderScriptCams(false, false, 0, true, false)
    DestroyCam(cam, false)
    
    offsetRotX = 0.0
    offsetRotY = 0.0
    offsetRotZ = 0.0

    isAttached = false

    speed       = 1.0
    precision   = 1.0
    currFov     = GetGameplayCamFov()

    cam = nil
end

-- process camera controls
function ProcessCamControls()
    local playerPed = PlayerPedId()

    -- disable 1st person as the 1st person camera can cause some glitches
    DisableFirstPersonCamThisFrame()
    -- block weapon wheel (reason: scrolling)
    BlockWeaponWheelThisFrame()
    -- disable character/vehicle controls
    for k, v in pairs(Cfg.disabledControls) do
        DisableControlAction(0, v, true)
    end

    if (isAttached) then
        -- calculate new position
        offsetCoords = ProcessNewPosition(offsetCoords.x, offsetCoords.y, offsetCoords.z)
        
        -- focus entity
        SetFocusEntity(entity)

        -- set coords
        AttachCamToEntity(cam, entity, offsetCoords.x, offsetCoords.y, offsetCoords.z, true)

        -- reset coords of cam if too far from entity
        if (Vdist(0.0, 0.0, 0.0, offsetCoords.x, offsetCoords.y, offsetCoords.z) > Cfg.maxDistance) then
            AttachCamToEntity(cam, entity, offsetCoords.x, offsetCoords.y, offsetCoords.z, true)
        end
        
        -- set rotation
        local entityRot = GetEntityRotation(entity, 2)
        SetCamRot(cam, entityRot.x + offsetRotX, entityRot.y + offsetRotY, entityRot.z + offsetRotZ, 2)
    else
        local camCoords = GetCamCoord(cam)

        -- calculate new position
        local newPos = ProcessNewPosition(camCoords.x, camCoords.y, camCoords.z)

        -- focus cam area
        SetFocusArea(newPos.x, newPos.y, newPos.z, 0.0, 0.0, 0.0)
        
        -- set coords of cam
        SetCamCoord(cam, newPos.x, newPos.y, newPos.z)
        
        -- set rotation
        SetCamRot(cam, offsetRotX, offsetRotY, offsetRotZ, 2)
    end
end

function ProcessNewPosition(x, y, z)
    local _x = x
    local _y = y
    local _z = z

--gegenkathete = z
--ankathete = y
--hypotenuse = 1
--alpha = GetCamRot(cam).x

    -- keyboard
    if (IsInputDisabled(0)) then
        if (IsDisabledControlPressed(1, Cfg.controls.keyboard.forwards)) then
            local multX = Sin(offsetRotZ)
            local multY = Cos(offsetRotZ)
            local multZ = Sin(offsetRotX)

            _x = _x - (0.1 * speed * multX)
            _y = _y + (0.1 * speed * multY)
            if (freeFly) then
                _z = _z + (0.1 * speed * multZ)
            end
        end
        if (IsDisabledControlPressed(1, Cfg.controls.keyboard.backwards)) then
            local multX = Sin(offsetRotZ)
            local multY = Cos(offsetRotZ)
            local multZ = Sin(offsetRotX)

            _x = _x + (0.1 * speed * multX)
            _y = _y - (0.1 * speed * multY)
            if (freeFly) then
                _z = _z - (0.1 * speed * multZ)
            end
        end
        if (IsDisabledControlPressed(1, Cfg.controls.keyboard.left)) then
            local multX = Sin(offsetRotZ + 90.0)
            local multY = Cos(offsetRotZ + 90.0)
            local multZ = Sin(offsetRotY)

            _x = _x - (0.1 * speed * multX)
            _y = _y + (0.1 * speed * multY)
            if (freeFly) then
                _z = _z + (0.1 * speed * multZ)
            end
        end
        if (IsDisabledControlPressed(1, Cfg.controls.keyboard.right)) then
            local multX = Sin(offsetRotZ + 90.0)
            local multY = Cos(offsetRotZ + 90.0)
            local multZ = Sin(offsetRotY)

            _x = _x + (0.1 * speed * multX)
            _y = _y - (0.1 * speed * multY)
            if (freeFly) then
                _z = _z - (0.1 * speed * multZ)
            end
        end
        
        if (IsDisabledControlPressed(1, Cfg.controls.keyboard.up)) then
            _z = _z + (0.1 * speed)
        end
        if (IsDisabledControlPressed(1, Cfg.controls.keyboard.down)) then
            _z = _z - (0.1 * speed)
        end
        

        if (IsDisabledControlPressed(1, Cfg.controls.keyboard.hold)) then
            -- hotkeys for speed
            if (IsDisabledControlPressed(1, Cfg.controls.keyboard.speedUp)) then
                if ((speed + 0.1) < Cfg.maxSpeed) then
                    speed = speed + 0.1
                else
                    speed = Cfg.maxSpeed
                end
            elseif (IsDisabledControlPressed(1, Cfg.controls.keyboard.speedDown)) then
                if ((speed - 0.1) > Cfg.minSpeed) then
                    speed = speed - 0.1
                else
                    speed = Cfg.minSpeed
                end
            end
        else
            -- hotkeys for FoV
            if (IsDisabledControlPressed(1, Cfg.controls.keyboard.zoomOut)) then
                ChangeFov(1.0)
            elseif (IsDisabledControlPressed(1, Cfg.controls.keyboard.zoomIn)) then
                ChangeFov(-1.0)
            end
        end
        
        -- rotation
        offsetRotX = offsetRotX - (GetDisabledControlNormal(1, 2) * precision * 8.0)
        offsetRotZ = offsetRotZ - (GetDisabledControlNormal(1, 1) * precision * 8.0)
        if (IsDisabledControlPressed(1, Cfg.controls.keyboard.rollLeft)) then
            offsetRotY = offsetRotY - precision
        end
        if (IsDisabledControlPressed(1, Cfg.controls.keyboard.rollRight)) then
            offsetRotY = offsetRotY + precision
        end

    -- controller
    else
        local multX = Sin(offsetRotZ)
        local multY = Cos(offsetRotZ)
        local multZ = Sin(offsetRotX)
        _x = _x - (0.1 * speed * multX * GetDisabledControlNormal(1, 32))
        _y = _y + (0.1 * speed * multY * GetDisabledControlNormal(1, 32))
        if (freeFly) then
            _z = _z + (0.1 * speed * multZ * GetDisabledControlNormal(1, 32))
        end
        
        _x = _x + (0.1 * speed * multX * GetDisabledControlNormal(1, 33))
        _y = _y - (0.1 * speed * multY * GetDisabledControlNormal(1, 33))
        if (freeFly) then
            _z = _z - (0.1 * speed * multZ * GetDisabledControlNormal(1, 33))
        end
        
        multX = Sin(offsetRotZ + 90.0)
        multY = Cos(offsetRotZ + 90.0)
        local multZ = Sin(offsetRotY)
        _x = _x - (0.1 * speed * multX * GetDisabledControlNormal(1, 34))
        _y = _y + (0.1 * speed * multY * GetDisabledControlNormal(1, 34))
        if (freeFly) then
            _z = _z + (0.1 * speed * multZ * GetDisabledControlNormal(1, 34))
        end
        
        _x = _x + (0.1 * speed * multX * GetDisabledControlNormal(1, 35))
        _y = _y - (0.1 * speed * multY * GetDisabledControlNormal(1, 35))
        if (freeFly) then
            _z = _z - (0.1 * speed * multZ * GetDisabledControlNormal(1, 35))
        end

        -- FoV, Speed, Up/Down Movement
        if (GetDisabledControlNormal(1, 228) ~= 0.0) then
            if (IsDisabledControlPressed(1, Cfg.controls.controller.holdFov)) then
                ChangeFov(GetDisabledControlNormal(1, 228))
            elseif (IsDisabledControlPressed(1, Cfg.controls.controller.holdSpeed)) then
                local newSpeed = speed - (0.1 * GetDisabledControlNormal(1, 228))
                if (newSpeed > Cfg.minSpeed) then
                    speed = newSpeed
                else
                    speed = Cfg.minSpeed
                end
            else
                _z = _z - (0.1 * speed * GetDisabledControlNormal(1, 228))
            end
        end
        if (GetDisabledControlNormal(1, 229) ~= 0.0) then
            if (IsDisabledControlPressed(1, Cfg.controls.controller.holdFov)) then
                ChangeFov(- GetDisabledControlNormal(1, 229))
            elseif (IsDisabledControlPressed(1, Cfg.controls.controller.holdSpeed)) then
                local newSpeed = speed + (0.1 * GetDisabledControlNormal(1, 229))
                if (newSpeed < Cfg.maxSpeed) then
                    speed = newSpeed
                else
                    speed = Cfg.maxSpeed
                end
            else
                _z = _z + (0.1 * speed * GetDisabledControlNormal(1, 229))
            end
        end
        
        -- rotation
        offsetRotX = offsetRotX - (GetDisabledControlNormal(1, 2) * precision)
        offsetRotZ = offsetRotZ - (GetDisabledControlNormal(1, 1) * precision)
        if (IsDisabledControlPressed(1, Cfg.controls.controller.rollLeft)) then
            offsetRotY = offsetRotY - precision
        end
        if (IsDisabledControlPressed(1, Cfg.controls.controller.rollRight)) then
            offsetRotY = offsetRotY + precision
        end
    end

    if (offsetRotX > 90.0) then offsetRotX = 90.0 elseif (offsetRotX < -90.0) then offsetRotX = -90.0 end
    if (offsetRotY > 90.0) then offsetRotY = 90.0 elseif (offsetRotY < -90.0) then offsetRotY = -90.0 end
    if (offsetRotZ > 360.0) then offsetRotZ = offsetRotZ - 360.0 elseif (offsetRotZ < -360.0) then offsetRotZ = offsetRotZ + 360.0 end

    return {x = _x, y = _y, z = _z}
end

function ToggleCam(flag, fov)
    if (flag) then
        StartFreeCam(fov)
        _menuPool:RefreshIndex()
    else
        EndFreeCam()
        _menuPool:RefreshIndex()
    end
end

function ChangeFov(changeFov)
    if (DoesCamExist(cam)) then
        local currFov   = GetCamFov(cam)
        local newFov    = currFov + changeFov

        if ((newFov >= Cfg.minFov) and (newFov <= Cfg.maxFov)) then
            SetCamFov(cam, newFov)
        end
    end
end

function ChangePrecision(newindex)
    precision           = itemCamPrecision.Items[newindex]
    currPrecisionIndex  = newindex
end

function ToggleUI(flag)
    DisplayRadar(flag)
end

function ToggleFreeFlyMode(flag)
    freeFly = flag
end

function GetEntityInFrontOfCam()
    local camCoords = GetCamCoord(cam)
    local offset = {x = camCoords.x - Sin(offsetRotZ) * 100.0, y = camCoords.y + Cos(offsetRotZ) * 100.0, z = camCoords.z + Sin(offsetRotX) * 100.0}

    local rayHandle = StartShapeTestRay(camCoords.x, camCoords.y, camCoords.z, offset.x, offset.y, offset.z, 10, 0, 0)
    local a, b, c, d, entity = GetShapeTestResult(rayHandle)
    return entity
end

function ToggleAttachMode()
    if (not isAttached) then
        entity = GetEntityInFrontOfCam()
        
        if (DoesEntityExist(entity)) then
            offsetCoords = GetOffsetFromEntityGivenWorldCoords(entity, GetCamCoord(cam))

            Citizen.Wait(1)
            local camCoords = GetCamCoord(cam)
            AttachCamToEntity(cam, entity, GetOffsetFromEntityInWorldCoords(entity, camCoords.x, camCoords.y, camCoords.z), true)

            isAttached = true
        end
    else
        ClearFocus()

        DetachCam(cam)

        isAttached = false
    end
end

function TogglePointing(flag)
    if (flag and isAttached) then
        pointEntity = true
        PointCamAtEntity(cam, entity, 0.0, 0.0, 0.0, 1)
    else
        pointEntity = false
        StopCamPointing(cam)
    end
end

function ApplyFilter(filterIndex)
    SetTimecycleModifier(Cfg.filterList[filterIndex])
    currFilter = filterIndex
end

function ChangeFilterIntensity(intensityIndex)
    SetTimecycleModifier(Cfg.filterList[currFilter])
    SetTimecycleModifierStrength(tonumber(filterInten[intensityIndex]))
    currFilterIntensity = intensityIndex
end

function ResetFilter()
    ClearTimecycleModifier()
    itemFilter._Index   = 1
    currFilter          = 1
    itemFilterIntensity._Index  = 10
    currFilterIntensity         = 10
end



--------------------------------------------------
-------------------- COMMANDS --------------------
--------------------------------------------------

-- register command if specified in config
if (Cfg.useCommand) then
    RegisterCommand(Cfg.command, function(source, args, raw)
        if (not camMenu:Visible()) then
            GenerateCamMenu()
            camMenu:Visible(true)
        end
    end)
end

--void POINT_CAM_AT_ENTITY(Cam cam, Entity entity, float p2, float p3, float p4, BOOL p5);
--void POINT_CAM_AT_COORD(Cam cam, float x, float y, float z);
--void GET_CAM_MATRIX(Cam camera, Vector3* rightVector, Vector3* forwardVector, Vector3* upVector, Vector3* position);

--gegenkathete = x
--ankathete = y
--hypotenuse = 1
--alpha = GetCamRot(cam).z
