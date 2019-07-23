HarvestLogger = {}
local LibAM = LibStub:GetLibrary ( "LibAddonMenu-2.0" )
HarvestLogger.name = "HarvestLogger"
HarvestLogger.lootedItems = {}
HarvestLogger.version = 1

function HarvestLogger:Initialize()
  
  SLASH_COMMANDS['/harvlog'] = HarvestLogger.toggleAddon
  SLASH_COMMANDS['/harvlog verbose'] = HarvestLogger.toggleVerbose
  SLASH_COMMANDS['/harvlog timer' ] = HarvestLogger.toggleAddon

  ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_HARVESTLOGGER", "Toggle addon")
  ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_HARVESTLOGGER_VERBOSE", "Toggle chat log")
  ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_HARVESTLOGGER_TIMER", "Toggle timer")


  --HarvestLogger.AddKeyBind()
  
   self.inCombat = IsUnitInCombat("player")
   
   --EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, self.OnPlayerCombatState)
   
   HarvestLogger.Default = {
     LogEnabled = true,
     TimerStarted = false,
     Time = 0,
     TimeString = "",
     Verbose = true,
     ShowBag = true,
     ShowCraftBag = true,
     ShowBank = true,
     ItemsLog = {}
     --MakeStatistics 
     -- writes data in csv (or txt, whatev format)
     --stats must be enabled to keep track between deconnections
    }
   
   HarvestLogger.savedVariables = ZO_SavedVars:NewAccountWide ( "HarvestLoggerVariables", HarvestLogger.version, nil, HarvestLogger.Default )

   HarvestLogger.LogEnabled = HarvestLogger.savedVariables.LogEnabled
   HarvestLogger.TimerStarted = HarvestLogger.savedVariables.TimerStarted
   HarvestLogger.Time = HarvestLogger.savedVariables.Time
   HarvestLogger.TimeString = HarvestLogger.savedVariables.TimeString
   HarvestLogger.Verbose = HarvestLogger.savedVariables.Verbose
   HarvestLogger.ShowBag = HarvestLogger.savedVariables.ShowBag
   HarvestLogger.ShowCraftBag = HarvestLogger.savedVariables.ShowCraftBag
   HarvestLogger.ShowBank = HarvestLogger.savedVariables.ShowBank
   HarvestLogger.ItemsLog = HarvestLogger.savedVariables.ItemsLog

   
   self.AddonSettings()
   
   EVENT_MANAGER:RegisterForEvent ( self.name, EVENT_LOOT_RECEIVED, self.LootReceived )
   
   
end

function HarvestLogger.OnAddOnLoaded(event, addonName)

  if addonName == HarvestLogger.name then
    HarvestLogger:Initialize()
  end
end
 
     
 function HarvestLogger.toggleAddon()
    HarvestLogger.LogEnabled = not HarvestLogger.LogEnabled
    HarvestLogger.savedVariables.LogEnabled = HarvestLogger.LogEnabled
    if( HarvestLogger.LogEnabled) then
      d("Harvest logger switched on")
    else
      d("Harvest logger switched off")
    end
    
end

 function HarvestLogger.toggleVerbose()
    HarvestLogger.Verbose = not HarvestLogger.Verbose
    HarvestLogger.savedVariables.Verbose = HarvestLogger.Verbose
    if( HarvestLogger.Verbose) then
      d("Harvest logger chat switched on")
    else
      d("Harvest logger chat switched off")
    end
