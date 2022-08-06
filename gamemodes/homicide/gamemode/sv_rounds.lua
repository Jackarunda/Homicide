
util.AddNetworkString("SetRound")
util.AddNetworkString("DeclareWinner")
util.AddNetworkString("hmcd_mode")
--util.AddNetworkString("Polizei")

local ForceZombi,ForceJihad=false,false
concommand.Add("homicide_forcejihad",function(ply,cmd,args)
	if((IsValid(ply))and not(ply:IsSuperAdmin()))then return end
	ForceJihad=true
	print("jihad forced for next round")
end)
concommand.Add("homicide_forcezombie",function(ply,cmd,args)
	if((IsValid(ply))and not(ply:IsSuperAdmin()))then return end
	ForceZombi=true
	print("zombies forced for next round")
end)

GM.RoundStage=0
GM.RoundCount=0
if GAMEMODE then
	GM.RoundStage=GAMEMODE.RoundStage
	GM.RoundCount=GAMEMODE.RoundCount
end

function GM:GetRound()
	return self.RoundStage or 0
end

function GM:SetRound(round)
	self.RoundStage=round
	self.RoundTime=CurTime()

	self.RoundSettings={}

	self:NetworkRound()
end

function GM:NetworkRound(ply)
	net.Start("SetRound")
	net.WriteUInt(self.RoundStage,8)
	net.WriteDouble(self.RoundTime or CurTime())
	net.WriteUInt(0,8)
	if(ply==nil)then
		net.Broadcast()
	else
		net.Send(ply)
	end
end

