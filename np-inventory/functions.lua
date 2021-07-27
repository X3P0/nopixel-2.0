local fixingvehicle = false
local justUsed = false
local retardCounter = 0
local lastCounter = 0
local HeadBone = 0x796e;
local wheelChair = nil
local boxAttached = false
local franksFluteCount = 0
-- Buddha quest

local BuddhaIsItemFound1 = false
local BuddhaIsItemFound2 = false
local BuddhaIsItemFound3 = false


local parachuteConfig = {
  ["-72657034"] = {
    replace = `p_parachute1_mp_s`,
    tint = 6,
  },
  ["airxchute"] = {
    replace = `p_parachute1_mp_dec`,
    tint = 1,
  },
}

local jailBounds = PolyZone:Create({
  vector2(1855.8966064453, 2701.9802246094),
  vector2(1775.4013671875, 2770.5339355469),
  vector2(1646.7535400391, 2765.9870605469),
  vector2(1562.7836914063, 2686.6459960938),
  vector2(1525.3662109375, 2586.5190429688),
  vector2(1533.7038574219, 2465.5300292969),
  vector2(1657.5997314453, 2386.9389648438),
  vector2(1765.8286132813, 2404.4763183594),
  vector2(1830.1740722656, 2472.1193847656),
  vector2(1855.7557373047, 2569.0361328125)
}, {
    name = "jail_bounds",
    minZ = 30,
    maxZ = 70.5,
    debugGrid = false,
    gridDivisions = 25
})

local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

local isStressBlocking = false
local function processStressBlock()
  if isStressBlocking then return end
  isStressBlocking = true
  TriggerEvent("client:disableStress", true)
  Citizen.CreateThread(function()
    Wait(1000 * 60 * 60) -- 60 minutes
    TriggerEvent("client:disableStress", false)
    isStressBlocking = false
  end)
end

local fruits = {
    "apple",
    "banana",
    "cherry",
    "coconut",
    "grapes",
    "kiwi",
    "lemon",
    "peach",
    "strawberry",
    "watermelon"
}

local validWaterItem = {
    ["oxygentank"] = true,
    ["water"] = true,
    ["poisonedwater"] = true,
    ["vodka"] = true,
    ["beer"] = true,
    ["whiskey"] = true,
    ["coffee"] = true,
    ["fishtaco"] = true,
    ["taco"] = true,
    ["burrito"] = true,
    ["churro"] = true,
    ["hotdog"] = true,
    ["greencow"] = true,
    ["donut"] = true,
    ["applepie"] = true,
    ["eggsbacon"] = true,
    ["icecream"] = true,
    ["mshake"] = true,
    ["winemilkshake"] = true,
    ["sandwich"] = true,
    ["customfooditem"] = true,
    ["customwateritem"] = true,
    ["customcoffeeitem"] = true,
    ["poisonedsandwich"] = true,
    ["hamburger"] = true,
    ["cola"] = true,
    ["jailfood"] = true,
    ["bleederburger"] = true,
    ["heartstopper"] = true,
    ["torpedo"] = true,
    ["meatfree"] = true,
    ["moneyshot"] = true,
    ["fries"] = true,
    ["slushy"] = true,
    ["frappuccino"] = true,
    ['latte'] = true,
    ['cookie'] = true,
    ['muffin'] = true,
    ['chocolate'] = true,
    ['softdrink'] = true,
    ['franksmonster'] = true,
    ['roostertea'] = true,
    ['buddhamedalion'] = true,
    ['buddhashovel'] = true
}

local sandwichItems = {
  ["sandwich"] = true,
  ["hamburger"] = true,
  ["poisonedsandwich"] = true,
  ["customfooditem"] = true,
}

local waterItems = {
  ["cola"] = true,
  ["water"] = true,
  ["poisonedwater"] = true,
  ["customwateritem"] = true,
  ["roostertea"] = true,
}

local waterItemsAttached = {
  ["water"] = true,
  ["poisonedwater"] = true,
  ["cola"] = true,
  ["vodka"] = true,
  ["whiskey"] = true,
  ["beer"] = true,
  ["coffee"] = true,
  ["bscoffee"] = true,
  ["softdrink"] = true,
  ["fries"] = true,
  ["roostertea"] = true,
  ["customwateritem"] = true,
  ["customcoffeeitem"] = true,
}

local deanworldFood = {
  ["deanworldcorndog"] = true,
  ["deanworldcottoncandy"] = true,
  ["deanworldcaramelapple"] = true,
  ["deanworldkettlecorn"] = true,
  ["deanworldsoftpretzel"] = true,
}

local validDogModels = {
    [`a_c_chop`] = true,
    [`a_c_husky`] = true,
}

local customMarketItems = {
  ["customfooditem"] = true,
  ["customwateritem"] = true,
  ["customcoffeeitem"] = true,
  ["customjointitem"] = true,
  ["custommerchitem"] = true,
}

local Throttles = {}

function Throttled(name, time)
    if not Throttles[name] then
        Throttles[name] = true
        Citizen.SetTimeout(time or 500, function() Throttles[name] = false end)
        return false
    end

    return true
end

local ItemCallbacks = {}

function RegisterItemCallback(itemName, cb)
    ItemCallbacks[itemName] = cb
end

RegisterCommand('+useKeyFob', function()
    if Throttled("np-doors:doorKeyFob", 1000) then return end
    TriggerEvent("np-doors:doorKeyFob")
end, false)
RegisterCommand('-useKeyFob', function() end, false)

Citizen.CreateThread(function()
    exports["np-keybinds"]:registerKeyMapping("", "Vehicle", "Door Keyfob", "+useKeyFob", "-useKeyFob", "Y")
    TriggerServerEvent("inv:playerSpawned")
    TriggerEvent("closeInventoryGui")
end)

RegisterNetEvent('inventory-jail')
AddEventHandler('inventory-jail', function(startPosition, cid, name)
    if (hasEnoughOfItem("okaylockpick",1,false)) then
        local plyPed = PlayerPedId()
        local coord = GetPedBoneCoords(plyPed, HeadBone)
        local inPoly = jailBounds:isPointInside(coord)
        if inPoly  then
             TriggerServerEvent("server-inventory-open", startPosition, cid, "1", name);
        end
    end
end)

local stolenItems = {
  ["stolentv"] = true
}

local LastUsedItem = 0
local LastUsedItemId = "ciggy"

RegisterNetEvent('inventory:DegenLastUsedItem')
AddEventHandler('inventory:DegenLastUsedItem', function(percent)
    local cid = exports["isPed"]:isPed("cid")
    print("Degen applied to ".. LastUsedItemId .. " ID: " .. LastUsedItem .. " at %" .. percent)
    TriggerServerEvent("inventory:degItem",LastUsedItem,percent,LastUsedItemId,cid)
end)

