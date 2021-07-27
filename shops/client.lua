local methlocation = {  coords = vector3(1763.75, 2499.44, 50.43), ['h'] = 213.58, ['info'] = ' cell1' }
------------------------------
--FONCTIONS
-------------------------------
local cellcoords = {
    [1] =  { coords = vector3(1763.75, 2499.44, 50.43), ['h'] = 213.58, ['info'] = ' cell1' },
    [2] =  { coords = vector3(1761.18, 2497.56, 50.43), ['h'] = 208.44, ['info'] = ' cell2' },
    [3] =  { coords = vector3(1758.35, 2495.69, 50.43), ['h'] = 201.86, ['info'] = ' cell3' },
    [4] =  { coords = vector3(1755.23, 2494.2, 50.43), ['h'] = 202.71, ['info'] = ' cell4' },
    [5] =  { coords = vector3(1752.35, 2492.39, 50.43), ['h'] = 201.77, ['info'] = ' cell5' },
    [6] =  { coords = vector3(1749.21, 2490.48, 50.43), ['h'] = 212.78, ['info'] = ' cell6' },
    [7] =  { coords = vector3(1745.86, 2488.94, 50.43), ['h'] = 213.06, ['info'] = ' cell7' },
    [8] =  { coords = vector3(1743.28, 2486.98, 50.43), ['h'] = 212.35, ['info'] = ' cell8' },
    [9] =  { coords = vector3(1743.2, 2486.85, 45.82), ['h'] = 212.24, ['info'] = ' cell9' },
    [10] =  { coords = vector3(1745.87, 2489.08, 45.82), ['h'] = 208.68, ['info'] = ' cell10' },
    [11] =  { coords = vector3(1748.99, 2490.77, 45.82), ['h'] = 202.26, ['info'] = ' cell11' },
    [12] =  { coords = vector3(1752.14, 2492.47, 45.82), ['h'] = 208.49, ['info'] = ' cell12' },
    [13] =  { coords = vector3(1755.08, 2494.0, 45.82), ['h'] = 212.58, ['info'] = ' cell13' },
    [14] =  { coords = vector3(1761.12, 2497.27, 45.83), ['h'] = 215.37, ['info'] = ' cell14' },
    [15] =  { coords = vector3(1763.93, 2499.34, 45.83), ['h'] = 217.65, ['info'] = ' cell15' },
    [16] =  { coords = vector3(1772.74, 2482.72, 50.43), ['h'] = 24.74, ['info'] = ' cell16' },
    [17] =  { coords = vector3(1769.67, 2480.9, 50.43), ['h'] = 29.66, ['info'] = ' cell17' },
    [18] =  { coords = vector3(1766.94, 2479.04, 50.43), ['h'] = 32.87, ['info'] = ' cell18' },
    [19] =  { coords = vector3(1763.79, 2477.64, 50.42), ['h'] = 22.54, ['info'] = ' cell19' },
    [20] =  { coords = vector3(1760.55, 2476.16, 50.42), ['h'] = 38.85, ['info'] = ' cell20' },
    [21] =  { coords = vector3(1757.82, 2473.99, 50.42), ['h'] = 32.59, ['info'] = ' cell21' },
    [22] =  { coords = vector3(1754.61, 2472.72, 50.42), ['h'] = 38.6, ['info'] = ' cell22' },
    [23] =  { coords = vector3(1751.35, 2470.67, 50.42), ['h'] = 31.17, ['info'] = ' cell23' },
    [24] =  { coords = vector3(1772.55, 2483.08, 45.82), ['h'] = 33.01, ['info'] = ' cell24' },
    [25] =  { coords = vector3(1769.41, 2481.15, 45.82), ['h'] = 32.61, ['info'] = ' cell25' },
    [26] =  { coords = vector3(1769.41, 2481.15, 45.82), ['h'] = 32.61, ['info'] = ' cell25' },
    [27] =  { coords = vector3(1766.78, 2478.99, 45.82), ['h'] = 27.96, ['info'] = ' cell26' },
    [28] =  { coords = vector3(1763.71, 2477.66, 45.82), ['h'] = 33.65, ['info'] = ' cell27' },
    [29] =  { coords = vector3(1760.7, 2475.73, 45.82), ['h'] = 30.13, ['info'] = ' cell28' },
    [30] =  { coords = vector3(1757.74, 2473.94, 45.82), ['h'] = 29.95, ['info'] = ' cell29' },
    [31] =  { coords = vector3(1754.95, 2471.86, 45.82), ['h'] = 40.79, ['info'] = ' cell30' },
    [32] =  { coords = vector3(1751.72, 2470.46, 45.82), ['h'] = 13.22, ['info'] = ' cell31' },

}

