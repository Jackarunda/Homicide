
local WRandom={}
WRandom.__index=WRandom

function WeightedRandom()
	local tab={}
	setmetatable(tab,WRandom)
	return tab
end

function WRandom:FindSetDefaultAverages() -- this initializes any new players with the current averages
	local playas=player.GetAll()
	local KillaAvg,GunnaAvg,NumPlayas=0,0,#playas -- starting them off with equal chances as those who have been playing
	for key,playa in pairs(playas)do
		GunnaAvg=GunnaAvg+(playa.GunnaChance or 0)
		KillaAvg=KillaAvg+(playa.KillaChance or 0)
	end
	GunnaAvg=math.ceil(GunnaAvg/NumPlayas) or 0
	KillaAvg=math.ceil(KillaAvg/NumPlayas) or 0
	for key,playa in pairs(player.GetAll())do -- likewise update the numbers to average for those who aren't playing
		if((not(playa.GunnaChance))or(playa:Team()!=2))then playa.GunnaChance=GunnaAvg end
		if((not(playa.KillaChance))or(playa:Team()!=2))then playa.KillaChance=KillaAvg end
	end
end

function WRandom:Roll() -- now dis is some magic shit hier, son
	local Playas,PotentialKillas,PotentialGunnas,Killa,Gunna=team.GetPlayers(2),{},{},0,nil,nil
	self:FindSetDefaultAverages()
	for key,playa in pairs(Playas)do
		local Record=GAMEMODE.SHITLIST[playa:SteamID()] or 0
		if(GetConVar("sv_cheats"):GetInt()=="1")then Record=0 end
		if((Record<GAMEMODE.GimpPunishmentThreshold)or(GetConVar("sv_cheats"):GetInt()=="1"))then
			for i=1,playa.KillaChance do table.insert(PotentialKillas,playa) end
		end
	end
	Killa=table.Random(PotentialKillas)
	if((SERVER)and(HMCD_DebugPrint))then print("killer is "..tostring(Killa)) end
	for key,playa in pairs(Playas)do
		local Record=GAMEMODE.SHITLIST[playa:SteamID()] or 0
		if not(((Record>=GAMEMODE.GimpPunishmentThreshold)and(GetConVar("sv_cheats"):GetInt()=="0"))or(playa==Killa))then
			for i=1,playa.GunnaChance do table.insert(PotentialGunnas,playa) end
		end
	end
	Gunna=table.Random(PotentialGunnas)
	if((SERVER)and(HMCD_DebugPrint))then print("gunner is "..tostring(Gunna)) end
	if not(Killa)then print("Homicide: murderer selection failed!");Killa=Playas[1] end
	if not(Gunna)then print("Homicide: gunman selection failed!");Gunna=Playas[2] end
	if((GAMEMODE.PUSSY)or(GAMEMODE.EPIC)or(GAMEMODE.DEATHMATCH))then Gunna=nil end
	if(GAMEMODE.DEATHMATCH)then Killa=nil end
	for key,playa in pairs(Playas)do
		if(playa==Killa)then
			playa.KillaChance=1
		else
			playa.KillaChance=playa.KillaChance+1
		end
		if((Gunna)and(playa==Gunna))then
			playa.GunnaChance=1
		else
			playa.GunnaChance=playa.GunnaChance+1
		end
		local Record=GAMEMODE.SHITLIST[playa:SteamID()] or 0
		if((Record>=GAMEMODE.GimpPunishmentThreshold)and(GetConVar("sv_cheats"):GetInt()==0))then
			playa:PrintMessage(HUD_PRINTTALK,"Your guilt is at "..math.Round((Record/GAMEMODE.KickbanPunishmentThreshold)*100).."%. Keep RDMing and you'll be banned.")
			playa.KillaChance=1
			playa.GunnaChance=1
		end
	end
	return Killa,Gunna
end

-- local murds=WeightedRandom()
-- murds:Add(1 ^ 3, "jim")
-- murds:Add(3 ^ 3, "john")
-- murds:Add(6 ^ 3, "peter")

-- local tab={}
-- for i=0, 1000 do
-- 	local p=murds:Roll()
-- 	tab[p]=(tab[p] or 0)+1
-- end
-- for k,v in pairs(tab) do
-- 	print(k, math.Round(v/1000*10))
-- end
