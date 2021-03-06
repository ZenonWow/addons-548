local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )

--lua api
local _table_remove = table.remove
local _table_insert = table.insert
local _setmetatable = setmetatable
local _table_wipe = table.wipe

local _detalhes = 		_G._detalhes
local gump = 			_detalhes.gump

local combate =			_detalhes.combate
local historico = 			_detalhes.historico
local barra_total =		_detalhes.barra_total
local container_pets =		_detalhes.container_pets
local timeMachine =		_detalhes.timeMachine

function historico:NovoHistorico()
	local esta_tabela = {tabelas = {}}
	_setmetatable (esta_tabela, historico)
	return esta_tabela
end

function historico:adicionar_overall (tabela)
	if (_detalhes.overall_clear_newboss) then
		if (tabela.instance_type == "raid" and tabela.is_boss) then
			if (_detalhes.last_encounter ~= _detalhes.last_encounter2) then
				for index, combat in ipairs (_detalhes.tabela_historico.tabelas) do 
					combat.overall_added = false
				end
				historico:resetar_overall()
			end
		end
	end

	_detalhes.tabela_overall = _detalhes.tabela_overall + tabela
	tabela.overall_added = true
	
	if (_detalhes.tabela_overall.start_time == 0) then
		_detalhes.tabela_overall.start_time = tabela.start_time
		_detalhes.tabela_overall.end_time = tabela.end_time
	end
	
	_detalhes:ClockPluginTickOnSegment()
end

function _detalhes:GetCurrentCombat()
	return _detalhes.tabela_vigente
end
function _detalhes:GetCombatSegments()
	return _detalhes.tabela_historico.tabelas
end