RegisterNetEvent('RunUseItem')
AddEventHandler('RunUseItem', function(itemid, slot, inventoryName, isWeapon, passedItemInfo)

    if itemid == nil then
        return
    end
    local player = PlayerPedId()
    local ItemInfo = GetItemInfo(slot)
    local currentVehicle = GetVehiclePedIsUsing(player)
    LastUsedItem = ItemInfo.id
    LastUsedItemId = itemid
    if ItemInfo.quality == nil then return end
    if ItemInfo.quality < 1 then
        TriggerEvent("DoLongHudText","Item is too worn.",2)
        if isWeapon then
            TriggerEvent("brokenWeapon")
        end
        return
    end

    if justUsed then
        retardCounter = retardCounter + 1
        if retardCounter > 10 and retardCounter > lastCounter+5 then
            lastCounter = retardCounter
            TriggerServerEvent("exploiter", "Tried using " .. retardCounter .. " items in < 500ms ")
        end
        return
    end

    justUsed = true

    if (not hasEnoughOfItem(itemid,1,false)) then
        TriggerEvent("DoLongHudText","You dont appear to have this item on you?",2)
        justUsed = false
        retardCounter = 0
        lastCounter = 0
        return
    end

    if parachuteConfig[itemid] and tonumber(ItemInfo.quality) > 0 and not IsPedInParachuteFreeFall(player) and not IsPedFalling(player) and (GetPedParachuteState(player) == -1 or GetPedParachuteState(player) == 0) then
        local pConf = parachuteConfig[itemid]
        SetPlayerParachuteModelOverride(PlayerId(), pConf.replace)
        SetPedParachuteTintIndex(PlayerPedId(), pConf.tint)
        TriggerEvent("equipWeaponID", "-72657034",ItemInfo.information,ItemInfo.id)
        TriggerEvent("inventory:removeItem",itemid, 1)
        TriggerEvent("hud:equipParachute")
        justUsed = false
        retardCounter = 0
        lastCounter = 0
        return
    end

    if not isValidUseCase(itemid,isWeapon) then
        justUsed = false
        retardCounter = 0
        lastCounter = 0
        return
    end

    if (itemid == nil) then
        justUsed = false
        retardCounter = 0
        lastCounter = 0
        return
    end


    if (isWeapon) then
        if tonumber(ItemInfo.quality) > 0 then
            TriggerEvent("equipWeaponID",itemid,ItemInfo.information,ItemInfo.id)
        end
        justUsed = false
        retardCounter = 0
        lastCounter = 0
        return
    end

    if itemid == "cursedkatanaweapon" then
        if GetEntityModel(PlayerPedId()) == `Mr_kebun` then
          if tonumber(ItemInfo.quality) > 0 then
              local katanaInfo = json.decode(ItemInfo.information)
              katanaInfo.componentVariant = "3"
              local hiddenKeys = katanaInfo._hideKeys or {}
              hiddenKeys[#hiddenKeys + 1] = "componentVariant"
              katanaInfo._hideKeys = hiddenKeys
              TriggerEvent("equipWeaponID","1692590063",json.encode(katanaInfo),ItemInfo.id)
          end
        else
          TriggerEvent("DoLongHudText", "You don't feel comfortable touching this.", 2)
        end
        justUsed = false
        retardCounter = 0
        lastCounter = 0
        return
    end

    if itemid == "talonweapon" then
        if GetEntityModel(PlayerPedId()) == `ig_buddha` then
          if tonumber(ItemInfo.quality) > 0 then
              local katanaInfo = json.decode(ItemInfo.information)
              katanaInfo.componentVariant = "5"
              local hiddenKeys = katanaInfo._hideKeys or {}
              hiddenKeys[#hiddenKeys + 1] = "componentVariant"
              katanaInfo._hideKeys = hiddenKeys
              TriggerEvent("equipWeaponID","1692590063",json.encode(katanaInfo),ItemInfo.id)
          end
        else
          TriggerEvent("DoLongHudText", 'You hear a voice in your head: You are not Shadow?', 2)
        end
        justUsed = false
        retardCounter = 0
        lastCounter = 0
        return
    end

    if itemid == "buddhamedalion" then
        buddhaMedalion()
    end

    if stolenItems[itemid] and exports["np-npcs"]:isCloseToPawnPed() then
        print("You should do stuff")
        justUsed = false
        retardCounter = 0
        lastCounter = 0
        return
    end


    TriggerEvent("hud-display-item",itemid,"Used")

    Wait(800)

    local playerVeh = GetVehiclePedIsIn(player, false)

    if (not IsPedInAnyVehicle(player)) then
        if (itemid == "Suitcase") then
            TriggerEvent('attach:suitcase')
        end

        if (itemid == "Boombox") then
                TriggerEvent('attach:boombox')
        end
        if (itemid == "Box") then
            if not boxAttached then
                TriggerEvent('attach:box')
                boxAttached = true
            else
                TriggerEvent("animation:carry", "none")
                boxAttached = false
            end
        end
        if (itemid == "DuffelBag") then
          TriggerEvent('attach:blackDuffelBag')
        end
        if (itemid == "MedicalBag") then
          TriggerEvent('attach:medicalBag')
        end
        if (itemid == "SecurityCase") then
          TriggerEvent('attach:securityCase')
        end
        if (itemid == "Toolbox") then
          TriggerEvent('attach:toolbox')
        end
        if itemid == "wheelchair" then
            if not DoesEntityExist(wheelChair) then
                local wheelChairModel = `npwheelchair`
                RequestModel(wheelChairModel)
                while not HasModelLoaded(wheelChairModel) do
                    Citizen.Wait(0)
                end
                wheelChair = CreateVehicle(wheelChairModel, GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId()), true, false)
                SetVehicleOnGroundProperly(wheelChair)
                SetVehicleNumberPlateText(wheelChair, "PILLBOX".. math.random(9))
                SetPedIntoVehicle(PlayerPedId(), wheelChair, -1)
                SetModelAsNoLongerNeeded(wheelChairModel)
                local wheelChairPlate = GetVehicleNumberPlateText(wheelChair)
                TriggerServerEvent('garages:addJobPlate', wheelChairPlate)
                TriggerEvent("keys:addNew", wheelChair, wheelChairPlate)
            elseif DoesEntityExist(wheelChair) and #(GetEntityCoords(wheelChair) - GetEntityCoords(PlayerPedId())) < 3.0 and GetPedInVehicleSeat(wheelChair,-1) == 0 then
                Sync.DeleteVehicle(wheelChair)
                wheelChair = nil
            else
                TriggerEvent("DoLongHudText","Too far away from the wheelchair or someon is sitting in it !",1)
            end
        end
    end

    local remove = false
    local removeId = nil
    local itemreturn = false
    local drugitem = false
    local fooditem = false
    local drinkitem = false
    local healitem = false

    if ItemCallbacks[itemid] and type(ItemCallbacks[itemid]) == 'function' then
        local options = { remove = false }

        ItemCallbacks[itemid](itemid, itemInfo, options)

        -- This is pepega af but I can't be arsed right now to make something that makes more sense
        if options.remove then
            remove = true
        end
    end

    if (itemid == "spellbook-flame" and currentVehicle == 0) then
        TriggerEvent("fx:spellcast","FireRay")
    end
    if (itemid == "spellbook-heal" and currentVehicle == 0) then
        TriggerEvent("fx:spellcast","AOEheal")
    end
    if (itemid == "spellbook-slow" and currentVehicle == 0) then
        TriggerEvent("fx:spellcast","AOEslow")
    end
    if (itemid == "spellbook-shock" and currentVehicle == 0) then
        TriggerEvent("fx:spellcast","AOEshock")
    end
    if (itemid == "spellbook-test" and currentVehicle == 0) then
        TriggerEvent("fx:spellcast","AOEtest")
    end
    if (itemid == "spellbook-blink" and currentVehicle == 0) then
        TriggerEvent("fx:spellcast","blink")
    end
    if (itemid == "spellbook-speed" and currentVehicle == 0) then
        TriggerEvent("fx:spellcast","AOEspeed")
    end
    if (itemid == "spellbook-buff" and currentVehicle == 0) then
        TriggerEvent("fx:spellcast","AOEbuff")
    end
    if (itemid == "spellbook-mana" and currentVehicle == 0) then
        remove = true
        TriggerEvent("fx:spellmana")
    end   

    

    if (itemid == "spikes" and currentVehicle == 0) then
        TriggerEvent("c_setSpike")
        remove = true
    end

    if (itemid == "pdbadge") then
        RPC.execute("np-gov:police:showBadge", json.decode(ItemInfo.information))
    end

    if (itemid == "joint" or itemid == "weed5oz" or itemid == "weedq" or itemid == "beer" or itemid == "vodka" or itemid == "whiskey" or itemid == "lsdtab" or itemid == 'winemilkshake' or itemid == 'honestwineglass' or itemid == "customjointitem") then
        drugitem = true
    end

    if (itemid == "burnerphone") then
        exports["np-ui"]:openApplication("burner", { source_number  = json.decode(ItemInfo.information).Number })
    end

    if (itemid == "tuner") then
      local finished = exports["np-taskbar"]:taskBar(2000,"Connecting Tuner Laptop",false,false,playerVeh)
      if (finished == 100) then
        TriggerEvent("tuner:open")
      end
    end

    if (itemid == "electronickit" or itemid == "lockpick") then
      TriggerServerEvent("robbery:triggerItemUsedServer",itemid)

    end
    if (itemid == "locksystem") then
      TriggerServerEvent("robbery:triggerItemUsedServer",itemid)
    end

    if (itemid == "thermite") then
      TriggerServerEvent("robbery:triggerItemUsedServer",itemid)
    end

    if(itemid == "evidencebag") then
        TriggerEvent("evidence:startCollect", itemid, slot)
        local itemInfo = GetItemInfo(slot)
        local data = itemInfo.information
        if data == '{}' then
            TriggerEvent("DoLongHudText","Start collecting evidence!",1)
            TriggerEvent("inventory:updateItem", itemid, slot, '{"used": "true"}')
            --
        else
            local dataDecoded = json.decode(data)
            if(dataDecoded.used) then
                print('YOURE ALREADY COLLECTING EVIDENCE YOU STUPID FUCK')
            end
        end
    end

    if (itemid == "lsdtab" or itemid == "badlsdtab") then
        TriggerEvent("animation:PlayAnimation","pill")
        local finished = exports["np-taskbar"]:taskBar(3000,"Placing LSD Strip on 👅",false,false,playerVeh)
        if (finished == 100) then
            TriggerEvent("Evidence:StateSet",2,1200)
            TriggerEvent("Evidence:StateSet",24,1200)
            TriggerEvent("fx:run", "lsd", 180, -1, (itemid == "badlsdtab" and true or false))
            remove = true
        end
    end

    if (itemid == "decryptersess" or itemid == "decrypterfv2" or itemid == "decrypterenzo") then
      if (#(GetEntityCoords(player) - vector3( 1275.49, -1710.39, 54.78)) < 3.0) then
          local finished = exports["np-taskbar"]:taskBar(25000,"Decrypting Data",false,false,playerVeh)
          if (finished == 100) then
            TriggerEvent("phone:crypto:use", 1, 3, "robbery:decrypt", true)
          end
      end

      if #(GetEntityCoords(player) - vector3( 2328.94, 2571.4, 46.71)) < 3.0 then
          local finished = exports["np-taskbar"]:taskBar(25000,"Decrypting Data",false,false,playerVeh)
          if finished == 100 then
            TriggerEvent("phone:crypto:use", 1, 3, "robbery:decrypt2", true)
          end
      end

      if #(GetEntityCoords(player) - vector3( 1208.73,-3115.29, 5.55)) < 3.0 then
          local finished = exports["np-taskbar"]:taskBar(25000,"Decrypting Data",false,false,playerVeh)
          if finished == 100 then
            TriggerEvent("phone:crypto:use", 1, 3,"robbery:decrypt3", true)
          end
      end

    end

    if (itemid == "pix1") then
      if (#(GetEntityCoords(player) - vector3( 1275.49, -1710.39, 54.78)) < 3.0) then
          local finished = exports["np-taskbar"]:taskBar(25000,"Decrypting Data",false,false,playerVeh)
          if (finished == 100) then
            TriggerEvent("phone:crypto:add", 1, math.random(1,2))
            remove = true
          end
      end
    end

    if (itemid == "pix2") then
      if (#(GetEntityCoords(player) - vector3( 1275.49, -1710.39, 54.78)) < 3.0) then
          local finished = exports["np-taskbar"]:taskBar(25000,"Decrypting Data",false,false,playerVeh)
          if (finished == 100) then
            TriggerEvent("phone:crypto:add", 1, math.random(5,12))
            remove = true
          end
      end
    end


    if (itemid == "femaleseed") then
     --  TriggerEvent("Evidence:StateSet",4,1600)
      -- TriggerEvent("weed:startcropInsideCheck","female")

    end

    if (itemid == "maleseed") then
      --  TriggerEvent("Evidence:StateSet",4,1600)
      --  TriggerEvent("weed:startcropInsideCheck","male")

    end

    if (itemid == "weedoz") then

      local finished = exports["np-taskbar"]:taskBar(5000,"Packing Q Bags",false,false,playerVeh)
        if (finished == 100) then
            CreateCraftOption("weedq", 40, true)
        end

    end

    if ( itemid == "smallbud" and hasEnoughOfItem("qualityscales",1,false) ) then
        local finished = exports["np-taskbar"]:taskBar(1000,"Packing Joint",false,false,playerVeh)
        if (finished == 100) then
            CreateCraftOption("joint2", 80, true)
        end
    end

    if (itemid == "weedq") then
        local finished = exports["np-taskbar"]:taskBar(1000,"Rolling Joints",false,false,playerVeh)
        if (finished == 100) then
            CreateCraftOption("joint", 80, true)
        end
    end

    if (itemid == "lighter") then
        TriggerEvent("animation:PlayAnimation","lighter")
          local finished = exports["np-taskbar"]:taskBar(2000,"Starting Fire",false,false,playerVeh)
        if (finished == 100) then

        end
    end

    if (itemid == "joint" or itemid == "joint2" or itemid == "customjointitem") then
        local finished = exports["np-taskbar"]:taskBar(2000,"Smoking Joint",false,false,playerVeh)
        if (finished == 100) then

            Wait(200)

            if math.random(100) == 69 then
                TriggerEvent("player:receiveItem","femaleseed",1)
            end

            if math.random(600) == 69 then
                TriggerEvent("player:receiveItem","maleseed",1)
            end

            if itemid == "customjointitem" then
              processStressBlock()
            end

            TriggerEvent("animation:PlayAnimation","weed")
            TriggerEvent("Evidence:StateSet",3,600)
            TriggerEvent("Evidence:StateSet",4,600)
            TriggerEvent(
              "weed",
              1000,
              "WORLD_HUMAN_SMOKING_POT",
              itemid == "customjointitem" and 1.25 or 0.75
            )
            remove = true
        end
    end

    if (
         itemid == "vodka"
      or itemid == "beer"
      or itemid == "whiskey" 
      or itemid == "absinthe" 
      or itemid == "drink1" 
      or itemid == "drink2" 
      or itemid == "drink3" 
      or itemid == "drink4" 
      or itemid == "drink5" 
      or itemid == "drink6"
      or itemid == "drink7" 
      or itemid == "drink8" 
      or itemid == "drink9" 
      or itemid == "drink10" 
      or itemid == "shot1" 
      or itemid == "shot2" 
      or itemid == "shot3" 
      or itemid == "shot4" 
      or itemid == "shot5" 
      or itemid == "shot6" 
      or itemid == "winemilkshake"
      or itemid == "shot7" 
      or itemid == "shot8" 
      or itemid == "shot9" 
      or itemid == "shot10" 
      or itemid == "moonshine"
      or itemid == "poisonedcocktail"
    ) then
        local success = itemid == "winemilkshake" and true or (AttachPropAndPlayAnimation("amb@world_human_drinking@coffee@male@idle_a", "idle_c", 49,6000,"Drink","changethirst",true,itemid,playerVeh))
        if success then
            TriggerEvent("Evidence:StateSet", 8, 600)
            local alcoholStrength = 0.5
            if itemid == "vodka" or itemid == "whiskey" then alcoholStrength = 1.0 end
            if itemid == "absinthe" then alcoholStrength = 2.5 end
            if itemid == "moonshine" then 
                alcoholStrength = 4.0
                TriggerEvent("np-roostersrest:drinkTea")
            end
            if itemid == "drink1" or itemid == "drink2" or itemid == "drink3" or itemid == "drink4" or itemid == "drink5" or itemid == "drink6"
            or itemid == "drink7" or itemid == "drink8" or itemid == "drink9" or itemid == "drink10" then
                alcoholStrength = 0.6
            end
            if itemid == "shot1" or itemid == "shot2" or itemid == "shot3" or itemid == "shot4" or itemid == "shot5" or itemid == "shot6"
            or itemid == "shot7" or itemid == "shot8" or itemid == "shot9" or itemid == "shot10" then
                alcoholStrength = 0.8
            end
            TriggerEvent("fx:run", "alcohol", 180, alcoholStrength, -1, (itemid == "absinthe" and true or false))
        end
    end

    if (itemid == "coffee" or itemid == "frappuccino" or itemid == "latte" or itemid == "customcoffeeitem") then
        AttachPropAndPlayAnimation(
          "amb@world_human_drinking@coffee@male@idle_a", 
          "idle_c", 
          49,
          6000,
          "Drink",
          "coffee:drink", 
          not customMarketItems[itemid], 
          itemid, 
          playerVeh
        )
        remove = customMarketItems[itemid]
    end

    if (itemid == "fishtaco") then
        AttachPropAndPlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 49,6000,"Eating","food:FishTaco",true,itemid,playerVeh)
    end

    if (itemid == "taco" or itemid == "burrito") then
        AttachPropAndPlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 49,6000,"Eating","food:Taco",true,itemid,playerVeh)
    end

    if (itemid == "churro" or itemid == "hotdog" or itemid == "chocobar") then
        TaskItem("mp_player_inteat@burger", "mp_player_int_eat_burger", 49,6000,"Eating","food:Condiment",true,itemid,playerVeh)
    end

    if (itemid == "greencow" or itemid == "franksmonster") then
        local fmMsg = itemid == "greencow" and "Drink" or "Shotgunning"
        local fmTimer = itemid == "greencow" and 6000 or 2000
        AttachPropAndPlayAnimation("amb@world_human_drinking@coffee@male@idle_a", "idle_c", 49,fmTimer,fmMsg,"food:Condiment",true,itemid,playerVeh)
    end

    if (itemid == "donut" or itemid == "applepie" or itemid == "eggsbacon" or itemid == "cookie" or itemid == "muffin") then
        AttachPropAndPlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 49,6000,"Eating","food:Condiment",true,itemid,playerVeh)
    end

    if (itemid == "icecream" or itemid == "mshake" or itemid == "winemilkshake") then
        TaskItem("mp_player_inteat@burger", "mp_player_int_eat_burger", 49,6000,"Eating","food:IceCream",true,itemid,playerVeh)
    end
    
    if (itemid == "advlockpick") then

        local myJob = exports["isPed"]:isPed("myJob")
        if myJob ~= "news" then
            TriggerEvent('inv:advancedLockpick',inventoryName,slot)
        else
            TriggerEvent("DoLongHudText","Nice news reporting, you shit lord idiot.")
        end

    end


    if (itemid == "Gruppe6Card") then

        local coordA = GetEntityCoords(GetPlayerPed(-1), 1)
        local coordB = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0.0, 100.0, 0.0)
        local countpolice = exports["isPed"]:isPed("countpolice")
        local targetVehicle = getVehicleInDirection(coordA, coordB)
        if targetVehicle ~= 0 and GetHashKey("stockade") == GetEntityModel(targetVehicle) and countpolice > 2 then
            local entityCreatePoint = GetOffsetFromEntityInWorldCoords(targetVehicle, 0.0, -4.0, 0.0)
            local coords = GetEntityCoords(GetPlayerPed(-1))
            local aDist = GetDistanceBetweenCoords(coords["x"], coords["y"],coords["z"], entityCreatePoint["x"], entityCreatePoint["y"],entityCreatePoint["z"])
            local cityCenter = vector3(-204.92, -1010.13, 29.55) -- alta street train station
            local timeToOpen = 45000
            local distToCityCenter = #(coords - cityCenter)
            if distToCityCenter > 1000 then
                local multi = math.floor(distToCityCenter / 1000)
                timeToOpen = timeToOpen + (30000 * multi)
            end
            if aDist < 2.0 then
                TriggerEvent("alert:noPedCheck", "banktruck")
                local finished = exports["np-taskbar"]:taskBar(timeToOpen,"Unlocking Vehicle",false,false,playerVeh)
                if finished == 100 then
                    remove = true
                    TriggerEvent("sec:AttemptHeist", targetVehicle)
                else
                    TriggerEvent("evidence:bleeding",false)
                end

            else
                TriggerEvent("DoLongHudText","You need to do this from behind the vehicle.")
            end
        end

    end


    if (itemid == "usbdevice") then
        local finished = exports["np-taskbar"]:taskBar(15000,"Scanning For Networks",false,false,playerVeh)
        if (finished == 100) then
            TriggerEvent("hacking:attemptHack")
        end

    end

    -- TODO: Unused?
    -- if (itemid == "weed12oz") then
    --     TriggerEvent("inv:weedPacking")
    --     remove = true
    -- end

    if (itemid == "heavyammo") then
        local finished = exports["np-taskbar"]:taskBar(5000,"Reloading",false,false,playerVeh)
        if (finished == 100) then
            TriggerEvent("actionbar:ammo",1788949567,50,true)
            remove = true
        end
    end

    if (itemid == "pistolammo") then
        local finished = exports["np-taskbar"]:taskBar(2500,"Reloading",false,false,playerVeh)
        if (finished == 100) then
            TriggerEvent("actionbar:ammo",1950175060,50,true)
            remove = true
        end
    end

    if (itemid == "pistolammoPD") then
        local finished = exports["np-taskbar"]:taskBar(2500,"Reloading",false,false,playerVeh)
        if (finished == 100) then
            TriggerEvent("actionbar:ammo",1950175060,50,true)
            remove = true
        end
    end

    if (itemid == "rifleammoPD") then
        local finished = exports["np-taskbar"]:taskBar(5000,"Reloading",false,false,playerVeh)
        if (finished == 100) then
            TriggerEvent("actionbar:ammo",218444191,50,true)
            remove = true
        end
    end

    if (itemid == "shotgunammoPD") then
        local finished = exports["np-taskbar"]:taskBar(5000,"Reloading",false,false,playerVeh)
        if (finished == 100) then
            TriggerEvent("actionbar:ammo",218444191,50,true)
            remove = true
        end
    end

    if (itemid == "rifleammo") then
        local finished = exports["np-taskbar"]:taskBar(5000,"Reloading",false,false,playerVeh)
        if (finished == 100) then
            TriggerEvent("actionbar:ammo",218444191,50,true)
            remove = true
        end
    end

    if (itemid == "huntingammo") then
        local finished = exports["np-taskbar"]:taskBar(10000,"Reloading",false,false,playerVeh)
        if (finished == 100) then
            TriggerEvent("actionbar:ammo",1285032059,10,true)
            remove = true
        end
    end

    if (itemid == "shotgunammo") then
        local finished = exports["np-taskbar"]:taskBar(5000,"Reloading",false,false,playerVeh)
        if (finished == 100) then
            TriggerEvent("actionbar:ammo",-1878508229,50,true)
            remove = true
        end
    end

    if (itemid == "subammo") then
        local finished = exports["np-taskbar"]:taskBar(5000,"Reloading",false,false,playerVeh)
        if (finished == 100) then
            TriggerEvent("actionbar:ammo",1820140472,50,true)
            remove = true
        end
    end

    if (itemid == "nails") then
        local finished = exports["np-taskbar"]:taskBar(5000,"Reloading",false,false,playerVeh)
        if (finished == 100) then
            TriggerEvent("actionbar:ammo",965225813,50,true)
            remove = true
        end
    end

    if (itemid == "paintballs") then
        local finished = exports["np-taskbar"]:taskBar(5000,"Reloading",false,false,playerVeh)
        if (finished == 100) then
            TriggerEvent("actionbar:ammo",1916856719,100,true)
            remove = true
        end
    end

    if (itemid == "rubberslugs") then
        local finished = exports["np-taskbar"]:taskBar(5000,"Reloading",false,false,playerVeh)
        if (finished == 100) then
            TriggerEvent("actionbar:ammo",1517835987,10,true)
            remove = true
        end
    end

    if (itemid == "taserammo") then
        local finished = exports["np-taskbar"]:taskBar(2000,"Reloading",false,false,playerVeh)
        if (finished == 100) then
            TriggerEvent("actionbar:ammo",-1575030772,3,true)
            remove = true
        end
    end

    if (itemid == "armor" or itemid == "pdarmor") then
        local finished = exports["np-taskbar"]:taskBar(5000,"Armor",true,false,playerVeh)
        if (finished == 100) then
            SetPlayerMaxArmour(PlayerId(), 60 )

            local wasBeatdown = exports["police"]:getBeatmodeDebuff()

            if not wasBeatdown then
                SetPedArmour( player, 60 )
                TriggerEvent("UseBodyArmor")
                remove = true
            else
                TriggerEvent("DoLongHudText","You cannot apply armor because you were beat down.")
            end
        end
    end

    if (itemid == "cbrownie" or itemid == "cgummies") then
        TriggerEvent("animation:PlayAnimation","pill")
        local finished = exports["np-taskbar"]:taskBar(3000,"Consuming edibles 😉",false,false,playerVeh)
        if (finished == 100) then
            TriggerEvent("Evidence:StateSet",3,1200)
            TriggerEvent("Evidence:StateSet",7,1200)
            TriggerEvent("fx:run", "weed", 180, -1, false)
            remove = true
        end
    end

    if (itemid == "bodybag") then
        local finished = exports["np-taskbar"]:taskBar(10000,"Opening bag",true,false,playerVeh)
        if (finished == 100) then
            remove = true
            TriggerEvent( "player:receiveItem", "humanhead", 1 )
            TriggerEvent( "player:receiveItem", "humantorso", 1 )
            TriggerEvent( "player:receiveItem", "humanarm", 2 )
            TriggerEvent( "player:receiveItem", "humanleg", 2 )
        end
    end

    if (itemid == "bodygarbagebag") then
            local finished = exports["np-taskbar"]:taskBar(10000,"Opening trash bag",false,false,playerVeh)
            if (finished == 100) then
                remove = true
                TriggerServerEvent('loot:useItem', itemid)
            end
    end

    if (itemid == "newaccountbox") then
        local finished = exports["np-taskbar"]:taskBar(5000,"Opening present",false,false,playerVeh)
        if (finished == 100) then
            remove = true
            TriggerServerEvent('loot:useItem', itemid)
        end
    end

    if (itemid == "foodsupplycrate") then
        TriggerEvent("DoLongHudText","Make sure you have a ton of space in your inventory! 100 or more.",2)
        local finished = exports["np-taskbar"]:taskBar(20000,"Opening the crate (ESC to Cancel)",false,false,playerVeh)
        if (finished == 100) then
            remove = true
            TriggerEvent( "player:receiveItem", "heartstopper", 10 )
            TriggerEvent( "player:receiveItem", "moneyshot", 10 )
            TriggerEvent( "player:receiveItem", "bleederburger", 10 )
            TriggerEvent( "player:receiveItem", "fries", 10 )
            TriggerEvent( "player:receiveItem", "cola", 10 )
        end
    end

    if (itemid == "fishingtacklebox") then
        local finished = exports["np-taskbar"]:taskBar(5000,"Opening",true,false,playerVeh)
        if (finished == 100) then
            remove = true
            TriggerServerEvent('loot:useItem', itemid)
        end
    end

    if (itemid == "fishingchest") then
        local finished = exports["np-taskbar"]:taskBar(5000,"Opening",true,false,playerVeh)
        if (finished == 100) then
            remove = true
            TriggerEvent( "player:receiveItem", "goldbar", math.random(1,5) )
        end
    end

    if (itemid == "fishinglockbox") then
        local finished = exports["np-taskbar"]:taskBar(5000,"Opening",true,false,playerVeh)
        if (finished == 100) then
            --remove = true
            --TriggerServerEvent('loot:useItem', itemid)
            TriggerEvent("DoLongHudText","Add your map thing here DW you fucking fuck fuck",2)
        end
    end

    if (itemid == "organcooler") then
        local finished = exports["np-taskbar"]:taskBar(5000,"Opening cooler",true,false,playerVeh)
        if (finished == 100) then
            remove = true
            TriggerEvent( "player:receiveItem", "humanheart", 1 )
            TriggerEvent( "player:receiveItem", "organcooleropen", 1 )
        end
    end

    if itemid == "humanhead" then
        TaskItem("mp_player_inteat@burger", "mp_player_int_eat_burger", 49, 10000, "Eating (ESC to Cancel)", "inv:wellfed", true,itemid,playerVeh,true,"humanskull")
    end

    if (itemid == "humantorso" or itemid == "humanarm" or itemid == "humanhand" or itemid == "humanleg" or itemid == "humanfinger") then
        TaskItem("mp_player_inteat@burger", "mp_player_int_eat_burger", 49, 10000, "Eating (ESC to Cancel)", "inv:wellfed", true,itemid,playerVeh,true,"humanbone")
    end

    if (itemid == "humanear" or itemid == "humanintestines" or itemid == "humanheart" or itemid == "humaneye" or itemid == "humanbrain" or itemid == "humankidney" or itemid == "humanliver" or itemid == "humanlungs" or itemid == "humantongue" or itemid == "humanpancreas") then
        TaskItem("mp_player_inteat@burger", "mp_player_int_eat_burger", 49, 10000, "Eating (ESC to Cancel)", "inv:wellfed", true,itemid)
    end

    if (itemid == "Bankbox") then
        if (hasEnoughOfItem("locksystem",1,false)) then
            local finished = exports["np-taskbar"]:taskBar(10000,"Opening bank box.",false,false,playerVeh)
            if (finished == 100) then
                remove = true
                TriggerEvent("inventory:removeItem","locksystem", 1)

                TriggerServerEvent('loot:useItem', itemid)
            end
        else
            TriggerEvent("DoLongHudText","You are missing something to open the box with",2)
        end
    end

    if (itemid == "Securebriefcase") then
        if (hasEnoughOfItem("Bankboxkey",1,false)) then
            local finished = exports["np-taskbar"]:taskBar(5000,"Opening briefcase.",false,false,playerVeh)
            if (finished == 100) then
                remove = true
                TriggerEvent("inventory:removeItem","Bankboxkey", 1)

                TriggerServerEvent('loot:useItem', itemid)
            end
        else
            TriggerEvent("DoLongHudText","You are missing something to open the briefcase with",2)
        end
    end

    if (itemid == "Largesupplycrate") then
        if (hasEnoughOfItem("2227010557",1,false)) then
            local finished = exports["np-taskbar"]:taskBar(15000,"Opening supply crate.",false,false,playerVeh)
            if (finished == 100) then
                remove = true
                TriggerEvent("inventory:removeItem","2227010557", 1)

                TriggerServerEvent('loot:useItem', itemid)
            end
        else
            TriggerEvent("DoLongHudText","You are missing something to open the crate with",2)
        end
    end

    if (itemid == "xmasgiftcoal") then
        local finished = exports["np-taskbar"]:taskBar(15000, "Opening Gift", false, false, playerVeh)
        if (finished == 100) then
            remove = true
            TriggerServerEvent('loot:useItem', itemid)
        end
    end

    if (itemid == "Smallsupplycrate") then
        if (hasEnoughOfItem("2227010557",1,false)) then
            local finished = exports["np-taskbar"]:taskBar(15000,"Opening supply crate.",false,false,playerVeh)
            if (finished == 100) then
                remove = true
                TriggerEvent("inventory:removeItem","2227010557", 1)

                TriggerServerEvent('loot:useItem', itemid)
            end
        else
            TriggerEvent("DoLongHudText","What, are you going to break it open with your hands?",2)
        end
    end

    if (itemid == "Smallsupplycrate2") then
        if (hasEnoughOfItem("2227010557",1,false)) then
            local finished = exports["np-taskbar"]:taskBar(15000,"Opening supply crate.",false,false,playerVeh)
            if (finished == 100) then
                remove = true
                TriggerEvent("inventory:removeItem","2227010557", 1)

                TriggerServerEvent('loot:useItem', itemid)
            end
        else
            TriggerEvent("DoLongHudText","What, are you going to break it open with your hands?",2)
        end
    end

    if (itemid == "Mediumsupplycrate") then
        if (hasEnoughOfItem("2227010557",1,false)) then
            local finished = exports["np-taskbar"]:taskBar(15000,"Opening supply crate.",false,false,playerVeh)
            if (finished == 100) then
                remove = true
                TriggerEvent("inventory:removeItem","2227010557", 1)

                TriggerServerEvent('loot:useItem', itemid)
            end
        else
            TriggerEvent("DoLongHudText","What, are you going to break it open with your hands?",2)
        end
    end

    if (itemid == "emptyballoon") then
        if (hasEnoughOfItem("nitrous",1,false)) then
            local finished = exports["np-taskbar"]:taskBar(5000,"Filling Balloon.",false,false,playerVeh)
            if (finished == 100) then
                remove = true
                TriggerEvent( "player:receiveItem","nosballoon",1)
            end
        else
            TriggerEvent("DoLongHudText","You need a bottle to fill the balloon with.",2)
        end
    end

    if (itemid == "binoculars") then
        TriggerEvent("binoculars:Activate")
    end

    if (itemid == "camera") then
        TriggerEvent("camera:Activate")
    end

    if (itemid == "megaphone") then
      TriggerEvent("np-usableprops:megaphone")
    end

    if (itemid == "nitrous") then
        local currentVehicle = GetVehiclePedIsIn(player, false)

        if currentVehicle == nil or currentVehicle == 0 then
            TriggerEvent("attachItem","nosbottle")
            TaskItem("amb@code_human_wander_idles@male@idle_a", "idle_b_rubnose", 49, 2800, "Sniff Sniff", "hadnitrous", false, itemid, playerVeh)
            TriggerEvent("destroyProp")
        elseif not IsToggleModOn(currentVehicle, 18) then
            TriggerEvent("DoLongHudText","You need a Turbo to use NOS!", 2)
        else
            local finished = 0
            local cancelNos = false
            Citizen.CreateThread(function()
                while finished ~= 100 and not cancelNos do
                    Citizen.Wait(100)
                    if GetEntitySpeed(GetVehiclePedIsIn(player, false)) > 11 then
                        exports["np-taskbar"]:closeGuiFail()
                        cancelNos = true
                    end
                end
            end)
            finished = exports["np-taskbar"]:taskBar(20000,"Nitrous")
            if (finished == 100 and not cancelNos) then
                TriggerEvent("NosStatus")
                TriggerEvent("vehicle:addNos", "large")
                TriggerEvent("noshud", 100, false)
                remove = true
            else
                TriggerEvent("DoLongHudText","You can't drive and hook up nos at the same time.",2)
            end
        end
    end

    if (itemid == "lockpick") then
        local myJob = exports["isPed"]:isPed("myJob")
        if myJob ~= "news" then
            TriggerEvent("inv:lockPick",false,inventoryName,slot)

        else
            TriggerEvent("DoLongHudText","Nice news reporting, you shit lord idiot.")
        end
    end

    if (itemid == "umbrella") then
        TriggerEvent("animation:PlayAnimation","umbrella")

    end

    if (itemid == "securityblue" or itemid == "securityblack" or itemid == "securitygreen" or itemid == "securitygold" or itemid == "securityred")  then
        TriggerEvent("robbery:scanLock",false,itemid)
    end

    if (itemid == "Gruppe6Card2")  then
        TriggerServerEvent("robbery:triggerItemUsedServer",itemid)
    end

    if (itemid == "Gruppe6Card222")  then
        TriggerServerEvent("robbery:triggerItemUsedServer",itemid)
    end

    if (itemid == "ciggypack" or itemid == "customciggyitem") then
        TriggerEvent( "player:receiveItem","ciggy",1)
        TriggerEvent("inventory:DegenLastUsedItem",8)
       -- TriggerServerEvent("inventory:degItem",ItemInfo.id)
    end

    if (itemid == "ciggy") then
        local finished = exports["np-taskbar"]:taskBar(1000,"Lighting Up",false,false,playerVeh)
        if (finished == 100) then
            Wait(300)
            TriggerEvent("animation:PlayAnimation","smoke")
        end
    end

    if (itemid == "cigar") then
        local finished = exports["np-taskbar"]:taskBar(1000,"Lighting Up",false,false,playerVeh)
        if (finished == 100) then
            Wait(300)
            TriggerEvent("animation:PlayAnimation","cigar")
        end
    end

    if (itemid == "oxygentank") then
        local finished = exports["np-taskbar"]:taskBar(30000,"Oxygen Tank",true,false,playerVeh)
        if (finished == 100) then
            TriggerEvent("UseOxygenTank")
            remove = true
        end
    end

    if (itemid == "bandage" or itemid == "custombandageitem") then
        TaskItem("amb@world_human_clipboard@male@idle_a", "idle_c", 49,10000,"Healing","healed:minors",true,itemid,playerVeh)
    end

    if (itemid == "coke50g") then
        CreateCraftOption("coke5g", 80, true)
    end

    if (itemid == "bakingsoda") then
        CreateCraftOption("1gcrack", 80, true)
    end

    if (itemid == "glucose") then
        CreateCraftOption("1gcocaine", 80, true)
    end

    if (itemid == "idcard") then 
        local ItemInfo = GetItemInfo(slot)
        TriggerServerEvent("police:showID",ItemInfo.information, GetEntityCoords(PlayerPedId()))   
    end

    if (itemid == "adrenaline") then
        TaskItem("amb@world_human_clipboard@male@idle_a", "idle_c", 49,1000,"POG GAMING Adrenaline","inventory:adrenaline",true,itemid,playerVeh)
    end

    if (itemid == "drivingtest") then
        local ItemInfo = GetItemInfo(slot)
        if (ItemInfo.information ~= "No information stored") then
            local data = json.decode(ItemInfo.information)
            TriggerServerEvent("driving:getResults", data.ID)
        end
    end

    if (itemid == "1gcocaine") then
        TriggerEvent("attachItemObjectnoanim","drugpackage01")
        TriggerEvent("Evidence:StateSet",2,1200)
        TriggerEvent("Evidence:StateSet",6,1200)
        TaskItem("anim@amb@nightclub@peds@", "missfbi3_party_snort_coke_b_male3", 49, 5000, "Coke Gaming", "hadcocaine", true,itemid,playerVeh)
    end

    if (itemid == "1gcrack") then
        TriggerEvent("attachItemObjectnoanim","crackpipe01")
        TriggerEvent("Evidence:StateSet",2,1200)
        TriggerEvent("Evidence:StateSet",6,1200)
        TaskItem("switch@trevor@trev_smoking_meth", "trev_smoking_meth_loop", 49, 5000, "Smoking Quack", "hadcrack", true,itemid,playerVeh)
    end

    if (itemid == "nosballoon") then
        TriggerEvent("Evidence:StateSet",2,1200)
        TriggerEvent("Evidence:StateSet",6,1200)
        TaskItem("switch@trevor@trev_smoking_meth", "trev_smoking_meth_loop", 49, 5000, "Huffing Nos", "hadcrack", true,itemid,playerVeh)
    end

    if (itemid == "treat") then
        local model = GetEntityModel(player)
        if validDogModels[model] then
            TaskItem("mp_player_inteat@burger", "mp_player_int_eat_burger", 49, 1200, "Treat Num's", "hadtreat", true,itemid,playerVeh)
        end
    end

    if (itemid == "IFAK") then
        TaskItem("amb@world_human_clipboard@male@idle_a", "idle_c", 49,2000,"Applying IFAK","healed:useOxy",true,itemid,playerVeh)
    end

    if (has_value(fruits, itemid)) then
        AttachPropAndPlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 49,6000,"Eating","food:Fruit",true,itemid,playerVeh)
    end


    if (itemid == "oxy") then
        TriggerEvent("animation:PlayAnimation","pill")
        TriggerEvent("useOxy")
        TriggerEvent("healed:useOxy", true)
        remove = true
    end

    if itemid == "frankstruth" then
        TriggerEvent("animation:PlayAnimation","pill")
        remove = true
    end

    if sandwichItems[itemid] or deanworldFood[itemid] then
        AttachPropAndPlayAnimation(
          "mp_player_inteat@burger",
          "mp_player_int_eat_burger",
          49,
          6000,
          "Eating",
          "changehunger",
          not customMarketItems[itemid],
          itemid,
          playerVeh
        )
        remove = customMarketItems[itemid]
    end

    if deanworldFood[itemid] then
      TriggerEvent("DoLongHudText", "Ew, tastes like shit.", 2)
      if math.random() < 0.05 then
        TriggerServerEvent("fx:puke")
      end
    end

    if waterItems[itemid] then
        --attachPropsToAnimation(itemid, 6000)
        --TaskItem("amb@world_human_drinking@coffee@male@idle_a", "idle_c", 49,6000,"Drink","changethirst",true,itemid)
        AttachPropAndPlayAnimation(
          "amb@world_human_drinking@beer@female@idle_a", 
          "idle_e", 
          49,
          6000,
          "Drink",
          "changethirst",
          not customMarketItems[itemid],
          itemid,
          playerVeh
        )
        remove = customMarketItems[itemid]
    end


    if (itemid == "bleederburger"
      or itemid == "heartstopper"
      or itemid == "torpedo"
      or itemid == "meatfree"
      or itemid == "moneyshot"
      or itemid == "maccheese"
      or itemid == "questionablemeatburger"
    ) then
        AttachPropAndPlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 49,6000,"Eating","inv:wellfed",true,itemid,playerVeh)
        --attachPropsToAnimation(itemid, 6000)
        --TaskItem("mp_player_inteat@burger", "mp_player_int_eat_burger", 49, 6000, "Eating", "inv:wellfed", true,itemid)
    end

    if (itemid == "sushiplate"
      or itemid == "sushiplatec"
      or itemid == "beefdish"
      or itemid == "beefdishc"
      or itemid == "ramen"
    ) then
        local success = AttachPropAndPlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 49,6000,"Eating","inv:wellfedNoStress",true,itemid,playerVeh)
        if success then
          TriggerEvent("DoLongHudText", "You feel lucky.")
          TriggerEvent("buffs:triggerBuff", itemid)
          TriggerServerEvent("buffs:triggerBuff", itemid)
        end
    end

    if (itemid == "methlabproduct") then
        local finished = exports["np-ui"]:taskBarSkill(1000, math.random(10, 15))
        if finished == 100 then
            TriggerEvent("attachItemObjectnoanim","crackpipe01")
            TriggerEvent("Evidence:StateSet",2,1200)
            TriggerEvent("Evidence:StateSet",6,1200)

            TaskItem(
              "switch@trevor@trev_smoking_meth",
              "trev_smoking_meth_loop",
              49,
              1500,
              "Smoking Meth",
              "hadcocaine",
              true,
              itemid,
              playerVeh,
              nil,
              nil,
              json.decode(passedItemInfo).purity
          )
        end
    end
    
    if itemid == "slushy" then
        --attachPropsToAnimation(itemid, 6000)
        AttachPropAndPlayAnimation("amb@world_human_drinking@beer@female@idle_a", "idle_e", 49, 6000,"Eating", "inv:slushy",true,itemid,playerVeh)
    end

    if itemid == "fruitslushy" then
        AttachPropAndPlayAnimation("amb@world_human_drinking@beer@female@idle_a", "idle_e", 49, 6000,"Drinking", "inv:fruitslushy",true,itemid,playerVeh)
    end

    if itemid == "jailfood" then
        AttachPropAndPlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 49,6000,"Eating","inv:wellfedwater",true,itemid,playerVeh)
    end

    if (itemid == "shitlockpick") then
        lockpicking = true
        TriggerEvent("animation:lockpickinvtestoutside")
        local finished = exports["np-ui"]:taskBarSkill(1000, math.random(7, 12))
        if (finished == 100) then
            TriggerEvent("police:uncuffMenu")
        end
        lockpicking = false
        remove = true
    end

    if (itemid == "watch") then
        TriggerEvent("np-ui:watch")
    end

    if (itemid == "godbook") then
        local ItemInfo = GetItemInfo(slot)
        if (ItemInfo == nil or ItemInfo.information == "No information stored" or  ItemInfo.information == nil) then 
            justUsed = false
            retardCounter = 0
            lastCounter = 0
            return
        end
        local data = json.decode(ItemInfo.information)
        local cid = exports["isPed"]:isPed("cid")

        if data.cid == cid then
            remove = true
            TriggerServerEvent("inventory:gb",data)
        else
            TriggerEvent("DoLongHudText","Just looks blank to me.",2)
        end
    end

    if (itemid == "harness") then
        local currentVehicle = GetVehiclePedIsIn(player, false)

        local finished = 0
        local cancelHarness = false
        Citizen.CreateThread(function()
            while finished ~= 100 and not cancelHarness do
                Citizen.Wait(100)
                if GetEntitySpeed(GetVehiclePedIsIn(player, false)) > 11 then
                    exports["np-taskbar"]:closeGuiFail()
                    cancelHarness = true
                end
            end
        end)
        finished = exports["np-taskbar"]:taskBar(20000,"Harness")
        if (finished == 100 and not cancelHarness) then
            TriggerEvent("vehicle:addHarness", "large")
            TriggerEvent("harness", false, 100)
            remove = true
        else
            TriggerEvent("DoLongHudText","You can't drive and hook up nos at the same time.",2)
        end
    end

    if itemid == "softdrink" then
        AttachPropAndPlayAnimation("amb@world_human_drinking@coffee@male@idle_a", "idle_c", 49,15000,"Drink","food:SoftDrink",true,itemid,playerVeh)
    end

    if itemid == "roostertea" then
        AttachPropAndPlayAnimation("amb@world_human_drinking@coffee@male@idle_a", "idle_c", 49,15000,"Drink","np-roostersrest:drinkTea",true,itemid,playerVeh)
    end
 
    if itemid == "fries" or itemid == "chips" then
        AttachPropAndPlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 49,15000,"Eating","food:Fries",true,itemid,playerVeh)
    end

    if itemid == "bscoffee" then
        AttachPropAndPlayAnimation("amb@world_human_drinking@coffee@male@idle_a", "idle_c", 49,15000,"Drink","coffee:drink",true,itemid,playerVeh)
    end

    if itemid == "foodbag" or itemid == "collectiblepouch" then
        local data = json.decode(passedItemInfo)
        TriggerEvent("inventory-open-container", data.inventoryId, data.slots, data.weight)
    end

    if itemid == "mask" then
        local parsedInfo = json.decode(passedItemInfo)
        TriggerEvent("facewear:setWear", 4, parsedInfo.mask, parsedInfo.txd, parsedInfo.palette)
        TriggerEvent("facewear:adjust", 4, false)
    end

    if itemid == "hat" then
        local parsedInfo = json.decode(passedItemInfo)
        TriggerEvent("facewear:setWear", 1, parsedInfo.hat, parsedInfo.txd)
        TriggerEvent("facewear:adjust", 1, false)
    end

    if itemid == "franksflute" then
      TriggerServerEvent("np-inventory:franksFlute", GetEntityCoords(PlayerPedId()))
      franksFluteCount = franksFluteCount + 1
      if franksFluteCount == 3 then
        franksFluteCount = 0
        remove = true
      end
    end

    if itemid == "tattooremover" then
        local target = exports['np-target']:GetCurrentEntity()
        --local target = PlayerPedId()
        if IsEntityAPed(target) and IsPedAPlayer(target) then
            TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_WELDING", 0, true)
            local finished = exports["np-taskbar"]:taskBar(60000, "Removing tattoos")
            ClearPedTasks(PlayerPedId())
            if finished == 100 then
                local plyCoords = GetEntityCoords(PlayerPedId())
                local targetCoords = GetEntityCoords(target)
                if #(plyCoords - targetCoords) < 5.0 then
                    local plyId = GetPlayerServerId( NetworkGetPlayerIndexFromPed(target))
                    local success = RPC.execute("clothing:removeTattoosForPlayer", plyId)
                    if success then 
                        TriggerEvent("DoLongHudText", "Removed tattoos.")
                    else
                        TriggerEvent("DoLongHudText", "Could not remove tattos.")
                    end
                else
                    TriggerEvent("DoLongHudText", "They are too far away.")
                end
            end
        end
    end

    if itemid == "buddhaletter" then
        if GetEntityModel(PlayerPedId()) == `ig_buddha` or GetEntityModel(PlayerPedId()) == `g_m_m_buddha` then
            local finished = exports["np-taskbar"]:taskBar(5000,"Opening letter.",false,false,playerVeh)
            if finished == 100 then
                TriggerEvent("DoLongHudText","As you open the letter something falls to the ground. You pick it up.",10)
                remove = true
                TriggerEvent( "player:receiveItem","buddhamedalion",1)
            end
        else
            TriggerEvent("DoLongHudText","Should I really be opening this?",3)
        end
    end
    if itemid == "buddhablade" or itemid == "buddhaguard" or itemid == "buddhahilt" then
        if hasEnoughOfItem("buddhablade",1,false) and hasEnoughOfItem("buddhaguard",1,false) and hasEnoughOfItem("buddhahilt",1,false) then
            if hasEnoughOfItem("buddhamedalion",1,false) then
                local playerPos = GetEntityCoords(PlayerPedId())
                if #(playerPos - vector3(-172.54, 319.13, 87.35)) < 10 then
                    local finished = exports["np-taskbar"]:taskBar(30000,"Putting sword together.",false,false,playerVeh)
                    if (finished == 100) then
                        TriggerEvent("inventory:removeItem","buddhablade", 1)
                        TriggerEvent("inventory:removeItem","buddhaguard", 1)
                        TriggerEvent("inventory:removeItem","buddhahilt", 1)
                        TriggerEvent("inventory:removeItem","buddhamedalion", 1)
                        TriggerEvent("player:receiveItem","talonweapon",1)
                    end
                else
                    TriggerEvent("DoLongHudText","Voice in your head: You can't do that here.",5)
                end
            else
                TriggerEvent("DoLongHudText","You seem to be missing something.",5)
            end
        else
            TriggerEvent("DoLongHudText","Voice in your head: Your quest is not yet complete.",5)
        end
    end
    if itemid == "buddhashovel" then
        local playerPos = GetEntityCoords(PlayerPedId())
        if #(playerPos - vector3(-1911.78, 1388.1, 219.35)) < 10 then
            if BuddhaIsItemFound1 == false then
                TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true)
                local finished = exports["np-taskbar"]:taskBar(15000, "Digging for something.", false, true, false, false, nil, 5.0, PlayerPedId())
                ClearPedTasks(PlayerPedId())
                if finished == 100 then
                    BuddhaIsItemFound1 = true
                    TriggerEvent( "player:receiveItem","buddhablade",1)
                end
            end
        elseif #(playerPos - vector3(-1717.48, 5649.55, -119.6)) < 5 then
            if BuddhaIsItemFound2 == false then
                TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true)
                local finished = exports["np-taskbar"]:taskBar(15000, "Digging for something.", false, true, false, false, nil, 5.0, PlayerPedId())
                ClearPedTasks(PlayerPedId())
                if finished == 100 then
                    BuddhaIsItemFound2 = true
                    TriggerEvent( "player:receiveItem","buddhaguard",1)
                end
            end
        elseif #(playerPos - vector3(3647.61, 3121.15, 1.31)) < 10 then
            if BuddhaIsItemFound3 == false then
                TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true)
                local finished = exports["np-taskbar"]:taskBar(15000, "Digging for something.", false, true, false, false, nil, 5.0, PlayerPedId())
                ClearPedTasks(PlayerPedId())
                if finished == 100 then
                    BuddhaIsItemFound3 = true
                    TriggerEvent( "player:receiveItem","buddhahilt",1)
                end
            end
        elseif not BuddhaIsItemFound1 or not BuddhaIsItemFound2 or not BuddhaIsItemFound3 then
            TriggerEvent("DoLongHudText","Voice in your head: This is not the place.",5)
        else
            TriggerEvent("DoLongHudText","Voice in your head: You already found it, move on!",5)
        end
    end

    TriggerEvent("np-inventory:itemUsed", itemid, passedItemInfo, inventoryName, slot)
    TriggerServerEvent("np-inventory:itemUsed", itemid, passedItemInfo, inventoryName, slot)

    if remove then
        local info = json.decode(passedItemInfo)
        if info and info._remove_id then
            TriggerEvent("inventory:removeItemByMetaKV", itemid, 1, "_remove_id", info._remove_id)
        else
            TriggerEvent("inventory:removeItem", itemid, 1)
        end
    end

    Wait(500)
    retardCounter = 0
    justUsed = false


