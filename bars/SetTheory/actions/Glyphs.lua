local L = LibStub("AceLocale-3.0"):GetLocale("SetTheory", true)

if SetTheory and GetBuildInfo() < "4.0.0" then
	local glyphs = {};
	glyphs.name = "SetTheory_Glyphs"
	glyphs.desc = L["Glyphs"]

local gs = {{ROGUE = {'42967:16511','42963:1966','45766:51723','42962:8647','42961:2098','42960:5277','42966:1776','42965:14278','42964:703','42954:13750','42955:8676','42956:53','42959:26679','42958:3408','45769:31224','42957:13877','45764:51713','42970:6770','42969:1943','42972:1752','45767:57934','42974:2983','42973:5171','45762:51690','45761:51662','42968:14185','45768:1329','42971:14983'},PRIEST = {'42399:6346','42398:586','45753:47585','42397:527','45755:47788','42400:2061','42396:34861','42415:589','42414:32379','42407:15473','42412:9484','42417:20711','42416:585','42411:139','42402:588','45758:64901','42401:15237','42403:724','42410:8122','42409:596','42408:17','45756:47540','45760:33206','45757:48045','42406:15407','42405:605','42404:32375'},WARLOCK = {'42458:5782','42459:30146','42460:691','42462:6201','42461:755','45779:48181','45782:48020','42457:6789','42456:980','42455:172','42454:17962','45781:50796','42472:30108','45783:47897','42468:17877','42467:686','42466:5676','42469:63108','42471:712','42470:693','45789:19028','45785:1454','42453:29722','42465:688','42464:348','42463:5484','45780:59672','42473:697'},WARRIOR = {'43416:5308','45794:55694','43415:20243','43417:1715','43414:845','43412:23881','43425:23922','45790:46924','43420:694','45797:871','43424:6572','43430:6343','45792:46968','43429:355','43428:12328','43427:7386','45795:23920','43423:772','43426:12975','43419:3411','43413:100','43422:7384','43421:12294','43418:78','43431:34428','45793:50720','43432:1680'},SHAMAN = {'41552:16166','41527:51730','45775:974','45771:51533','41534:331','41533:5394','41547:8056','41532:8024','41531:8050','41530:1535','41529:2894','41518:421','41517:1064','41526:8042','45772:61295','45776:30706','45770:51490','41539:17364','45778:5730','41535:8004','41540:60103','41524:51505','45777:51514','41536:403','41537:324','41538:16190','41542:8232','41541:52127'},HUNTER = {'42917:19386','42916:1510','42915:19506','42909:19552','42899:13161','42906:13809','42905:1499','45733:13813','45731:53301','42908:13795','42907:1130','42902:19574','42901:34074','42898:3044','45625:53209','42904:781','42903:19263','42897:19434','42912:1978','45735:2973','42911:3045','45734:19503','42913:34600','42900:136','42914:56641','42910:2643','45732:53351'},DRUID = {'40922:5176','45602:48438','40906:18562','46372:61336','40908:29166','40899:6795','40896:22842','44928:48505','40914:5185','40920:16914','40924:339','45601:50334','45623:22812','40919:5570','40913:774','40909:20484','40903:1822','40912:8936','40901:5221','40902:1079','45604:52610','40923:8921','40916:2912','40915:33763','40897:6807','45622:50516','45603:50464','40900:48564','40921:48505'},MAGE = {'42754:31687','44684:44614','42742:116','42741:122','42739:133','42740:2136','42747:11095','42746:12472','42745:30455','42744:45438','45740:11426','42743:7302','42738:12051','42737:1953','42736:12042','42735:5143','42734:1449','44955:30451','45738:44425','45736:44572','42752:118','42753:475','45739:55342','45737:44457','42749:6117','42750:759','42751:30482','42748:66'},DEATHKNIGHT = {'43554:55233','45803:49194','43553:51271','43549:46584','43552:47476','43543:49143','43546:45477','43545:48792','45800:49203','45806:49184','43534:48721','43536:49222','43826:45902','43537:45524','45805:50842','43827:49998','43541:49576','43542:43265','45804:49895','43538:56222','45799:49028','43533:48707','43548:45462','43551:55090','43825:48982','43550:56815','43547:49020'},PALADIN = {'41102:10326','43369:20166','41095:853','41105:19750','41103:879','45742:53595','41097:24275','45746:20473','41106:635','45741:53563','41107:31884','41101:31935','41104:4987','41108:633','45743:53385','45745:54428','41098:35395','41099:26573','41110:20165','45744:53600','41100:31789','41094:20375','43868:21084','43867:31892','43869:31801','41109:20166','45747:1038','41092:53408','41096:31785'},},{SHAMAN = {'43388:546','43386:52127','43344:131','43385:20608','44923:51490','43725:2645','43381:556'},ROGUE = {'43380:1856','43376:1725','43378:1860','43343:921','43377:1804','43379:2983'},WARLOCK = {'43389:5697','43394:29893','43392:18223','43391:126','43390:1120','43393:1098'},PRIEST = {'43374:34433','43372:976','43373:9484','43342:586','43371:1243','43370:1706'},DEATHKNIGHT = {'43535:45529','43672:50842','43544:57330','43673:46584','43671:49158','43539:49895'},DRUID = {'43316:1066','43334:5209','44922:50516','43335:1126','43332:467','43331:20484','43674:1850'},MAGE = {'43361:851','43339:1459','44920:11113','43364:130','43359:168','43360:6143','43357:543'},HUNTER = {'43355:13159','43354:1002','43350:136','43356:1513','43338:982','43351:5384'},WARRIOR = {'43399:6343','43400:34428','43395:6673','43396:2687','43398:694','43397:100'},PALADIN = {'43365:20217','43340:19740','43366:19742','43368:5502','43367:633'},},}

	for t=1,2 do
		local types = gs[t]
		for c, glyphs in pairs(types) do
			if c == select(2, UnitClass('player')) then 
				for g=1,#glyphs do
					local glyphId = strsplit(':', glyphs[g])
					glyphName = GetItemInfo(glyphId)
					if not glyphName then
						GameTooltip:SetHyperlink("item:"..glyphId..":0:0:0:0:0:0:0")
					end
				end
			end
		end
	end

	function getGlyphs(type)
		local ret = {}
		local glyphs = gs[type][select(2, UnitClass("player"))]
		for i=1,#glyphs do
			local g = strsplit(':', glyphs[i])
			glyph = GetItemInfo(g)
			if not glyph then 
				GameTooltip:SetHyperlink("item:"..g..":0:0:0:0:0:0:0")
				glyph = GetItemInfo(g)
			end
			if glyph then
				ret[glyphs[i]] = glyph:gsub(L['Glyph of '], '')
			end
		end
		return ret
	end

	function glyphs.set(opts)
		local slots, glyphs = {{}, {}}, {{}, {}}
		for s=1,GetNumGlyphSockets() do
			local enabled, type = GetGlyphSocketInfo(s)
			if enabled then tinsert(slots[type], s) end
			if opts[tostring(s)] then tinsert(glyphs[type], opts[tostring(s)]) end
		end
		
		local freeSlots, addGlyphs = {}, {}
		glyphs_tcopy(freeSlots, slots)
		glyphs_tcopy(addGlyphs, glyphs)

		for t=1,#slots do
			for s=1,#slots[t] do
				for g=1,#glyphs[t] do
					local _, _, id = GetGlyphSocketInfo(slots[t][s])
					if id then
						local socket = GetSpellInfo(id)
						local glyph = strsplit(':', glyphs[t][g])
						local item = GetItemInfo(glyph)
						if not item then
							GameTooltip:SetHyperlink("item:"..glyph..":0:0:0:0:0:0:0")
							local item = GetItemInfo(glyph)
						end

						if socket == item then
							glyphs_tremovebyval(addGlyphs[t], glyphs[t][g])
							glyphs_tremovebyval(freeSlots[t], slots[t][s])
						end
					end
				end
			end
		end

		local swaps = {{}, {}}
		for t=1,#addGlyphs do
			for g=1,#addGlyphs[t] do
				swaps[t][freeSlots[t][g]] = addGlyphs[t][g]
			end
		end

		SetTheory:PromptToSetGlyphs(swaps)
	end

	function glyphs_tremovebyval(tab, val)
		for k,v in pairs(tab) do
			if(v==val) then
				table.remove(tab, k);
				return true;
			end
		end
		return false;
	end

	function glyphs_tcopy(to, from) 
		for k,v in pairs(from) do
			if(type(v)=="table") then
				to[k] = {}
				glyphs_tcopy(to[k], v);
			else
				to[k] = v;
			end
		end
	end

	function exists(i, glyph)
	end

	glyphs.opts = {
		type = "group",
		name = L["Glyphs"],
		handler = SetTheory,
		set = "SetActionOption",
		get = "GetActionOption",
		args = {
			actionInstructions = {
				type = "description",
				name = L["Select which glyphs you'd like to apply. You should select a glyph for each slot. This action requires you to press a button for each glyph you wish to apply and should go in an action sequence AFTER any Dual Spec swaps."],
				order = 0,
			},
		}
	}

	local types = {
		Majors = {
			['1'] = 1,
			['4'] = 1,
			['6'] = 1,
		},
		Minors = {
			['2'] = 2,
			['3'] = 2,
			['5'] = 2,
		}
	}

	local order = 10 
	for type, slots in pairs(types) do
		glyphs.opts.args[type] = {
			type = "header",
			name = L[type],
			order = order,
		}

		for k, t in pairs(slots) do 
			order = order + 10
			glyphs.opts.args[k] = {		
				name = "",
				type = "select",
				values = function() return getGlyphs(t) end,
				order = order
			}
		end
	end

	SetTheory:RegisterAction(glyphs)

