AddCSLuaFile("shared.lua")
AddCSLuaFile("sh_translate.lua")
AddCSLuaFile("weightedrandom.lua")
AddCSLuaFile("cl_scoreboard.lua")
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("cl_footsteps.lua")
AddCSLuaFile("cl_respawn.lua")
AddCSLuaFile("cl_murderer.lua")
AddCSLuaFile("cl_player.lua")
AddCSLuaFile("cl_fixplayercolor.lua")
AddCSLuaFile("cl_ragdoll.lua")
AddCSLuaFile("cl_chattext.lua")
AddCSLuaFile("cl_voicepanels.lua")
AddCSLuaFile("cl_rounds.lua")
AddCSLuaFile("cl_endroundboard.lua")
AddCSLuaFile("cl_qmenu.lua")
AddCSLuaFile("cl_spectate.lua")
AddCSLuaFile("cl_adminpanel.lua")
AddCSLuaFile("cl_flashlight.lua")
AddCSLuaFile("cl_fixemitters.lua")

include("sh_translate.lua")
include("shared.lua")
include("weightedrandom.lua")
include("weightedrandom.lua")
include("sv_player.lua")
include("sv_spectate.lua")
include("sv_spawns.lua")
include("sv_ragdoll.lua")
include("sv_respawn.lua")
include("sv_murderer.lua")
include("sv_rounds.lua")
include("sv_footsteps.lua")
include("sv_chattext.lua")
include("sv_loot.lua")
include("sv_taunt.lua")
include("sv_bystandername.lua")
include("sv_adminpanel.lua")
include("sv_tker.lua")
include("sv_flashlight.lua")
include("sv_resources.lua")

GM.RoundLimit = CreateConVar("hmcd_roundlimit", 0, bit.bor(FCVAR_NOTIFY), "Number of rounds we should play before map change" )
GM.Language = CreateConVar("hmcd_language", "", bit.bor(FCVAR_NOTIFY), "The language Murder should use" )
GM.MurdererWins=0
GM.BystanderWins=0
GM.SHTF_MODE_ENGAGED=GM.SHTF_MODE_ENGAGED or false
GM.PUSSY_MODE_ENGAGED=GM.PUSSY_MODE_ENGAGED or false
GM.ISLAM_MODE_ENGAGED=GM.ISLAM_MODE_ENGAGED or false
GM.EPIC_MODE_ENGAGED=GM.EPIC_MODE_ENGAGED or false
GM.DEATHMATCH_MODE_ENGAGED=GM.DEATHMATCH_MODE_ENGAGED or false
GM.ZOMBIE_MODE_ENGAGED=GM.ZOMBIE_MODE_ENGAGED or false
GM.SHTF=GM.SHTF or false
GM.PUSSY=GM.PUSSY or false
GM.ISLAM=GM.ISLAM or false
GM.EPIC=GM.EPIC or false
GM.ZOMBIE=GM.ZOMBIE or false
GM.DEATHMATCH=GM.DEATHMATCH or false
GM.EnoughAINodes=GM.EnoughAINodes or false
GM.SHTF_Specified=false
GM.ZombiesLeft=0
GM.SHITLIST={}
GM.GimpPunishmentThreshold=50
GM.GodPunishmentThreshold=75
GM.KickbanPunishmentThreshold=200
GM.InstantPunishmentThreshold=350
GM.ForgivenessRate=1 -- every ten seconds
GM.BonusForgiveness=40 -- if you still have your innocence at the end of the round, get bonus forgiveness
GM.HeroPlayer=nil
GM.VillainPlayer=nil
GM.PLAYER_SPEED_MUL=1
GM.LOOT_SPAWN_MUL=1

HMCD_DebugPrint=false

util.AddNetworkString("hmcd_tempspeedmul")
util.AddNetworkString("hmcd_hudhalo")
--util.AddNetworkString("hmcd_help")
util.AddNetworkString("hmcd_legsreset")
util.AddNetworkString("hmcd_player_accessory")
util.AddNetworkString("hmcd_innocence")
util.AddNetworkString("hmcd_noscopeaberration")
util.AddNetworkString("hmcd_painvision")
util.AddNetworkString("hmcd_seizure")
util.AddNetworkString("hmcd_forgive")

local function HOMICIDE_DEBUG(ply,cmd,args)
	--[[
	local Pos=player.GetAll()[1]:GetPos()
	for key,ply in pairs(player.GetAll())do ply:SetPos(Pos+Vector(math.random(0,500),math.random(0,500),10)) end
	--]]
	umsg.Start("HOMICIDE_DEBUG")
	umsg.End()
end
concommand.Add("HOMICIDE_DEBUG",HOMICIDE_DEBUG)

local function ThesePeopleAreFuckingIdiots(ply,cmd,args)
	net.Start("hmcd_noscopeaberration")
	net.Send(ply)
	print(ply:Nick().." "..ply:SteamID().." has disabled scope aberration.")
end
concommand.Add("homicide_scope_fix",ThesePeopleAreFuckingIdiots)

local function ChangeDebugPrinting(ply,cmd,args)
	if((ply.IsAdmin)and not(ply:IsAdmin()))then ply:PrintMessage(HUD_PRINTTALK,translate.youAreNoAdmin) return end
	if(args[1]=="1")then
		HMCD_DebugPrint=true
	elseif(args[1]=="0")then
		HMCD_DebugPrint=false
	end
	print("Homicide debug printing toggled.")
end
concommand.Add("homicide_debugprint",ChangeDebugPrinting)

local function SpecSHTF(ply,cmd,args)
	if((ply.IsAdmin)and not(ply:IsAdmin()))then ply:PrintMessage(HUD_PRINTTALK,translate.youAreNoAdmin) return end
	if(args[1]=="1")then
		GAMEMODE.SHTF_MODE_ENGAGED=true
		GAMEMODE.PUSSY_MODE_ENGAGED=false
		GAMEMODE.EPIC_MODE_ENGAGED=false
		GAMEMODE.ISLAM_MODE_ENGAGED=false
	elseif(args[1]=="0")then
		GAMEMODE.SHTF_MODE_ENGAGED=false
		GAMEMODE.DEATHMATCH_MODE_ENGAGED=false
		GAMEMODE.ZOMBIE_MODE_ENGAGED=false
	end
	GAMEMODE.SHTF_Specified=true
	print("SHTF mode specified as "..tostring(GAMEMODE.SHTF_MODE_ENGAGED))
	ply:PrintMessage(HUD_PRINTTALK,"SHTF mode specified as "..tostring(GAMEMODE.SHTF_MODE_ENGAGED))
end
concommand.Add("homicide_setmode",SpecSHTF)

function GM:EnoughRoom(pos,human)
	if not(human)then
		local SmallTrace=util.QuickTrace(pos,vector_up)
		if((SmallTrace.Hit)or(SmallTrace.StartSolid))then return false else return true end
	else
		local SmallTrace,Result=util.QuickTrace(pos,Vector(0,0,70)),true
		if((SmallTrace.Hit)or(SmallTrace.StartSolid))then return false end
		for i=1,10 do
			if(util.QuickTrace(pos+Vector(0,0,35),VectorRand()*35).Hit)then return false end
		end
		return true
	end
end