end)

function AttachPropAndPlayAnimation(dictionary,animation,typeAnim,timer,message,func,remove,itemid,vehicle)
    if itemid == "hamburger" or itemid == "heartstopper" or itemid == "bleederburger" or itemid == "moneyshot" or itemid == "torpedo" or itemid == "questionablemeatburger" then
        TriggerEvent("attachItem", "hamburger")
    elseif sandwichItems[itemid] then
        TriggerEvent("attachItem", "sandwich")
    elseif itemid == "donut" or itemid == "applepie" then
        TriggerEvent("attachItem", "donut")
    elseif waterItemsAttached[itemid] then
        TriggerEvent("attachItem", itemid == "poisonedwater" and "water" or itemid)
    elseif itemid == "drink1" or itemid == "drink2" or itemid == "drink3" or itemid == "drink4" or itemid == "drink5" or itemid == "drink6"
        or itemid == "drink7" or itemid == "drink8" or itemid == "drink9" or itemid == "drink10" or itemid == "absinthe" or itemid == "moonshine" then
        TriggerEvent("attachItem", "whiskeyglass")
    elseif itemid == "shot1" or itemid == "shot2" or itemid == "shot3" or itemid == "shot4" or itemid == "shot5" or itemid == "shot6"
        or itemid == "shot7" or itemid == "shot8" or itemid == "shot9" or itemid == "shot10" then
        TriggerEvent("attachItem", "shotglass")
    elseif itemid == "fishtaco" or itemid == "taco" then
        TriggerEvent("attachItem", "taco")
    elseif itemid == "greencow" or itemid == "franksmonster" then
        TriggerEvent("attachItem", "energydrink")
    elseif itemid == "slushy" then
        TriggerEvent("attachItem", "cup")
    elseif has_value(fruits, itemid) then
        TriggerEvent("attachItem", "fruit")
    end
    local success = TaskItem(dictionary, animation, typeAnim, timer, message, func, remove, itemid,vehicle)
    TriggerEvent("destroyProp")
    return success
