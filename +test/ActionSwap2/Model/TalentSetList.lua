--[[========================================================================================
      ActionSwap 2, a World of Warcraft addon which swaps out sets of actions, glyphs, and
      keybindings.
      
      Copyright (c) 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      All Rights Reserved unless otherwise explicitly stated.
    ========================================================================================]]

local AS2 = ActionSwap2
if AS2.DEBUG and LibDebug then LibDebug() end
local TalentSetList = AS2.Model.TalentSetList

-- Creates a new TalentSetList object around an existing data source.
function TalentSetList:CreateWithDataSource(dataSource, dataContext)
	assert(dataSource and dataContext, "NIL_ARGUMENT")
	self = AS2.Model.SetListBase.CreateWithDataSource(self, dataSource, dataContext, AS2.Model.TalentSet, "talentSets", "activeTalentSet",
		function() return AS2.activeModel:IsActivatingTalentSet() end)

	-- Validate the data source

	-- Synchronize the object model to the data source

	return self
end

-- Rename the base class functions, as set operations can be confusing if you don't specify the kind of set.
function TalentSetList:GetTalentSetCount(...) return self:GetSetCount(...) end
function TalentSetList:AddTalentSet(...) return self:AddSet(...) end
function TalentSetList:RemoveTalentSetAt(...) return self:RemoveSetAt(...) end
function TalentSetList:GetTalentSetAt(...) return self:GetSetAt(...) end
function TalentSetList:FindTalentSet(...) return self:FindSet(...) end
function TalentSetList:GetActiveTalentSet(...) return self:GetActiveSet(...) end
function TalentSetList:friend_SetActiveTalentSet(...) return self:friend_SetActiveSet(...) end