-- 0 not enough players
-- 1 playing
-- 2 round ended, about to restart
-- 4 waiting for map switch
GM.NextForgivenessTime=0
local NextThink=0
function GM:RoundThink()
	if not(NextThink<CurTime())then return end
	NextThink=CurTime()+1
	local players,AllBots=team.GetPlayers(2),true
	for key,ply in pairs(players)do
		if not(ply:IsBot())then AllBots=false break end
	end
	if(AllBots)then
		for key,ply in pairs(players)do ply:Kick() end
		players={}
	end
	if self.RoundStage == 0 then
		if #players > 1 && (!self.LastPlayerSpawn || self.LastPlayerSpawn+1 < CurTime()) then
			self:StartNewRound()
		elseif((#players==1)and(!self.LastPlayerSpawn || self.LastPlayerSpawn+1 < CurTime()))then
			RunConsoleCommand("bot")
			timer.Simple(2,function()
				local PlayersNow=team.GetPlayers(2)
				if(#PlayersNow>1)then
					for key,ply in pairs(PlayersNow)do
						if(ply:IsBot())then ply.AutoSpawnedBot=true break end
					end
				end
			end)
		elseif(#players==0)then
			if(#player.GetAll()>0)then
				for key,ply in pairs(player.GetAll())do
					ply:AddToShitList(-100)
				end
			end
		end
	elseif self.RoundStage == 1 then
		if(self.NextForgivenessTime<CurTime())then
			self.NextForgivenessTime=CurTime()+10
			for id,shit in pairs(self.SHITLIST)do
				self.SHITLIST[id]=math.Clamp(shit-self.ForgivenessRate,0,100000)
			end
		end
		if(#players>2)then
			for key,playa in pairs(players)do
				if((playa:IsBot())and(playa.AutoSpawnedBot))then
					playa:Kick()
				end
			end
		end
		if self.RoundUnFreezePlayers && self.RoundUnFreezePlayers < CurTime() then
			self.RoundUnFreezePlayers=nil
			for k, ply in pairs(players) do
				if ply:Alive() then
					ply:Freeze(false)
					ply.Frozen=false
				end
			end
		end
		if((self.ForceRoundEndTime<CurTime())and not(self.DEATHMATCH))then
			if not(self.MurdererLastKill)then self.MurdererLastKill=CurTime() end
			if((self.MurdererLastKill+100)<CurTime())then
				local murderer
				for key,ply in pairs(player.GetAll())do
					if(ply.Murderer)then murderer=ply break end
				end
				self:EndTheRound(4,murderer)
				return
			end
		end
		if !self.RoundLastDeath || self.RoundLastDeath < CurTime() then
			self:RoundCheckForWin()
		end
	elseif self.RoundStage == 2 then
		if self.RoundTime+5 < CurTime() then
			self:StartNewRound()
		end
	end
end

function GM:RoundCheckForWin()
	local murderer
	local players=team.GetPlayers(2)
	if #players <= 0 then
		self:SetRound(0)
		return
	end
	local survivors={}
	for k,v in pairs(players) do
		if v:Alive() && !v.Murderer then
			table.insert(survivors, v)
		end
		if v.Murderer then
			murderer=v
		end
	end
	
	if(self.DEATHMATCH)then
		if(#survivors<1)then
			self:EndTheRound(6,nil)
		elseif(#survivors==1)then
			self.HeroPlayer=survivors[1]
			self:EndTheRound(5,survivors[1])
		end
		return
	end

	-- check we have a murderer
	if !IsValid(murderer) then
		self:EndTheRound(3, murderer)
		return
	end

	-- has the murderer killed everyone?
	if #survivors < 1 then
		self:EndTheRound(1, murderer)
		return
	end

	-- is the murderer dead?
	if !murderer:Alive() then
		self:EndTheRound(2, murderer)
		return
	end

	-- keep playing.
end


function GM:DoRoundDeaths(dead, attacker)
	if self.RoundStage == 1 then
		self.RoundLastDeath=CurTime()+2
	end
end

-- 1 Murderer wins
-- 2 Murderer loses
-- 3 Murderer rage quit
-- 4 Murderer became a not-murderer
-- 5 deathmatch: last man standing
-- 6 deathmatch: everyone dead
-- 7 deathmatch: time up
function GM:EndTheRound(reason, murderer)
	if self.RoundStage != 1 then return end

	local players=team.GetPlayers(2)
	for k, ply in pairs(players) do
		ply:UnMurdererDisguise()
		ply:SetFOV(90,0)
	end

	if(reason==4)then
		if murderer then
			local col=murderer:GetPlayerColor()
			local msgs
			if(self.SHTF)then
				msgs=Translator:AdvVarTranslate("The murderer lost the will to murder, it was {murderer}.\nEveryone lived happily ever after.", {
					murderer={text=murderer:Nick() .. ", " .. murderer:GetBystanderName(), color=Color(col.x*255, col.y*255, col.z*255)}
				})
			else
				msgs=Translator:AdvVarTranslate("The traitor lost the will to murder, it was {murderer}.\nEveryone lived happily ever after.", {
					murderer={text=murderer:Nick() .. ", " .. murderer:GetBystanderName(), color=Color(col.x*255, col.y*255, col.z*255)}
				})
			end
			local ct=ChatText(msgs)
			ct:SendAll()
		else
			local ct=ChatText()
			ct:Add(translate.murdererDisconnect)
			ct:SendAll()
		end
	elseif reason == 3 then
		if murderer then
			local col=murderer:GetPlayerColor()
			local msgs
			if(self.SHTF)then
				msgs=Translator:AdvVarTranslate("The traitor rage quit, it was {murderer}", {
					murderer={text=murderer:Nick() .. ", " .. murderer:GetBystanderName(), color=Color(col.x*255, col.y*255, col.z*255)}
				})
			else
				msgs=Translator:AdvVarTranslate(translate.murdererDisconnectKnown, {
					murderer={text=murderer:Nick() .. ", " .. murderer:GetBystanderName(), color=Color(col.x*255, col.y*255, col.z*255)}
				})
			end
			local ct=ChatText(msgs)
			ct:SendAll()
			-- ct:Add(", it was ")
			-- ct:Add(murderer:Nick() .. ", " .. murderer:GetBystanderName(), Color(col.x*255, col.y*255, col.z*255))
		else
			if(self.SHTF)then
				local ct=ChatText()
				ct:Add("The traitor rage quit")
				ct:SendAll()
			else
				local ct=ChatText()
				ct:Add(translate.murdererDisconnect)
				ct:SendAll()
			end
		end
	elseif reason == 2 then
		local col=murderer:GetPlayerColor()
		local msgs,RealName,GameName=nil,murderer:Nick(),murderer:GetBystanderName()
		if(RealName==GameName)then
			if(self.SHTF)then
				msgs=Translator:AdvVarTranslate("The traitor was, {murderer}",{
					murderer={text=GameName, color=Color(col.x*255, col.y*255, col.z*255)}
				})
			else
				msgs=Translator:AdvVarTranslate(translate.winBystandersMurdererWas, {
					murderer={text=GameName, color=Color(col.x*255, col.y*255, col.z*255)}
				})
			end
		else
			if(self.SHTF)then
				msgs=Translator:AdvVarTranslate("The traitor was {murderer}", {
					murderer={text=RealName .. ", " .. GameName, color=Color(col.x*255, col.y*255, col.z*255)}
				})
			else
				msgs=Translator:AdvVarTranslate(translate.winBystandersMurdererWas, {
					murderer={text=RealName .. ", " .. GameName, color=Color(col.x*255, col.y*255, col.z*255)}
				})
			end
		end
		local ct=ChatText()
		if(self.SHTF)then
			ct:Add("Innocents win! ", Color(20, 120, 255))
		else
			ct:Add(translate.winBystanders, Color(20, 120, 255))
		end
		ct:AddParts(msgs)
		ct:SendAll()
		self.BystanderWins=self.BystanderWins+1
	elseif reason == 1 then
		murderer:AddMerit(1)
		local col=murderer:GetPlayerColor()
		local msgs,RealName,GameName=nil,murderer:Nick(),murderer:GetBystanderName()
		if(RealName==GameName)then
			msgs=Translator:AdvVarTranslate(translate.winMurdererMurdererWas, {
				murderer={text=GameName, color=Color(col.x*255, col.y*255, col.z*255)}
			})
		else
			msgs=Translator:AdvVarTranslate(translate.winMurdererMurdererWas, {
				murderer={text=RealName .. ", " .. GameName, color=Color(col.x*255, col.y*255, col.z*255)}
			})
		end
		local ct=ChatText()
		if(self.ZOMBIE)then
			ct:Add("The zombies win!", Color(190, 20, 20))
		elseif(self.SHTF)then
			ct:Add("The traitor wins!", Color(190, 20, 20))
		else
			ct:Add(translate.winMurderer, Color(190, 20, 20))
		end
		ct:AddParts(msgs)
		ct:SendAll()
		self.MurdererWins=self.MurdererWins+1
	elseif(reason==5)then
		murderer:AddMerit(5)
		local col=murderer:GetPlayerColor()
		local msgs,RealName,GameName=nil,murderer:Nick(),murderer:GetBystanderName()
		msgs=Translator:AdvVarTranslate("{murderer} wins!", {
			murderer={text=GameName, color=Color(col.x*255, col.y*255, col.z*255)}
		})
		local ct=ChatText()
		ct:AddParts(msgs)
		ct:SendAll()
	elseif(reason==6)then
		msgs=Translator:AdvVarTranslate("Everyone died. The end",{})
		local ct=ChatText()
		ct:AddParts(msgs)
		ct:SendAll()
	elseif(reason==7)then
		msgs=Translator:AdvVarTranslate("Match over, time up",{})
		local ct=ChatText()
		ct:AddParts(msgs)
		ct:SendAll()
	end

	self:SetRound(2)
	net.Start("DeclareWinner")
	net.WriteUInt(reason, 8)
	net.WriteEntity(self.HeroPlayer or Entity(0))
	if murderer then
		net.WriteEntity(murderer)
		if(murderer.MurdererIdentityHidden)then
			net.WriteVector(murderer.TrueIdentity[7])
			net.WriteString(murderer.TrueIdentity[5])
		else
			net.WriteVector(murderer:GetPlayerColor())
			net.WriteString(murderer:GetBystanderName())
		end
	else
		net.WriteEntity(Entity(0))
		net.WriteVector(Vector(1, 1, 1))
		net.WriteString("?")
	end

	for k, ply in pairs(team.GetPlayers(2)) do
		net.WriteUInt(1, 8)
		net.WriteEntity(ply)
		net.WriteUInt(ply.LootCollected, 32)
		net.WriteVector(ply:GetPlayerColor())
		net.WriteString(ply:GetBystanderName())
		if(ply.GetAwardStats)then
			local ME,DM,XP=ply:GetAwardStats()
			net.WriteFloat(ME)
			net.WriteFloat(DM)
			net.WriteFloat(XP)
		else
			net.WriteFloat(0)
			net.WriteFloat(0)
			net.WriteFloat(0)
		end
	end
	net.WriteUInt(0, 8)

	net.Broadcast()

	for k, ply in pairs(players) do
		if((!ply.HasMoved && !ply.Frozen))then
			local oldTeam=ply:Team()
			ply:SetTeam(1)
			GAMEMODE:PlayerOnChangeTeam(ply, 1, oldTeam)

			local col=ply:GetPlayerColor()
			local msgs=Translator:AdvVarTranslate(translate.teamMoved, {
				player={text=ply:Nick(), color=Color(col.x*255, col.y*255, col.z*255)},
				team={text=team.GetName(1), color=team.GetColor(2)}
			})
			local ct=ChatText()
			ct:AddParts(msgs)
			ct:SendAll()
		end
		if ply:Alive() then
			ply:Freeze(false)
			ply.Frozen=false
		end
	end
	self.RoundUnFreezePlayers=nil

	self.MurdererLastKill=nil

	hook.Call("OnEndRound")
	self.RoundCount=self.RoundCount+1
	local limit=self.RoundLimit:GetInt()
	if limit > 0 then
		if self.RoundCount >= limit then
			self:ChangeMap()
			self:SetRound(4)
			return
		end
	end
	
	print("Homicide balance reporting: murderer "..tostring(self.MurdererWins).." bystanders "..tostring(self.BystanderWins))
	
	for key,playa in pairs(player.GetAll())do
		local Record=self.SHITLIST[playa:SteamID()] or 0
		if((playa.Innocent)and(Record>self.BonusForgiveness))then
			playa:AddToShitList(-self.BonusForgiveness)
		end
		if(Record>GAMEMODE.KickbanPunishmentThreshold)then
			playa:KickForTeamKilling()
		end
	end
end

function GM:StartNewRound()
	self.PUSSY_MODE_ENGAGED=false
	self.EPIC_MODE_ENGAGED=false
	self.ISLAM_MODE_ENGAGED=false
	self.DEATHMATCH_MODE_ENGAGED=false
	self.ZOMBIE_MODE_ENGAGED=false
	if not(self.SHTF_MODE_ENGAGED)then
		if(math.random(1,7)==2)then
			self.PUSSY_MODE_ENGAGED=true
		elseif(math.random(1,5)==2)then
			if(math.random(1,2)==1)then
				self.ISLAM_MODE_ENGAGED=true
			else
				self.EPIC_MODE_ENGAGED=true
			end
		end
		if(ForceJihad)then
			ForceJihad=false
			self.PUSSY_MODE_ENGAGED=false
			self.ISLAM_MODE_ENGAGED=true
			self.EPIC_MODE_ENGAGED=false
		end
	else
		if(math.random(1,8)==3)then
			self.DEATHMATCH_MODE_ENGAGED=true
		else
			local Chance=.8
			if(string.find(game.GetMap(),"zs_"))then Chance=.4 end
			if(math.Rand(0,1)>Chance)then
				if(self.EnoughAINodes)then
					self.ZOMBIE_MODE_ENGAGED=true
				else
					print("Homicide: map does not have enough AI nodes for Zombie Outbreak")
				end
			end
		end
		if(ForceZombi)then
			ForceZombi=false
			self.DEATHMATCH_MODE_ENGAGED=false
			self.ZOMBIE_MODE_ENGAGED=true
		end
	end
	self.ZombiesLeft=#team.GetPlayers(2)*60
	self:RoundModeCheck()
	
	if not(self.RoundNumber)then self.RoundNumber=0 end
	self.RoundNumber=self.RoundNumber+1
	
	local players=team.GetPlayers(2)
	if #players <= 1 then 
		local ct=ChatText()
		ct:Add(translate.minimumPlayers, Color(255, 150, 50))
		ct:SendAll()
		self:SetRound(0)
		return
	end

	local ct,DaText=ChatText(),translate.roundStarted
	if(GetConVar("sv_cheats"):GetInt()==1)then DaText=DaText.."\nWARNING: teamkill penalties are disabled!" end
	ct:Add(DaText)
	ct:SendAll()

	self.HeroPlayer=nil
	self.VillainPlayer=nil
	
	self:SetRound(1)
	self.RoundUnFreezePlayers=CurTime()+10

	local players=team.GetPlayers(2)
	for k,ply in pairs(players) do
		ply:UnSpectate()
	end
	game.CleanUpMap()
	self:InitPostEntityAndMapCleanup()
	self:ClearAllFootsteps()
	
	for k, ply in pairs(players) do
		ply:SetMurderer(false)
		ply.ArmedAtSpawn=false
		ply.HMCD_MarkedForDeath=false
		ply:KillSilent()
		ply:Freeze(true)
		if not((ply.CustomName)and(ply.CustomModel)and(ply.CustomColor)and(ply.CustomUpperBody)and(ply.CustomCoreBody)and(ply.CustomLowerBody)and(ply.CustomClothes))then
			umsg.Start("HMCD_Identity",ply)
			umsg.End()
		end

		ply.LootCollected=0
		ply.HasMoved=false
		ply.Frozen=true
	end
	
	-- pick the roles
	local rand=WeightedRandom()
	local murderer,gunman=rand:Roll()
	if(murderer)then murderer:SetMurderer(true) end
	if(gunman)then gunman.ArmedAtSpawn=true end

	self.MurdererLastKill=CurTime()
	
	for key,playah in pairs(player.GetAll())do
		playah.StartedRoundAsTeam=playah:Team()
	end
	
	local Minutes=math.ceil(2+(#team.GetPlayers(2)*1))
	if(self.PUSSY)then Minutes=Minutes/2 elseif(self.EPIC)then Minutes=Minutes*2 elseif(self.ZOMBIE)then Minutes=Minutes*2 end
	self.PoliceTime=CurTime()+(Minutes*60)
	self.DeathmatchEndTime=CurTime()+(Minutes*60*2)
	self.PoliceNotified=false
	self.ForceRoundEndTime=CurTime()+(Minutes*90)
	
	for key,dude in pairs(team.GetPlayers(2))do
		dude:Spawn()
		dude:GenerateClothes()
		dude:GenerateBystanderName()
		dude:GenerateBody()
		dude:GenerateColor()
		dude:GenerateAccessories()
		
		if not((dude.ArmedAtSpawn)or(dude.Murderer))then
			local Record=self.SHITLIST[dude:SteamID()] or 0
			if(Record>self.GodPunishmentThreshold)then
				dude.HMCD_MarkedForDeath=true
			end
		end
		
		if((self.ZOMBIE)and(dude.Murderer))then
			dude:SetBystanderName("Alpha Zombie")
			dude:SetPlayerColor(Vector(.5,0,0))
		end
	end
	
	self:CreateFirstVictim()

	hook.Call("OnStartRound")
end

function GM:RoundModeCheck()
	if(self.SHTF_MODE_ENGAGED)then
		self.SHTF=true
		self.PUSSY=false
		self.EPIC=false
		self.ISLAM=false
		self.ZOMBIE=self.ZOMBIE_MODE_ENGAGED
		self.DEATHMATCH=self.DEATHMATCH_MODE_ENGAGED
	else
		self.SHTF=false
		self.DEATHMATCH=false
		self.PUSSY=self.PUSSY_MODE_ENGAGED
		self.ISLAM=self.ISLAM_MODE_ENGAGED
		self.EPIC=self.EPIC_MODE_ENGAGED
	end
	net.Start("hmcd_mode")
	net.WriteBit(self.SHTF)
	net.WriteBit(self.PUSSY)
	net.WriteBit(self.ISLAM)
	net.WriteBit(self.EPIC)
	net.WriteBit(self.DEATHMATCH)
	net.WriteBit(self.ZOMBIE)
	net.Broadcast()
end

function GM:PlayerLeavePlay(ply)
	if ply:HasWeapon("wep_jack_hmcd_smallpistol") then
		ply:DropWeapon(ply:GetWeapon("wep_jack_hmcd_smallpistol"))
	end
	if self.RoundStage == 1 then
		if ply.Murderer then
			self:EndTheRound(3, ply)
		end
	end
end

--[[
concommand.Add("mu_forcenextmurderer", function (ply, com, args)
	if !ply:IsAdmin() then return end
	if #args < 1 then return end

	local ent=Entity(tonumber(args[1]) or -1)
	if !IsValid(ent) || !ent:IsPlayer() then 
		ply:ChatPrint("not a player")
		return 
	end

	GAMEMODE.ForceNextMurderer=ent
	local msgs=Translator:AdvVarTranslate(translate.adminMurdererSelect, {
		player={text=ent:Nick(), color=team.GetColor(2)}
	})
	local ct=ChatText()
	ct:AddParts(msgs)
	ct:Send(ply)
end)
--]]

function GM:ChangeMap()
	if #self.MapList > 0 then
		if MapVote then
			// only match maps that we have specified
			local prefix={}
			for k, map in pairs(self.MapList) do
				table.insert(prefix, map .. "%.bsp$")
			end
			MapVote.Start(nil, nil, nil, prefix)
			return
		end
		self:RotateMap()
	end
end

function GM:RotateMap()
	local map=game.GetMap()
	local index 
	for k, map2 in pairs(self.MapList) do
		if map == map2 then
			index=k
		end
	end
	if !index then index=1 end
	index=index+1
	if index > #self.MapList then
		index=1
	end
	local nextMap=self.MapList[index]
	print("[Homicide] Rotate changing map to " .. nextMap)
	local ct=ChatText()
	ct:Add(Translator:QuickVar(translate.mapChange, "map", nextMap))
	ct:SendAll()
	hook.Call("OnChangeMap", GAMEMODE)
	timer.Simple(5, function ()
		RunConsoleCommand("changelevel", nextMap)
	end)
end

GM.MapList={}

local defaultMapList={
	"clue",
	"cs_italy",
	"ttt_clue",
	"cs_office",
	"de_chateau",
	"de_tides",
	"de_prodigy",
	"mu_nightmare_church",
	"dm_lockdown",
	"housewithgardenv2",
	"de_forest"
}

function GM:SaveMapList()
	local txt=""
	for k, map in pairs(self.MapList) do
		txt=txt .. map .. "\r\n"
	end
	file.Write("homicide_maplist.txt", txt)
end

function GM:LoadMapList() 
	local jason=file.ReadDataAndContent("homicide_maplist.txt")
	if jason then
		local tbl={}
		local i=1
		for map in jason:gmatch("[^\r\n]+") do
			table.insert(tbl, map)
		end
		self.MapList=tbl
	else
		local tbl={}
		for k, map in pairs(defaultMapList) do
			if file.Exists("maps/" .. map .. ".bsp", "GAME") then
				table.insert(tbl, map)
			end
		end
		self.MapList=tbl
		self:SaveMapList()
	end
end