end

 function HarvestLogger.toggleTimer()
    HarvestLogger.TimerStarted = not HarvestLogger.TimerStarted
    HarvestLogger.savedVariables.TimerStarted = HarvestLogger.TimerStarted
    if( HarvestLogger.TimerStarted) then
      d("Harvest logger timer switched on")
      --HarvestLogger.Timer = os.clock
      HarvestLogger.TimeString = ""..os.date("%m/%d/%Y %I:%M %p")
      HarvestLogger.savedVariables.TimeString = HarvestLogger.TimeString
      d(""..HarvestLogger.TimeString)
      HarvestLogger.Time = os.time()
      HarvestLogger.savedVariables.Time = HarvestLogger.Time     
    else
      
      d("Harvest logger timer switched off")
      d("Timer began "..HarvestLogger.savedVariables.TimeString)
      d("Timer ended "..os.date("%m/%d/%Y %I:%M %p"))
      totalSecs = os.difftime(os.time(), HarvestLogger.Time)
      totalMin = math.floor(totalSecs/60)
      diff = os.difftime(os.time(), HarvestLogger.Time)
      --d("time "..diff)
      hours = math.floor(diff/3600)
      diff = math.fmod(diff,3600)
      minutes = math.floor(diff/60)
      diff = math.fmod(diff,60)
      seconds = diff
      d(hours.." hours, "..minutes.." minutes, "..seconds.." seconds")
      --[[
      if next(HarvestLogger.savedVariables.ItemsLog) == nil then
        d("found log to be null")
      else 
        d("log not null")    
      end
      --]]
      --print the logs
      
      
      --[[
      for key,value in pairs(HarvestLogger.ItemsLog) do
        --d("in for")
        local icon, sellPrice, meetsUsageRequirement, equipType, itemStyle = GetItemLinkInfo (key)
        --d("got icon")
        iconLogo = zo_strformat ( "|t24:24:<<1>>|t", icon )
        d("Looted "..value.quantity.." "..iconLogo.." "..key.." price X, level"..value.level.."type: "..value.itemType)
        
      end
      --]]
      --HarvestLogger.ItemsLog = {}
      --HarvestLogger.savedVariables.ItemsLog = {}
      
      local displayRawMat = true
      local stringArray = {}
      local total = 0
      --d("before for")
      for key,value in pairs(HarvestLogger.ItemsLog) do
        if next(value) then
        --d("----------------1")
        local d1 = false
        --d(""..key)
          for key2, value2 in pairs(value) do
            d1 = false
            if next(value) then
              --d("----------------2")
              --d(""..key2)
              if key2 == "default" then
                d("in default")
              end
              for key3, value3 in pairs(value2) do
                d1 = false
                if next(value) then
                  local icon, sellPrice, meetsUsageRequirement, equipType, itemStyle = GetItemLinkInfo (key3)
                  --d("got icon")
                  iconLogo = zo_strformat ( "|t24:24:<<1>>|t", icon )
                  d1 = true
                  local matCost = MasterMerchant:itemStats(key3)["avgPrice"]
                  table.insert(stringArray, "Looted "..value3.quantity.." "..iconLogo.." "..key3.." price "..round(matCost*value3.quantity,2))
                  total = total + round(matCost*value3.quantity,2)
                end
              end
            end
            if d1 then
              table.insert(stringArray, "----------------2")
              table.insert(stringArray, ""..key2)
            end
          end
          if d1 then 
            table.insert(stringArray, "---------1")
            table.insert(stringArray, ""..key)
          end
        end
        --[[
        if displayRawMat then--and value == rawMats then
          d("past if")
          for matType,mats in pairs(value) do
            d("for mattype")
            for matLink, matQuantity in pairs(mats) do
              d(""..matLink..": "..matQuantity)
            end
          end
        end
        --]]
        
      end
      
      for i = #stringArray, 1, -1 do
        value = stringArray[i]
        d("".. value)
      end
      d("total = "..total)
      d("taux = "..round(total/totalMin,2).."/min") 
      
      HarvestLogger.ItemsLog = {}
      HarvestLogger.savedVariables.ItemsLog = {}
    end
end
 
 function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end
 