end

RegisterNetEvent('randPickupAnim')
AddEventHandler('randPickupAnim', function()
    loadAnimDict('pickup_object')
    TaskPlayAnim(PlayerPedId(),'pickup_object', 'putdown_low',5.0, 1.5, 1.0, 48, 0.0, 0, 0, 0)
    Wait(1000)
    ClearPedSecondaryTask(PlayerPedId())
end)


-- should remove weapons from players if they drop them but dont put them away
RegisterNetEvent('inventory:wepDropCheck')
AddEventHandler('inventory:wepDropCheck', function()
    if (not hasEnoughOfItem(GetSelectedPedWeapon(PlayerPedId()),1,false)) then
        SetCurrentPedWeapon(PlayerPedId(), `WEAPON_UNARMED`, true)
    end
end)




local clientInventory = {};
RegisterNetEvent('current-items')
AddEventHandler('current-items', function(inv)
    -- print("getting client inventory")
    clientInventory = inv
    checkForItems()
    checkForAttachItem()
end)



RegisterNetEvent('SniffRequestCID')
AddEventHandler('SniffRequestCID', function(src)
    local cid = exports["isPed"]:isPed("cid")
    TriggerServerEvent("SniffCID",cid,src)
end)



function GetItemInfo(checkslot)
    for i,v in pairs(clientInventory) do
        if (tonumber(v.slot) == tonumber(checkslot)) then
            local info = {["information"] = v.information,["id"] = v.id, ["quality"] = v.quality }
            return info
        end
    end
    return "No information stored";
