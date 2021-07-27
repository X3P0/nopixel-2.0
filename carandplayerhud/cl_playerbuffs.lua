ActiveBuffsCID = {
    -- Barry Briddle
    [1108] = {
        maxhealth = 140
    },
}

ActiveBuffsModel = {
    --Bovice
    [`s_m_y_bovice`] = {
        stamina = 40.0,
        maxhealth = 600,
        meleedamage = 1.5,
    },
}

ActiveBuffsItem = {
    ['boxinggloves'] = {
        meleedamage = 0.1
    }
}

local buffNameToPedFunction = {
    ["maxhealth"] = SetPedMaxHealth,
    ["sweat"] = SetPedSweat,
}

local buffNameToPlayerFunction = {
    ["maxarmor"] = SetPlayerMaxArmour,
    ["meleedamage"] = SetPlayerMeleeWeaponDamageModifier,
    ["meleedefense"] = SetPlayerMeleeWeaponDefenseModifier,
    ["weapondamage"] = SetPlayerWeaponDamageModifier,
    ["weapondefense"] = SetPlayerWeaponDefenseModifier_2,
    ["healthregenlimit"] = SetPlayerHealthRechargeLimit,
    ["healthregenmultiplier"] = SetPlayerHealthRechargeMultiplier,
    ["invincible"] = SetPlayerInvincible,
    ["sprint"] = SetRunSprintMultiplierForPlayer,
    ["swim"] = SetSwimMultiplierForPlayer,
    ["stamina"] = RestorePlayerStamina,
}

local HasBoxingGloves = false

function SetDefaultValues()
    SetPlayerMeleeWeaponDamageModifier(PlayerId(), 1.0)
    SetWeaponDamageModifierThisFrame(`WEAPON_UNARMED`, 1.0)
end

AddEventHandler("np-inventory:itemCheck", function(item, hasItem, quantity)
    local buffs = ActiveBuffsItem[item]
    if buffs == nil then return end

    if not hasItem then
        if item == "boxinggloves" then
            HasBoxingGloves = false
        end
        SetDefaultValues()
        return
    end

    local player = PlayerPedId()
    local playerId = PlayerId()

    for buff, value in pairs(buffs) do
        if buffNameToPedFunction[buff] then
            buffNameToPedFunction[buff](player, value)
        end
        if buffNameToPlayerFunction[buff] then
            buffNameToPlayerFunction[buff](playerId, value)
        end
        if buff == "maxhealth" then
            TriggerEvent("police:setFadeState", false)
        end
        if buff == "meleedamage" then
            SetWeaponDamageModifierThisFrame(`WEAPON_UNARMED`, value)
            if item == "boxinggloves" then
                HasBoxingGloves = true
                Citizen.CreateThread(function()
                    while HasBoxingGloves do
                        Wait(0)
                        SetWeaponDamageModifierThisFrame(`WEAPON_UNARMED`, value)
                    end
                    SetWeaponDamageModifierThisFrame(`WEAPON_UNARMED`, 1.0)
                end)
            end
        end
    end
end)

Citizen.CreateThread(function()
    local isPublic = exports["np-config"]:IsPublic()
    while true and not isPublic do
        local characterId = exports["isPed"]:isPed("cid")
        local player = PlayerPedId()
        local playerId = PlayerId()
        local plyModel = GetEntityModel(player)
        local buffs = ActiveBuffsCID[tonumber(characterId)] or ActiveBuffsModel[plyModel]
        if buffs then
            for buff, value in pairs(buffs) do
                if buffNameToPedFunction[buff] then
                    buffNameToPedFunction[buff](player, value)
                end
                if buffNameToPlayerFunction[buff] then
                    buffNameToPlayerFunction[buff](playerId, value)
                end
                if buff == "maxhealth" then
                    TriggerEvent("police:setFadeState", false)
                end
                if buff == "meleedamage" then
                    SetWeaponDamageModifierThisFrame(`WEAPON_UNARMED`, value)
                end
            end
            Citizen.Wait(60000)
        else
            SetDefaultValues()
            Citizen.Wait(30000)
        end
    end
end)
