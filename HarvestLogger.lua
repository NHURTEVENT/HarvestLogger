-- First, we create a namespace for our addon by declaring a top-level table that will hold everything else.
HarvestLogger = {}

local LibAM = LibStub:GetLibrary ( "LibAddonMenu-2.0" )
-- This isn't strictly necessary, but we'll use this string later when registering events.
-- Better to define it in a single place rather than retyping the same string.
HarvestLogger.name = "HarvestLogger"

 
-- Next we create a function that will initialize our addon
function HarvestLogger:Initialize()
  
  SLASH_COMMANDS['/harvlog'] = HarvestLogger.toggle

  
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
 
 
 function HarvestLogger.toggle()

    HarvestLogger.LogEnabled = not HarvestLogger.LogEnabled
    HarvestLogger.savedVariables.LogEnabled = HarvestLogger.LogEnabled
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