elseif SetTheory and select(4, GetBuildInfo()) >= 40000 then
	local glyphs = {};
	glyphs.name = "SetTheory_Glyphs"
	glyphs.desc = L["Glyphs"]

	local function getGlyphs(type)
		local ret = {}
		for i=1,GetNumGlyphs() do
			local name, glyphType, isKnown = GetGlyphInfo(i);
			if name ~= 'header' and glyphType == type and isKnown then 	ret[i] = name end
		end
		return ret
	end

	function glyphs.set(opts)
		local glyphedSpells = {};
		for i=1,GetNumGlyphSockets() do
			local spell = select(4, GetGlyphSocketInfo(i))
			if spell then glyphedSpells[spell] = i; end
		end

		local requested = {}; glyphs_tcopy(requested, opts);
		requested.id = nil; requested.name = nil

		local glyphs = {}
		local takenSockets = {}

		for socket, glyph in pairs(requested) do
			local name, glyphType, isKnown, icon, castSpell = GetGlyphInfo(tonumber(glyph));
			if isKnown then
				if not glyphedSpells[castSpell] then table.insert(glyphs, glyph);
				else takenSockets[glyphedSpells[castSpell]] = true; end
			end
		end

		local availableSockets = {{}, {}, {}}
		for i=1, GetNumGlyphSockets() do
			local _, type, _, spell = GetGlyphSocketInfo(i)
			if type == 3 then type = 1
			elseif type == 1 then type = 2
			elseif type == 2 then type = 3 end
			if not takenSockets[i] then availableSockets[type][i] = spell end
		end

		if(#glyphs > 0) then SetTheory:Print("Glyph swaps:") end
		local numbering = 1
		for _,glyph in ipairs(glyphs) do
			local name, type = GetGlyphInfo(glyph)
			for i,sSpell in pairs(availableSockets[type]) do
				sName = GetSpellInfo(sSpell)
				SetTheory:Print(numbering .. ". "..name .. " can replace " .. sName)
				numbering = numbering+1
				availableSockets[type][i] = nil
				break
			end
		end

		--[[if not IsAddOnLoaded('Blizzard_GlyphUI') and IsAddOnLoadOnDemand('Blizzard_GlyphUI') then LoadAddOn('Blizzard_GlyphUI') end
		if not IsGlyphFlagSet(32) then ToggleGlyphFilter(32) end

		UIDropDownMenu_Initialize(GlyphFrameFilterDropDown, function() 
				GlyphFrameFilter_Initialize();
				local info = UIDropDownMenu_CreateInfo();
				info.isNotRadio = true;
				info.func = function(self, arg1)
					GlyphFrameFilter_Modify	(self, arg1)
				end

				info.text = L["SetTheory Glyphs"];
				info.checked = IsGlyphFlagSet(32);
				info.arg1 = 32;
				UIDropDownMenu_AddButton(info);
			end);

		blizzardGetNumGlyphs = GetNumGlyphs
		GetNumGlyphs = function()
			local num = blizzardGetNumGlyphs()
			if not IsGlyphFlagSet(32) then return num end
			return num + 1
		end

		blizzardGetGlyphInfo = GetGlyphInfo
		GLYPH_STRING_PLURAL[4] = "SetTheory Swaps"
		GetGlyphInfo = function(index)
			if not IsGlyphFlagSet(32) then return blizzardGetGlyphInfo(index) end
			if index == 1 then return "header", 4, 1
			else return blizzardGetGlyphInfo(index-1) end
		end]]

		--GlyphFrame_Open ()
	end

	function glyphs_tremovebyval(tab, val)
		for k,v in pairs(tab) do
			if(v==val) then
				table.remove(tab, k);
				return true;
			end
		end
		return false;
	end

	function glyphs_tcopy(to, from) 
		for k,v in pairs(from) do
			if(type(v)=="table") then
				to[k] = {}
				glyphs_tcopy(to[k], v);
			else
				to[k] = v;
			end
		end
	end

	local function socketEnabled(socket)
		if GetGlyphSocketInfo(socket) == 1 then return true else return false end
	end

	glyphs.opts = {
		type = "group",
		name = L["Glyphs"],
		handler = SetTheory,
		set = "SetActionOption",
		get = "GetActionOption",
		args = {
			actionInstructions = {
				type = "description",
				name = L["Select which glyphs you'd like to apply. You should select a glyph for each slot. This action requires you to press a button for each glyph you wish to apply and should go in an action sequence AFTER any Dual Spec swaps."],
				order = 0,
			},
		}
	}

	local types = {
		Primes = {
			['7'] = 1, 
			['8'] = 1, 
			['9'] = 1,
		},
		Majors = {
			['1'] = 2,
			['4'] = 2,
			['6'] = 2,
		},
		Minors = {
			['2'] = 3,
			['3'] = 3,
			['5'] = 3,
		},
	}

	local order = 10 
	for type, slots in pairs(types) do
		glyphs.opts.args[type] = {
			type = "header",
			name = L[type],
			order = order,
		}

		for k, t in pairs(slots) do 
			order = order + 10
			glyphs.opts.args[k] = {		
				name = "",
				type = "select",
				values = function() return getGlyphs(t) end,
				disabled = function() return not socketEnabled(tonumber(k)) end,
				order = order
			}
		end
	end

	SetTheory:RegisterAction(glyphs)
end
