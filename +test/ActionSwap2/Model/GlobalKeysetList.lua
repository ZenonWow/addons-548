--[[========================================================================================
      ActionSwap 2, a World of Warcraft addon which swaps out sets of actions, glyphs, and
      keybindings.
      
      Copyright (c) 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      All Rights Reserved unless otherwise explicitly stated.
    ========================================================================================]]

-- GlobalKeysetList - a list of global keysets, of which at most one per spec is active at a time.

local AS2 = ActionSwap2
if AS2.DEBUG and LibDebug then LibDebug() end
local GlobalKeysetList = AS2.Model.GlobalKeysetList

-- Creates a new GlobalKeysetList object around an existing data source.
function GlobalKeysetList:CreateWithDataSource(dataSource, dataContext)
	assert(dataSource and dataContext, "NIL_ARGUMENT")
	self = AS2.Model.SetListBase.CreateWithDataSource(self, dataSource, dataContext, AS2.Model.GlobalKeyset, "keysets", "activeKeyset",
		function() return AS2.activeModel:IsActivatingGlobalKeyset() end)

	-- Validate the data source

	-- Synchronize the object model to the data source

	return self
end

-- Rename the base class functions, as set operations can be confusing if you don't specify the kind of set.
function GlobalKeysetList:GetKeysetCount(...) return self:GetSetCount(...) end
function GlobalKeysetList:AddKeyset(...) return self:AddSet(...) end
function GlobalKeysetList:RemoveKeysetAt(...) return self:RemoveSetAt(...) end
function GlobalKeysetList:GetKeysetAt(...) return self:GetSetAt(...) end
function GlobalKeysetList:FindKeyset(...) return self:FindSet(...) end
function GlobalKeysetList:GetActiveKeyset(...) return self:GetActiveSet(...) end
function GlobalKeysetList:friend_SetActiveKeyset(...) return self:friend_SetActiveSet(...) end
