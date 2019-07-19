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
   
   EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, self.OnPlayerCombatState)
   
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
      for key,value in pairs(HarvestLogger.ItemsLog) do
        --d("in for")
        local icon, sellPrice, meetsUsageRequirement, equipType, itemStyle = GetItemLinkInfo (key)
        --d("got icon")
        iconLogo = zo_strformat ( "|t24:24:<<1>>|t", icon )
        d("Looted "..value.quantity.." "..iconLogo.." "..key.." price X, level"..value.level)
        
      end
      
      HarvestLogger.ItemsLog = {}
      HarvestLogger.savedVariables.ItemsLog = {}
    end
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
      d("rank "..rank)
      if trait ~= nil then
        d("trait "..trait)
      end
      if refined ~= nil then
        d("refined "..refined)
      end
      
      local LogEntry = {
          ["itemLink"] = itemLink,
          ["quantity"] = quantity,
          ["price"] = 5
        }
      
      if HarvestLogger.ItemsLog[itemLink] == nil then
        --d("create new item")
        HarvestLogger.ItemsLog[itemLink] = {}
        HarvestLogger.savedVariables.ItemsLog[itemLink] = {}
        HarvestLogger.ItemsLog[itemLink].quantity = quantity
        HarvestLogger.savedVariables.ItemsLog[itemLink].quantity = quantity
        
        HarvestLogger.ItemsLog[itemLink].level = rank
        HarvestLogger.savedVariables.ItemsLog[itemLink].level = rank
        --d("null?")
      else 
        --d("will add")
        --d("add to"..HarvestLogger.ItemsLog[itemLink]) 
        HarvestLogger.ItemsLog[itemLink].quantity = HarvestLogger.ItemsLog[itemLink].quantity + quantity
        HarvestLogger.savedVariables.ItemsLog[itemLink].quantity =  HarvestLogger.savedVariables.ItemsLog[itemLink].quantity + quantity
      end
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
		version = "0.6",
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