local tool_shops = {
    vector3(44.838947296143, -1748.5364990234, 29.549386978149),
    vector3(2749.2309570313, 3472.3308105469, 55.679393768311),
}

-- Massive PP regex VECTOR3 VECTOR4 BUZZWORDS
--[[
    \{\s*\[['"]x["']\]\s*=\s*(-?\d+\.?\d+)\s*,\s*\[['"]y["']\]\s*=\s*(-?\d+\.?\d+)\s*,\s*\[['"]z["']\]\s*=\s*(-?\d+\.?\d+)\s*\}
    vector3($1, $2, $3)

    \{\s*(-?\d+\.?\d+)\s*,\s*(-?\d+\.?\d+)\s*,\s*(-?\d+\.?\d+)\s*\}
    vector3($1, $2, $3)

    This is for x=,y=,z=
    x=([\d.-]+),\s*y=([\d.-]+),\s*z=([\d.-]+)
    vector3($1, $2, $3)
]]
local polarmory_locations = {
    -- vector3(477.97, -988.83, 25.33), --OLD MRPD
    vector3(1773.92, 2517.05, 45.83),
    vector3(1848.82, 3694.61, 34.28),
    vector3(-438.57, 6001.59, 31.72),
    vector3(-1078.78, -824.56, 19.3)
}



local weashop_blips = {}

local helpTextShowing = false