end

function GetInfoForFirstItemOfName(item_id)
    for i,v in pairs(clientInventory) do
        if (v.item_id == item_id) then
            local info = {
              ["information"] = v.information,
              ["id"] = v.id,
              ["quality"] = v.quality,
            }
            return info
        end
    end
    return nil
end

function GetItemsByItemMetaKV(item_id, meta_key, meta_value)
  local items = {}
  for i, v in pairs(clientInventory) do
      if v.item_id == item_id then
          local info = json.decode(v.information)
          if info[meta_key] == meta_value then
              items[#items + 1] = {
                ["information"] = v.information,
                ["id"] = v.id,
                ["quality"] = v.quality,
              }
          end
      end
  end
  return items
end
exports("GetItemsByItemMetaKV", GetItemsByItemMetaKV)

-- item id, amount allowed, crafting.
function CreateCraftOption(id, add, craft)
    TriggerEvent("CreateCraftOption", id, add, craft)
end

-- Animations
function loadAnimDict( dict )
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Citizen.Wait( 5 )
    end
end

function TaskItem(dictionary,animation,typeAnim,timer,message,func,remove,itemid,playerVeh,itemreturn,itemreturnid,quality)
    loadAnimDict( dictionary )
    TaskPlayAnim( PlayerPedId(), dictionary, animation, 8.0, 1.0, -1, typeAnim, 0, 0, 0, 0 )
    local timer = tonumber(timer)
    if timer > 0 then
        local finished = exports["np-taskbar"]:taskBar(timer,message,true,false,playerVeh)
        if finished == 100 or timer == 0 then
            TriggerEvent(func, quality and quality or -1, itemid)
            if remove then
                TriggerEvent("inventory:removeItem", itemid, 1)
            end
            if itemreturn then
                TriggerEvent( "player:receiveItem",itemreturnid, 1 )
            end
            
            TriggerServerEvent( "player:itemTaskCompleted", itemid, timer)

            ClearPedSecondaryTask(PlayerPedId())
            return true
        else
            ClearPedSecondaryTask(PlayerPedId())
            return false
        end
    else
        TriggerEvent(func, quality and quality or -1, itemid)
        ClearPedSecondaryTask(PlayerPedId())
        return true
    end