local SpawnFails=0
function GM:FindSpawnLocation(human)
	local DistMul,InitialDist,MinAddDist,SpawnExclusionDist=1,200,400,1000
	if(self.SHTF)then MinAddDist=800 end
	local SpawnPos,Tries,Players,TryDist,NPCs,Loot=nil,0,team.GetPlayers(2),InitialDist*DistMul,ents.FindByClass("npc_*"),ents.FindByClass("ent_jack_hmcd_*")
	local NoBlockEnts={}
	table.Add(NoBlockEnts,Players);table.Add(NoBlockEnts,NPCs);table.Add(NoBlockEnts,Loot)
	for key,potential in pairs(Players)do
		if not(potential:Alive())then table.remove(Players,key) end
	end
	if(#Players<1)then return nil end
	local SelectedPlaya=table.Random(Players)
	local Origin=SelectedPlaya:GetPos()+SelectedPlaya:GetVelocity()*math.Rand(0,15) -- attempt to spawn things in whatever direction the player is moving so that there'll be shit when he gets there and can't just outrun the spawning by moving constantly
	while((SpawnPos==nil)and(TryDist<=9000*DistMul))do
		while((SpawnPos==nil)and(Tries<15))do
			local RandVec,Below,Vertical=VectorRand()*(math.Rand(10,TryDist)+MinAddDist),false,0
			if(math.random(1,3)==2)then RandVec.z=math.abs(RandVec.z) end
			RandVec.z=RandVec.z/2
			if(math.random(1,3)==2)then RandVec.z=RandVec.z/2 end
			Vertical=RandVec.z
			local TryPos=Origin+RandVec
			if(util.IsInWorld(TryPos))then
				local Contents=util.PointContents(TryPos)
				if((Contents==CONTENTS_EMPTY)or(Contents==CONTENTS_TESTFOGVOLUME))then -- don't spawn zombs in water either
					local Close=false
					for key,plaiyah in pairs(Players)do -- spawn may not be close to a player
						if(TryPos:Distance(plaiyah:GetPos())<MinAddDist)then Close=true;break end
					end
					for key,thingamajig in pairs(ents.FindInSphere(TryPos,SpawnExclusionDist))do
						if(thingamajig.SpawnRepellent)then -- for every spawn repellent item within range, there's a chance the spawn will be rejected
							if(math.random(1,2)==2)then Close=true;break end
						end
					end
					if not(Close)then
						local AboveGround=true
						if(Vertical<0)then -- if the pos is below the player, then the player must be standing on something
							local UpTr=util.QuickTrace(TryPos,Vector(0,0,-Vertical+10),Players) -- we therefore should be able to detect that something
							if not(UpTr.Hit)then AboveGround=false end -- if we can't, then the pos is probably below the surface of "solid" groud
						elseif(Vertical>0)then -- if the pos is above the player, there's gotta be something that we can fall onto
							local DownTr=util.QuickTrace(TryPos,Vector(0,0,-Vertical*5),Players) -- try to detect the surface we're gonna fall on
							if not(DownTr.Hit)then AboveGround=false end -- if we can't see anything that far down, we're probably below the ground
						end
						if((AboveGround)and(self:EnoughRoom(TryPos,human)))then
							local FinalDownTr=util.QuickTrace(TryPos,Vector(0,0,-20000),NoBlockEnts)
							if(FinalDownTr.Hit)then
								TryPos=FinalDownTr.HitPos+Vector(0,0,60)
								local CanSee=false
								for key,ply in pairs(Players)do
									if(ply:Alive())then
										local ToTrace=util.TraceLine({start=ply:GetShootPos(),endpos=TryPos+Vector(0,0,10),filter=NoBlockEnts})
										if not(ToTrace.Hit)then
											CanSee=true
											break
										end
										local ToTrace2=util.TraceLine({start=ply:GetShootPos(),endpos=TryPos-Vector(0,0,10),filter=NoBlockEnts})
										if not(ToTrace2.Hit)then
											CanSee=true
											break
										end
									end
								end
								for key,cayum in pairs(ents.FindByClass("sky_camera"))do -- don't spawn shit in the skybox you stupid fucking game
									local ToTrace=util.TraceLine({start=cayum:GetPos(),endpos=TryPos})
									if not(ToTrace.Hit)then
										CanSee=true
										break
									end
								end
								if not(CanSee)then
									SpawnPos=TryPos
									if(SelectedPlaya.Murderer)then goodShit=true end
								end
							end
						end
					end
				end
			end
			Tries=Tries+1
		end
		TryDist=TryDist+200*DistMul
		Tries=0
	end
	if(SpawnPos==nil)then
		SpawnFails=SpawnFails+1
		if(SpawnFails>5)then
			print("Homicide: Unable to find suitable spawn location for item/npc!")
		end
	else
		SpawnFails=0
	end
	return SpawnPos
end

--[[
local SpawnFails=0
function GM:FindSpawnLocation(human)
	local DistMul,goodShit=1,false
	if(self.SHTF)then DistMul=2 end
	local SpawnPos,Tries,Players,TryDist=nil,0,team.GetPlayers(2),200*DistMul
	for key,potential in pairs(Players)do
		if not(potential:Alive())then table.remove(Players,key) end
	end
	if(#Players<1)then return nil end
	local SelectedPlaya=table.Random(Players)
	local Origin=SelectedPlaya:GetPos()
	while((SpawnPos==nil)and(TryDist<=3000*DistMul))do
		while((SpawnPos==nil)and(Tries<10))do
			local RandVec,Below,Vertical=VectorRand()*math.Rand(10,TryDist),false,0
			if(math.random(1,3)==2)then RandVec.z=math.abs(RandVec.z) end
			RandVec.z=RandVec.z/2
			Vertical=RandVec.z
			local TryPos=Origin+RandVec
			if(util.IsInWorld(TryPos))then
				local Contents=util.PointContents(TryPos)
				if((Contents==CONTENTS_EMPTY)or(Contents==CONTENTS_WATER)or(Contents==CONTENTS_TESTFOGVOLUME))then
					local AboveGround=true
					if(Vertical<0)then -- if the pos is below the player, then the player must be standing on something
						local UpTr=util.QuickTrace(TryPos,Vector(0,0,-Vertical+10),Players) -- we therefore should be able to detect that something
						if not(UpTr.Hit)then AboveGround=false end -- if we can't, then the pos is probably below the surface of "solid" groud
					elseif(Vertical>0)then -- if the pos is above the player, there's gotta be something that we can fall onto
						local DownTr=util.QuickTrace(TryPos,Vector(0,0,-Vertical*5),Players) -- try to detect the surface we're gonna fall on
						if not(DownTr.Hit)then AboveGround=false end -- if we can't see anything that far down, we're probably below the ground
					end
					if((AboveGround)and(self:EnoughRoom(TryPos,human)))then
						local CanSee=false
						for key,ply in pairs(Players)do
							if(ply:Alive())then
								local ToTrace=util.TraceLine({start=ply:GetShootPos(),endpos=TryPos+Vector(0,0,10),filter=Players})
								if not(ToTrace.Hit)then
									CanSee=true
									break
								end
								local ToTrace2=util.TraceLine({start=ply:GetShootPos(),endpos=TryPos-Vector(0,0,10),filter=Players})
								if not(ToTrace2.Hit)then
									CanSee=true
									break
								end
							end
						end
						for key,cayum in pairs(ents.FindByClass("sky_camera"))do -- don't spawn shit in the skybox you stupid fucking game
							local ToTrace=util.TraceLine({start=cayum:GetPos(),endpos=TryPos})
							if not(ToTrace.Hit)then
								CanSee=true
								break
							end
						end
						if not(CanSee)then
							SpawnPos=TryPos
							if(SelectedPlaya.Murderer)then goodShit=true end
						end
					end
				end
			end
			Tries=Tries+1
		end
		TryDist=TryDist+200*DistMul
		Tries=0
	end
	if(SpawnPos==nil)then
		SpawnFails=SpawnFails+1
		if(SpawnFails>5)then
			print("---------- Couldn't find a spawn location for object, five times in a row! ----------")
		end
	else
		SpawnFails=0
	end
	return SpawnPos,goodShit
end
--]]

function GM:Initialize()
	self:LoadSpawns()
	self.DeathRagdolls = {}
	self:StartNewRound()
	self:LoadMapList()
	concommand.Remove("WobbleCreate") -- bastards
	concommand.Remove("wobbletoggleragdoll") -- you asses
	concommand.Remove("JI_BFS_2114_Begin") -- don't even try
end

function GM:InitPostEntity()
	self:InitPostEntityAndMapCleanup()
end

function GM:InitPostEntityAndMapCleanup()
	--
end

local NextCopSpawnTime,NextCopThinkTime,NextSirenTime,NextZombieThinkTime,NextZombieSpawnTime=0,0,0,0,0
function GM:SpawnCop(pos)
	local Cop=ents.Create("npc_metropolice")
	Cop.HmcdSpawned=true
	Cop:SetKeyValue("model","models/gta5/npc/citycop.mdl")
	Cop:SetKeyValue("additionalequipment","wep_jack_hmcd_npc_pistol")
	Cop:SetKeyValue("squadname","homicidal_police")
	Cop:SetCurrentWeaponProficiency(WEAPON_PROFICIENCY_POOR)
	Cop:SetBystanderName(translate.police)
	Cop:SetPlayerColor(Vector(.1,.125,.2))
	Cop:SetPos(pos)
	Cop:SetAngles(Angle(0,math.random(0,360),0))
	Cop:Spawn()
	Cop:SetModel("models/gta5/npc/citycop.mdl")
	Cop:SetBodygroup(1,1)
	Cop:SetBodygroup(2,math.random(0,1))
	Cop:SetBodygroup(3,math.random(0,1))
	Cop:SetBodygroup(4,math.random(0,1))
	Cop:SetBodygroup(5,math.random(0,1))
	Cop:Activate()
	Cop:SetMaxHealth(100)
	Cop:SetHealth(100)
	Cop:AddRelationship("player D_NU 50")
	Cop:AddRelationship("npc_citizen D_NU 50")
	if(math.random(1,2)==1)then Cop:Fire("gagenable","",0) end
	for key,other in pairs(ents.FindByClass("npc_metropolice"))do
		constraint.NoCollide(Cop,other,0,0)
	end
	return Cop
end
local GuardModels={"models/wgrunt/wgrunt6.mdl","models/wgrunt/wgrunt6b.mdl","models/wgrunt/wgrunt6.mdl"}--,"models/wgrunt/wgrunt6b.mdl","models/wgrunt/wgrunt6c.mdl","models/wgrunt/wgrunt6d.mdl","models/wgrunt/wgrunt6e.mdl"}
function GM:SpawnGuardsman(pos)
	local dude,Maudell=ents.Create("npc_combine_s"),table.Random(GuardModels)
	dude.HmcdSpawned=true
	dude:SetKeyValue("model",Maudell)
	dude:SetKeyValue("tacticalvariant","1")
	dude:SetKeyValue("spawnflags",tostring(bit.bor(256,8192)))
	dude:SetBloodColor(-1)
	dude:SetCurrentWeaponProficiency(WEAPON_PROFICIENCY_PERFECT)
	dude:SetKeyValue("additionalequipment","wep_jack_hmcd_npc_rifle")
	dude:SetKeyValue("squadname","homicide_guardsmen")
	dude:SetBystanderName(translate.nationalguardsman)
	dude:SetPlayerColor(Vector(.15,.2,.1))
	dude:SetPos(pos)
	dude:SetAngles(Angle(0,math.random(0,360),0))
	dude:Spawn()
	dude:SetModel(Maudell)
	dude:Activate()
	dude:SetMaxHealth(300)
	dude:SetHealth(300)
	dude:AddRelationship("player D_NU 50")
	dude:AddRelationship("npc_citizen D_NU 50")
	if(math.random(1,2)==1)then dude:Fire("gagenable","",0) end
	for key,other in pairs(ents.FindByClass("npc_metropolice"))do
		constraint.NoCollide(dude,other,0,0)
	end
	sound.Play("snd_jack_hmcd_heli"..math.random(1,2)..".mp3",pos,85,math.random(90,110))
	return dude
end
local ZombTypes={"npc_zombie","npc_zombie","npc_zombie_torso","npc_fastzombie","npc_fastzombie","npc_fastzombie","npc_fastzombie_torso","npc_zombine","npc_poisonzombie","npc_poisonzombie"}
function GM:SpawnZombie(pos)
	if(self.ZombiesLeft<=0)then return end
	if(self.PoliceTime<CurTime())then return end
	local Typ=table.Random(ZombTypes)
	local dude=ents.Create(Typ)
	dude.HmcdSpawned=true
	dude:SetBystanderName(translate.zombieSimple)
	dude:SetPlayerColor(Vector(.3,.1,.1))
	dude:SetPos(pos)
	dude:SetAngles(Angle(0,math.random(0,360),0))
	dude.HMCD_Zomb=true
	dude:SetKeyValue("crabcount","3")
	dude:Spawn()
	dude:Activate()
	dude:SetBodygroup(1,0)
	dude:SetBloodColor(BLOOD_COLOR_RED)
	dude:SetShouldServerRagdoll(false)
	if(math.random(1,2)==1)then
		dude:Fire("gagenable","",0)
		for key,other in pairs(self:GetZombies())do
			constraint.NoCollide(dude,other,0,0)
		end
		for key,playa in pairs(team.GetPlayers())do
			if(playa.Murderer)then constraint.NoCollide(dude,playa,0,0) end
		end
	end
	self.ZombiesLeft=self.ZombiesLeft-1
	return dude
end
function GM:TryToSpawnNPC(alternateNPCs)
	local SpawnPos=self:FindSpawnLocation(true)
	if(SpawnPos)then
		if(self.SHTF)then
			if(self.ZOMBIE)then
				if(alternateNPCs)then
					local dude=self:SpawnGuardsman(SpawnPos)
					return dude
				else
					local dude=self:SpawnZombie(SpawnPos)
					return dude
				end
			else
				local dude=self:SpawnGuardsman(SpawnPos)
				return dude
			end
		else
			local cop=self:SpawnCop(SpawnPos)
			return cop
		end
	end
	return nil
end
function GM:ArmyThink()
	if(NextCopThinkTime>CurTime())then return end
	NextCopThinkTime=CurTime()+.25
	local Guards,Playas=ents.FindByClass("npc_combine_s"),player.GetAll()
	for key,guard in pairs(Guards)do
		local KeepGuard=guard:GetActivity()!=ACT_IDLE
		for key,playa in pairs(Playas)do
			if(playa:Alive())then
				if((playa:GetPos()-guard:GetPos()):Length()<5000)then KeepGuard=true break end
			end
		end
		if not(KeepGuard)then
			SafeRemoveEntity(guard)
		else
			for key,playa in pairs(Playas)do
				if(playa:Alive())then
					local Disp,Pri=D_LI,50
					if(playa.GuardGuilty)then Disp=D_HT;Pri=80 end
					if(playa.Murderer)then
						Disp=D_HT;Pri=80
					end
					guard:AddEntityRelationship(playa,Disp,Pri)
					if(math.random(1,50)==15)then guard:UpdateEnemyMemory(playa,playa:GetPos()) end
				end
			end
			for key,door in pairs(ents.FindInSphere(guard:GetPos(),100))do
				local Class=door:GetClass()
				if not(door:GetNoDraw())then
					if(math.random(1,50)==29)then
						if((Class=="prop_door")or(Class=="prop_door_rotating")or(Class=="func_door")or(Class=="func_door_rotating"))then
							door:Fire("open","",0)
						elseif(door.PlayerHiddenInside)then
							door.PlayerHiddenInside:ExitContainer()
						end
					end
				end
			end
		end
	end
	local CopLimit=20+#Playas*2
	if(#Guards>=CopLimit)then return end
	if(NextCopSpawnTime>CurTime())then return end
	NextCopSpawnTime=CurTime()+3
	self:TryToSpawnNPC(true)
end
function GM:CopThink()
	if(NextCopThinkTime>CurTime())then return end
	NextCopThinkTime=CurTime()+.25
	local Cops,Playas=ents.FindByClass("npc_metropolice"),player.GetAll()
	for key,cop in pairs(Cops)do
		local KeepCop=cop:GetActivity()!=ACT_IDLE
		for key,playa in pairs(Playas)do
			if(playa:Alive())then
				if((playa:GetPos()-cop:GetPos()):Length()<2000)then KeepCop=true break end
			end
		end
		if not(KeepCop)then
			SafeRemoveEntity(cop)
		else
			for key,playa in pairs(Playas)do
				if(playa:Alive())then
					local Wep,Disp,Pri=playa:GetActiveWeapon(),D_NU,80
					if(IsValid(Wep))then
						if(Wep.ClassName=="wep_jack_hmcd_smallpistol")then
							Disp=D_HT;Pri=70
						elseif(Wep.ClassName=="wep_jack_hmcd_baseballbat")then
							Disp=D_HT;Pri=65
						elseif(Wep.ClassName=="wep_jack_hmcd_pocketknife")then
							Disp=D_HT;Pri=60
						elseif(Wep.ClassName=="wep_jack_hmcd_hammer")then
							Disp=D_HT;Pri=55
						elseif(Wep.ClassName=="wep_jack_hmcd_hands")then
							if(Wep:GetFists())then Disp=D_HT;Pri=50 end
						end
					end
					if(playa.Murderer)then
						Disp=D_HT;Pri=90
					end
					cop:AddEntityRelationship(playa,Disp,Pri)
					if(math.random(1,50)==15)then cop:UpdateEnemyMemory(playa,playa:GetPos()) end
				end
			end
			for key,door in pairs(ents.FindInSphere(cop:GetPos(),100))do
				local Class=door:GetClass()
				if not(door:GetNoDraw())then
					if(math.random(1,50)==29)then
						if((Class=="prop_door")or(Class=="prop_door_rotating")or(Class=="func_door")or(Class=="func_door_rotating"))then
							door:Fire("open","",0)
						elseif(door.PlayerHiddenInside)then
							door.PlayerHiddenInside:ExitContainer()
						end
					end
				end
			end
		end
	end
	if(NextSirenTime<CurTime())then
		NextSirenTime=CurTime()+4.8
		local SirenCop=table.Random(Cops)
		if(SirenCop)then
			local Pos=SirenCop:GetPos()
			sound.Play("snd_jack_hmcd_policesiren.wav",Pos,150,100)
			local EffDat=EffectData()
			EffDat:SetOrigin(Pos)
			EffDat:SetScale(1)
			util.Effect("eff_jack_hmcd_redflash",EffDat,true,true)
			timer.Simple(.5,function()
				local EffDat=EffectData()
				EffDat:SetOrigin(Pos)
				EffDat:SetScale(1)
				util.Effect("eff_jack_hmcd_blueflash",EffDat,true,true)
			end)
		end
	end
	local CopLimit=10+#Playas*2
	if(#Cops>=CopLimit)then return end
	if(NextCopSpawnTime>CurTime())then return end
	NextCopSpawnTime=CurTime()+3
	self:TryToSpawnNPC()
end
function GM:ZombieThink()
	if(NextZombieThinkTime>CurTime())then return end
	NextZombieThinkTime=CurTime()+.25
	local Zombs,Playas=self:GetZombies(),player.GetAll()
	for key,zomb in pairs(Zombs)do
		local KeepZomb=zomb:GetActivity()!=ACT_IDLE
		for key,playa in pairs(Playas)do
			if(playa:Alive())then
				if((playa:GetPos()-zomb:GetPos()):Length()<2000)then KeepZomb=true break end
			end
		end
		if((self.PoliceTime<CurTime())and(KeepZomb))then KeepZomb=math.random(2)==1 end
		if not(KeepZomb)then
			SafeRemoveEntity(zomb)
		elseif(math.random(1,5000)==25)then
			zomb:TakeDamage(200,game.GetWorld())
		else
			for key,playa in pairs(Playas)do
				if(playa:Alive())then
					if(playa.Murderer)then
						zomb:AddEntityRelationship(playa,D_LI,99)
					else
						zomb:AddEntityRelationship(playa,D_HT,90)
					end
				end
			end
		end
	end
	local ZombLimit=40+#Playas*5
	if(#Zombs>=ZombLimit)then return end
	if(NextZombieSpawnTime>CurTime())then return end
	NextZombieSpawnTime=CurTime()+1
	self:TryToSpawnNPC()
end
function GM:GetZombies()
	local All,Result=ents.FindByClass("npc_*"),{}
	for key,npc in pairs(All)do
		if(npc.HMCD_Zomb)then table.insert(Result,npc) end
	end
	return Result
end

local NextMovementSet,NextBreathe,NextBleed,NextRegen,NextSpeedCalc,SHTF_CheckTime,CheatCheck,XPAdd,GodCheckTime=0,0,0,0,0,10,0,0,0
function GM:Think()
	--JackaPrint(tostring(player.GetAll()[1]:GetEyeTrace().Entity).." "..tostring(player.GetAll()[1]:GetEyeTrace().Entity:GetModel()))
	--print(ents.FindByClass("phys_lengthconstraint")[1]:GetTable().Type)
	--print(player.GetAll()[1]:GetPhysicsObject():IsPenetrating())
	self:RoundThink()
	if((CurTime()>SHTF_CheckTime)and not(self.SHTF_Specified))then
		SHTF_CheckTime=CurTime()+100
		local Size,Threshold,Map=self:DetermineMapSize(),3000,game.GetMap()
		if(string.find(Map,"ttt_"))then
			Threshold=2000
		elseif((string.find(Map,"mu_"))or(string.find(Map,"md_")))then
			Threshold=4000
		elseif(string.find(Map,"zs_"))then
			Threshold=1000
		end
		if(HMCD_CountAiNodes()>=50)then self.EnoughAINodes=true else self.EnoughAINodes=false end
		--print(Size)
		if(Size>Threshold)then
			self.SHTF_MODE_ENGAGED=true
			self.PUSSY_MODE_ENGAGED=false
			self.EPIC_MODE_ENGAGED=false
			self.ISLAM_MODE_ENGAGED=false
		else
			self.SHTF_MODE_ENGAGED=false
			self.DEATHMATCH_MODE_ENGAGED=false
			self.ZOMBIE_MODE_ENGAGED=false
		end
	end
	if not(self:GetRound()==1)then
		self:IntermissionThink()
		return
	end
	local Time,WillCalc,WillBreathe,WillBleed,WillRegen,WillCalcSpeed,WillCheatCheck,WillAdd,WillGodCheck=CurTime(),false,false,false,false,false,false,false,false
	self:MurdererThink()
	if((self.PoliceTime<CurTime())and not(self.DEATHMATCH))then
		if not(self.PoliceNotified)then
			self.PoliceNotified=true
			for key,playah in pairs(player.GetAll())do
				if(self.SHTF)then
					playah:PrintMessage(HUD_PRINTTALK,translate.arrivalNationalGuard)
				else
					playah:PrintMessage(HUD_PRINTTALK,translate.arrivalPolice)
				end
			end
		end
		if(self.SHTF)then
			self:ArmyThink()
		else
			self:CopThink()
		end
	elseif((self.DEATHMATCH)and(self.DeathmatchEndTime<CurTime()))then
		self:EndTheRound(7,nil)
	else
		if(self.ZOMBIE)then self:ZombieThink() end
		self:LootThink()
	end
	self:FlashlightThink()
	if(XPAdd<Time)then
		XPAdd=Time+60
		WillAdd=true
	end
	if(NextMovementSet<Time)then
		NextMovementSet=Time+.25
		WillCalc=true
	end
	if(GodCheckTime<Time)then
		GodCheckTime=Time+1
		WillGodCheck=true
	end
	if(NextBreathe<Time)then
		NextBreathe=Time+1
		WillBreathe=true
	end
	if(NextBleed<Time)then
		NextBleed=Time+.6
		WillBleed=true
	end
	if(NextRegen<Time)then
		NextRegen=Time+2
		WillRegen=true
	end
	if(NextSpeedCalc<Time)then
		NextSpeedCalc=Time+.15
		WillCalcSpeed=true
	end
	if(CheatCheck<Time)then
		CheatCheck=Time+.5
		self:GlobalAntiCheat()
	end
	for k,ply in pairs(player.GetAll()) do
		local ActiveWep=ply:GetActiveWeapon()
		if not(IsValid(ActiveWep))then
			if(ply:HasWeapon("wep_jack_hmcd_hands"))then
				ply:SelectWeapon("wep_jack_hmcd_hands")
			else
				ply:SelectWeapon("wep_jack_hmcd_zombhands")
			end
		end
		if((ply:Team()==2)and(ply:Alive())and(self.DEATHMATCH))then
			if(self.RoundTime+20>CurTime())then
				if((self.RoundTime+20-CurTime())<10)then ply:PrintMessage(HUD_PRINTCENTER,translate.battleStartsIn..tostring(math.Round(self.RoundTime+20-CurTime()))) end
			end
		end
		for key,wep in pairs(ply:GetWeapons())do
			if((wep.NoHolster)and not(ActiveWep==wep)and not(ActiveWep.NoHolsterForce))then ply:DropWeapon(wep) end
		end
		if(WillAdd)then -- award system
			if((ply:Team()==2)and(ply:Alive()))then
				ply:AddExperience(1)
			end
		end
		if(WillRegen)then
			if(ply.FoodBoost>Time)then
				if(ply:Health()<100)then
					ply:SetHealth(ply:Health()+1)
				end
			end
		end
		if(WillGodCheck)then
			ply:GodCheck()
		end
		if(WillCalcSpeed)then
			ply:CalculateSpeed()
		end
		if(WillCalc)then
			if((ply:KeyDown(IN_SPEED))and(ply:KeyDown(IN_FORWARD))and not(ply:InVehicle()))then
				if(ply.Stamina>40)then
					local PenMul=.7
					HMCD_StaminaPenalize(ply,2*PenMul)
				end
			else
				local StamAmt=-1.5
				if(ply.FoodBoost>Time)then StamAmt=-3 end
				HMCD_StaminaPenalize(ply,StamAmt)
			end
			self:CalculateFoV(ply,ply:KeyDown(IN_WALK),ply:KeyDown(IN_SPEED),(ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT) or ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_BACK)))
			ply.TempSpeedMul=math.Clamp(ply.TempSpeedMul+.1,.1,1)
			net.Start("hmcd_tempspeedmul")
			net.WriteFloat(ply.TempSpeedMul)
			net.Send(ply)
		end
		if((WillBreathe)and(ply:Alive())and not((ply.Murderer)and(self.ZOMBIE)))then
			if(ply:WaterLevel()>=3)then
				ply.HeldBreath=math.Clamp(ply.HeldBreath-1,0,50)
				if(ply.HeldBreath<=0)then
					local Dmg=DamageInfo()
					Dmg:SetAttacker(game.GetWorld())
					Dmg:SetInflictor(game.GetWorld())
					Dmg:SetDamageType(DMG_DROWN)
					Dmg:SetDamage(100)
					ply:TakeDamageInfo(Dmg)
				elseif(ply.HeldBreath<10)then
					ply:EmitSound("player/pl_drown"..math.random(1,3)..".wav",60,math.random(90,110))
					ply:ViewPunch(Angle(math.random(-5,5),math.random(-5,5),math.random(-5,5)))
				end
			else
				local Chance=400
				if(ply.Murderer)then Chance=600 end
				if(math.random(1,Chance)==5)then ply:InvoluntaryEvent() end
				ply.HeldBreath=50
			end
			if(ply.Stamina<45)then
				if(ply.ModelSex=="male")then
					ply:EmitSound("snds_jack_hmcd_breathing/m"..math.random(1,6)..".wav",45,math.random(90,110))
				elseif(ply.ModelSex=="female")then
					ply:EmitSound("snds_jack_hmcd_breathing/f"..math.random(1,6)..".wav",45,math.random(90,110))
				end
			end
		end
		if(WillBleed)then
			local Existing,Att=ply.Bleedout,ply.LastAttacker
			if not(IsValid(Att))then Att=game.GetWorld() end
			if((Existing)and(Existing>0)and(ply:Alive()))then
				local Dmg=DamageInfo()
				Dmg:SetDamage(1)
				Dmg:SetDamageType(DMG_GENERIC)
				Dmg:SetAttacker(Att)
				Dmg:SetInflictor(ply)
				Dmg:SetDamageForce(Vector(0,0,0))
				Dmg:SetDamagePosition(ply:GetPos())
				ply:TakeDamageInfo(Dmg)
				ply.Bleedout=Existing-1
				sound.Play("snd_jack_hmcd_heartpound.wav",ply:GetShootPos(),45,100)
				if(math.random(1,2)==1)then
					local Tr=util.QuickTrace(ply:GetPos()+Vector(math.random(-25,25),math.random(-25,25),70),Vector(0,0,-100),{ply})
					if(Tr.Hit)then util.Decal("blood",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal) end
				end
			elseif(not(ply:Alive()))then
				ply.Bleedout=0
			end
			if((ply:IsOnFire())and(ply:WaterLevel()>=2))then
				ply:Extinguish()
			end
		end
		if ply:IsCSpectating() && IsValid(ply:GetCSpectatee()) && (!ply.LastSpectatePosSet || ply.LastSpectatePosSet < CurTime()) then
			ply.LastSpectatePosSet = CurTime() + 0.25
			ply:SetPos(ply:GetCSpectatee():GetPos())
		end
		if !ply.HasMoved then
			if ply:IsBot() || ply:KeyDown(IN_FORWARD) || ply:KeyDown(IN_JUMP) || ply:KeyDown(IN_ATTACK) || ply:KeyDown(IN_ATTACK2)
				|| ply:KeyDown(IN_MOVELEFT) || ply:KeyDown(IN_MOVERIGHT) || ply:KeyDown(IN_BACK) || ply:KeyDown(IN_DUCK) then
				ply.HasMoved = true
			end
		end
		--if ply.LastTKTime && ply.LastTKTime + self:GetTKPenaltyTime() < CurTime() then
		--	ply:SetTKer(false)
		--end
	end
end
local NextIntermissionThink=0
function GM:IntermissionThink()
	if(NextIntermissionThink>CurTime())then return end
	NextIntermissionThink=CurTime()+1
	for key,ply in pairs(player.GetAll())do
		ply.Stamina=100
		ply.Bleedout=0
		net.Start("stamina")
		net.WriteFloat(ply.Stamina)
		net.WriteFloat(ply.Bleedout)
		net.Send(ply)
	end
end

function GM:GlobalAntiCheat()
	if(GetConVar("sv_cheats"):GetBool())then return end
	local Shit=ents.GetAll()
	for key,ent in pairs(Shit)do
		if(ent:IsPlayer())then
			ent:AntiCheat()
		else
			if not(ent.HmcdSpawned)then
				local Good,Class=false,ent:GetClass()
				for key,suffix in pairs(HMCD_AllowedEntities)do
					if(string.find(Class,suffix))then Good=true;break end
				end
				if(ent.GetOwner)then
					local Own=ent:GetOwner()
					if((IsValid(Own))and(Own:IsNPC())and(Own.HmcdSpawned))then Good=true end
				end
				if not(Good)then
					local Rep=HMCD_LootReplacements[Class]
					if((Rep)and(math.Rand(0,1)<Rep[2])and(((Rep[3])and(self.SHTF))or not(Rep[3])))then
						if(Rep[1]=="REPLACEVEHICLE")then
							HMCD_ReplaceVehicle(ent)
						else
							local Wee=ents.Create(Rep[1])
							Wee:SetPos(ent:GetPos())
							Wee:SetAngles(ent:GetAngles())
							if(Rep[4])then Wee.AmmoType=Rep[4] end
							Wee.HmcdSpawned=true
							Wee:Spawn()
							Wee:Activate()
							SafeRemoveEntity(ent)
						end
					else
						print("Homicide: anti-cheat system deleting "..tostring(ent))
						SafeRemoveEntity(ent)
					end
				end
			end
		end
	end
end

function GM:CalculateFoV(ply,CalmYourShit,BallsToTheWall,Movin)
	local FoV=88
	if((BallsToTheWall)or not(ply:IsOnGround()))then
		FoV=95
	else
		local Wep=ply:GetActiveWeapon()
		if((Wep)and(IsValid(Wep))and(Wep.GetAiming))then
			local Aim=Wep:GetAiming()
			if(Aim>99)then
				if(Wep.Scoped)then
					FoV=Wep.ScopeFoV
				else
					FoV=87
				end
			end
		end
	end
	if(ply.HighOnDrugs)then FoV=105 end
	if(self:GetRound()==2)then FoV=90 end
	if(ply:InVehicle())then FoV=90 end
	ply:SetFOV(FoV,.24)
end

function GM:AllowPlayerPickup( ply, ent )
	return true
end

function GM:PlayerNoClip(ply)
	if((ply:GetMoveType()==MOVETYPE_NOCLIP)or(GetConVar("sv_cheats"):GetBool()))then
		return true
	else
		ply:PrintMessage(HUD_PRINTTALK,translate.notAllowedNoclip)
	end
end

function GM:OnEndRound()
	--
end

function GM:OnStartRound()
	-- hi
end

function GM:SendMessageAll(msg) 
	for k,v in pairs(player.GetAll()) do
		v:ChatPrint(msg)
	end
end

function GM:ScaleNPCDamage(npc,hitgroup,dmginfo)
	--print(hitgroup)
	local Mul=1
	if(hitgroup==HITGROUP_HEAD)then
		Mul=Mul*3
	elseif((hitgroup==HITGROUP_LEFTLEG)or(hitgroup==HITGROUP_RIGHTLEG)or(hitgroup==HITGROUP_RIGHTARM)or(hitgroup==HITGROUP_LEFTARM)or(hitgroup==HITGROUP_GEAR))then
		Mul=Mul*.25
	elseif(hitgroup==HITGROUP_STOMACH)then
		Mul=Mul*.75
	end
	dmginfo:ScaleDamage(Mul)
end

function GM:EntityTakeDamage(ent,dmginfo)
	--print(ent,dmginfo:GetAttacker(),dmginfo:GetInflictor(),dmginfo:GetDamageType())
	local Mul,Att,Infl=1,dmginfo:GetAttacker(),dmginfo:GetInflictor()
	if((Infl:IsVehicle())and(Infl:GetDriver()))then Att=Infl:GetDriver() end
	if((IsValid(Att))and(IsValid(Att:GetPhysicsAttacker())))then Att=Att:GetPhysicsAttacker() end
	if((IsValid(Infl))and(Infl:GetClass()=="ent_jack_hmcd_grapl"))then Att=Infl.Owner end
	if((self.PoliceTime)and(self.PoliceTime<CurTime())and((ent:IsPlayer())or(ent:GetClass()=="npc_combine_s"))and not(ent.Murderer))then
		if((IsValid(Att))and(Att:IsPlayer()))then Att.GuardGuilty=true end
	end
	if(ent:IsPlayer())then
		local Crush,Club,Slash,Bullet,Buckshot,Blast,Burn=dmginfo:IsDamageType(DMG_CRUSH),dmginfo:IsDamageType(DMG_CLUB),dmginfo:IsDamageType(DMG_SLASH),dmginfo:IsDamageType(DMG_BULLET),dmginfo:IsDamageType(DMG_BUCKSHOT),dmginfo:IsDamageType(DMG_BLAST),dmginfo:IsDamageType(DMG_BURN) or dmginfo:IsDamageType(DMG_DIRECT)
		if(ent:InVehicle())then
			if(((Crush)or(Club)or(Slash)or(Burn))and not(Att==ent))then
				if not(math.random(1,4)==2)then Mul=Mul*.01 end
			elseif((Bullet)or(Buckshot)or(Blast))then
				if(math.random(1,3)==2)then Mul=Mul*.01 end
			elseif(dmginfo:GetDamageType()==0)then -- strange shit the source engine does with vehicle damage types
				ent:SetHealth(ent:Health()-dmginfo:GetDamage())
			end
		end
		--JackaPrint(ent,Att,dmginfo:GetInflictor())
		if((IsValid(Att))and(Att:IsPlayer())and(Att:Alive())and not(Att==ent))then
			if(ent.Murderer)then
				self.HeroPlayer=Att
			elseif(Att.Murderer)then
				self.VillainPlayer=Att
			end
		end
		ent.LastDamager=dmginfo:GetAttacker()
		ent.LastDamagedTime=CurTime()
		if(((Att)and(IsValid(Att))and(Att.IsPlayerHolding)and(Att:IsPlayerHolding()))or((Infl)and(IsValid(Infl))and(Infl.IsPlayerHolding)and(Infl:IsPlayerHolding())))then
			if not((Att.MurdererExplosive)or(Infl.MurdererExplosive))then
				Mul=Mul/100
			end
		end -- no propkilling
		if(dmginfo:GetDamageType()==0)then
			ent.LastBled=true
		else
			ent.LastBled=false
		end
		local Wep=ent:GetActiveWeapon()
		if((Wep)and(IsValid(Wep))and(Wep.GetBlocking)and(Wep:GetBlocking()))then
			if(dmginfo:IsDamageType(DMG_CLUB))then
				HMCD_StaminaPenalize(ent,dmginfo:GetDamage())
				Mul=Mul*.2
			elseif(dmginfo:IsDamageType(DMG_CRUSH))then
				HMCD_StaminaPenalize(ent,dmginfo:GetDamage())
				Mul=Mul*.5
			end
		end
		HMCD_TakeDestabilizingDamage(ent,dmginfo,Mul)
		if((IsValid(dmginfo:GetInflictor()))and(dmginfo:GetInflictor().AttackSlowDown))then
			ent.TempSpeedMul=dmginfo:GetInflictor().AttackSlowDown
			if(dmginfo:GetInflictor().AttackSlowDown<1)then
				umsg.Start("HMCD_StatusEffect",ent)
				umsg.String(translate.statusEffectImmobilized)
				umsg.End()
			end
		end
		if((Att)and(IsValid(Att))and(Att.GetClass))then
			local Class=Att:GetClass()
			if(Att:IsPlayer())then
				if((Att.Murderer)and not(Att==ent))then
					if(self.SHTF)then
						ent.LastAttackerName=translate.attTraitor
					else
						ent.LastAttackerName=translate.attMurderer
					end
				else
					ent.LastAttackerName=Att:GetBystanderName()
				end
			elseif(Class=="npc_metropolice")then
				ent.LastAttackerName=translate.attPolice
			elseif(Class=="npc_combine_s")then
				ent.LastAttackerName=translate.attGuardsman
			elseif((Class=="prop_physics")or(Class=="prop_physics_multiplayer"))then
				ent.LastAttackerName=translate.attObject
			elseif(dmginfo:IsFallDamage())then
				ent.LastAttackerName=translate.attGround
			end
			if((Att:IsPlayer())and(GetConVar("sv_cheats"):GetInt()==0)and not(ent==Att)and not(Att.Murderer)and(self:GetRound()==1)and not(self.DEATHMATCH))then
				if((Att.LastDamager)and(Att.LastDamager==ent)and((Att.LastDamagedTime+3)>CurTime()))then
					-- self defense
				else
					local Ow=math.Clamp(dmginfo:GetDamage(),0,100)
					Att.DamageDealt=Att.DamageDealt+Ow
					local PreviousInnocence=Att.Innocent
					if(Att.DamageDealt>5)then
						Att.Innocent=false
						if((PreviousInnocence)and(#team.GetPlayers(2)>2))then
							net.Start("hmcd_innocence")
							net.WriteEntity(Att)
							net.Broadcast()
						end
					end
					if(ent.Innocent)then
						Att:AddToShitList(Ow)
						ent:AddAttackerDmg(Att,Ow)
					end
				end
			end
		end
		for key,strin in pairs(HMCD_DamageTypes)do
			if(dmginfo:IsDamageType(key))then
				ent.LastDamageType=strin
				break
			end
		end
		if(dmginfo:GetDamage()*Mul>5)then
			net.Start("hmcd_painvision")
			net.Send(ent)
		end
	elseif(ent.PlayerHiddenInside)then
		ent.PlayerHiddenInside:ExitContainer()
	end
	dmginfo:ScaleDamage(Mul)
end

function file.ReadDataAndContent(path)
	local f = file.Read(path, "DATA")
	if f then return f end
	f = file.Read(GAMEMODE.Folder .. "/content/data/" .. path, "GAME")
	return f
end

util.AddNetworkString("reopen_round_board")
function GM:ShowTeam(ply) // F2
	net.Start("reopen_round_board")
	net.Send(ply)
end

concommand.Add("hmcd_version", function (ply)
	if IsValid(ply) then
		ply:ChatPrint("Homicide by Jackarunda & Mechanical Mind version " .. tostring(GAMEMODE.Version or "error"))
	else
		print("Homicide by Jackarunda & Mechanical Mind version " .. tostring(GAMEMODE.Version or "error"))
	end
end)

function GM:GetFallDamage(ply,speed)
	-- the threshold impact speed for damage seems to be about 600 ups
	local EffSpd=math.Clamp(speed-575,0,1e5)
	EffSpd=EffSpd/2.5
	return EffSpd
end

function GM:DetermineMapSize()
	local MapStart,MapEnd,SizeAvg,CheckSize,DistAvg,Result,TraceHits,NumSizes=0,0,0,30000,0,0,0,0
	for i=0,30000 do
		local StartVec=Vector(math.random(-CheckSize,CheckSize),math.random(-CheckSize,CheckSize),math.random(-CheckSize,CheckSize))
		if(util.IsInWorld(StartVec))then
			SizeAvg=SizeAvg+StartVec:LengthSqr()
			NumSizes=NumSizes+1
			local Tr=util.QuickTrace(StartVec,VectorRand()*20000)
			if((Tr.Hit)and not(Tr.StartSolid))then
				DistAvg=DistAvg+(StartVec-Tr.HitPos):LengthSqr()
				TraceHits=TraceHits+1
			end
		else
			CheckSize=CheckSize-1
		end
	end
	if(NumSizes==0)then NumSizes=1 end -- no div by zero crashes
	if(TraceHits==0)then TraceHits=1 end
	SizeAvg=((SizeAvg/NumSizes)^.5)*2
	DistAvg=(DistAvg/TraceHits)^.5
	Result=(DistAvg+SizeAvg+DistAvg)/3
	--JackaPrint(SizeAvg,DistAvg,Result)
	return Result
end

function GM:OnNPCKilled(victim,attacker,inflictor)
	if(self.ZOMBIE)then
		if(victim.HMCD_Zomb)then
			if((attacker)and(attacker:IsPlayer())and not(attacker.Murderer))then
				attacker:AddMerit(.05)
			end
			if(math.random(1,10)==5)then
				self:SpawnLoot(victim:LocalToWorld(victim:OBBCenter()),true,math.random(1,2)==2)
			end
		end
	end
end

function HMCD_StaminaPenalize(ply,amt)
	if(CLIENT)then return end
	if((ply.HighOnDrugs)and(amt>0))then return end
	if((ply.Murderer)and(GAMEMODE.ZOMBIE))then return end
	if(amt>0)then
		local Weight=ply.CarryWeightStaminaMul or 1
		amt=amt/Weight
	end
	if((ply.Murderer)and(amt>0))then amt=amt*.9 end
	ply.Stamina=math.Clamp(ply.Stamina-amt,1,100)
	net.Start("stamina")
	net.WriteFloat(ply.Stamina)
	net.WriteFloat(ply.Bleedout)
	net.Send(ply)
end

function HMCD_TakeDestabilizingDamage(victim,dmginfo,mul)
	if not(victim:Alive())then return end
	if((GAMEMODE.ZOMBIE)and(victim.Murderer))then
		sound.Play("npc/zombie/zombie_pain"..math.random(6)..".wav",victim:GetPos(),75,math.random(90,110))
		return
	end
	local damage,BleedMul=dmginfo:GetDamage()*mul,0
	if(damage<5)then return end
	if(dmginfo:IsDamageType(DMG_SLASH))then
		BleedMul=1.5
	elseif(dmginfo:IsDamageType(DMG_BULLET))then
		BleedMul=1
	elseif(dmginfo:IsDamageType(DMG_BUCKSHOT))then
		BleedMul=.75
	elseif(dmginfo:IsDamageType(DMG_BLAST))then
		BleedMul=.25
	end
	if(BleedMul==0)then return end
	victim.Bleedout=victim.Bleedout+math.ceil(damage*BleedMul)
	victim.LastAttacker=dmginfo:GetAttacker()
end
function HMCD_HideBody(body)
	sound.Play("snd_jack_hmcd_poof.wav",body:GetPos(),50,100)
	local Eff=EffectData()
	Eff:SetOrigin(body:GetPos())
	Eff:SetScale(1)
	util.Effect("eff_jack_hmcd_poof",Eff,true,true)
	SafeRemoveEntityDelayed(body,.1)
end
function HMCD_PainMoan(victim,breath)
	if(victim.ModelSex=="male")then
		if(breath)then
			victim:EmitSound("snds_jack_hmcd_breathing/m"..math.random(1,6)..".wav",70,math.random(90,110))
		else
			victim:EmitSound("vo/npc/male01/moan0"..math.random(1,5)..".wav",70,math.random(90,110))
		end
	elseif(victim.ModelSex=="female")then
		if(breath)then
			victim:EmitSound("snds_jack_hmcd_breathing/f"..math.random(1,6)..".wav",70,math.random(90,110))
		else
			victim:EmitSound("vo/npc/female01/moan0"..math.random(1,5)..".wav",70,math.random(90,110))
		end
	end
end
function HMCD_Poison(vic,murd,fast)
	if(vic.Poisoned)then return end
	vic.Poisoned=true
	if not(vic.LifeID)then vic.LifeID=1 end
	local Victim,Murderer,LifeID=vic,murd,vic.LifeID
	if(fast)then
		timer.Simple(math.random(5,10),function()
			if((Victim)and(IsValid(Victim))and(Victim:Alive())and(Victim.LifeID==LifeID))then
				HMCD_PainMoan(Victim,true)
				umsg.Start("HMCD_StatusEffect",Victim)
				umsg.String(translate.statusEffectPoisoned)
				umsg.End()
				timer.Simple(math.random(2,4),function()
					if((IsValid(Victim))and(Victim:Alive())and(Victim.LifeID==LifeID))then
						HMCD_PainMoan(Victim,true)
						umsg.Start("HMCD_StatusEffect",Victim)
						umsg.String(translate.statusEffectPoisoned)
						umsg.End()
						Victim.TempSpeedMul=.1
						timer.Simple(math.random(2,4),function()
							if((IsValid(Victim))and(Victim:Alive())and(Victim.LifeID==LifeID))then
								local Dmg=DamageInfo()
								Dmg:SetDamage(105)
								Dmg:SetDamageType(DMG_POISON)
								Dmg:SetAttacker(Murderer)
								Dmg:SetInflictor(Victim)
								Dmg:SetDamagePosition(Victim:GetPos())
								Dmg:SetDamageForce(Vector(0,0,0))
								Victim:TakeDamageInfo(Dmg)
								if(Victim:InVehicle())then Victim:Kill() end
							end
						end)
					end
				end)
			end
		end)
	else
		timer.Simple(math.random(20,40),function()
			if((Victim)and(IsValid(Victim))and(Victim:Alive())and(Victim.LifeID==LifeID))then
				HMCD_PainMoan(Victim)
				umsg.Start("HMCD_StatusEffect",Victim)
				umsg.String(translate.statusEffectPoisoned)
				umsg.End()
				timer.Simple(math.random(2,4),function()
					if((IsValid(Victim))and(Victim:Alive())and(Victim.LifeID==LifeID))then
						HMCD_PainMoan(Victim)
						umsg.Start("HMCD_StatusEffect",Victim)
						umsg.String(translate.statusEffectPoisoned)
						umsg.End()
						Victim.TempSpeedMul=.1
						timer.Simple(math.random(2,4),function()
							if((IsValid(Victim))and(Victim:Alive())and(Victim.LifeID==LifeID))then
								umsg.Start("HMCD_StatusEffect",Victim)
								umsg.String(translate.statusEffectAsphyxiating)
								umsg.End()
								Victim:Freeze(true)
								timer.Simple(math.random(2,4),function()
									if((IsValid(Victim))and(Victim:Alive())and(Victim.LifeID==LifeID))then
										local Dmg=DamageInfo()
										Dmg:SetDamage(105)
										Dmg:SetDamageType(DMG_POISON)
										Dmg:SetAttacker(Murderer)
										Dmg:SetInflictor(Victim)
										Dmg:SetDamagePosition(Victim:GetPos())
										Dmg:SetDamageForce(Vector(0,0,0))
										Victim:TakeDamageInfo(Dmg)
										if(Victim:InVehicle())then Victim:Kill() end
									end
								end)
							end
						end)
					end
				end)
			end
		end)
	end
end
function HMCD_BlastThatDoor(ent)
	local Moddel,Pozishun,Ayngul,Muteeriul,Skin=ent:GetModel(),ent:GetPos(),ent:GetAngles(),ent:GetMaterial(),ent:GetSkin()
	sound.Play("Wood_Crate.Break",Pozishun,60,100)
	sound.Play("Wood_Furniture.Break",Pozishun,60,100)
	ent:Fire("open","",0)
	ent:Fire("kill","",.1)
	if((Moddel)and(Pozishun)and(Ayngul))then
		local Replacement=ents.Create("prop_physics")
		Replacement.HmcdSpawned=true
		Replacement:SetModel(Moddel);Replacement:SetPos(Pozishun);Replacement:SetAngles(Ayngul)
		if(Muteeriul)then Replacement:SetMaterial(Muteeriul) end
		if(Skin)then Replacement:SetSkin(Skin) end
		Replacement:Spawn()
		Replacement:Activate()
		timer.Simple(3,function()
			if(IsValid(Replacement))then Replacement:SetCollisionGroup(COLLISION_GROUP_WEAPON) end
		end)
	end
end
function HMCD_BindObjects(ent1,pos1,ent2,pos2,power)
	local Strength,CheckEnt,OtherEnt=1,ent1,ent2
	if(CheckEnt:IsWorld())then CheckEnt=ent2;OtherEnt=ent1 end
	if not(power)then power=1 end
	for key,tab in pairs(constraint.FindConstraints(CheckEnt,"Rope"))do
		if((tab.Ent1==OtherEnt)or(tab.Ent2==OtherEnt))then Strength=Strength+1 end
	end
	local Rope=constraint.Rope(ent1,ent2,0,0,ent1:WorldToLocal(pos1),ent2:WorldToLocal(pos2),(pos1-pos2):Length(),-.1,(500+Strength*100)*power,0,"",false)
	return Strength
end

function HMCD_ReplaceVehicle(veh)
	local Bug,pos,ang,mdl=nil,veh:GetPos(),veh:GetAngles(),veh:GetModel()
	if(mdl=="models/buggy.mdl")then
		Bug=ents.Create("prop_vehicle_jeep_old")
		Bug:SetKeyValue("vehiclescript","scripts/vehicles/normal_jeep.txt")
		Bug:SetModel("models/buggy.mdl")
		Bug:Fire("FinishRemoveTauCannon","",0)
	elseif(mdl=="models/vehicle.mdl")then
		Bug=ents.Create("prop_vehicle_jeep")
		Bug:SetKeyValue("vehiclescript","scripts/vehicles/fast_car.txt")
		Bug:SetModel("models/vehicle.mdl")
	elseif(mdl=="models/airboat.mdl")then
		Bug=ents.Create("prop_vehicle_airboat")
		Bug:SetKeyValue("vehiclescript","scripts/vehicles/normal_jeep.txt")
		Bug:SetModel("models/airboat.mdl")
		Bug:Fire("EnableGun","0",0)
	else
		Bug=ents.Create("prop_vehicle_jeep_old")
		if(math.random(1,2)==1)then Bug:SetKeyValue("vehiclescript","scripts/vehicles/normal_jeep.txt") else Bug:SetKeyValue("vehiclescript","scripts/vehicles/fast_car.txt") end
		Bug:SetModel(mdl)
		Bug:Fire("FinishRemoveTauCannon","",0)
	end
	if(Bug)then
		Bug:SetPos(pos)
		Bug:SetAngles(ang)
		Bug.HmcdSpawned=true
		Bug:Spawn()
		Bug:Activate()
		Bug:SetThirdPersonMode(false)
		Bug:SetCameraDistance(0)
		Bug:AddCallback("PhysicsCollide",function(self,data,collider)
			local Driver=self:GetDriver()
			if(IsValid(Driver))then
				local ImpactSpeed=(data.OurOldVelocity-self:GetPhysicsObject():GetVelocity()):Length()
				if(ImpactSpeed>250)then
					local Dmg=DamageInfo()
					Dmg:SetAttacker(Driver)
					Dmg:SetInflictor(self)
					Dmg:SetDamage(1) -- fucking source engine
					Dmg:SetDamageType(DMG_CRUSH)
					Driver:TakeDamageInfo(Dmg)
					Driver:SetHealth(Driver:Health()-ImpactSpeed*.01)
				end
			end
		end)
		SafeRemoveEntity(veh)
	end
end

-- IMPORTED FROM FUNGUNS --
function HMCD_ElectricalArcEffect(pos,victim,scale)
	local TargetType=type(Victim)
	local VictimPos
	if(TargetType=="Vector")then
		VictimPos=victim
	else
		VictimPos=victim:LocalToWorld(victim:OBBCenter())
	end

	local SelfPos=pos

	local ToVector=(VictimPos-SelfPos)
	local Dist=ToVector:Length()
	local Dir=ToVector:GetNormalized()
	
	local PrettyStartDirection=VectorRand() --make it start out to the side so the user can see the arc better

	local WanderDirection=(Dir+PrettyStartDirection*math.Rand(0,1)):GetNormalized()
	
	local NumPoints=math.Clamp((math.ceil(100*(Dist/3000))+1),1,60)
	local PointTable={}
	PointTable[1]=SelfPos
	for i=2,NumPoints do
		local NewPoint
		local WeCantGoThere=true
		local C_P_I_L=0
		while(WeCantGoThere)do
			NewPoint=PointTable[i-1]+WanderDirection*Dist/NumPoints
			local CheckTr={}
			CheckTr.start=PointTable[i-1]
			CheckTr.endpos=NewPoint
			CheckTr.filter={victim}
			local CheckTra=util.TraceLine(CheckTr)
			if(CheckTra.Hit)then
				WanderDirection=(WanderDirection+CheckTra.HitNormal*0.5):GetNormalized()
			else
				WeCantGoThere=false
			end
			C_P_I_L=C_P_I_L+1;if(C_P_I_L>=200)then print("CRASH PREVENTION") break end
		end
		PointTable[i]=NewPoint
		local Randomness=(.000005*i^3)
		WanderDirection=(WanderDirection+VectorRand()*Randomness+(VictimPos-NewPoint):GetNormalized()*0.2):GetNormalized()
	end
	PointTable[NumPoints+1]=VictimPos
	
	for key,point in pairs(PointTable)do
		if not(key==NumPoints+1)then
			if(SERVER)then
				local Harg=EffectData()
				Harg:SetStart(point)
				Harg:SetOrigin(PointTable[key+1])
				Harg:SetScale(scale)
				util.Effect("eff_jack_plasmaarc",Harg,true,true)
			end
		end
	end
	
	sound.Play("snd_jack_hmcd_lightning.wav",VictimPos,80,100)
	sound.Play("snd_jack_hmcd_thunder.wav",VictimPos,160,100)
end

-- IMPORTED FROM FUNGUNS --
function HMCD_ArcToGround(victim,scale)
	if(victim:IsWorld())then return end
	local Trayuss=util.QuickTrace(victim:GetPos()+Vector(0,0,5),Vector(0,0,-30000),victim)
	if(Trayuss.Hit)then
		local NewStart=victim:GetPos()+Vector(0,0,5)
		ToVector=Trayuss.HitPos-NewStart
		Dist=ToVector:Length()	
		if(Dist>150)then
			WanderDirection=Vector(0,0,-1)
			NumPoints=math.Clamp((math.ceil(30*(Dist/1000))+1),1,50)
			PointTable={}
			PointTable[1]=NewStart
			for i=2,NumPoints do
				local NewPoint
				local WeCantGoThere=true
				C_P_I_L=0
				while(WeCantGoThere)do
					NewPoint=PointTable[i-1]+WanderDirection*Dist/NumPoints
					local CheckTr={}
					CheckTr.start=PointTable[i-1]
					CheckTr.endpos=NewPoint
					CheckTr.filter=victim
					local CheckTra=util.TraceLine(CheckTr)
					if(CheckTra.Hit)then
						WanderDirection=(WanderDirection+CheckTra.HitNormal*0.5):GetNormalized()
					else
						WeCantGoThere=false
					end
					C_P_I_L=C_P_I_L+1;if(C_P_I_L>=200)then print("CRASH PREVENTION; Arc effect started at a world-clipping entity.") break end
				end
				PointTable[i]=NewPoint
				WanderDirection=(WanderDirection+VectorRand()*0.3+(Trayuss.HitPos-NewPoint):GetNormalized()*0.2):GetNormalized()
			end
			PointTable[NumPoints+1]=Trayuss.HitPos
			for key,point in pairs(PointTable)do
				if not(key==NumPoints+1)then
					if(SERVER)then
						local Harg=EffectData()
						Harg:SetStart(point)
						Harg:SetOrigin(PointTable[key+1])
						Harg:SetScale(scale)
						util.Effect("eff_jack_plasmaarc",Harg,true,true)
					end
				end
			end
		else
			if(SERVER)then
				local Harg=EffectData()
				Harg:SetStart(NewStart)
				Harg:SetOrigin(Trayuss.HitPos)
				Harg:SetScale(scale)
				util.Effect("eff_jack_plasmaarc",Harg,true,true)
			end
		end
		sound.Play("snd_jack_hmcd_lightning.wav",victim:GetPos(),80,100)
		sound.Play("snd_jack_hmcd_thunder.wav",victim:GetPos(),160,100)
	end
end

-- DEVELOPED FOR BFS2114, IMPORTED FROM BFS2114
local function toInt(b) -- this awesome shit copied from Silverlan's Nodegraph Editor
	local i = {string.byte(b,1,4)}
	i = i[1] +i[2] *256 +i[3] *65536 +i[4] *16777216
	if(i > 2147483647) then return i -4294967296 end
	return i
end
HMCD_CountAiNodes=function()
	local File=file.Open("maps/graphs/"..game.GetMap()..".ain","rb","GAME")
	if(File)then
		local Lol1,Lol2,Lol3=File:Read(4),File:Read(4),File:Read(4)
		return toInt(Lol3)
	else
		return 0
	end
end

--[[
concommand.Add("homicide_identity_help",function(ply,cmd,args)
	net.Start("hmcd_help")
	net.WriteString("identity")
	net.Send(ply)
end)
--]]

concommand.Add("homicide_player_speed_mul",function(ply,cmd,args)
	if((ply.IsAdmin)and not(ply:IsAdmin()))then ply:PrintMessage(HUD_PRINTTALK,translate.youAreNoAdmin) return end
	local Num=tonumber(args[1])
	if(Num)then
		GAMEMODE.PLAYER_SPEED_MUL=Num
		print("Player movement ability multiplier set: "..tostring(GAMEMODE.PLAYER_SPEED_MUL))
		ply:PrintMessage(HUD_PRINTTALK,"Player movement ability multiplier set: "..tostring(GAMEMODE.PLAYER_SPEED_MUL))
	end
end)

concommand.Add("homicide_loot_spawn_mul",function(ply,cmd,args)
	if((ply.IsAdmin)and not(ply:IsAdmin()))then ply:PrintMessage(HUD_PRINTTALK,translate.youAreNoAdmin) return end
	local Num=tonumber(args[1])
	if(Num)then
		GAMEMODE.LOOT_SPAWN_MUL=Num
		print("Loot spawn rate multiplier set: "..tostring(GAMEMODE.LOOT_SPAWN_MUL))
		ply:PrintMessage(HUD_PRINTTALK,"Loot spawn rate multiplier set: "..tostring(GAMEMODE.LOOT_SPAWN_MUL))
	end
end)

HitLocationPhrases={
	[HITGROUP_HEAD]=translate.attHead,
	[HITGROUP_RIGHTARM]=translate.attRArm,
	[HITGROUP_LEFTARM]=translate.attLArm,
	[HITGROUP_LEFTLEG]=translate.attLLeg,
	[HITGROUP_RIGHTLEG]=translate.attRLeg,
	[HITGROUP_CHEST]=translate.attChest,
	[HITGROUP_STOMACH]=translate.attAbdomen,
	[HITGROUP_GEAR]="",
	[HITGROUP_GENERIC]=""
}