RegisterNetEvent("shop:createMeth")
AddEventHandler("shop:createMeth", function()
    methlocation = cellcoords[math.random(#cellcoords)]
end)


function setShopBlip()

    -- for station,pos in pairs(weashop_locations) do
    --     local loc = pos
    --     pos = pos.entering
    --     local blip = AddBlipForCoord(pos[1],pos[2],pos[3])
    --     -- 60 58 137
    --     SetBlipSprite(blip,110)
    --     SetBlipScale(blip, 0.85)
    --     SetBlipColour(blip, 17)
    --     BeginTextCommandSetBlipName("STRING")
    --     AddTextComponentString('Ammunation')
    --     EndTextCommandSetBlipName(blip)
    --     SetBlipAsShortRange(blip,true)
    --     SetBlipAsMissionCreatorBlip(blip,true)
    --     weashop_blips[#weashop_blips+1]= {blip = blip, pos = loc}
    -- end

    -- for k,v in ipairs(twentyfourseven_shops)do
    --     local blip = AddBlipForCoord(v)
    --     SetBlipSprite(blip, 52)
    --     SetBlipScale(blip, 0.7)
    --     SetBlipColour(blip, 2)
    --     SetBlipAsShortRange(blip, true)
    --     BeginTextCommandSetBlipName("STRING")
    --     AddTextComponentString("Shop")
    --     EndTextCommandSetBlipName(blip)
    -- end

    -- for k,v in ipairs(tool_shops)do
    --     local blip = AddBlipForCoord(v)
    --     SetBlipSprite(blip, 52)
    --     SetBlipScale(blip, 0.7)
    --     SetBlipColour(blip, 2)
    --     SetBlipAsShortRange(blip, true)
    --     BeginTextCommandSetBlipName("STRING")
    --     AddTextComponentString("Tool Shop")
    --     EndTextCommandSetBlipName(blip)
    -- end

end
function DisplayHelpText(str)
    SetTextComponentFormat("STRING")
    AddTextComponentString(str)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

AddEventHandler('shops:vendingMachine', function (pParams, pEntity, pContext)
    if pContext then
        TriggerEvent("server-inventory-open", pContext.flags['isVendingMachineBeverage'] and "36" or "37", "Shop");
    end
end)

Citizen.CreateThread(function()
    setShopBlip()
    while true do

        local found = false
        Citizen.Wait(0)
        local dstscan = 3.0
        local pos = GetEntityCoords(PlayerPedId(), false)

        if(Vdist( 1000.94, -115.18, 74.19, pos.x, pos.y, pos.z) < 20.0)then
            found = true
            -- TODO: At a later date move location
            -- DrawMarker(27,  977.81, -101.04, 74.85 - 1, 0, 0, 0, 0, 0, 0, 1.0001, 1.0001, 1.5001, 0, 25, 165, 165, 0,0, 0,0)
            if(Vdist( 1000.94, -115.18, 74.19, pos.x, pos.y, pos.z) < 2.0)then
                -- DisplayHelpText("Press ~INPUT_CONTEXT~ to open the ~g~craft bench.")
                if IsControlJustPressed(1, 38) and exports["isPed"]:GroupRank("parts_shop") > 3 then
                    TriggerEvent("server-inventory-open", "16", "Craft");
                    Wait(1000)
                    --TriggerEvent("openSubMenu","shop")
                end
            end
        end

        -- if(Vdist( 1108.45, -2007.2, 30.95, pos.x, pos.y, pos.z) < 20.0)then
        --     found = true
        --     DrawMarker(27,  1108.45, -2007.2, 30.95 - 1, 0, 0, 0, 0, 0, 0, 1.0001, 1.0001, 1.5001, 0, 25, 165, 165, 0,0, 0,0)
        --     if(Vdist( 1108.45, -2007.2, 30.95, pos.x, pos.y, pos.z) < 2.0)then
        --         DisplayHelpText("Press ~INPUT_CONTEXT~ to open the ~g~smelter.")
        --         if IsControlJustPressed(1, 38) then
        --             local finished = exports["np-taskbar"]:taskBar(60000,"Readying Smelter")
        --               if (finished == 100) then
        --                   pos = GetEntityCoords(PlayerPedId(), false)
        --                   if(Vdist( 1108.45, -2007.2, 30.95, pos.x, pos.y, pos.z) < 2.0)then
        --                     TriggerEvent("server-inventory-open", "17", "Craft");
        --                     Wait(1000)
        --                 end
        --             end
        --             --TriggerEvent("openSubMenu","shop")
        --         end
        --     end
        -- end

        if(Vdist(256.18,-368.91,-44.13, pos.x, pos.y, pos.z) < 20.0)then
            found = true
            DrawMarker(27, 256.18,-368.91,-44.13 - 1, 0, 0, 0, 0, 0, 0, 1.0001, 1.0001, 1.5001, 0, 25, 165, 165, 0,0, 0,0)
            if(Vdist(256.18,-368.91,-44.13, pos.x, pos.y, pos.z) < 3.0)then
                DisplayHelpText("Press ~INPUT_CONTEXT~ to open the ~g~shop.")
                if IsControlJustPressed(1, 38) then
                    TriggerEvent("server-inventory-open", "14", "Shop");
                    Wait(1000)
                    --TriggerEvent("openSubMenu","shop")
                end
            end
        end

        -- if(Vdist(105.2,3600.14, 40.73, pos.x, pos.y, pos.z) < 20.0)then
        --     found = true
        --     DrawMarker(27, 105.2,3600.14, 40.73 - 1, 0, 0, 0, 0, 0, 0, 1.0001, 1.0001, 1.5001, 0, 25, 165, 165, 0,0, 0,0)
        --     if(Vdist(105.2,3600.14, 40.73, pos.x, pos.y, pos.z) < 3.0)then
        --         DisplayHelpText("Press ~INPUT_CONTEXT~ to ~g~ Craft.")
        --         if IsControlJustPressed(1, 38) and exports["isPed"]:GroupRank("lost_mc") >= 3 then
        --               pos = GetEntityCoords(PlayerPedId(), false)
        --               if(Vdist(105.2,3600.14, 40.73, pos.x, pos.y, pos.z) < 3.0)then
        --                 TriggerEvent("server-inventory-open", "9", "Craft");
        --                 Wait(1000)
        --             end
        --         end
        --     end
        -- end

        if(Vdist(885.61,-3199.84,-98.19, pos.x, pos.y, pos.z) < 20.0)then
            found = true
            DrawMarker(27, 885.61,-3199.84,-98.19 - 1, 0, 0, 0, 0, 0, 0, 1.0001, 1.0001, 1.5001, 0, 25, 165, 165, 0,0, 0,0)
            if(Vdist(885.61,-3199.84,-98.19, pos.x, pos.y, pos.z) < 3.0)then
                DisplayHelpText("Press ~INPUT_CONTEXT~ to ~g~ CRAFT.")
                if IsControlJustPressed(1, 38) then

                      pos = GetEntityCoords(PlayerPedId(), false)
                      if(Vdist(885.61,-3199.84,-98.19, pos.x, pos.y, pos.z) < 3.0)then
                        TriggerEvent("server-inventory-open", "6", "Craft");
                        Wait(1000)
                    end

                end
            end
        end

        if(Vdist(1783.16, 2557.02, 45.68, pos.x, pos.y, pos.z) < 10.0)then
            found = true
            DrawMarker(27, 1783.16, 2557.02, 45.68 - 1, 0, 0, 0, 0, 0, 0, 1.0001, 1.0001, 1.5001, 0, 25, 165, 165, 0,0, 0,0)
            if(Vdist(1783.16, 2557.02, 45.68, pos.x, pos.y, pos.z) < 2.0)then
                DisplayHelpText("Press ~INPUT_CONTEXT~ to look at food")
                if IsControlJustPressed(1, 38) then
                    TriggerEvent("server-inventory-open", "22", "Shop");
                    Wait(1000)
                    --TriggerEvent("openSubMenu","burgershot")
                end
            end
        end

        if(Vdist(-1528.8, 846.02, 181.6, pos.x, pos.y, pos.z) < 10.0)then
            found = true
            DrawMarker(27, -1528.8, 846.02, 181.6 - 1, 0, 0, 0, 0, 0, 0, 1.0001, 1.0001, 1.5001, 0, 25, 165, 165, 0,0, 0,0)
            if(Vdist(-1528.8, 846.02, 181.6, pos.x, pos.y, pos.z) < 2.0)then
                DisplayHelpText("Press ~INPUT_CONTEXT~ to look at food")
                if IsControlJustPressed(1, 38) then
                    TriggerEvent("server-inventory-open", "22", "Shop");
                    Wait(1000)
                    --TriggerEvent("openSubMenu","burgershot")
                end
            end
        end

        if(Vdist(methlocation["x"],methlocation["y"],methlocation["z"], pos.x, pos.y, pos.z) < 10.0)then
            found = true
            if(Vdist(methlocation["x"],methlocation["y"],methlocation["z"], pos.x, pos.y, pos.z) < 5.0)then
                DisplayHelpText("Press ~INPUT_CONTEXT~ what dis?")
                if IsControlJustPressed(1, 38) then
                    local finished = exports["np-taskbar"]:taskBar(60000,"Searching...")
                      if (finished == 100) and Vdist(methlocation["x"],methlocation["y"],methlocation["z"], pos.x, pos.y, pos.z) < 2.0 then
                        TriggerEvent("server-inventory-open", "25", "Shop");
                        Wait(1000)
                    end
                    --TriggerEvent("openSubMenu","burgershot")
                end
            end
        end

        if(Vdist(1663.36, 2512.99, 46.87, pos.x, pos.y, pos.z) < 10.0)then
            found = true
            if(Vdist(1663.36, 2512.99, 46.87, pos.x, pos.y, pos.z) < 2.0)then
                DisplayHelpText("Press ~INPUT_CONTEXT~ what dis?")
                if IsControlJustPressed(1, 38) and (Vdist(1663.36, 2512.99, 46.87, pos.x, pos.y, pos.z) < 2.0) then
                    local finished = exports["np-taskbar"]:taskBar(60000,"Searching...")
                      if (finished == 100) then
                        TriggerEvent("server-inventory-open", "26", "Shop");
                        Wait(1000)
                    end
                    --TriggerEvent("openSubMenu","burgershot")
                end
            end
        end

        if(Vdist(1778.47, 2557.58, 45.68, pos.x, pos.y, pos.z) < 10.0)then
            found = true
            if(Vdist(1778.47, 2557.58, 45.68, pos.x, pos.y, pos.z) < 2.0)then
                DisplayHelpText("Press ~INPUT_CONTEXT~ what dis?")
                if IsControlJustPressed(1, 38) and (Vdist(1778.47, 2557.58, 45.68, pos.x, pos.y, pos.z) < 2.0) then
                    local finished = exports["np-taskbar"]:taskBar(60000,"Making a god slushy...")
                      if (finished == 100) then
                        TriggerEvent("server-inventory-open", "27", "Shop");
                        Wait(1000)
                    end
                    --TriggerEvent("openSubMenu","burgershot")
                end
            end
        end

        if(Vdist(1777.58, 2565.15, 45.68, pos.x, pos.y, pos.z) < 10.0)then
            found = true
            if(Vdist(1777.58, 2565.15, 45.68, pos.x, pos.y, pos.z) < 2.0)then
                DisplayHelpText("Press ~INPUT_CONTEXT~ what dis?")
                if IsControlJustPressed(1, 38) then
                    local finished = exports["np-taskbar"]:taskBar(60000,"Searching...")
                      if (finished == 100) and (Vdist(1777.58, 2565.15, 45.68, pos.x, pos.y, pos.z) < 2.0) then
                        TriggerEvent("server-inventory-open", "23", "Craft");
                        Wait(1000)
                    end
                    --TriggerEvent("openSubMenu","burgershot")
                end
            end
        end

        --Old bean machine
        --if(Vdist(-632.64, 235.25, 81.89, pos.x, pos.y, pos.z) < 10.0)then
        --    found = true
        --    DrawMarker(27, -632.64, 235.25, 81.89 - 1, 0, 0, 0, 0, 0, 0, 1.0001, 1.0001, 1.5001, 0, 25, 165, 165, 0,0, 0,0)
        --    if(Vdist(-632.64, 235.25, 81.89, pos.x, pos.y, pos.z) < 5.0)then
        --        DisplayHelpText("Press ~INPUT_CONTEXT~ to purchase coffee")
        --        if IsControlJustPressed(1, 38) then
        --            TriggerEvent("server-inventory-open", "12", "Shop");
        --            Wait(1000)
                    --TriggerEvent("openSubMenu","burgershot")
        --        end
        --    end
        --end


        --Bean Machine Ingredients
        -- if(Vdist(-631.7341, 228.0552, 81.88, pos.x, pos.y, pos.z) < 2.5) then
        --     found = true
        --     DrawMarker(27, -631.7341, 228.0552, 81.88 - 1, 0, 0, 0, 0, 0, 0, 1.0001, 1.0001, 1.5001, 0, 25, 165, 165, 0,0, 0,0)
        --     if(Vdist(-631.7341, 228.0552, 81.88, pos.x, pos.y, pos.z) < 1.0) then
        --         if not helpTextShowing then
        --             exports["np-ui"]:showInteraction("[E] Grab Ingredients")
        --             helpTextShowing = true
        --         end
        --         if IsControlJustPressed(1, 38) then
        --             exports["np-ui"]:hideInteraction()
        --             local finished = exports["np-taskbar"]:taskBar(6000, "Getting Ingredients")
        --             if finished == 100 then
        --                 pos = GetEntityCoords(PlayerPedId(), false)
        --                 if(Vdist(-631.7341, 228.0552, 81.88, pos.x, pos.y, pos.z) < 2.0) then
        --                     TriggerEvent("server-inventory-open", "124", "Shop");
        --                     Wait(1000)
        --                 end
        --             end
        --         end
        --     else
        --         if helpTextShowing then
        --             exports["np-ui"]:hideInteraction()
        --             helpTextShowing = false
        --         end
        --     end
        -- end

        -- --Bean Machine Crafting
        -- if(Vdist(-630.86,223.59,81.89, pos.x, pos.y, pos.z) < 2.5) then
        --     found = true
        --     DrawMarker(27, -630.86,223.59,81.89 - 1, 0, 0, 0, 0, 0, 0, 1.0001, 1.0001, 1.5001, 0, 25, 165, 165, 0,0, 0,0)
        --     if(Vdist(-630.86,223.59,81.89, pos.x, pos.y, pos.z) < 1.0) then
        --         if not helpTextShowing then
        --             exports["np-ui"]:showInteraction("[E] Cook Food")
        --             helpTextShowing = true
        --         end
        --         if IsControlJustPressed(1, 38) then
        --             exports["np-ui"]:hideInteraction()
        --             local finished = exports["np-taskbar"]:taskBar(60000, "Cooking Food")
        --             if finished == 100 then
        --                 pos = GetEntityCoords(PlayerPedId(), false)
        --                 if(Vdist(-630.86,223.59,81.89, pos.x, pos.y, pos.z) < 2.0) then
        --                     TriggerEvent("server-inventory-open", "122", "Craft");
        --                     Wait(1000)
        --                 end
        --             end
        --         end
        --     else
        --         if helpTextShowing then
        --             exports["np-ui"]:hideInteraction()
        --             helpTextShowing = false
        --         end
        --     end
        -- end

        if(Vdist(-678.24, 5838.43, 16.63, pos.x, pos.y, pos.z) < 10.0)then
            found = true
            DrawMarker(27, -678.24, 5838.43, 16.63 - 1, 0, 0, 0, 0, 0, 0, 1.0001, 1.0001, 1.5001, 0, 25, 165, 165, 0,0, 0,0)
            if(Vdist(-678.24, 5838.43, 16.63, pos.x, pos.y, pos.z) < 2.0)then
                DisplayHelpText("Press ~INPUT_CONTEXT~ to look at gear.")
                if IsControlJustPressed(1, 38) then
                    TriggerEvent("server-inventory-open", "34", "Shop");
                    Wait(1000)
                end
            end
        end

        if not found and dstscan > 2.5 then
            Wait(1200)
        end
    end
end)