end



function GetCurrentWeapons()
    local returnTable = {}
    for i,v in pairs(clientInventory) do
        if (tonumber(v.item_id)) then
            local t = { ["hash"] = v.item_id, ["id"] = v.id, ["information"] = v.information, ["name"] = v.item_id, ["slot"] = v.slot }
            returnTable[#returnTable+1]=t
        end
    end
    if returnTable == nil then
        return {}
    end
    return returnTable
end

function getFreeSpace()
    local space = 40
    for i,v in pairs(clientInventory) do
        if v.item_id then
            space = space - 1
        end
    end
    return space
end

function getQuantity(itemid, checkQuality, metaInformation)
    local amount = 0
    for i,v in pairs(clientInventory) do
        local qCheck = not checkQuality or v.quality > 0
        if v.item_id == itemid and qCheck then
            if metaInformation then
                local totalMetaKeys = 0
                local metaFoundCount = 0
                local itemMeta = json.decode(v.information)
                for metaKey, metaValue in pairs(metaInformation) do
                    totalMetaKeys = totalMetaKeys + 1
                    if itemMeta[metaKey] and itemMeta[metaKey] == metaValue then
                        metaFoundCount = metaFoundCount + 1
                    end
                end
                if totalMetaKeys <= metaFoundCount then
                    amount = amount + v.amount
                end
            else
                amount = amount + v.amount
            end
        end
    end
    return amount
end

function hasEnoughOfItem(itemid,amount,shouldReturnText,checkQuality, metaInformation)
    if shouldReturnText == nil then shouldReturnText = true end
    if itemid == nil or itemid == 0 or amount == nil or amount == 0 then
        if shouldReturnText then
            TriggerEvent("DoLongHudText","I dont seem to have " .. itemid .. " in my pockets.",2)
        end
        return false
    end
    amount = tonumber(amount)
    local slot = 0
    local found = false

    if getQuantity(itemid, checkQuality, metaInformation) >= amount then
        return true
    end
    if (shouldReturnText) then
        TriggerEvent("DoLongHudText","I dont have enough of that item...",2)
    end
    return false
end

function getItemsOfType(itemid, limitAmount, checkQuality, metaInformation)
    if itemid == nil then
        return nil
    end
    local itemsFound = {}
    local amount = tonumber(limitAmount)
    for i,v in pairs(clientInventory) do
        if amount and #itemsFound >= amount then
            break
        end

        local qCheck = not checkQuality or v.quality > 0
        if v.item_id == itemid and qCheck then
            if metaInformation then
                local totalMetaKeys = 0
                local metaFoundCount = 0
                local itemMeta = json.decode(v.information)
                for metaKey, metaValue in pairs(metaInformation) do
                    totalMetaKeys = totalMetaKeys + 1
                    if itemMeta[metaKey] and itemMeta[metaKey] == metaValue then
                        metaFoundCount = metaFoundCount + 1
                    end
                end
                if totalMetaKeys <= metaFoundCount then
                    itemsFound[#itemsFound+1] = v
                end
            else
                itemsFound[#itemsFound+1] = v
            end
        end
    end
    return itemsFound
end

exports("getItemsOfType", getItemsOfType)

function checkForAttachItem()
    local AttatchItems = {
        "stolentv",
        "stolenmusic",
        "stolencoffee",
        "stolenmicrowave",
        "stolencomputer",
        "stolenart",
        "darkmarketpackage",
        "weedpackage"
    }

    local itemToAttach = "none"
    for k,v in pairs(AttatchItems) do
        if getQuantity(v) >= 1 then
            itemToAttach = v
            break
        end
    end

    TriggerEvent("animation:carry",itemToAttach,true)
end

local PreviousItemCheck = {}

function checkForItems()
    local items = {
        "mobilephone",
        "stoleniphone",
        "stolennokia",
        "stolenpixel3",
        "stolens8",
        "boomerphone",
        "radio",
        "civradio",
        "burgershotheadset",
        "megaphone",
        "watch",
        "boxinggloves"
    }

    for _, item in ipairs(items) do
        local quantity = getQuantity(item)
        local hasItem = quantity >= 1

        if hasItem and not PreviousItemCheck[item] then
            PreviousItemCheck[item] = true
            TriggerEvent('np-inventory:itemCheck', item, true, quantity)
        elseif not hasItem and PreviousItemCheck[item] then
            PreviousItemCheck[item] = false
            TriggerEvent('np-inventory:itemCheck', item, false, quantity)
        end
    end
end

function isValidUseCase(itemID, isWeapon)
    local player = PlayerPedId()
    local playerVeh = GetVehiclePedIsIn(player, false)
    if playerVeh ~= 0 then
        local model = GetEntityModel(playerVeh)
        if IsThisModelACar(model) or IsThisModelABike(model) or IsThisModelAQuadbike(model) then
            if IsEntityInAir(playerVeh) then
                Wait(1000)
                if IsEntityInAir(playerVeh) then
                    TriggerEvent("DoLongHudText","You appear to be flying through the air",2)
                    return false
                end
            end
        end
    end

    if not validWaterItem[itemID] and not isWeapon then
        if IsPedSwimming(player) then
            local targetCoords = GetEntityCoords(player, 0)
            Wait(700)
            local plyCoords = GetEntityCoords(player, 0)
            if #(targetCoords - plyCoords) > 1.3 then
                TriggerEvent("DoLongHudText","Cannot be moving while swimming to use this.",2)
                return false
            end
        end

        if IsPedSwimmingUnderWater(player) then
            TriggerEvent("DoLongHudText","Cannot be underwater to use this.",2)
            return false
        end
    end

    return true
end


-- DNA



RegisterNetEvent('evidence:addDnaSwab')
AddEventHandler('evidence:addDnaSwab', function(dna)
    TriggerEvent("DoLongHudText", "DNA Result: " .. dna,1)
end)

RegisterNetEvent('CheckDNA')
AddEventHandler('CheckDNA', function()
    TriggerServerEvent("Evidence:checkDna")
end)

RegisterNetEvent('evidence:dnaSwab')
AddEventHandler('evidence:dnaSwab', function(pArgs, pEntity, pContext)
    TriggerServerEvent("police:dnaAsk", GetPlayerServerId(NetworkGetPlayerIndexFromPed(pEntity)))
end)

RegisterNetEvent('evidence:swabNotify')
AddEventHandler('evidence:swabNotify', function()
    TriggerEvent("DoLongHudText", "DNA swab taken.",1)
end)


function GetPlayers()
    local players = {}

    for i = 0, 255 do
        if NetworkIsPlayerActive(i) then
            players[#players+1]= i
        end
    end

    return players
end

function GetClosestPlayer()
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


-- DNA AND EVIDENCE END

-- Others
local buddhaEventLastDist = 0
function buddhaMedalion()
    local playerPos = GetEntityCoords(PlayerPedId())

    local hasBlade = hasEnoughOfItem("buddhablade", 1, false)
    local hasGuard = hasEnoughOfItem("buddhaguard", 1, false)
    local hasHilt = hasEnoughOfItem("buddhahilt", 1, false)

    local dist = 9999
    
    if hasBlade and hasGuard and hasHilt then
        --return TriggerEvent("DoLongHudText", "The medallion is pulling you towards the basement.", 5)
        dist = #(playerPos - vector3(-172.54, 319.13, 87.35))
    end
    
    if not hasBlade then
        dist = #(playerPos - vector3(-1911.78, 1388.1, 219.35))
    end
    local distToGuard = #(playerPos - vector3(-1717.48, 5649.55, -119.6))
    if not hasGuard and dist > distToGuard then
        dist = distToGuard
    end
    local distToHilt = #(playerPos - vector3(3647.61, 3121.15, 1.31))
    if not hasHilt and dist > distToHilt then
        dist = distToHilt
    end

    local oldDist = buddhaEventLastDist
    buddhaEventLastDist = dist

    if dist < 10 then
        return TriggerEvent("DoLongHudText", "The medallion is shaking uncontrollably.", 5)
    end
    if dist < 2500 then
        if dist > oldDist then
            return TriggerEvent("DoLongHudText", "The humming is getting weaker.", 5)
        end
        if dist < oldDist then
            return TriggerEvent("DoLongHudText", "The humming is getting stronger.", 5)
        end
        return TriggerEvent("DoLongHudText", "The medallion is humming.", 5)
    end
    TriggerEvent("DoLongHudText", "The medallion is quiet.", 5)
end




















-- this is the upside down world, be careful.


function getVehicleInDirection(coordFrom, coordTo)
    local offset = 0
    local rayHandle
    local vehicle

    for i = 0, 100 do
        rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z + offset, 2, PlayerPedId(), 0)
        a, b, c, d, vehicle = GetRaycastResult(rayHandle)

        offset = offset - 1

        if vehicle ~= 0 then break end
    end

    local distance = Vdist2(coordFrom, GetEntityCoords(vehicle))

    if distance > 25 then vehicle = nil end

    return vehicle ~= nil and vehicle or 0
end
function DrawText3Ds(x,y,z, text)
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

RegisterNetEvent('inv:wellfed')
AddEventHandler('inv:wellfed', function()
    TriggerEvent("Evidence:StateSet",25,3600)
    TriggerEvent("changehunger")
    TriggerEvent("changehunger")
    TriggerEvent("changehunger")
    TriggerEvent("client:newStress", false, 3000)
end)

RegisterNetEvent('inv:wellfedwater')
AddEventHandler('inv:wellfedwater', function()
    TriggerEvent("inv:wellfed")
    TriggerEvent("changethirst")
end)

RegisterNetEvent("inv:slushy")
AddEventHandler('inv:slushy', function()
    TriggerEvent("inv:wellfed")
    TriggerEvent("healed:useOxy")
    TriggerEvent("changethirst")
end)

RegisterNetEvent("inv:fruitslushy")
AddEventHandler('inv:fruitslushy', function()
    -- TriggerEvent("inv:wellfed")
    -- TriggerEvent("healed:useOxy")
    TriggerEvent("changethirst")
    TriggerEvent("changethirst")
end)

RegisterNetEvent('inv:wellfedNoStress')
AddEventHandler('inv:wellfedNoStress', function()
    TriggerEvent("Evidence:StateSet",25,3600)
    TriggerEvent("changehunger")
    TriggerEvent("changehunger")
    TriggerEvent("changehunger")
end)

RegisterNetEvent('animation:lockpickinvtestoutside')
AddEventHandler('animation:lockpickinvtestoutside', function()
    local lPed = PlayerPedId()
    RequestAnimDict("veh@break_in@0h@p_m_one@")
    while not HasAnimDictLoaded("veh@break_in@0h@p_m_one@") do
        Citizen.Wait(0)
    end

    while lockpicking do
        TaskPlayAnim(lPed, "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0, 1.0, 1.0, 16, 0.0, 0, 0, 0)
        Citizen.Wait(2500)
    end
    ClearPedTasks(lPed)
end)

RegisterNetEvent('animation:lockpickinvtest')
AddEventHandler('animation:lockpickinvtest', function(disable)
    local lPed = PlayerPedId()
    RequestAnimDict("mini@repair")
    while not HasAnimDictLoaded("mini@repair") do
        Citizen.Wait(0)
    end
    if disable ~= nil then
        if not disable then
            lockpicking = false
            return
        else
            lockpicking = true
        end
    end
    while lockpicking do

        if not IsEntityPlayingAnim(lPed, "mini@repair", "fixing_a_player", 3) then
            ClearPedSecondaryTask(lPed)
            TaskPlayAnim(lPed, "mini@repair", "fixing_a_player", 8.0, -8, -1, 16, 0, 0, 0, 0)
        end
        Citizen.Wait(1)
    end
    ClearPedTasks(lPed)
end)



RegisterNetEvent('inv:lockPick')
AddEventHandler('inv:lockPick', function(isForced,inventoryName,slot)
    TriggerEvent("robbery:scanLock",true)
    if lockpicking then return end

    lockpicking = true
    playerped = PlayerPedId()
    targetVehicle = GetVehiclePedIsUsing(playerped)
    local itemid = 21

    if targetVehicle == 0 then
        coordA = GetEntityCoords(playerped, 1)
        coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, 100.0, 0.0)
        targetVehicle = getVehicleInDirection(coordA, coordB)
        local driverPed = GetPedInVehicleSeat(targetVehicle, -1)
        if targetVehicle == 0 then
            lockpicking = false
            TriggerEvent("housing:attemptToLockPick")
            return
        end

        if driverPed ~= 0 and (IsPedAPlayer(driverPed) or not IsPedDeadOrDying(driverPed)) then
            lockpicking = false
            return
        end
            local d1,d2 = GetModelDimensions(GetEntityModel(targetVehicle))
            local leftfront = GetOffsetFromEntityInWorldCoords(targetVehicle, d1["x"]-0.25,0.25,0.0)

            local count = 5000
            local dist = #(vector3(leftfront["x"],leftfront["y"],leftfront["z"]) - GetEntityCoords(PlayerPedId()))
            while dist > 2.0 and count > 0 do
                dist = #(vector3(leftfront["x"],leftfront["y"],leftfront["z"]) - GetEntityCoords(PlayerPedId()))
                Citizen.Wait(1)
                count = count - 1
                DrawText3Ds(leftfront["x"],leftfront["y"],leftfront["z"],"Move here to lockpick.")
            end

            if dist > 2.0 then
                lockpicking = false
                return
            end


            TaskTurnPedToFaceEntity(PlayerPedId(), targetVehicle, 1.0)
            Citizen.Wait(1000)
            TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 3.0, 'lockpick', 0.4)
            local triggerAlarm = GetVehicleDoorLockStatus(targetVehicle) > 1
            if triggerAlarm then
                SetVehicleAlarm(targetVehicle, true)
                StartVehicleAlarm(targetVehicle)
            end


            TriggerEvent("civilian:alertPolice",20.0,"lockpick",targetVehicle)

            TriggerEvent("animation:lockpickinvtestoutside")
            TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 3.0, 'lockpick', 0.4)

            local p = promise:new()

            exports['np-vehicles']:LockpickVehicleDoor(targetVehicle, function(result)
                p:resolve(result)
            end)

            local result = Citizen.Await(p)

            if result.success then
                if triggerAlarm then
                    SetVehicleAlarm(targetVehicle, false)
                end
            end

            SetEntityAsMissionEntity(targetVehicle, true, true)

            local plate = GetVehicleNumberPlateText(targetVehicle)

            Citizen.SetTimeout(math.random(120, 7200) * 1000, function ()
                TriggerServerEvent('np:vehicles:hotPlate', plate, '10-60')
            end)

            exports['np-flags']:SetVehicleFlag(targetVehicle, 'isStolenVehicle', true)

        lockpicking = false
    else
        if targetVehicle ~= 0 and not isForced then
            if exports["np-vehicles"]:HasVehicleKey(targetVehicle) then lockpicking = false return end
            TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 3.0, 'lockpick', 0.4)
            local triggerAlarm = GetVehicleDoorLockStatus(targetVehicle) > 1
            if triggerAlarm then
                SetVehicleAlarm(targetVehicle, true)
                StartVehicleAlarm(targetVehicle)
            end

            SetVehicleHasBeenOwnedByPlayer(targetVehicle,true)

            TriggerEvent("animation:lockpickinvtest")
            TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 3.0, 'lockpick', 0.4)

            TriggerEvent("civilian:alertPolice", 12.0, "lockpick", targetVehicle)

            local p = promise:new()

            exports['np-vehicles']:HotwireVehicle(function(result)
                p:resolve(result)
            end)

            local result = Citizen.Await(p)

            if not result.success then
                if result.stage >= 2 and math.random() < 0.25 then
                    TriggerEvent("DoLongHudText", "The lockpick bent out of shape.",2)
                    TriggerEvent("inventory:removeItem","lockpick", 1)
                    lockpicking = false
                    return
                end
            end

            SetEntityAsMissionEntity(targetVehicle, true, true)

            local plate = GetVehicleNumberPlateText(targetVehicle)

            Citizen.SetTimeout(math.random(120, 7200) * 1000, function ()
                TriggerServerEvent('np:vehicles:hotPlate', plate, '10-60')
            end)

            exports['np-flags']:SetVehicleFlag(targetVehicle, 'isStolenVehicle', true)
        end
    end
    lockpicking = false
