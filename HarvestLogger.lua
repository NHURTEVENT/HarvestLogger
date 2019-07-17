-- First, we create a namespace for our addon by declaring a top-level table that will hold everything else.
HarvestLogger = {}

local LibAM = LibStub:GetLibrary ( "LibAddonMenu-2.0" )
-- This isn't strictly necessary, but we'll use this string later when registering events.
-- Better to define it in a single place rather than retyping the same string.
HarvestLogger.name = "HarvestLogger"


 
-- Next we create a function that will initialize our addon
function HarvestLogger:Initialize()
  
  SLASH_COMMANDS['/harvlog'] = HarvestLogger.toggleAddon
  SLASH_COMMANDS['/harvlog verbose'] = HarvestLogger.toggleVerbose
  SLASH_COMMANDS['/harvlog timer' ] = HarvestLogger.toggleAddon

  ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_HARVESTLOGGER", "Toggle addon")
  ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_HARVESTLOGGER_VERBOSE", "Toggle chat log")
  ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_HARVESTLOGGER_TIMER", "Toggle timer")


  HarvestLogger.AddKeyBind()
  
   self.inCombat = IsUnitInCombat("player")
   
   EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, self.OnPlayerCombatState)
   
   HarvestLogger.Default = {
     LogEnabled = true,
     TimerStarted = false,
     Time = true,
     Verbose = true
    }
   
   HarvestLogger.savedVariables = ZO_SavedVars:NewAccountWide ( "HarvestLoggerVariables", HarvestLogger.version, nil, HarvestLogger.Default )

   HarvestLogger.LogEnabled = HarvestLogger.savedVariables.LogEnabled
   HarvestLogger.TimerStarted = HarvestLogger.savedVariables.TimerStarted
   HarvestLogger.Time = HarvestLogger.savedVariables.Time
   HarvestLogger.Verbose = HarvestLogger.savedVariables.Verbose
   
   self.AddonSettings()
   
   EVENT_MANAGER:RegisterForEvent ( self.name, EVENT_LOOT_RECEIVED, self.LootReceived )
   
   
end
 
-- Then we create an event handler function which will be called when the "addon loaded" event
-- occurs. We'll use this to initialize our addon after all of its resources are fully loaded.
function HarvestLogger.OnAddOnLoaded(event, addonName)
  -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
  if addonName == HarvestLogger.name then
    HarvestLogger:Initialize()
  end
end
 
 function HarvestLogger.AddKeyBind()
   HarvestLogger.myButtonGroup = {
    {
      name = "Do Something",
      keybind = "UI_HARVESTLOG_PRIMARY",
      callback = function() HarvestLogger.toggleAddon() end,
    },
    {
      name = "Do Something Else",
      keybind = "UI_HARVESTLOG_SECONDARY",
      callback = function() HarvestLogger.toggleVerbose() end,
    },
    alignment = KEYBIND_STRIP_ALIGN_CENTER,
  }

  KEYBIND_STRIP:AddKeybindButtonGroup(HarvestLogger.myButtonGroup)
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
      d(""..os.date("%m/%d/%Y %I:%M %p"))
    else
      d("Harvest logger timer switched off")
    end
end
 
function HarvestLogger.LootReceived ( eventCode, lootedBy, itemLink, quantity, itemSound, lootType, self )
    if HarvestLogger.LogEnabled then
      d("looted")
    end
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
		version = "0.1",
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
		}		
  
	}
	
	LibAM:RegisterOptionControls ( "HarvestLoggerPanel", optionsData )
end

 
 
 
-- Finally, we'll register our event handler function to be called when the proper event occurs.
EVENT_MANAGER:RegisterForEvent(HarvestLogger.name, EVENT_ADD_ON_LOADED, HarvestLogger.OnAddOnLoaded)