function HarvestLogger.LootReceived ( eventCode, lootedBy, itemLink, quantity, itemSound, lootType, self )
    if HarvestLogger.LogEnabled and HarvestLogger.TimerStarted then
      
      --local name = GetItemLinkName(itemLink) -- may contain localization control codes
 
      --local formattedName = LocalizeString("<<1>>", name) -- no control codes
      --d("looted "..formattedName)
      local stackCountBackpack, stackCountBank, stackCountCraftBag = GetItemLinkStacks ( itemLink )
      local item_total_count = ""
				
				if stackCountBackpack > 1.0 and HarvestLogger.savedVariables.ShowBag then
					item_total_count = zo_strformat ( "<<1>> (|t18:18:esoui/art/tooltips/icon_bag.dds|t <<2>>)",
					item_total_count, comma_value ( stackCountBackpack ))
				end
				
				if stackCountBank > 1.0 and HarvestLogger.savedVariables.ShowCraftBag then
					item_total_count = zo_strformat ( "<<1>> (|t18:18:esoui/art/tooltips/icon_bank.dds|t <<2>>)",
					item_total_count, comma_value ( stackCountBank ))
				end
				
				if stackCountCraftBag > 1.0 and HarvestLogger.savedVariables.ShowBank then
					item_total_count = zo_strformat ( "<<1>> (|t24:24:esoui/art/tooltips/icon_craft_bag.dds|t <<2>>)",item_total_count, comma_value ( stackCountCraftBag ))
        end
      
      local icon, sellPrice, meetsUsageRequirement, equipType, itemStyle = GetItemLinkInfo (itemLink )
      iconLogo = zo_strformat ( "|t24:24:<<1>>|t", icon )
      d("Looted "..quantity.." "..iconLogo.." "..itemLink.." "..item_total_count)
      local rank = GetItemLinkRequiredCraftingSkillRank(itemLink)
      local known,trait= GetItemLinkReagentTraitInfo(itemLink, 1)
      local refined = GetItemLinkRefinedMaterialItemLink(itemLink)
      local itemType = GetItemLinkItemType(itemLink)
      --d("rank "..rank)
      
      --[[
      if trait ~= nil then
        d("trait "..trait)
      end
      if refined ~= nil then
        d("refined "..refined)
      end
      if itemType ~= nil then
        d("itemType "..itemType)
      end
      --]]
      
      local LogEntry = {
          ["itemLink"] = itemLink,
          ["quantity"] = quantity,
          ["price"] = 5
        }
      --[[
      if HarvestLogger.ItemsLog[itemLink] == nil then
        --d("create new item")
        HarvestLogger.ItemsLog[itemLink] = {}
        HarvestLogger.ItemsLog.rawMats = {}
        HarvestLogger.ItemsLog.rawMats.blacksmith = {}
        HarvestLogger.ItemsLog.rawMats.clothier = {}
        HarvestLogger.ItemsLog.rawMats.woodworking = {}
        HarvestLogger.ItemsLog.rawMats.jewelry = {}
        HarvestLogger.ItemsLog.runes = {}
        HarvestLogger.ItemsLog.runes.potency = {}
        HarvestLogger.ItemsLog.runes.aspect = {}
        HarvestLogger.ItemsLog.runes.essence = {}

        d("created categories")
        
        HarvestLogger.savedVariables.ItemsLog[itemLink] = HarvestLogger.ItemsLog[itemLink]
        HarvestLogger.ItemsLog[itemLink].quantity = quantity
        HarvestLogger.savedVariables.ItemsLog[itemLink].quantity = quantity
        
        HarvestLogger.ItemsLog[itemLink].level = rank
        HarvestLogger.savedVariables.ItemsLog[itemLink].level = rank
        
        HarvestLogger.ItemsLog[itemLink].itemType = itemType
        HarvestLogger.savedVariables.ItemsLog[itemLink].itemType = itemType
        
        
        
        --d("null?")
      else 
      --]]
      
        --d("will add")
        --d("add to"..HarvestLogger.ItemsLog[itemLink]) 
        if HarvestLogger.ItemsLog.rawMats == nil then
        --d("create new item")
          --HarvestLogger.ItemsLog[itemLink] = {}
          
          HarvestLogger.ItemsLog.rawMats = {}
          HarvestLogger.ItemsLog.rawMats.blacksmith = {}
          HarvestLogger.ItemsLog.rawMats.clothier = {}
          HarvestLogger.ItemsLog.rawMats.woodworking = {}
          HarvestLogger.ItemsLog.rawMats.jewelry = {}
          HarvestLogger.ItemsLog.rawMats.alchemy = {}
          HarvestLogger.ItemsLog.rawMats.default = {}
          HarvestLogger.ItemsLog.runes = {}
          HarvestLogger.ItemsLog.runes.potency = {}
          HarvestLogger.ItemsLog.runes.aspect = {}
          HarvestLogger.ItemsLog.runes.essence = {}

          --d("created categories")
          HarvestLogger.savedVariables.ItemsLog = HarvestLogger.ItemsLog
          --d("created saved cat")
        end
        
        
        case = {
          [35] = function ( ) 
            --d("in case 35")
            if HarvestLogger.ItemsLog.rawMats.blacksmith[itemLink] == nil then
              --d("create entry in case 35")
              HarvestLogger.ItemsLog.rawMats.blacksmith[itemLink] = {}
              --d("created empty table0")
              HarvestLogger.savedVariables.ItemsLog.rawMats.blacksmith[itemLink] = {}
              --d("created empty table1")
              --HarvestLogger.saveVariables.ItemsLog.rawMats.blacksmith[itemLink][quantity] = {}
              --d("created empty table2")
              HarvestLogger.ItemsLog.rawMats.blacksmith[itemLink]["quantity"] =  quantity
              HarvestLogger.savedVariables.ItemsLog.rawMats.blacksmith[itemLink]["quantity"] =  quantity

              --d("added quantity")
              --HarvestLogger.saveVariables.ItemsLog.rawMats.blacksmith[itemLink][quantity] = HarvestLogger.ItemsLog.rawMats.blacksmith[itemLink][quantity]
              --d("created empty table in savedvar")
            else
              --d("case 35 wasn't null")
              HarvestLogger.ItemsLog.rawMats.blacksmith[itemLink]["quantity"] = HarvestLogger.ItemsLog.rawMats.blacksmith[itemLink]["quantity"] + quantity
              --d("add1")
              HarvestLogger.savedVariables.ItemsLog.rawMats.blacksmith[itemLink]["quantity"] = HarvestLogger.ItemsLog.rawMats.blacksmith[itemLink]["quantity"]
              --d("add2")
            end
          end,  
          ["default"] = function()
            --d("in case default")
            --HarvestLogger.ItemsLog[itemLink].quantity = HarvestLogger.ItemsLog[itemLink].quantity + quantity
            --HarvestLogger.savedVariables.ItemsLog[itemLink].quantity =  HarvestLogger.savedVariables.ItemsLog[itemLink].quantity + quantity
            if HarvestLogger.ItemsLog.rawMats.default[itemLink] == nil then
              HarvestLogger.ItemsLog.rawMats.default[itemLink] = {}
              --d("created empty table0")
              HarvestLogger.savedVariables.ItemsLog.rawMats.default[itemLink] = {}
              --HarvestLogger.saveVariables.ItemsLog.rawMats.blacksmith[itemLink] = {}
              --d("created empty table1")
              --HarvestLogger.saveVariables.ItemsLog.rawMats.blacksmith[itemLink][quantity] = {}
              --d("created empty table2")
              HarvestLogger.ItemsLog.rawMats.default[itemLink]["quantity"] =  quantity
              HarvestLogger.savedVariables.ItemsLog.rawMats.default[itemLink]["quantity"] =  quantity

              --d("added quantity")
              --HarvestLogger.saveVariables.ItemsLog.rawMats.blacksmith[itemLink][quantity] = HarvestLogger.ItemsLog.rawMats.blacksmith[itemLink][quantity]
              --d("created empty table in savedvar")
            else
              --d("case default wasn't null")
              HarvestLogger.ItemsLog.rawMats.default[itemLink]["quantity"] = HarvestLogger.ItemsLog.rawMats.default[itemLink]["quantity"] + quantity
              --d("case default not null done")
              HarvestLogger.savedVariables.ItemsLog.rawMats.default[itemLink]["quantity"] = HarvestLogger.ItemsLog.rawMats.default[itemLink]["quantity"]
            end
          end,
          
          [53] = function()
            --d("rune triangle")
            --HarvestLogger.ItemsLog[itemLink].quantity = HarvestLogger.ItemsLog[itemLink].quantity + quantity
            --HarvestLogger.savedVariables.ItemsLog[itemLink].quantity =  HarvestLogger.savedVariables.ItemsLog[itemLink].quantity + quantity

            
            if HarvestLogger.ItemsLog.runes["aspect"][itemLink] == nil then
              --d("in if")
            HarvestLogger.ItemsLog.runes["aspect"][itemLink] = {}
              --d("created empty table0")
              --HarvestLogger.saveVariables.ItemsLog.rawMats.blacksmith[itemLink] = {}
              --d("created empty table1")
              --HarvestLogger.saveVariables.ItemsLog.rawMats.blacksmith[itemLink][quantity] = {}
              --d("created empty table2")
              HarvestLogger.ItemsLog.runes["aspect"][itemLink]["quantity"] =  quantity
              --d("added quantity")
              --HarvestLogger.saveVariables.ItemsLog.rawMats.blacksmith[itemLink][quantity] = HarvestLogger.ItemsLog.rawMats.blacksmith[itemLink][quantity]
              --d("created empty table in savedvar")
            else
              --d("case default wasn't null")
               HarvestLogger.ItemsLog.runes["aspect"][itemLink]["quantity"] = HarvestLogger.ItemsLog.runes["aspect"][itemLink]["quantity"] + quantity
              --HarvestLogger.saveVariables.ItemsLog.rawMats.default[itemLink]["quantity"] = HarvestLogger.ItemsLog.rawMats.default[itemLink]["quantity"]
            end
          end,
          
          [51] = function()
            --d("rune carre")
            
            if HarvestLogger.ItemsLog.runes["potency"][itemLink] == nil then
              --d("in if")
            HarvestLogger.ItemsLog.runes["potency"][itemLink] = {}
              --d("created empty table0")
              --HarvestLogger.saveVariables.ItemsLog.rawMats.blacksmith[itemLink] = {}
              --d("created empty table1")
              --HarvestLogger.saveVariables.ItemsLog.rawMats.blacksmith[itemLink][quantity] = {}
              --d("created empty table2")
              HarvestLogger.ItemsLog.runes["potency"][itemLink]["quantity"] =  quantity
              --d("added quantity")
              --HarvestLogger.saveVariables.ItemsLog.rawMats.blacksmith[itemLink][quantity] = HarvestLogger.ItemsLog.rawMats.blacksmith[itemLink][quantity]
              --d("created empty table in savedvar")
            else
              --d("case default wasn't null")
               HarvestLogger.ItemsLog.runes["potency"][itemLink]["quantity"] = HarvestLogger.ItemsLog.runes["potency"][itemLink]["quantity"] + quantity
              --HarvestLogger.saveVariables.ItemsLog.rawMats.default[itemLink]["quantity"] = HarvestLogger.ItemsLog.rawMats.default[itemLink]["quantity"]
            end
          end,
          
          
          [52] = function()
            --d("rune ronde")
            --HarvestLogger.ItemsLog[itemLink].quantity = HarvestLogger.ItemsLog[itemLink].quantity + quantity
            --HarvestLogger.savedVariables.ItemsLog[itemLink].quantity =  HarvestLogger.savedVariables.ItemsLog[itemLink].quantity + quantity
             
            if HarvestLogger.ItemsLog.runes["essence"][itemLink] == nil then
              --d("in if")
            HarvestLogger.ItemsLog.runes["essence"][itemLink] = {}
              --d("created empty table0")
              --HarvestLogger.saveVariables.ItemsLog.rawMats.blacksmith[itemLink] = {}
              --d("created empty table1")
              --HarvestLogger.saveVariables.ItemsLog.rawMats.blacksmith[itemLink][quantity] = {}
              --d("created empty table2")
              HarvestLogger.ItemsLog.runes["essence"][itemLink]["quantity"] =  quantity
              --d("added quantity")
              --HarvestLogger.saveVariables.ItemsLog.rawMats.blacksmith[itemLink][quantity] = HarvestLogger.ItemsLog.rawMats.blacksmith[itemLink][quantity]
              --d("created empty table in savedvar")
            else
              --d("case default wasn't null")
               HarvestLogger.ItemsLog.runes["essence"][itemLink]["quantity"] = HarvestLogger.ItemsLog.runes["essence"][itemLink]["quantity"] + quantity
              --HarvestLogger.saveVariables.ItemsLog.rawMats.default[itemLink]["quantity"] = HarvestLogger.ItemsLog.rawMats.default[itemLink]["quantity"]
            end
          end,
          
          
          --[[
          [39] = function ( ) 
            d("in case 39")
            if HarvestLogger.ItemsLog.rawMats.clothier[itemLink] == nil then
              d("create entry in case 39")
              HarvestLogger.ItemsLog.rawMats.clothier[itemLink] = {}
              d("created empty table and trying to do same in savevar")
              HarvestLogger.saveVariables.ItemsLog.rawMats.clothier[itemLink] = {}
              d("created empty table in savevar")
              HarvestLogger.ItemsLog.rawMats.clothier[itemLink].quantity =  quantity
              d("added quantity")
              HarvestLogger.saveVariables.ItemsLog.rawMats.clothier[itemLink].quantity = HarvestLogger.ItemsLog.rawMats.clothier[itemLink].quantity
              d("created empty table in savedvar")
            else
              d("case 39 wasn't null")
              HarvestLogger.ItemsLog.rawMats.clothier[itemLink].quantity = HarvestLogger.ItemsLog.rawMats.clothier[itemLink].quantity + quantity
              HarvestLogger.saveVariables.ItemsLog.rawMats.clothier[itemLink].quantity = HarvestLogger.ItemsLog.rawMats.clothier[itemLink].quantity
            end
          end,
          
          [37] = function ( ) 
            d("in case 37")
            if HarvestLogger.ItemsLog.rawMats.woodworking[itemLink] == nil then
              d("create entry in case 37")
              HarvestLogger.ItemsLog.rawMats.woodworking[itemLink] = {}
              HarvestLogger.saveVariables.ItemsLog.rawMats.woodworking[itemLink] = {}
              d("created empty table")
              HarvestLogger.ItemsLog.rawMats.woodworking[itemLink].quantity =  quantity
              d("added quantity")
              HarvestLogger.saveVariables.ItemsLog.rawMats.woodworking[itemLink].quantity = HarvestLogger.ItemsLog.rawMats.woodworking[itemLink].quantity
              d("created empty table in savedvar")
            else
              d("case 37 wasn't null")
              HarvestLogger.ItemsLog.rawMats.woodworking[itemLink].quantity = HarvestLogger.ItemsLog.rawMats.woodworking[itemLink].quantity + quantity
              HarvestLogger.saveVariables.ItemsLog.rawMats.woodworking[itemLink].quantity = HarvestLogger.ItemsLog.rawMats.woodworking[itemLink].quantity
            end
          end,
          }
        if case[itemType] then 
          d("do case")
          case[itemType]()
        else 
          d("do default")
          case["default"]()
        end
        
        --HarvestLogger.ItemsLog[itemLink].quantity = HarvestLogger.ItemsLog[itemLink].quantity + quantity
        --HarvestLogger.savedVariables.ItemsLog[itemLink].quantity =  HarvestLogger.savedVariables.ItemsLog[itemLink].quantity + quantity

      end
    --end
    --]]
          [39] = function ( ) 
            --d("in case 39")
            if HarvestLogger.ItemsLog.rawMats.clothier[itemLink] == nil then
              --d("create entry in case 39")
              HarvestLogger.ItemsLog.rawMats.clothier[itemLink] = {}
              --d("created empty table0")
              --HarvestLogger.saveVariables.ItemsLog.rawMats.blacksmith[itemLink] = {}
              --d("created empty table1")
              --HarvestLogger.saveVariables.ItemsLog.rawMats.blacksmith[itemLink][quantity] = {}
              --d("created empty table2")
              HarvestLogger.ItemsLog.rawMats.clothier[itemLink]["quantity"] =  quantity
              --d("added quantity")
              --HarvestLogger.saveVariables.ItemsLog.rawMats.blacksmith[itemLink][quantity] = HarvestLogger.ItemsLog.rawMats.blacksmith[itemLink][quantity]
              --d("created empty table in savedvar")
            else
              --d("case 39 wasn't null")
              HarvestLogger.ItemsLog.rawMats.clothier[itemLink]["quantity"] = HarvestLogger.ItemsLog.rawMats.clothier[itemLink]["quantity"] + quantity
              --HarvestLogger.saveVariables.ItemsLog.rawMats.clothier[itemLink]["quantity"] = HarvestLogger.ItemsLog.rawMats.clothier[itemLink]["quantity"]
            end
          end, 
          [37] = function ( ) 
            --d("in case 37")
            if HarvestLogger.ItemsLog.rawMats.woodworking[itemLink] == nil then
              --d("create entry in case 37")
              HarvestLogger.ItemsLog.rawMats.woodworking[itemLink] = {}
              --d("created empty table0")
              --HarvestLogger.saveVariables.ItemsLog.rawMats.blacksmith[itemLink] = {}
              --d("created empty table1")
              --HarvestLogger.saveVariables.ItemsLog.rawMats.blacksmith[itemLink][quantity] = {}
              --d("created empty table2")
              HarvestLogger.ItemsLog.rawMats.woodworking[itemLink]["quantity"] =  quantity
              --d("added quantity")
              --HarvestLogger.saveVariables.ItemsLog.rawMats.blacksmith[itemLink][quantity] = HarvestLogger.ItemsLog.rawMats.blacksmith[itemLink][quantity]
              --d("created empty table in savedvar")
            else
              --d("case 37 wasn't null")
              HarvestLogger.ItemsLog.rawMats.woodworking[itemLink]["quantity"] = HarvestLogger.ItemsLog.rawMats.woodworking[itemLink]["quantity"] + quantity
              --HarvestLogger.saveVariables.ItemsLog.rawMats.woodworking[itemLink]["quantity"] = HarvestLogger.ItemsLog.rawMats.woodworking[itemLink]["quantity"]
            end
          end,
          [63] = function ( ) 
            --d("in case 63")
            if HarvestLogger.ItemsLog.rawMats.jewelry[itemLink] == nil then
              --d("create entry in case 63")
              HarvestLogger.ItemsLog.rawMats.jewelry[itemLink] = {}
              HarvestLogger.savedVariables.ItemsLog.rawMats.jewelry[itemLink] = {}
              --d("created empty table0")
              --HarvestLogger.saveVariables.ItemsLog.rawMats.blacksmith[itemLink] = {}
              --d("created empty table1")
              --HarvestLogger.saveVariables.ItemsLog.rawMats.blacksmith[itemLink][quantity] = {}
              --d("created empty table2")
              HarvestLogger.ItemsLog.rawMats.jewelry[itemLink]["quantity"] =  quantity
              HarvestLogger.savedVariables.ItemsLog.rawMats.jewelry[itemLink]["quantity"] =  quantity
              --d("added quantity")
              --HarvestLogger.saveVariables.ItemsLog.rawMats.blacksmith[itemLink][quantity] = HarvestLogger.ItemsLog.rawMats.blacksmith[itemLink][quantity]
              --d("created empty table in savedvar")
            else
              --d("case 63 wasn't null")
              HarvestLogger.ItemsLog.rawMats.jewelry[itemLink]["quantity"] = HarvestLogger.ItemsLog.rawMats.jewelry[itemLink]["quantity"] + quantity
              HarvestLogger.savedVariables.ItemsLog.rawMats.jewelry[itemLink]["quantity"] = HarvestLogger.ItemsLog.rawMats.jewelry[itemLink]["quantity"]
            end
          end,
          [31] = function ( ) 
            --d("in case 63")
            if HarvestLogger.ItemsLog.rawMats.alchemy[itemLink] == nil then
              --d("create entry in case 63")
              HarvestLogger.ItemsLog.rawMats.alchemy[itemLink] = {}
              HarvestLogger.savedVariables.ItemsLog.rawMats.alchemy[itemLink] = {}
              --d("created empty table0")
              --HarvestLogger.saveVariables.ItemsLog.rawMats.blacksmith[itemLink] = {}
              --d("created empty table1")
              --HarvestLogger.saveVariables.ItemsLog.rawMats.blacksmith[itemLink][quantity] = {}
              --d("created empty table2")
              HarvestLogger.ItemsLog.rawMats.alchemy[itemLink]["quantity"] =  quantity
              HarvestLogger.savedVariables.ItemsLog.rawMats.alchemy[itemLink]["quantity"] =  quantity
              --d("added quantity")
              --HarvestLogger.saveVariables.ItemsLog.rawMats.blacksmith[itemLink][quantity] = HarvestLogger.ItemsLog.rawMats.blacksmith[itemLink][quantity]
              --d("created empty table in savedvar")
            else
              --d("case 63 wasn't null")
              HarvestLogger.ItemsLog.rawMats.alchemy[itemLink]["quantity"] = HarvestLogger.ItemsLog.rawMats.alchemy[itemLink]["quantity"] + quantity
              HarvestLogger.savedVariables.ItemsLog.rawMats.alchemy[itemLink]["quantity"] = HarvestLogger.ItemsLog.rawMats.alchemy[itemLink]["quantity"]
            end
          end
    }
    
    if case[itemType] then 
      --d("do case")
      case[itemType]()
    else 
      --d("do default")
      case["default"]()
    end
    --]]
    
    --HarvestLogger.savedVariables.ItemsLog = HarvestLogger.ItemsLog
  end