end)

local function repairVehiclePart(pTargetVehicle, pData)
    for part, data in pairs(pData) do
        if part == "Engine" then
            SetVehicleEngineHealth(pTargetVehicle, data + 0.0)
        elseif part == "Body" then
            SetVehicleBodyHealth(pTargetVehicle, data + 0.0)
        elseif part == "PetrolTank" then
            SetVehiclePetrolTankHealth(pTargetVehicle, data + 0.0)
        elseif part == "Tyre" then
            for i = 0, 11 do
                SetVehicleTyreFixed(pTargetVehicle, i)
            end
        end
    end
end


RegisterNetEvent("repair:vehicle")
AddEventHandler("repair:vehicle", function(pTargetVehicle, pData)
    repairVehiclePart(NetToVeh(pTargetVehicle), pData)
end)

-- Animations
RegisterNetEvent('animation:load')
AddEventHandler('animation:load', function(dict)
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Citizen.Wait( 5 )
    end
end)

RegisterNetEvent('animation:repair')
AddEventHandler('animation:repair', function(veh)
    SetVehicleDoorOpen(veh, 4, 0, 0)
    RequestAnimDict("mini@repair")
    while not HasAnimDictLoaded("mini@repair") do
        Citizen.Wait(0)
    end

    TaskTurnPedToFaceEntity(PlayerPedId(), veh, 1.0)
    Citizen.Wait(1000)

    while fixingvehicle do
        local anim3 = IsEntityPlayingAnim(PlayerPedId(), "mini@repair", "fixing_a_player", 3)
        if not anim3 then
            TaskPlayAnim(PlayerPedId(), "mini@repair", "fixing_a_player", 8.0, -8, -1, 16, 0, 0, 0, 0)
        end
        Citizen.Wait(1)
    end
    SetVehicleDoorShut(veh, 4, 1, 1)
end)

