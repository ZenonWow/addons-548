--[[========================================================================================
      ActionSwap 2, a World of Warcraft addon which swaps out sets of actions, glyphs, and
      keybindings.
      
      Copyright (c) 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      All Rights Reserved unless otherwise explicitly stated.
    ========================================================================================]]

-- GlyphSetList - a list of glyph sets, of which at most one per spec is active at a time.

local AS2 = ActionSwap2
if AS2.DEBUG and LibDebug then LibDebug() end
local GlyphSetList = AS2.Model.GlyphSetList

-- Creates a new GlyphSetList object around an existing data source.
function GlyphSetList:CreateWithDataSource(dataSource, dataContext)
	assert(dataSource and dataContext, "NIL_ARGUMENT")
	self = AS2.Model.SetListBase.CreateWithDataSource(self, dataSource, dataContext, AS2.Model.GlyphSet, "glyphSets", "activeGlyphSet",
		function() return AS2.activeModel:IsActivatingGlyphSet() end)

	-- Validate the data source

	-- Synchronize the object model to the data source

	-- UPGRADE: Upgrade the glyph set list from revision 7- (Cataclysm) to revision 8 (Mists of Pandaria), if not already done
	self:UpgradeToRevision8()

	return self
end

-- Upgrades this glyph set list to revision 8 if not already done.
-- At revision 8 (Mists of Pandaria), deactivate any active glyph sets, because all glyph sets are being cleared.
function GlyphSetList:UpgradeToRevision8()
	if not self.dataSource.revision or self.dataSource.revision < 8 then
		-- Deactivate all glyph sets.
		for i = 1, AS2.NUM_SPECS do
			self:friend_SetActiveGlyphSet(i, nil)
		end

		-- Mark this glyph set list as upgraded so we don't ever upgrade it again.
		self.dataSource.revision = 8
	end
end

-- Rename the base class functions, as set operations can be confusing if you don't specify the kind of set.
function GlyphSetList:GetGlyphSetCount(...) return self:GetSetCount(...) end
function GlyphSetList:AddGlyphSet(...) return self:AddSet(...) end
function GlyphSetList:RemoveGlyphSetAt(...) return self:RemoveSetAt(...) end
function GlyphSetList:GetGlyphSetAt(...) return self:GetSetAt(...) end
function GlyphSetList:FindGlyphSet(...) return self:FindSet(...) end
function GlyphSetList:GetActiveGlyphSet(...) return self:GetActiveSet(...) end
function GlyphSetList:friend_SetActiveGlyphSet(...) return self:friend_SetActiveSet(...) end