end
  
 function comma_value(amount)
  local formatted = amount
  while true do  
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted
end
 
 
 function HarvestLogger.OnPlayerCombatState(event, inCombat)
  -- The ~= operator is "not equal to" in Lua.
  if inCombat ~= HarvestLogger.inCombat then
    -- The player's state has changed. Update the stored state...
    HarvestLogger.inCombat = inCombat
 
    -- ...and then announce the change.
    if inCombat then
      d("Entering combat.")
    else
      d("Exiting combat.")
    end
 
  end
end
 

 
 
 
 
function HarvestLogger.AddonSettings()
	local panelData = {
		type = "panel",
		name = "Harvest Logger",
		displayName = "Harvest logger settings",
		author = "@TheLordRassilon",
		version = "0.7.2",
		registerForRefresh = true,
		registerForDefaults = true
	}
	
	local cntrlOptionsPanel = LibAM:RegisterAddonPanel ( "HarvestLoggerPanel", panelData )
	
	local optionsData = {
		[1] = {
			type = "header",
			name = "General settings",
			width = "full"
		},
  
		
		[2] = {
			type = "checkbox",
			name = "Enable logs",
			default = true,
      tooltip = GetString(SI_HARVEST_LOGGER_ENABLE_LOGS),
			width = "full",
			
			getFunc = function ( )
				return HarvestLogger.savedVariables.LogEnabled
			end,
			
			setFunc = function (LogEnabled)
        HarvestLogger.LogEnabled = LogEnabled
        HarvestLogger.savedVariables.LogEnabled = LogEnabled
			end
		},
    
		[3] = {
			type = "checkbox",
			name = "Write logs in chat",
      tooltip = GetString(SI_HARVEST_LOGGER_ENABLE_VERBOSE),
			default = true,
			width = "full",
			
			getFunc = function ( )
				return HarvestLogger.savedVariables.Verbose
			end,
			
			setFunc = function (Verbose)
        HarvestLogger.Verbose = Verbose
        HarvestLogger.savedVariables.Verbose = Verbose
			end
		},		
    [4] = {
			type = "checkbox",
			name = "Show amount in bag",
			default = true,
			width = "full",
			
			getFunc = function ( )
				return HarvestLogger.savedVariables.ShowBag
			end,
			
			setFunc = function (ShowBag)
        HarvestLogger.ShowBag = ShowBag
        HarvestLogger.savedVariables.ShowBag = ShowBag
			end
		},
    [5] = {
			type = "checkbox",
			name = "Show amount in crafting bag",
			default = true,
			width = "full",
			
			getFunc = function ( )
				return HarvestLogger.savedVariables.ShowCraftBag
			end,
			
			setFunc = function (ShowCraftBag)
        HarvestLogger.ShowCraftBag = ShowCraftBag
        HarvestLogger.savedVariables.ShowCraftBag = ShowCraftBag
			end
		},
    [6] = {
			type = "checkbox",
			name = "Show amount in bank",
			default = true,
			width = "full",
			
			getFunc = function ( )
				return HarvestLogger.savedVariables.ShowBank
			end,
			
			setFunc = function (ShowBank)
        HarvestLogger.ShowBank = ShowBank
        HarvestLogger.savedVariables.ShowBank = ShowBank
			end
		}
  
	}
	
	LibAM:RegisterOptionControls ( "HarvestLoggerPanel", optionsData )
end

 
 
 
-- Finally, we'll register our event handler function to be called when the proper event occurs.
EVENT_MANAGER:RegisterForEvent(HarvestLogger.name, EVENT_ADD_ON_LOADED, HarvestLogger.OnAddOnLoaded)