function getInformationFromFirstItem(itemToFind)
  local foundItem = exports["np-inventory"]:GetInfoForFirstItemOfName(itemToFind)
  return foundItem and json.decode(foundItem.information or '{}') or nil
end
exports("getInformationFromFirstItem", getInformationFromFirstItem)

--
local isDead = false
AddEventHandler("pd:deathcheck", function()
  isDead = not isDead
end)
local poisonedThings = {
  ["poisonedcocktail"] = true,
  ["poisonedsandwich"] = true,
  ["poisonedwater"] = true,
}
AddEventHandler("np-inventory:itemUsed", function(name, info)
  if not info then return end
  local info = json.decode(info)
  if not info._is_poisoned then return end
  local potency = info.potency or 5
  if not potency or potency < 1 then
    potency = 1
  end
  if potency and potency > 101 then
    potency = 101
  end
  local interval = info.interval or 60
  if interval < 1 then
    interval = 1
  end
  local duration = info.duration or 60
  if duration < 1 then
    duration = 1
  end
  TriggerServerEvent("ems:addpoisonedblood")
  Citizen.CreateThread(function()
    local loopCount = 0
    local alertSent = false
    while loopCount < duration and not isDead do
      loopCount = loopCount + 1
      Wait(interval * 1000)
      if not alertSent and math.random() < 0.2 then
        alertSent = true
        TriggerEvent("DoLongHudText", "You don't feel too well.", 2)
      end
      SetEntityHealth(PlayerPedId(), GetEntityHealth(PlayerPedId()) - potency)
    end
  end)
end)

RegisterUICallback("np-ui:inv:moneycaseAction", function(data, cb)
	cb({ data = {}, meta = { ok = true, message = "done" } })
  exports['np-ui']:closeApplication('textbox')
  RPC.execute("np-inventory:doMoneycaseAction", data)
end)
