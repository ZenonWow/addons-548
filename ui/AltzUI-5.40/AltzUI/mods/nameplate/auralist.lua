local T, C, L, G = unpack(select(2, ...))

G.BuffWhiteList = {
	--druid
	-- OLD
	[61336] = true, -- ��������
	[29166] = false, -- ����
	[22812] = true, -- ��Ƥ�g
	--[132158] = "naturesSwiftness", -- ��ȻѸ��
	--[16689] = "naturesGrasp", -- ��Ȼ֮��
	[22842] = true, -- �񱩻֏�
	--[5229] = "enrage", -- ��ŭ
	[1850] = true, -- ����
	[50334] = true, -- ��
	--[69369] = "predatorSwiftness", -- PredatorSwiftness �ͫFѸ��
	--[102280] = "displacerBeast", 
	--Mist of Pandaria
	--[124974] = true,
	--[112071] = "celestialAlignment",
	--[102342] = true,--��Ƥ
	--[110575] = "sIcebound",
	--[110570] = "sAntiMagicShell", 
	--[110617] = "sDeterrance", 
	--[110696] = "sIceBlock", 
	--[110700] = "sDivineShield", 
	--[110717] = "sFearWard", 
	--[110806] = "sSpiritWalkersGrace", 
	--[122291] = "sUnendingResolve", 
	--[110715] = "sDispersion", 
	--[110788] = "sCloakOfShadows", 
	--[126456] = "sFortifyingBrew", 
	--[126453] = "sElusiveBrew", 
	--paladin
	-- OLD
	[31821] = true, -- ��h��ͨ
	[1022] = true, -- ���o
	[1044] = true, -- ����
	[642] = true, -- �o��
	[6940] = true, -- ����ף��
	--[54428] = "divinePlea", -- ��������
	--[85696] = "zealotry", -- ��ᾫ�� rimosso/removed
	[31884] = true,--���
	-- Mist of pandaria
	--[114163] = "eternalFlame",
	--[20925] ="sacredShield",
	[114039] = true, --����֮��
	[105809] = true,--����
	[114917] = true, --
	[113075] = true,
	[85499]= true,--����
	--rogue
	-- OLD
	[51713] = true, -- ��Ӱ֮��
	[2983] = true, -- ����
	[31224] = true, -- ����
	[13750] = true, -- �n��
	[5277] = true, -- �W��
	[74001] = true, -- ���Y�;w
	--[121471] = "shadowBlades",
	-- Mist of pandaria
	--[114018] = "shroudOfConcealment",
	--warrior
	-- OLD
	[55694] = true, -- ��ŭ�֏�
	[871] = true, --�܉�
	[18499] = true, -- ��֮ŭ
	-- [20230] = "retaliation", -- �����L�� rimosso/removed
	[23920] = true, -- �ܷ�
	--[12328] = "sweepingStrikes", -- �M�߹���
	--[46924] = "bladestorm", -- �����L��
	[85730] = true, -- �������C
	[1719] = true, -- ��ç
	-- Mist of pandaria
	[114028] = true, --Ⱥ�巴��
	[114029] = "safeguard",
	[114030] = "vigilance",
	[107574] = true,--�����·�
	[12292] = true, -- old death wish
	--[112048] = "shieldBarrier",
	--preist
	-- OLD
	[33206] = true, -- ʹ������
	[37274] = true, -- ������ע
	[6346] = true, -- ����
	[47585] = true, -- ��ɢ
	[89485] = true, -- ���`��ע
	--[87153] = "darkArchangel", rimosso/reomved
	[81700] = "archangel",
	[47788] = true,--���
	-- Mist of pandaria
	--[112833] = "spectralGuise",
	[10060] = true,--������ע
	--[109964] = "spiritShell",
	--[81209] = "chakraChastise",
	--[81206] = "chakraSanctuary",
	--[81208] = "chakraSerenity",
	--shaman
	-- OLD
	--[52127] = "waterShield", -- ˮ��
	[30823] = true, -- �_�M֮ŭ
	[974] = true, -- ���֮��
	[16188] = true, -- ��ȻѸ��
	[79206] = true, --�ƶ�ʩ��
	[16166] = true, --Ԫ������
	[8178] = true,--����
	-- Mist of pandaria
	[114050] = true,
	[114051] = true,
	[114052] = true,
	--mage
	-- OLD
	[45438] = true, -- ��������
	[12042] = true, -- ��ǿ
	[12472] = true, --���}
	-- Mist of pandaria
	[12043] = true,--����
	[108839] = true,
	[110909] = true,--ʱ��ٿ�
	--dk
	-- OLD
	[49039] = true, -- ����֮�|
	[48792] = true, -- ����
	[55233] = true, -- Ѫ��֮��
	[49016] = true, -- а�����
	[51271] = true, --��˪֮
	[48707] = true,
	-- Mist of pandaria
	[115989] = true,
	[113072] = true,
	--hunter
	-- OLD
	[34471] = true, -- �F��
	[19263] = true, -- ����
	[3045] = true,
	[54216] = true,--�����ٻ�
	-- Mist of pandaria
	[113073] = true, 
	--lock
	-- Mist of pandaria
	[108416] = true,
	[108503] = true,
	[119049] = true,
	[113858] = true,
	[113861] = true,
	[113860] = true,
	[104773] = true,
	--monk
	-- Mist of pandaria
	[122278] = true,
	[122783] = true,
	[120954] = true,
	[115176] = true,
	[115213] = true,
	[116849] = true,
	[113306] = true,
	--[115294] = "manaTea",
	[108359] = true,
}

G.DebuffWhiteList = {
	[78675] = true, -- ̫ꖹ���
	[108194] = true,-- ��Ϣ
	[47481] =true, -- �У�ʳʬ��
	[91797] =true, -- �����ػ�������ʳʬ��
	[47476] =true, -- ��ɱ
	[126458] =true, -- ������������
	[5211] =true, -- ǿ���ػ�
	[33786] =true, -- ����
	[81261] =true, -- ̫������
	[19386] =true, -- ��������
	[34490] =true, -- ��Ĭ���
	[5116] =true, -- �����
	[61394] =true, -- �����������
	[4167] =true, -- ���磨֩�룩
	[44572] =true, -- ��ȶ���
	[55021] =true, -- ��Ĭ - ǿ����������
	[31661] =true, -- ��֮��Ϣ
	[118] =true, -- ����
	[82691] =true, -- ˪֮��
	[105421] =true, -- äĿ֮��
	[115752] =true, -- ����äĿ֮�⣨�磩
	[105593] =true, -- ����֮ȭ
	[853] =true, -- �Ʋ�֮��
	[20066] =true, -- ���
	[605] =true, -- ��������
	[64044] =true, -- ����ֲ�Ƭ
	[8122] =true, -- �����Х
	[9484] =true, -- ��������
	[87204] =true, -- ���뷣
	[15487] =true, -- ��Ĭ
	[2094] =true, -- ä
	[64058] =true, -- ����ֻ�
	[76577] =true, --����
	[6770] =true, -- SAP
	[1330] =true, -- �ʺ� - ��Ĭ
	[51722] =true, -- ���
	[118905] =true, -- ����
	[5782] =true, -- �־�
	[5484] =true, -- �־庿��
	[6358] =true, -- �ջ���ħ��
	[30283] =true, -- ��Ӱ֮ŭ
	[24259] =true, --��������������Ȯ��
	[31117] =true, -- ʹ���޳�
	[5246] =true, -- �Ƶ�ŭ��
	[46968] =true, --�����
	[18498] =true, -- ��Ĭ - GAG����
	[676] =true, -- ���
	[20549] =true, -- ս����̤
	[25046] =true, -- ��������
}

G.DebuffBlackList = {
	[15407] = true, -- �������
}