--> sai do combate, chamou adicionar a tabela ao hist�rico
function historico:adicionar (tabela)

	local tamanho = #self.tabelas
	
	--> verifica se precisa dar UnFreeze()
	if (tamanho < _detalhes.segments_amount) then --> vai preencher um novo index vazio
		local ultima_tabela = self.tabelas[tamanho]
		if (not ultima_tabela) then --> n�o ha tabelas no historico, esta ser� a #1
			--> pega a tabela do combate atual
			ultima_tabela = tabela
		end
		_detalhes:InstanciaCallFunction (_detalhes.CheckFreeze, tamanho+1, ultima_tabela)
	end

	--> adiciona no index #1
	_table_insert (self.tabelas, 1, tabela)
	
	local overall_added = false
	
	if (not overall_added and bit.band (_detalhes.overall_flag, 0x1) ~= 0) then --> raid boss - flag 0x1
		if (tabela.is_boss and tabela.instance_type == "raid" and not tabela.is_pvp) then
			overall_added = true
		end
		--print ("0x1")
	end

	if (not overall_added and bit.band (_detalhes.overall_flag, 0x2) ~= 0) then --> raid trash - flag 0x2
		if (tabela.is_trash and tabela.instance_type == "raid") then --check if the player is in a raid
			overall_added = true
		end
		--print ("0x2")
	end
	
	if (not overall_added and bit.band (_detalhes.overall_flag, 0x4) ~= 0) then --> dungeon boss - flag 0x4
		if (tabela.is_boss and tabela.instance_type == "party" and not tabela.is_pvp) then --check if this is a dungeon boss
			overall_added = true
		end
		--print ("0x4")
	end

	if (not overall_added and bit.band (_detalhes.overall_flag, 0x8) ~= 0) then --> dungeon trash - flag 0x8
		if (tabela.is_trash and tabela.instance_type == "party") then --check if the player is in a raid
			overall_added = true
		end
		--print ("0x8")
	end
	
	if (not overall_added and bit.band (_detalhes.overall_flag, 0x10) ~= 0) then --> any combat
		overall_added = true
		--print ("0x10")
	end
	
	if (overall_added) then
		if (_detalhes.debug) then
			_detalhes:Msg ("(debug) overall data flag match with the current combat.")
		end
		if (InCombatLockdown()) then
			_detalhes.schedule_add_to_overall = true
			if (_detalhes.debug) then
				_detalhes:Msg ("(debug) player is in combat, scheduling overall addition.")
			end
		else
			historico:adicionar_overall (tabela)
		end
	end
	
	if (self.tabelas[2]) then
	
		--> fazer limpeza na tabela

		local _segundo_combate = self.tabelas[2]
		
		local container_damage = _segundo_combate [1]
		local container_heal = _segundo_combate [2]
		
		for _, jogador in ipairs (container_damage._ActorTable) do 
			--> remover a tabela de last events
			jogador.last_events_table =  nil
			--> verifica se ele ainda esta registrado na time machine
			if (jogador.timeMachine) then
				jogador:DesregistrarNaTimeMachine()
			end
		end
		for _, jogador in ipairs (container_heal._ActorTable) do 
			--> remover a tabela de last events
			jogador.last_events_table =  nil
			--> verifica se ele ainda esta registrado na time machine
			if (jogador.timeMachine) then
				jogador:DesregistrarNaTimeMachine()
			end
		end
		
		if (_detalhes.trash_auto_remove) then
		
			local _terceiro_combate = self.tabelas[3]
		
			if (_terceiro_combate) then
			
				if (_terceiro_combate.is_trash and not _terceiro_combate.is_boss) then
					--if (_terceiro_combate.overall_added) then
					--	_detalhes.tabela_overall = _detalhes.tabela_overall - _terceiro_combate
					--	print ("removendo combate 1")
					--end
					--> verificar novamente a time machine
					for _, jogador in ipairs (_terceiro_combate [1]._ActorTable) do --> damage
						if (jogador.timeMachine) then
							jogador:DesregistrarNaTimeMachine()
						end
					end
					for _, jogador in ipairs (_terceiro_combate [2]._ActorTable) do --> heal
						if (jogador.timeMachine) then
							jogador:DesregistrarNaTimeMachine()
						end
					end
					--> remover
					_table_remove (self.tabelas, 3)
					_detalhes:SendEvent ("DETAILS_DATA_SEGMENTREMOVED", nil, nil)
				end
				
			end

		end
		
	end

	--> verifica se precisa apagar a �ltima tabela do hist�rico
	if (#self.tabelas > _detalhes.segments_amount) then
		
		local combat_removed = self.tabelas [#self.tabelas]
	
		--> diminuir quantidades no overall
		--if (combat_removed.overall_added) then
		--	_detalhes.tabela_overall = _detalhes.tabela_overall - combat_removed
		--	print ("removendo combate 2")
		--end

		--> verificar novamente a time machine
		for _, jogador in ipairs (combat_removed [1]._ActorTable) do --> damage
			if (jogador.timeMachine) then
				jogador:DesregistrarNaTimeMachine()
			end
		end
		for _, jogador in ipairs (combat_removed [2]._ActorTable) do --> heal
			if (jogador.timeMachine) then
				jogador:DesregistrarNaTimeMachine()
			end
		end
		
		--> remover
		_table_remove (self.tabelas, #self.tabelas)
		_detalhes:SendEvent ("DETAILS_DATA_SEGMENTREMOVED", nil, nil)
		
	end
	
	--> chama a fun��o que ir� atualizar as inst�ncias com segmentos no hist�rico
	_detalhes:InstanciaCallFunction (_detalhes.AtualizaSegmentos_AfterCombat, self)
	
	_detalhes:InstanciaCallFunction (_detalhes.AtualizarJanela)
end

--> verifica se tem alguma instancia congelada mostrando o segmento rec�m liberado
function _detalhes:CheckFreeze (instancia, index_liberado, tabela)
	if (instancia.freezed) then --> esta congelada
		if (instancia.segmento == index_liberado) then
			instancia.showing = tabela
			instancia:UnFreeze()
		end
	end
end

function _detalhes:OverallOptions (reset_new_boss, reset_new_challenge)
	if (reset_new_boss == nil) then
		reset_new_boss = _detalhes.overall_clear_newboss
	end
	if (reset_new_challenge == nil) then
		reset_new_challenge = _detalhes.overall_clear_newchallenge
	end
	
	_detalhes.overall_clear_newboss = reset_new_boss
	_detalhes.overall_clear_newchallenge = reset_new_challenge
end

function historico:resetar_overall()
	if (InCombatLockdown()) then
		_detalhes:Msg (Loc ["STRING_ERASE_IN_COMBAT"])
		_detalhes.schedule_remove_overall = true
	else
		--> fecha a janela de informa��es do jogador
		_detalhes:FechaJanelaInfo()
		
		_detalhes.tabela_overall = combate:NovaTabela()
		
		for index, instancia in ipairs (_detalhes.tabela_instancias) do 
			if (instancia.ativa and instancia.segmento == -1) then
				instancia:InstanceReset()
				instancia:ReajustaGump()
			end
		end
	end
	
	_detalhes:ClockPluginTickOnSegment()
end

function historico:resetar()

	if (_detalhes.bosswindow) then
		_detalhes.bosswindow:Reset()
	end
	
	if (_detalhes.tabela_vigente.verifica_combate) then --> finaliza a checagem se esta ou n�o no combate
		_detalhes:CancelTimer (_detalhes.tabela_vigente.verifica_combate)
	end
	
	--> fecha a janela de informa��es do jogador
	_detalhes:FechaJanelaInfo()
	
	--> empty temporary tables
	_detalhes.atributo_damage:ClearTempTables()
	
	for _, combate in ipairs (_detalhes.tabela_historico.tabelas) do 
		_table_wipe (combate)
	end
	_table_wipe (_detalhes.tabela_vigente)
	_table_wipe (_detalhes.tabela_overall)
	_table_wipe (_detalhes.spellcache)
	
	_detalhes:LimparPets()
	
	-- novo container de historico
	_detalhes.tabela_historico = historico:NovoHistorico() --joga fora a tabela antiga e cria uma nova
	--novo container para armazenar pets
	_detalhes.tabela_pets = _detalhes.container_pets:NovoContainer()
	_detalhes.container_pets:BuscarPets()
	-- nova tabela do overall e current
	_detalhes.tabela_overall = combate:NovaTabela() --joga fora a tabela antiga e cria uma nova
	-- cria nova tabela do combate atual
	_detalhes.tabela_vigente = combate:NovaTabela (nil, _detalhes.tabela_overall)
	
	--marca o addon como fora de combate
	_detalhes.in_combat = false
	--zera o contador de combates
	_detalhes:NumeroCombate (0)
	
	--> limpa o cache de magias
	_detalhes:ClearSpellCache()
	
	--> limpa a tabela de escudos
	_table_wipe (_detalhes.escudos)
	
	--> reinicia a time machine
	timeMachine:Reiniciar()
	
	_table_wipe (_detalhes.cache_damage_group)
	_table_wipe (_detalhes.cache_healing_group)
	_detalhes:UpdateParserGears()

	collectgarbage()
	
	_detalhes:InstanciaCallFunction (_detalhes.AtualizaSegmentos) -- atualiza o instancia.showing para as novas tabelas criadas
	_detalhes:InstanciaCallFunction (_detalhes.AtualizaSoloMode_AfertReset) -- verifica se precisa zerar as tabela da janela solo mode
	_detalhes:InstanciaCallFunction (_detalhes.ResetaGump) --_detalhes:ResetaGump ("de todas as instancias")
	_detalhes:InstanciaCallFunction (gump.Fade, "in", nil, "barras")
	
	_detalhes:AtualizaGumpPrincipal (-1) --atualiza todas as instancias
	
	_detalhes:SendEvent ("DETAILS_DATA_RESET", nil, nil)
end

function _detalhes.refresh:r_historico (este_historico)
	_setmetatable (este_historico, historico)
	--este_historico.__index = historico
end

--[[
		elseif (_detalhes.trash_concatenate) then
			
			if (true) then
				return
			end
			
			if (_terceiro_combate) then
				if (_terceiro_combate.is_trash and _segundo_combate.is_trash and not _terceiro_combate.is_boss and not _segundo_combate.is_boss) then
					--> tabela 2 deve ser deletada e somada a tabela 1
					if (_detalhes.debug) then
						detalhes:Msg ("(debug) concatenating two trash segments.")
					end
					
					_segundo_combate = _segundo_combate + _terceiro_combate
					_detalhes.tabela_overall = _detalhes.tabela_overall - _terceiro_combate
					
					_segundo_combate.is_trash = true

					--> verificar novamente a time machine
					for _, jogador in ipairs (_terceiro_combate [1]._ActorTable) do --> damage
						if (jogador.timeMachine) then
							jogador:DesregistrarNaTimeMachine()
						end
					end
					for _, jogador in ipairs (_terceiro_combate [2]._ActorTable) do --> heal
						if (jogador.timeMachine) then
							jogador:DesregistrarNaTimeMachine()
						end
					end
					--> remover
					_table_remove (self.tabelas, 3)
					_detalhes:SendEvent ("DETAILS_DATA_SEGMENTREMOVED", nil, nil)
				end
			end
--]]