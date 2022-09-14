local PlayerMeta = FindMetaTable("Player")
local EntityMeta = FindMetaTable("Entity")

util.AddNetworkString("hmcd_playersilent")
util.AddNetworkString("hmcd_armor")
util.AddNetworkString("hmcd_flashlightpickup")
util.AddNetworkString("hmcd_openammomenu")
util.AddNetworkString("hmcd_openappearancemenu")

function GM:PlayerConnect(name,ip)
	timer.Simple(.1,function()
		for key,found in pairs(player.GetAll())do
			if(found:Nick()==name)then
				umsg.Start("HMCD_Identity",found)
				umsg.End()
			end
		end
	end)
end

function GM:PlayerInitialSpawn( ply )
	if not((ply)and(IsValid(ply)))then return end
	timer.Simple(.1,function()
		if((ply)and(IsValid(ply)))then
			umsg.Start("HMCD_Identity",ply)
			umsg.End()
		end
	end)

	ply.LootCollected = 0

	timer.Simple(0, function ()
		if IsValid(ply) then
			ply:KillSilent()
		end
	end)
	
	ply.HasMoved = true
	ply:SetTeam(2)

	self:NetworkRound(ply)

	self.LastPlayerSpawn = CurTime()

	local vec = Vector(0.5, 0.5, 0.5)
	ply:SetPlayerColor(vec)
end

function GM:PlayerSpawn( ply )
	-- If the player doesn't have a team
	-- then spawn him as a spectator
	local DatTeam=ply:Team()
	
	if(DatTeam==1)then
		if not(ply.RoundsSpectator)then ply.RoundsSpectator=0 end
		ply.RoundSpectator=ply.RoundsSpectator+1
		if(ply.RoundsSpectator>=3)then
			if not(ply:IsListenServerHost())then ply:Kick(translate.kickSpectate) else ply:Kill() end
			return
		end
	else
		ply.RoundsSpectator=0
	end
	
	if Team == 1 || Team == TEAM_UNASSIGNED then
		GAMEMODE:PlayerSpawnAsSpectator( ply )
		return
	end

	-- Stop observer mode
	ply:UnCSpectate()
	ply.Stamina=100
	ply.DynamicSprintSpeed=1
	ply.AttackerRecord={}
	ply.ForgiveTime=0
	--ply:SetFlashlightCharge(1)
	ply.Bleedout=0
	ply.TempSpeedMul=1
	ply.LastAttacker=nil
	ply.LastAttackerName=nil
	ply.LastDamageType=nil
	ply.LastBled=nil
	ply.LastHitLocation=nil
	ply.LifeID=math.random(1,100000) -- essentially a guid
	ply.FoodBoost=0
	ply.PainBoost=0
	ply.ContainingContainer=nil
	ply:SetHighOnDrugs(false)
	ply.HeldBreath=50
	ply.LastKillTime=0
	ply.MultiKill=1
	ply.GuardGuilty=false
	ply.DamageDealt=0
	ply.Unstickable=true
	ply.MurdererIdentityHidden=false
	ply.TrueIdentity=nil
	ply.Poisoned=false
	ply:SetCanZoom(false)
	ply:SetDSP(0,true)
	umsg.Start("HMCD_FoodBoost",ply)
	umsg.Short(0)
	umsg.End()
	umsg.Start("HMCD_PainBoost",ply)
	umsg.Short(0)
	umsg.End()
	if not(ply.Murderer)then ply.Innocent=true else ply.Innocent=false end

	player_manager.OnPlayerSpawn( ply )
	player_manager.RunClass( ply, "Spawn" )

	hook.Call( "PlayerSetModel", GAMEMODE, ply )

	local oldhands = ply:GetHands()
	if ( IsValid( oldhands ) ) then oldhands:Remove() end

	local hands = ents.Create( "gmod_hands" )
	hands.HmcdSpawned=true
	if ( IsValid( hands ) ) then
		ply:SetHands( hands )
		hands:SetOwner( ply )

		-- Which hands should we use?
		local cl_playermodel = ply:GetInfo( "cl_playermodel" )
		local info = player_manager.TranslatePlayerHands( cl_playermodel )
		if ( info ) then
			hands:SetModel( info.model )
			hands:SetSkin( info.skin )
			hands:SetBodyGroups( info.body )
		end

		-- Attach them to the viewmodel
		local vm = ply:GetViewModel( 0 )
		hands:AttachToViewmodel( vm )

		vm:DeleteOnRemove( hands )
		ply:DeleteOnRemove( hands )

		hands:Spawn()
	end

	local spawnPoint=self:PlayerSelectTeamSpawn(ply:Team(),ply)
	if(IsValid(spawnPoint))then ply:SetPos(spawnPoint:GetPos());ply.HMCD_SpawnPos=spawnPoint:GetPos() end
	for i=1,4 do
		timer.Simple(i*2,function()
			if((IsValid(ply))and(ply:GetPhysicsObject()))then
				if(ply:GetPhysicsObject():IsPenetrating())then
					print(tostring(ply).." spawned stuck in something. Repositioning")
					local spawnPoint=self:PlayerSelectTeamSpawn(ply:Team(),ply)
					if(IsValid(spawnPoint))then ply:SetPos(spawnPoint:GetPos());ply.HMCD_SpawnPos=spawnPoint:GetPos() end
				end
			end
		end)
	end
	
	timer.Simple(1,function() -- fuck you garry
		if((IsValid(ply))and(ply:Alive()))then -- fuck you robot boy
			umsg.Start("HMCD_FixViewModelGlitch",ply) -- fuck all of you
			umsg.End() -- why do i have to do this
		end -- this is so fucking hacky
	end) -- you pricks, just make your game work properly
	
	timer.Simple(10,function()
		if((ply)and(IsValid(ply))and(ply:Alive())and(ply.Murderer))then
			local mins=math.ceil((self.PoliceTime-CurTime())/60)
			if(self.SHTF)then
				local argh = Translator:AdvVarTranslate(translate.guardIn, {
					mins = {text = mins}
				})
				aargh = ""
				for k, msg in pairs(argh) do
					aargh = aargh..msg.text
				end
				ply:PrintMessage(HUD_PRINTTALK,aargh)
			else
				local argh = Translator:AdvVarTranslate(translate.policeIn, {
					mins = {text = mins}
				})
				aargh = ""
				for k, msg in pairs(argh) do
					aargh = aargh..msg.text
				end
				ply:PrintMessage(HUD_PRINTTALK,aargh)
			end
		end
	end)
	
	hook.Call( "PlayerLoadout", GAMEMODE, ply )
	timer.Simple(1,function()
		if((IsValid(ply))and(ply:Alive()))then
			if not(ply:HasWeapon("wep_jack_hmcd_hands"))then -- some maps do some weird override thing
				GAMEMODE:PlayerLoadout(ply)
			end
		end
	end)
end

function GM:PlayerLoadout(ply)
	ply:StripWeapons()
	ply:StripAmmo()
	ply.HasFlashlight=false
	ply.HMCD_Light=nil
	ply:SetHeadArmor(nil)
	ply:SetChestArmor(nil)
	ply.InfiniShuriken=false
	if((self.ZOMBIE)and(ply.Murderer))then
		ply:Give("wep_jack_hmcd_zombhands")
	else
		ply:Give("wep_jack_hmcd_hands")
		if(self.SHTF)then
			if(self.DEATHMATCH)then
				ply:Give("wep_jack_hmcd_pocketknife")
				ply:Give("wep_jack_hmcd_pistol")
				ply:GetWeapon("wep_jack_hmcd_pistol"):SetClip1(13)
				ply:GiveAmmo(26,"Pistol",true)
				ply:Give("wep_jack_hmcd_oldgrenade_dm")
				ply:Give("wep_jack_hmcd_bandage")
				ply:Give("wep_jack_hmcd_walkietalkie")
				ply.HasFlashlight=true
				timer.Simple(math.Rand(1,5),function()
					if(IsValid(ply))then
						ply:SetHeadArmor("ACH")
						ply:SetChestArmor("Level IIIA")
					end
				end)
			else
				if ply.Murderer then -- DAT MURDERER CAME PREPARED TO MURDER, DIDN'E?
					ply:Give("wep_jack_hmcd_knife")
					ply:Give("wep_jack_hmcd_poisonpowder")
					ply:Give("wep_jack_hmcd_smokebomb")
					ply:Give("wep_jack_hmcd_adrenaline")
					ply:Give("wep_jack_hmcd_suppressed")
					ply:Give("wep_jack_hmcd_walkietalkie")
					ply:Give("wep_jack_hmcd_oldgrenade")
					ply:Give("wep_jack_hmcd_poisoncanister")
					ply:Give("wep_jack_hmcd_poisonliquid")
					ply:Give("wep_jack_hmcd_mask")
					ply:GetWeapon("wep_jack_hmcd_suppressed"):SetClip1(10)
					ply.HasFlashlight=true
				elseif(ply.ArmedAtSpawn)then
					if(math.random(1,2)==1)then
						ply:Give("wep_jack_hmcd_shotgun")
						ply:GetWeapon("wep_jack_hmcd_shotgun"):SetClip1(6)
					else
						ply:Give("wep_jack_hmcd_rifle")
						ply:GetWeapon("wep_jack_hmcd_rifle"):SetClip1(5)
					end
				end
			end
		else
			if(self.EPIC)then
				ply:Give("wep_jack_hmcd_revolver")
				ply:GetWeapon("wep_jack_hmcd_revolver"):SetClip1(6)
				if(ply.Murderer)then
					ply:Give("wep_jack_hmcd_knife")
					ply:Give("wep_jack_hmcd_smokebomb")
					ply:Give("wep_jack_hmcd_ied")
					ply:GiveAmmo(6,"357",true)
					ply.HasFlashlight=true
				end
			else
				if ply.Murderer then -- DAT MURDERER CAME PREPARED TO MURDER, DIDN'E?
					if(self.ISLAM)then
						ply:Give("wep_jack_hmcd_knife")
						ply:Give("wep_jack_hmcd_ied")
						ply:Give("wep_jack_hmcd_pipebomb")
						ply:Give("wep_jack_hmcd_jihad")
					else
						ply:Give("wep_jack_hmcd_knife")
						ply:Give("wep_jack_hmcd_shuriken")
						ply.InfiniShuriken=true
						ply:Give("wep_jack_hmcd_poisonneedle")
						ply:Give("wep_jack_hmcd_poisonpowder")
						ply:Give("wep_jack_hmcd_ied")
						ply:Give("wep_jack_hmcd_smokebomb")
						ply:Give("wep_jack_hmcd_fakepistol")
						ply:Give("wep_jack_hmcd_adrenaline")
						ply:Give("wep_jack_hmcd_jam")
						ply:Give("wep_jack_hmcd_poisonliquid")
						ply:Give("wep_jack_hmcd_poisongoo")
						ply:Give("wep_jack_hmcd_poisoncanister")
						ply:Give("wep_jack_hmcd_mask")
						ply.HasFlashlight=true
					end
				elseif(ply.ArmedAtSpawn)then
					ply:Give("wep_jack_hmcd_smallpistol")
					ply:GetWeapon("wep_jack_hmcd_smallpistol"):SetClip1(10)
				end
			end
		end
	end
	for key,wep in pairs(ply:GetWeapons())do
		if(wep.HomicideSWEP)then wep.HmcdSpawned=true end
	end
	net.Start("hmcd_flashlightpickup")
	net.WriteEntity(ply)
	net.WriteBit(ply.HasFlashlight)
	net.Broadcast()
end

function GM:PlayerSetModel(ply)
	local cl_playermodel,playerModel=ply:GetInfo("cl_playermodel"),table.Random(HMCD_PlayerModelInfoTable)
	if((self.ZOMBIE)and(ply.Murderer))then
		playerModel={
			model="Homicide Alpha-Zombie",
			sex="male",
			clothes=""
		}
	elseif(ply.CustomModel)then
		for key,maudhayle in pairs(HMCD_PlayerModelInfoTable)do -- WOW FAGGOT
			if(maudhayle.model==ply.CustomModel)then playerModel=maudhayle break end
		end
	end
	cl_playermodel = playerModel.model
	local modelname = player_manager.TranslatePlayerModel( cl_playermodel )
	util.PrecacheModel( modelname )
	ply:SetModel( modelname )
	ply.ModelSex = playerModel.sex
	ply.ClothingMatIndex=playerModel.clothes
end

function GM:DoPlayerDeath(ply,attacker,dmginfo)
	local Infl=dmginfo:GetInflictor()
	if((Infl)and(Infl:IsVehicle())and(Infl:GetDriver()))then attacker=Infl:GetDriver() end
	if((IsValid(Infl))and(Infl:GetClass()=="ent_jack_hmcd_grapl"))then attacker=Infl.Owner end
	if((self:GetRound()==1)and not(ply:IsBot()))then
		if((IsValid(attacker))and(attacker:IsPlayer())and not(attacker==ply))then
			local Slash,Blast,Bullet,Buckshot,Burn,Club,Crush,Poison,Bleed=dmginfo:IsDamageType(DMG_SLASH),dmginfo:IsDamageType(DMG_BLAST),dmginfo:IsDamageType(DMG_BULLET),dmginfo:IsDamageType(DMG_BUCKSHOT),dmginfo:IsDamageType(DMG_BURN),dmginfo:IsDamageType(DMG_CLUB),dmginfo:IsDamageType(DMG_CRUSH),dmginfo:IsDamageType(DMG_POISON),dmginfo:IsDamageType(DMG_GENERIC)
			-- print(attacker)
			if(self.DEATHMATCH)then
				attacker:AddMerit(3)
			else
				if(attacker.Murderer)then
					local Mul=1
					if(Poison)then Mul=Mul*2 end
					attacker:AddMerit(1*Mul)
				elseif(ply.Murderer)then
					attacker:AddMerit(3)
				elseif(ply.Innocent)then -- you teamkilling fucktard
					attacker:AddDemerit(2)
				end
			end
		end
		if not((#team.GetPlayers(2)<2)and(#player.GetBots()>0))then
			if(self.DEATHMATCH)then
				ply:AddDemerit(3)
			else
				ply:AddDemerit(1)
			end
		end
	end

	for k, weapon in pairs(ply:GetWeapons()) do
		if weapon.DeathDroppable then
			ply:DropWeapon(weapon)
		end
	end
	ply:UnMurdererDisguise()
	ply:Freeze(false)
	ply:CreateRagdoll()
	local ent=ply:GetNWEntity("DeathRagdoll")
	if IsValid(ent) then
		ply:CSpectate(OBS_MODE_CHASE, ent)
		ent:SetBystanderName(ply:GetBystanderName())
		if(ply:IsOnFire())then ent:Ignite(10) end
	end
	ply:Extinguish()

	ply:AddDeaths( 1 )

	if ( attacker:IsValid() && attacker:IsPlayer() ) then

		if ( attacker == ply ) then
			attacker:AddFrags( -1 )
		else
			attacker:AddFrags( 1 )
			
			if(attacker.Murderer)then
				if((attacker.LastKillTime+4)>CurTime())then
					attacker.MultiKill=attacker.MultiKill+1
					if(attacker.MultiKill>1)then
						local KillNum=attacker.MultiKill
						timer.Simple(.5,function()
							if((IsValid(attacker))and(KillNum==attacker.MultiKill))then
								umsg.Start("HMCD_SurfaceSound",attacker)
								umsg.String("snd_jack_hmcd_mk_"..KillNum..".wav")
								umsg.End()
							end
						end)
						timer.Simple(4.5,function()
							if((IsValid(attacker))and(KillNum==attacker.MultiKill))then -- if multikill streak timer expires, award extra points for total streak
								attacker:AddMerit(KillNum)
							end
						end)
					end
				else
					attacker.MultiKill=1
				end
				attacker.LastKillTime=CurTime()
			end
		end
	end
	
	PrintTable(ply.AttackerRecord)
	local TotalWrong=0
	for badman,dmg in pairs(ply.AttackerRecord)do
		TotalWrong=TotalWrong+dmg
	end
	if(TotalWrong>=50)then
		ply.ForgiveTime=CurTime()+10
		net.Start("hmcd_forgive")
		net.Send(ply)
	end
	
	local DeathString,ServerDeathString="",""
	local Att=ply.LastAttackerName
	local Typ=ply.LastDamageType or translate.attGeneric
	if(ply.LastBled)then
		ServerDeathString=ply:Nick()..translate.attTheyBledToDeath
		DeathString=translate.attYouBledToDeath
	else
		ServerDeathString=ply:Nick()..translate.attHeWas
		DeathString=translate.attYouWere
	end
	ServerDeathString=ServerDeathString..Typ.." "
	DeathString=DeathString..Typ.." "
	if((ply.LastHitLocation)and not(ply.LastHitLocation==HITGROUP_GENERIC)and not(ply.LastHitLocation==HITGROUP_GEAR))then
		ServerDeathString=ServerDeathString..HitLocationPhrases[ply.LastHitLocation].." "
		DeathString=DeathString..HitLocationPhrases[ply.LastHitLocation].." "
	end
	if((Att)and not(Att==""))then
		local ServerAtt=Att
		if(Att==ply:GetBystanderName())then Att=translate.attYourself;ServerAtt=translate.attHimself end
		ServerDeathString=ServerDeathString..translate.attBy..ServerAtt
		DeathString=DeathString..translate.attBy..Att
	end
	if((SERVER)and(HMCD_DebugPrint))then print(ServerDeathString) end
	ply:PrintMessage(HUD_PRINTTALK,DeathString)
end

local plyMeta = FindMetaTable("Player")

function plyMeta:CalculateSpeed()
	--print(self:GetEyeTrace().HitPos:Distance(self:GetShootPos())/52)
	if(self:InVehicle())then return end
	local walk,run,jumppower,wep,DSM,ground,ballsToWall,gMul,Time=120,390,245,self:GetActiveWeapon(),self.DynamicSprintSpeed,self:IsOnGround(),self:KeyDown(IN_SPEED),GAMEMODE.PLAYER_SPEED_MUL,CurTime()
	if((GAMEMODE.ZOMBIE)and(self.Murderer))then
		walk=walk*.5
		run=run*.5
	end
	if(self.Murderer)then run=run*1.1 end
	if(GAMEMODE.SHTF)then run=run*1.1 end
	if(IsValid(wep))then
		if wep.GetCarrying && IsValid(wep:GetCarrying()) && IsValid(wep:GetCarrying():GetPhysicsObject()) then
			if(wep:GetCarrying():GetPhysicsObject():GetMass()>30)then
				walk=walk*.5
				run=run*.5
				jumppower=jumppower*.5
			end
		end
	end
	if(ground)then
		local Pos,Forward=self:GetPos(),self:GetVelocity():GetNormalized()
		Forward.z=0
		local Here,Ground=util.QuickTrace(Pos+Vector(0,0,20),Vector(0,0,-40),{self}),self:GetGroundEntity()
		if((Here.Hit)and(Ground))then
			Here=Here.Fraction*20
			local There=util.QuickTrace(Pos+Forward*30+Vector(0,0,20),Vector(0,0,-40),{self})
			if((There.Hit)and(There.Entity)and(There.Entity==Ground))then
				There=There.Fraction*20
				local Diff=(Here-There)
				if(Diff>=6)then
					run=run*.5
					walk=walk*.5
				end
			end
		end
	end
	if not(self.NextWeightCalcTime)then self.NextWeightCalcTime=0 end
	if(self.NextWeightCalcTime<Time)then
		self.NextWeightCalcTime=Time+1
		local Weight=0
		for key,wep in pairs(self:GetWeapons())do
			if(wep.CarryWeight)then Weight=Weight+wep.CarryWeight end
		end
		for typ,wght in pairs(HMCD_AmmoWeights)do
			local Amt=self:GetAmmoCount(typ)
			if(Amt>0)then Weight=Weight+Amt*wght end
		end
		if(self.HasFlashlight)then Weight=Weight+800 end
		if((self.ChestArmor)and(self.ChestArmor=="Level III"))then Weight=Weight+10000 end
		if((self.ChestArmor)and(self.ChestArmor=="Level IIIA"))then Weight=Weight+2000 end
		if((self.HeadArmor)and(self.HeadArmor=="ACH"))then Weight=Weight+2000 end
		self.CarryWeightSpeedMul=math.Clamp(1-(Weight/100000),0,1)
		self.CarryWeightStaminaMul=math.Clamp(1-(Weight/100000),0,1)
	end
	local Helths,wMul=self:Health(),self.CarryWeightSpeedMul or 1
	if(self.HighOnDrugs)then Helths=100 end
	if(self.PainBoost>CurTime())then Helths=math.Clamp(Helths,99,100) end
	local mul=math.Clamp((self.Stamina/100)*((Helths*.5+50)/100)*self.TempSpeedMul,.1,1)
	--mul=mul*self.Stature -- longer legs faster move
	--print(CurTime())
	if((ground)and(ballsToWall)and(self:KeyDown(IN_FORWARD)))then
		DSM=math.Clamp(DSM+16,1,100)
	else
		DSM=1
	end
	local SprintAdd=run-walk
	self.DynamicSprintSpeed=DSM
	self:SetCrouchedWalkSpeed(.5*gMul*wMul)
	self:SetMaxSpeed((walk+(SprintAdd*(DSM/100))*mul)*gMul*wMul)
	self:SetRunSpeed((walk+(SprintAdd*(DSM/100))*mul)*gMul*wMul)
	self:SetWalkSpeed(walk*mul*gMul*wMul)
	self:SetJumpPower(jumppower*mul*gMul*wMul)
end

local function isValid() return true end
local function getPos(self) return self.pos end

local function generateSpawnEntities(spawnList)
	local tbl = {}

	for k, pos in pairs(spawnList) do
		local t = {}
		t.IsValid = isValid
		t.GetPos = getPos
		t.pos = pos
		table.insert(tbl, t)
	end

	return tbl
end

function GM:IsSpawnpointSuitable(ply,spawnpointent,bMakeSuitable)
	local Pos=spawnpointent:GetPos()
	local Ents=ents.FindInBox(Pos+Vector(-16,-16,0),Pos+Vector(16,16,72))
	local Tem=2
	if(ply:IsPlayer())then Tem=ply:Team() end
	if(Tem==TEAM_SPECTATOR or Tem==TEAM_UNASSIGNED)then return true end
	local Blockers=0
	for k,v in pairs(Ents) do
		if(IsValid(v) && v:GetClass()=="player" && v:Alive())then
			Blockers=Blockers+1
			if(bMakeSuitable)then
				v:SetPos(v:GetPos()+Vector(math.random(-100,100),math.random(-100,100),0))
			end
		end
	end
	if(bMakeSuitable)then return true end
	if(Blockers>0)then return false end
	return true
end

function GM:PlayerSelectTeamSpawn(TeamID,pl)
	local SpawnPoints=generateSpawnEntities(TeamSpawns)
	if(!SpawnPoints || table.Count(SpawnPoints)<2)then
		SpawnPoints=table.Add(ents.FindByClass("info_player_deathmatch"),ents.FindByClass("info_player_start"))
		SpawnPoints=table.Add(SpawnPoints,ents.FindByClass("info_player_terrorist"))
		SpawnPoints=table.Add(SpawnPoints,ents.FindByClass("info_player_counterterrorist"))
	end
	if(!SpawnPoints || table.Count(SpawnPoints)<2)then return end
	local ChosenSpawnPoint=nil
	for i=1,10 do
		ChosenSpawnPoint=table.Random(SpawnPoints)
		if(self:IsSpawnpointSuitable(pl,ChosenSpawnPoint,true))then
			return ChosenSpawnPoint
		end
	end
	return ChosenSpawnPoint
end


function GM:PlayerDeathSound()
	// don't play sound
	return true
end

function GM:ScalePlayerDamage(ply,hitgroup,dmginfo)
	local Mul,Dam,Bullet,Shrapnel=1,dmginfo:GetDamage(),dmginfo:IsDamageType(DMG_BULLET),dmginfo:IsDamageType(DMG_BUCKSHOT)
	if(hitgroup==HITGROUP_HEAD)then
		local Protected=false
		if((ply.HeadArmor)and(ply.HeadArmor=="ACH"))then
			if(math.Rand(0,1)<=.7)then
				Protected=true
				sound.Play("snd_jack_hmcd_ricochet_"..math.random(1,2)..".wav",ply:GetShootPos(),70,math.random(90,100))
			end
		end
		local Att=dmginfo:GetAttacker()
		if(((ply.Murderer)and(Bullet))or((IsValid(Att))and(Att.Murderer)))then
			if((IsValid(Att))and(Att:IsPlayer()))then
				local Wep=Att:GetActiveWeapon()
				if((IsValid(Wep))and(Wep.GetAiming)and(Wep:GetAiming()>90)and not(Protected))then
					umsg.Start("HMCD_SurfaceSound",dmginfo:GetAttacker())
					umsg.String("snd_jack_hmcd_hedshott.wav")
					umsg.End()
				end
			end
		end
		if(Protected)then
			Mul=Mul*.01
		else
			Mul=Mul*10
		end
	elseif((hitgroup==HITGROUP_LEFTLEG)or(hitgroup==HITGROUP_RIGHTLEG))then
		Mul=Mul*.2
		ply.TempSpeedMul=.1
		umsg.Start("HMCD_StatusEffect",ply)
		umsg.String(translate.statusEffectImmobilized)
		umsg.End()
	elseif((hitgroup==HITGROUP_RIGHTARM)or(hitgroup==HITGROUP_LEFTARM)or(hitgroup==HITGROUP_GEAR))then
		Mul=Mul*.2
		ply:SelectWeapon("wep_jack_hmcd_hands")
		umsg.Start("HMCD_StatusEffect",ply)
		umsg.String(translate.statusEffectDisarmed)
		umsg.End()
	elseif(hitgroup==HITGROUP_STOMACH)then
		Mul=Mul*.5
	elseif(hitgroup==HITGROUP_CHEST)then
		if((ply.ChestArmor)and(ply.ChestArmor!=""))then
			if((Bullet)or(Shrapnel))then
				if(ply.ChestArmor=="Level IIIA")then
					if(Dam<65)then Mul=Mul/20 end
				elseif(ply.ChestArmor=="Level III")then
					sound.Play("SolidMetal.BulletImpact",ply:GetPos(),55,120)
					if(Dam<65)then Mul=Mul/40 elseif(Dam<=130)then Mul=Mul/20 end
				end
			end
		end
	elseif(hitgroup==HITGROUP_GENERIC)then
		if((ply.ChestArmor)and(ply.ChestArmor=="Level III"))then
			if((dmginfo:IsDamageType(DMG_CLUB))or(dmginfo:IsDamageType(DMG_SLASH)))then
				sound.Play("SolidMetal.BulletImpact",ply:GetPos(),55,120)
				Mul=Mul/5
			end
		end
		if((ply.ChestArmor)and((ply.ChestArmor=="Level IIIA")or(ply.ChestArmor=="Level III")))then
			if(Shrapnel)then
				Mul=Mul/3
			elseif(Bullet)then
				if(ply.ChestArmor=="Level IIIA")then
					if(Dam<65)then Mul=Mul/20 end
				elseif(ply.ChestArmor=="Level III")then
					sound.Play("SolidMetal.BulletImpact",ply:GetPos(),55,120)
					if(Dam<65)then Mul=Mul/40 elseif(Dam<=130)then Mul=Mul/20 end
				end
			end
		end
	end
	if not(dmginfo:IsDamageType(DMG_GENERIC))then ply.LastHitLocation=hitgroup end
	dmginfo:ScaleDamage(Mul)
end

function GM:PlayerDeath(ply, Inflictor, attacker )
	if((Inflictor)and(Inflictor:IsVehicle())and(Inflictor:GetDriver()))then attacker=Inflictor:GetDriver() end
	if((IsValid(Inflictor))and(Inflictor:GetClass()=="ent_jack_hmcd_grapl"))then attacker=Inflictor.Owner end
	self:DoRoundDeaths(ply, attacker)

	if (attacker.ModelSex == "male") then
		s = translate.ms
	else
		s = translate.fs
	end

	if !ply.Murderer then

		self.MurdererLastKill = CurTime()
		local murderer
		local players = team.GetPlayers(2)
		for k,v in pairs(players) do
			if v.Murderer then
				murderer = v
			end
		end

		if IsValid(attacker) && attacker:IsPlayer() then
			if attacker.Murderer then
				-- self:SendMessageAll("The murderer has struck again")
			elseif attacker != ply then
				local col,msgs,col2=attacker:GetPlayerColor(),nil,ply:GetPlayerColor()
				if(ply.Innocent)then
					if(self.SHTF)then
						msgs = Translator:AdvVarTranslate(translate.killedTeamKillInnocent, {
							player = {text = attacker:GetBystanderName(), color = Color(col.x * 255, col.y * 255, col.z * 255)},
							s = {text = s}
						})
					else
						msgs = Translator:AdvVarTranslate(translate.killedTeamKill, {
							player = {text = attacker:GetBystanderName(), color = Color(col.x * 255, col.y * 255, col.z * 255)},
							s = {text = s}
						})
					end
				else
					msgs = Translator:AdvVarTranslate(translate.killedTeamKillAggressive, {
						player = {text = attacker:GetBystanderName(), color = Color(col.x * 255, col.y * 255, col.z * 255)},
						s = {text = s}
					})
				end
				if(self.DEATHMATCH)then
					msgs = Translator:AdvVarTranslate(translate.killedDM, {
						player = {text = attacker:GetBystanderName(), color = Color(col.x * 255, col.y * 255, col.z * 255)},
						ded = {text = ply:GetBystanderName(), color = Color(col2.x * 255, col2.y * 255, col2.z * 255)},
						s = {text = s}
					})
				end
				if(self:GetRound()==1)then
					local ct = ChatText()
					ct:AddParts(msgs)
					ct:SendAll()
					--[[
					if(ply.Innocent)then
						attacker:SetTKer(true)
					end
					--]]
				end
			end
			-- self:SendMessageAll("An bystander died in mysterious circumstances")
		else
		end
	else
		if attacker != ply && IsValid(attacker) && attacker:IsPlayer() then
			local col,col2 = attacker:GetPlayerColor(),ply:GetPlayerColor()
			local msgs,RealName,GameName=nil,attacker:Nick(),attacker:GetBystanderName()
			if(RealName==GameName)then
				if(self.ZOMBIE)then
					msgs=Translator:AdvVarTranslate(translate.killedZombie, {
						player = {text = GameName, color = Color(col.x * 255, col.y * 255, col.z * 255)},
						s = {text = s}
					})
				elseif(self.SHTF)then
					msgs=Translator:AdvVarTranslate(translate.killedTraitor, {
						player = {text = GameName, color = Color(col.x * 255, col.y * 255, col.z * 255)},
						s = {text = s}
					})
				else
					msgs=Translator:AdvVarTranslate(translate.killedMurderer, {
						player = {text = GameName, color = Color(col.x * 255, col.y * 255, col.z * 255)},
						s = {text = s}
					})
				end
			else
				if(self.SHTF)then
					msgs=Translator:AdvVarTranslate(translate.killedTraitor, {
						player = {text = RealName .. ", " .. GameName, color = Color(col.x * 255, col.y * 255, col.z * 255)},
						s = {text = translate.ms}
					})
				else
					msgs=Translator:AdvVarTranslate(translate.killedMurderer, {
						player = {text = RealName .. ", " .. GameName, color = Color(col.x * 255, col.y * 255, col.z * 255)},
						s = {text = translate.ms}
					})
				end
			end
			if(self.DEATHMATCH)then
				msgs = Translator:AdvVarTranslate(translate.killedDM, {
					player = {text = attacker:GetBystanderName(), color = Color(col.x * 255, col.y * 255, col.z * 255)},
					ded = {text = ply:GetBystanderName(), color = Color(col2.x * 255, col2.y * 255, col2.z * 255)},
					s = {text = s}
				})
			end
			local ct = ChatText()
			ct:AddParts(msgs)
			ct:SendAll()
		elseif(attacker!=ply && IsValid(attacker) && attacker:IsNPC())then
			local ct = ChatText()
			if(self.ZOMBIE)then
				ct:Add(translate.guardShotZombie)
			elseif(self.SHTF)then
				ct:Add(translate.guardShotTraitor)
			else
				ct:Add(translate.policeShotMurderer)
			end
			ct:SendAll()
		else
			local ct = ChatText()
			if(self.SHTF)then
				ct:Add(translate.traitorDeathUnknown)
			else
				ct:Add(translate.murdererDeathUnknown)
			end
			ct:SendAll()
		end
	end

	ply.NextSpawnTime = CurTime() + 6
	ply.DeathTime = CurTime()
	ply.SpectateTime = CurTime() + 5

	umsg.Start("rp_death", ply)
	umsg.Long(6)
	umsg.Long(5)
	umsg.End()
	
	if ( Inflictor && Inflictor == attacker && (Inflictor:IsPlayer() || Inflictor:IsNPC()) ) then
	
		Inflictor = Inflictor:GetActiveWeapon()
		if ( !Inflictor || Inflictor == NULL ) then Inflictor = attacker end
	
	end

	self:RagdollSetDeathDetails(ply, Inflictor, attacker)
end

function GM:PlayerDeathThink(ply)
	if self:CanRespawn(ply) then
		ply:Spawn()
	else
		self:ChooseSpectatee(ply)
	end
	
end

function EntityMeta:GetPlayerColor()
	return self.playerColor or Vector()
end

function EntityMeta:SetPlayerColor(vec)
	self.playerColor = vec
	self:SetNWVector("playerColor", vec)
end

function GM:PlayerFootstep(ply,pos,foot,snd,volume,filter)
	self:FootstepsOnFootstep(ply,pos,foot,snd,volume,filter)
	net.Start("hmcd_playersilent")
	net.WriteEntity(ply)
	if((ply.Murderer)and(ply:KeyDown(IN_WALK))and not(ply:KeyDown(IN_SPEED)))then
		net.WriteBit(true)
	else
		net.WriteBit(false)
	end
	net.Send(player.GetAll())
end

function GM:PlayerCanPickupWeapon( ply, ent )

	// can't pickup a weapon twice
	if ply:HasWeapon(ent:GetClass()) then
		return false
	end

	if ent:GetClass() == "wep_jack_hmcd_smallpistol" then
		// murderer can't have the gun
		if ply.Murderer then
			return false
		end
	end

	if ent:GetClass() == "wep_jack_hmcd_shuriken" then
		// bystanders can't have the knife
		if !ply.Murderer then
			return false
		end
	end

	return true
end

function GM:PlayerCanHearPlayersVoice( listener, talker )
	if !IsValid(talker) then return false end
	return self:PlayerCanHearChatVoice(listener, talker, "voice")
end

function GM:PlayerCanHearChatVoice(listener, talker, typ)
	if self.RoundStage != 1 then
		return true
	end
	if self:GetRound() == 1 && self.RoundUnFreezePlayers && self.RoundUnFreezePlayers > CurTime() then
		return true
	end
	if !talker:Alive() || talker:Team() != 2 then
		return !listener:Alive() || listener:Team() != 2
	end
	
	local ply = listener

	-- listen as if spectatee when spectating
	if listener:IsCSpectating() && IsValid(listener:GetCSpectatee()) then
		ply = listener:GetCSpectatee()
	end
	
	local Wep=talker:GetActiveWeapon()
	if((IsValid(Wep))and(Wep:GetClass()=="wep_jack_hmcd_walkietalkie"))then
		if((ply)and(ply.Alive)and(ply:Alive())and(ply.HasWeapon)and(ply:HasWeapon("wep_jack_hmcd_walkietalkie")))then
			return true
		end
	end
	
	local dis,MaxDist=ply:GetPos():Distance(talker:GetPos()),1500
	if not((talker:Visible(ply))or(ply:Visible(talker)))then MaxDist=500 end
	if dis < MaxDist then
		return true
	end
	return false
end

function GM:PlayerDisconnected(ply)
	self:PlayerLeavePlay(ply)
end

function GM:PlayerOnChangeTeam(ply, newTeam, oldTeam) 
	if oldTeam == 2 then
		self:PlayerLeavePlay(ply)	
	end
	ply:SetMurderer(false)
	if newteam == 1 then
		
	end
	ply.HasMoved = true
	ply:KillSilent()
end

concommand.Add("mu_jointeam", function (ply, com, args)
	local newTeam = tonumber(args[1] or "") or 0
	if ply.LastChangeTeam && ply.LastChangeTeam + 5 > CurTime() then return end
	ply.LastChangeTeam = CurTime()

	local curTeam = ply:Team()
	if newTeam >= 1 && newTeam <= 2 && newTeam != curTeam then
		ply:SetTeam(newTeam)
		GAMEMODE:PlayerOnChangeTeam(ply, newTeam, curTeam)

		local msgs = Translator:AdvVarTranslate(translate.changeTeam, {
			player = {text = ply:Nick(), color = team.GetColor(curTeam)},
			team = {text = team.GetName(newTeam), color = team.GetColor(newTeam)}
		})
		local ct = ChatText()
		ct:AddParts(msgs)
		ct:SendAll()
	end
end)

concommand.Add("hmcd_movetospectate", function (ply, com, args)
	if !ply:IsAdmin() then return end
	if #args < 1 then return end

	local ent = Entity(tonumber(args[1]) or -1)
	if !IsValid(ent) || !ent:IsPlayer() then return end
	
	local curTeam = ent:Team()
	if 1 != curTeam then
		ent:SetTeam(1)
		GAMEMODE:PlayerOnChangeTeam(ent, 1, curTeam)

		local msgs = Translator:AdvVarTranslate(translate.teamMoved, {
			player = {text = ent:Nick(), color = team.GetColor(curTeam)},
			team = {text = team.GetName(1), color = team.GetColor(1)}
		})
		local ct = ChatText()
		ct:AddParts(msgs)
		ct:SendAll()
	end
end)

concommand.Add("mu_spectate", function (ply, com, args)
	if !ply:IsAdmin() then return end
	if #args < 1 then return end

	local ent = Entity(tonumber(args[1]) or -1)
	if !IsValid(ent) || !ent:IsPlayer() then return end
	
	if ply:Alive() && ply:Team() != 1 then
		local ct = ChatText()
		ct:Add(translate.spectateFailed)
		ct:Send(ply)
		return
	end
	ply:CSpectate(OBS_MODE_IN_EYE, ent)
end)

function GM:PlayerCanSeePlayersChat( text, teamOnly, listener, speaker )
	if !IsValid(speaker) then return false end
	local canhear = self:PlayerCanHearChatVoice(listener, speaker) 
	return canhear
end

local HardFrics,SoftFrics=translate.table.hardFrics,translate.table.softFrics
local Alphabet=translate.table.alphabet
function GM:PlayerSay(ply,text,teem)
	if ply:Team()==2 && ply:Alive() && self:GetRound()!=0 then
		if(string.lower(text)=="*drop")then
			local Wep=ply:GetActiveWeapon()
			if((IsValid(Wep))and(Wep.CommandDroppable)and not((self.SHTF)and(Wep.SHTF_NoDrop)))then
				ply:DropWeapon(Wep)
				return ""
			end
		elseif(string.lower(text)=="*unstick")then
			if not(ply.HMCD_SpawnPos)then ply.HMCD_SpawnPos=ply:GetPos() end
			if(ply.Unstickable)then
				local Wall,Playa,Still,SelfPos=ply:GetPhysicsObject():IsPenetrating(),nil,ply.HMCD_SpawnPos==ply:GetPos() or (ply.HMCD_SpawnPos-ply:GetPos()):Length()==31,ply:GetPos()
				for key,playa in pairs(team.GetPlayers(2))do
					if not(playa==ply)then
						local PlayaPos=playa:GetPos()
						local Dist=(PlayaPos-SelfPos):Length()
						if(Dist<20)then Playa=playa break end
						if((math.abs(PlayaPos.x-SelfPos.x)<19)and(math.abs(PlayaPos.y-SelfPos.y)<19)and(Dist<70))then Playa=playa break end
					end
				end
				if(((Wall)or(Playa)or(Still))and not(ply:InVehicle())and not(ply.HiddenInContainer))then
					ply.Unstickable=false
					ply:PrintMessage(HUD_PRINTTALK,translate.stuck)
					local Tr=util.TraceLine({
						start=ply:GetShootPos(),
						endpos=ply:GetShootPos()+ply:GetAimVector()*500,
						filter={ply,Playa}
					})
					if(Tr.Hit)then
						local Stert=Tr.HitPos+Tr.HitNormal*25
						local DownTr=util.TraceLine({
							start=Stert,
							endpos=Stert+Vector(0,0,-1000),
							filter={ply,Playa}
						})
						if(DownTr.Hit)then
							ply:SetPos(DownTr.HitPos+DownTr.HitNormal*10)
						else
							ply:SetPos(Stert)
						end
					else
						ply:SetPos(ply:GetShootPos()+ply:GetAimVector()*500)
					end
				else
					ply:PrintMessage(HUD_PRINTTALK,translate.stuckUnable)
				end
			else
				ply:PrintMessage(HUD_PRINTTALK,translate.stuckAlready)
			end
		elseif(ply.Seizuring)then
			local Chars=string.Explode("",string.lower(text))
			for key,characta in pairs(Chars)do
				local Fric=nil
				for k,v in pairs(HardFrics)do
					if(characta==v)then Fric=k;break end
				end
				if(Fric)then
					Chars[key]=SoftFrics[Fric]
				elseif((math.random(1,10)==1)and(table.HasValue(Alphabet,characta)))then
					Chars[key]=table.Random(Alphabet)
				end
			end
			text=string.Implode("",Chars)
		end
		local Wep,WalkieTalkie=ply:GetActiveWeapon(),false
		if((IsValid(Wep))and(Wep:GetClass()=="wep_jack_hmcd_walkietalkie"))then WalkieTalkie=true end
		local col=ply:GetPlayerColor()
		for k,ply2 in pairs(player.GetAll()) do
			local can=hook.Call("PlayerCanSeePlayersChat", GAMEMODE, text, teem, ply2, ply)
			if(can)then
				local ct=ChatText()
				if((WalkieTalkie)and not(ply2==ply))then
					ct:Add(translate.weaponWalkieTalkie,color_white)
				else
					ct:Add(ply:GetBystanderName(), Color(col.x * 255, col.y * 255, col.z * 255))
				end
				ct:Add(": " .. text, color_white)
				ct:Send(ply2)
				if(WalkieTalkie)then sound.Play("snd_jack_hmcd_walkietalkie.wav",ply2:GetShootPos(),50,100) end
			end
		end
		local Extra=""
		if(WalkieTalkie)then Extra=translate.radio end
		if(SERVER)then print(ply:Nick()..": "..text..Extra) end
		return false
	end
	return true
end

function GM:PlayerShouldTaunt( ply, actid )
	return false
end

function GM:GetTKPenaltyTime()
	return math.max(0, 5)
end

function GM:PlayerUse(ply,ent)
	local Class=ent:GetClass()
	if((Class=="prop_physics")or(Class=="prop_physics_multiplayer")or(Class=="func_physbox"))then
		local PhysObj=ent:GetPhysicsObject()
		if((PhysObj)and(PhysObj.GetMass)and(PhysObj:GetMass()>14))then return false end
	end
	if(ent.ContactPoisoned)then
		if(ply.Murderer)then
			ply:PrintMessage(HUD_PRINTTALK,translate.poisoned)
			return false
		else
			ent.ContactPoisoned=false
			HMCD_Poison(ply,ent.Poisoner)
		end
	end
	return true
end

function GM:KeyPress(ply,key)
	if(key==IN_USE)then
		if(ply.ContainingContainer)then
			ply:ExitContainer()
		else
			local tr=ply:GetEyeTraceNoCursor()
			-- disguise as ragdolls
			if(IsValid(tr.Entity))then
				local Dist=tr.HitPos:Distance(tr.StartPos)
				if(ply.Murderer)then
					local Class,Modle=tr.Entity:GetClass(),tr.Entity:GetModel()
					if Class == "prop_ragdoll" && Dist < 65 and not(self.ZOMBIE) then
						ply:MurdererDisguise(tr.Entity)
					end
					--[[
					if(((Class=="prop_physics")or(Class=="prop_dynamic")or(Class=="prop_physics_multiplayer"))and(Dist<65)and(tr.Entity:GetPhysicsObject())and(tr.Entity:GetPhysicsObject():GetVolume()>=19000))then
						if not(tr.Entity.HMCD_HiddenBody)then
							for key,found in pairs(ents.FindInSphere(tr.HitPos,20))do
								if(found:GetClass()=="prop_ragdoll")then
									tr.Entity:HideBody(found)
									net.Start("hmcd_hudhalo")
									net.WriteEntity(tr.Entity)
									net.WriteInt(2,32)
									net.Send(ply)
									break
								end
							end
						end
					end
					--]]
				end
				if((tr.Entity.GetModel)and(ply:KeyDown(IN_ATTACK2))and(Dist<65))then
					local Mod=string.lower(tr.Entity:GetModel())
					if((Mod)and(table.HasValue(HMCD_PersonContainers,Mod)))then
						ply:EnterContainer(tr.Entity)
					end
				end
			end
		end

	end
	local Ground=ply:GetGroundEntity()
	if((key==IN_JUMP)and((IsValid(Ground))or(Ground:IsWorld())))then
		HMCD_StaminaPenalize(ply,8)
	end
end

function PlayerMeta:EnterContainer(ent)
	if((ent.PlayerHiddenInside)and(IsValid(ent.PlayerHiddenInside)))then
		self:PrintMessage(HUD_PRINTCENTER,translate.someonesInside)
	else
		ent:EmitSound("Body.ImpactSoft")
		self.ContainingContainer=ent
		ent.PlayerHiddenInside=self
		self:SetViewEntity(ent)
		self:SetNoDraw(true)
		self:SetNotSolid(true)
		self:Freeze(true)
		self:SetDSP(30,true)
		self:SetPos(ent:LocalToWorld(ent:OBBCenter())-Vector(0,0,20))
		timer.Simple(.1,function()
			self:DropObject()
			local Wep=self:GetWeapon("wep_jack_hmcd_hands")
			if(IsValid(Wep))then Wep:SetCarrying() end
		end)
		ent:GetPhysicsObject():SetMass((ent:GetPhysicsObject():GetMass() or 1)+50)
	end
end

function PlayerMeta:ExitContainer()
	local Ent=self.ContainingContainer
	if not(Ent)then return end
	Ent:EmitSound("Body.ImpactSoft")
	Ent.PlayerHiddenInside=nil
	self.ContainingContainer=nil
	self:SetNoDraw(false)
	self:SetNotSolid(false)
	self:SetViewEntity(self)
	self:Freeze(false)
	self:SetDSP(0,true)
	timer.Simple(.1,function()
		self:DropObject()
		local Wep=self:GetWeapon("wep_jack_hmcd_hands")
		if(IsValid(Wep))then Wep:SetCarrying() end
	end)
	local Center,Size=Ent:LocalToWorld(Ent:OBBCenter()),Ent:OBBMaxs():Length()
	self:SetPos(Center)
	for i=0,100 do
		local Dir=VectorRand()
		local Tr=util.QuickTrace(Center,Dir*Size*2,{Ent,self})
		if not(Tr.Hit)then
			local DownTr=util.QuickTrace(Center+Dir*Size*1.5,Vector(0,0,-1000),{Ent,self})
			if(DownTr.Hit)then
				self:SetPos(DownTr.HitPos+DownTr.HitNormal)
				break
			end
		end
	end
	Ent:GetPhysicsObject():SetMass(((Ent:GetPhysicsObject():GetMass() or 1)-50) or 1)
end

function PlayerMeta:AntiCheat()
	if not(self:Alive())then return end
	if not(self:Team()==2)then return end
	local Weps=self:GetWeapons()
	if(Weps)then
		for key,wep in pairs(Weps)do
			if not(wep.HomicideSWEP)then
				self:PrintMessage(HUD_PRINTTALK,wep:GetClass()..translate.notAllowedWithSVC0)
				SafeRemoveEntity(wep)
			end
		end
	end
	if(self:GetMoveType()==MOVETYPE_NOCLIP)then
		self:SetMoveType(MOVETYPE_WALK)
		self:PrintMessage(HUD_PRINTTALK,translate.notAllowedNoclip)
	end
	if(self:HasGodMode())then
		self:GodDisable()
		self:PrintMessage(HUD_PRINTTALK,translate.notAllowedGodmode)
	end
	local Health=self:Health()
	if((Health)and(Health>105))then
		self:SetHealth(100)
		self:PrintMessage(HUD_PRINTTALK,translate.notAllowedAdditionalHealth)
	end
	local Armor=self:Armor()
	if((Armor)and(Armor>0))then
		self:SetArmor(0)
		self:PrintMessage(HUD_PRINTTALK,translate.notAllowedHL2Armor)
	end
	if not(self:HasWeapon("wep_jack_hmcd_hands")) and not(self:HasWeapon("wep_jack_hmcd_zombhands")) then
		self:Give("wep_jack_hmcd_hands")
		self:GetWeapon("wep_jack_hmcd_hands").HmcdSpawned=true
	end
end

function PlayerMeta:MurdererDisguise(copyent)
	if(GAMEMODE.ZOMBIE)then return end
	if(self.MurdererIdentityHidden)then return end
	if !self.Disguised then
		self.DisguiseColor = self:GetPlayerColor()
		self.DisguiseName = self:GetBystanderName()
		self.DisquiseClothes = self.ClothingType
	end
	local WillSwitchArmor,WillSwitchHelmet=false,false
	if(copyent.ChestArmor)then
		if(copyent.ChestArmor=="Level III")then
			if(not(self.ChestArmor)or(self.ChestArmor=="")or(self.ChestArmor=="Level IIIA"))then
				WillSwitchArmor=true
			end
		elseif(copyent.ChestArmor=="Level IIIA")then
			if(not(self.ChestArmor)or(self.ChestArmor==""))then
				WillSwitchArmor=true
			end
		end
	end
	if(copyent.HeadArmor)then
		if(copyent.HeadArmor=="ACH")then
			if not(self.HeadArmor)then
				WillSwitchHelmet=true
			end
		end
	end
	self.Disguised = true
	self.DisguisedStart=CurTime()
	--self:SetBystanderName(copyent:GetBystanderName())
	local OrigColor,OrigClothes,OrigAccessory,OrigArmor,OrigHelmet=self:GetPlayerColor(),self.ClothingType,self.Accessory,self.ChestArmor,self.HeadArmor
	self:SetPlayerColor(copyent:GetPlayerColor())
	self:SetClothing(copyent.ClothingType)
	self:SetAccessory(copyent.Accessory)
	if(WillSwitchArmor)then self:SetChestArmor(copyent.ChestArmor) end
	if(WillSwitchHelmet)then self:SetHeadArmor(copyent.HeadArmor) end
	copyent:SetClothing(OrigClothes)
	copyent:SetPlayerColor(OrigColor)
	copyent:SetAccessory(OrigAccessory)
	if(WillSwitchArmor)then copyent:SetChestArmor(OrigArmor) end
	if(WillSwitchHelmet)then copyent:SetHeadArmor(OrigHelmet) end
	sound.Play("snd_jack_hmcd_disguise.wav",copyent:GetPos(),60,math.random(90,110))
end

function PlayerMeta:UnMurdererDisguise()
	if self.Disguised then
		-- fuck you sonny boy
	end
	self.Disguised = false
end

function PlayerMeta:GetMurdererDisguised()
	return self.Disguised and true or false
end

function PlayerMeta:SetHighOnDrugs(high)
	self.HighOnDrugs=high
	if(high)then self.Stamina=100 end
	umsg.Start("HMCD_DrugsHigh",self)
	umsg.Bool(high)
	umsg.End()
end

function PlayerMeta:InvoluntaryEvent()
	if((self.Murderer)and(GAMEMODE.ZOMBIE))then return end
	local Event,Ma,Fe,Pos=math.random(1,4),self.ModelSex=="male",self.ModelSex=="female",self:GetShootPos()
	if(Event==1)then
		self:ViewPunch(Angle(5,0,0))
		timer.Simple(.5,function() if(IsValid(self))then self:ViewPunch(Angle(2,0,0)) end end)
		if(Ma)then
			self:EmitSound("snd_jack_hmcd_cough_male.wav",60,100)
		elseif(Fe)then
			self:EmitSound("snd_jack_hmcd_cough_female.wav",60,100)
		end
	elseif(Event==2)then
		timer.Simple(.9,function() if(IsValid(self))then self:ViewPunch(Angle(-5,0,0)) end end)
		timer.Simple(1.1,function() if(IsValid(self))then self:ViewPunch(Angle(20,0,0)) end end)
		if(Ma)then
			self:EmitSound("snd_jack_hmcd_sneeze_male.wav",60,100)
		elseif(Fe)then
			self:EmitSound("snd_jack_hmcd_sneeze_female.wav",60,100)
		end
	elseif(Event==3)then
		util.ScreenShake(Pos,255,255,.3,40)
		if(Ma)then
			self:EmitSound("snd_jack_hmcd_burp.wav",60,80)
		elseif(Fe)then
			self:EmitSound("snd_jack_hmcd_burp.wav",60,110)
		end
	elseif(Event==4)then
		util.ScreenShake(Pos,255,255,.6,40)
		if(Ma)then
			self:EmitSound("snd_jack_hmcd_fart.wav",60,80)
		elseif(Fe)then
			self:EmitSound("snd_jack_hmcd_fart.wav",60,110)
		end
	end
end

function PlayerMeta:MurdererHideIdentity()
	if(self.MurdererIdentityHidden)then return end
	self.TrueIdentity={
		self.ClothingType,
		self.UpperBody,
		self.Core,
		self.LowerBody,
		self:GetBystanderName(),
		self:GetModel(),
		self:GetPlayerColor(),
		self.ModelSex,
		self.ClothingMatIndex
	}
	self:SetModel("models/player/mkx_jajon.mdl")
	self:SetClothing()
	self.Core=1
	self.UpperBody=1
	self.LowerBody=1
	self.ModelSex="male" -- i just
	self.ClothingMatIndex=0
	if(GAMEMODE.SHTF)then self:SetBystanderName(translate.traitor) else self:SetBystanderName(translate.murderer) end
	self:SetPlayerColor(Vector(.25,0,0))
	self:ManipulateBoneScale(self:LookupBone("ValveBiped.Bip01_R_UpperArm"),Vector(1,.8,.8))
	self:ManipulateBoneScale(self:LookupBone("ValveBiped.Bip01_L_UpperArm"),Vector(1,.8,.8))
	self:ManipulateBoneScale(self:LookupBone("ValveBiped.Bip01_Spine4"),Vector(1,1,1))
	self:ManipulateBoneScale(self:LookupBone("ValveBiped.Bip01_Spine1"),Vector(1,.7,.7))
	self:ManipulateBoneScale(self:LookupBone("ValveBiped.Bip01_Pelvis"),Vector(.8,.8,.8))
	self:ManipulateBoneScale(self:LookupBone("ValveBiped.Bip01_R_Thigh"),Vector(.9,.9,.9))
	self:ManipulateBoneScale(self:LookupBone("ValveBiped.Bip01_L_Thigh"),Vector(.9,.9,.9))
	sound.Play("snd_jack_hmcd_disguise.wav",self:GetPos(),65,110)
	self.MurdererIdentityHidden=true
end

function PlayerMeta:MurdererShowIdentity()
	if not(self.MurdererIdentityHidden)then return end
	local Orig=self.TrueIdentity
	self:SetModel(Orig[6])
	self.ModelSex=Orig[8]
	self.ClothingMatIndex=Orig[9]
	self:SetClothing(Orig[1])
	-- print(Orig[2],Orig[3],Orig[4])
	self:SetBodyProportions(Orig[2],Orig[3],Orig[4])
	self:SetBystanderName(Orig[5])
	self:SetPlayerColor(Orig[7])
	sound.Play("snd_jack_hmcd_disguise.wav",self:GetPos(),65,90)
	self.TrueIdentity=nil
	self.MurdererIdentityHidden=false
end

-- you can run on for a long time
-- you can run on for a long time
-- you can run on for a long time
-- soon or later God'll cut you down
local function AnyoneCanSee(pos)
	for key,ply in pairs(team.GetPlayers(2))do
		if(ply:Alive())then
			local PlyPos=ply:GetShootPos()
			if(PlyPos:Distance(pos)<50)then return true end
			local Tr=util.TraceLine({start=PlyPos,endpos=pos,filter={ply}})
			if not(Tr.Hit)then
				local Vec=(PlyPos-pos):GetNormalized()
				local RelAngle=-math.deg(math.asin(Vec:DotProduct(ply:GetAimVector())))
				if(RelAngle>25)then return true end
			end
		end
	end
	return false
end
local function SpawnDeathProp(ply,tab,pos,vel)
	local Mdl=table.Random(tab)
	Obj=ents.Create("prop_physics")
	Obj.HmcdSpawned=true
	Obj:SetModel(Mdl)
	Obj:SetPos(pos)
	Obj:Spawn()
	Obj:GetPhysicsObject():SetVelocity(vel)
	Obj:GetPhysicsObject():EnableDrag(false)
	Obj.Collided=false
	local playa,prop=ply,Obj
	Obj:AddCallback("PhysicsCollide",function(self,colData)
		if not(prop.Collided)then
			prop.Collided=true
			if(colData.HitEntity==playa)then sound.Play("Flesh.ImpactHard",playa:GetPos(),75,100) end
		end
	end)
	for key,other in pairs(team.GetPlayers(2))do
		if(not(other==ply))then constraint.NoCollide(other,Obj,0,0) end
	end
	SafeRemoveEntityDelayed(Obj,200)
end
function PlayerMeta:GodCheck()
	if not(self.HMCD_MarkedForDeath)then return end
	if(self:IsBot())then return end
	if not(self:Alive())then return end
	if not(GAMEMODE:GetRound()==1)then return end
	if(GAMEMODE.DEATHMATCH)then return end
	local Chance=50
	if(math.random(1,Chance)==1)then
		local DeathTypes={1,1,1,2,2,3,4,4}
		local DeathType,CanGo,SelfPos,SelfDir,SelfVel,GoPos,GoVel,UpDir=table.Random(DeathTypes),false,self:GetPos()+Vector(0,0,60),self:GetAimVector(),self:GetVelocity(),nil,nil,-physenv.GetGravity():GetNormalized()
		if(DeathType==1)then
			-- lightning
			local UpTr,SkyPos=util.QuickTrace(SelfPos,UpDir*20000,self),nil
			if(not(UpTr.Hit)or(UpTr.HitSky))then
				if not(UpTr.Hit)then
					GoPos=SelfPos+UpDir*3000
				elseif(UpTr.Hit)then
					GoPos=UpTr.HitPos+UpTr.HitNormal*10
				end
				CanGo=!AnyoneCanSee(GoPos)
			end
			if(CanGo)then
				HMCD_ElectricalArcEffect(GoPos,self,1)
				HMCD_ArcToGround(self,1)
				local Dam=DamageInfo()
				Dam:SetDamage(200)
				Dam:SetDamageType(DMG_SHOCK)
				Dam:SetDamagePosition(SelfPos)
				Dam:SetDamageForce(vector_up)
				Dam:SetAttacker(game.GetWorld())
				Dam:SetInflictor(game.GetWorld())
				self:TakeDamageInfo(Dam)
			end
		elseif(DeathType==2)then
			-- skyobject
			local UpTr,SkyPos=util.QuickTrace(SelfPos,UpDir*20000,self),nil
			if(not(UpTr.Hit)or(UpTr.HitSky)or((UpTr.Hit)and(UpTr.HitPos:Distance(SelfPos)>2000)))then
				if not(UpTr.Hit)then
					GoPos=SelfPos+UpDir*20000
				elseif(UpTr.Hit)then
					GoPos=UpTr.HitPos+UpTr.HitNormal*100
				end
				GoVel=SelfVel
				CanGo=!AnyoneCanSee(GoPos)
			end
			if(CanGo)then
				SpawnDeathProp(self,HMCD_BigProjectileJunkModels,GoPos,GoVel)
			end
		elseif(DeathType==3)then
			-- flying object
			local BackTr=util.QuickTrace(SelfPos,-SelfDir*500,self)
			if(BackTr.Hit)then GoPos=BackTr.HitPos+BackTr.HitNormal*50 else GoPos=SelfPos-SelfDir*500 end
			CanGo=!AnyoneCanSee(GoPos)
			GoVel=SelfDir*1750+SelfVel
			if not(CanGo)then
				local LeftTr=util.QuickTrace(SelfPos,-self:GetRight()*500,self)
				if(LeftTr.Hit)then GoPos=LeftTr.HitPos+LeftTr.HitNormal*50 else GoPos=SelfPos-self:GetRight()*500 end
				GoVel=self:GetRight()*1750+SelfVel
				CanGo=!AnyoneCanSee(GoPos)
			end
			if not(CanGo)then
				local RightTr=util.QuickTrace(SelfPos,self:GetRight()*500,self)
				if(RightTr.Hit)then GoPos=RightTr.HitPos+RightTr.HitNormal*50 else GoPos=SelfPos+self:GetRight()*500 end
				GoVel=-self:GetRight()*1750+SelfVel
				CanGo=!AnyoneCanSee(GoPos)
			end
			if(CanGo)then
				SpawnDeathProp(self,HMCD_ProjectileJunkModels,GoPos,GoVel)
			end
		elseif(DeathType==4)then
			-- seizure
			if not(self.Seizuring)then
				self.Seizuring=true
				CanGo=true
				net.Start("hmcd_seizure")
				net.WriteBit(true)
				net.Send(self)
				self:PrintMessage(HUD_PRINTTALK,translate.youAreHavingASeizure)
				self:PrintMessage(HUD_PRINTCENTER,translate.seizure)
				local LifeID=self.LifeID
				timer.Simple(30,function()
					if(self)then
						net.Start("hmcd_seizure")
						net.WriteBit(false)
						net.Send(self)
						self.Seizuring=false
						if(self.LifeID==LifeID)then
							local Dam=DamageInfo()
							Dam:SetDamage(110)
							Dam:SetDamageType(DMG_GENERIC)
							Dam:SetDamagePosition(SelfPos)
							Dam:SetDamageForce(vector_up)
							Dam:SetAttacker(game.GetWorld())
							Dam:SetInflictor(game.GetWorld())
							self:TakeDamageInfo(Dam)
						end
					end
				end)
			end
		end
		if(CanGo)then self.HMCD_MarkedForDeath=false end
	end
end

concommand.Add("hmcd_dropwep",function(ply,cmd,args)
	local Wep=ply:GetActiveWeapon()
	if((IsValid(Wep))and(Wep.CommandDroppable)and not((GAMEMODE.SHTF)and(Wep.SHTF_NoDrop)))then
		ply:DropWeapon(Wep)
		return ""
	end
end)

concommand.Add("hmcd_dropequipment",function(ply,cmd,args)
	sound.Play("snd_jack_hmcd_disguise.wav",ply:GetPos(),65,80)
	if((ply.HeadArmor)and(ply.HeadArmor!=""))then
		ply:DoAnimationEvent(ACT_GMOD_GESTURE_ITEM_DROP)
		local Armor=ents.Create("ent_jack_hmcd_helmet")
		Armor:SetPos(ply:GetShootPos()+ply:GetAimVector()*25)
		Armor.HmcdSpawned=true
		Armor:Spawn();Armor:Activate()
		Armor:GetPhysicsObject():SetVelocity(ply:GetVelocity())
		ply:SetHeadArmor(nil)
	end
	if((ply.ChestArmor)and(ply.ChestArmor!=""))then
		ply:DoAnimationEvent(ACT_GMOD_GESTURE_ITEM_DROP)
		local Class=nil
		if(ply.ChestArmor=="Level IIIA")then Class="ent_jack_hmcd_softarmor" end
		if(ply.ChestArmor=="Level III")then Class="ent_jack_hmcd_hardarmor" end
		if(Class)then
			local Armor=ents.Create(Class)
			Armor:SetPos(ply:GetShootPos()+ply:GetAimVector()*20)
			Armor.HmcdSpawned=true
			Armor:Spawn();Armor:Activate()
			Armor:GetPhysicsObject():SetVelocity(ply:GetVelocity())
			ply:SetChestArmor(nil)
		end
	end
	if(ply.HasFlashlight)then
		ply:DoAnimationEvent(ACT_GMOD_GESTURE_ITEM_DROP)
		local Armor=ents.Create("ent_jack_hmcd_flashlight")
		Armor:SetPos(ply:GetShootPos()+ply:GetAimVector()*30)
		Armor.HmcdSpawned=true
		Armor:Spawn();Armor:Activate()
		Armor:GetPhysicsObject():SetVelocity(ply:GetVelocity())
		ply.HasFlashlight=false
		net.Start("hmcd_flashlightpickup")
		net.WriteEntity(ply)
		net.WriteBit(ply.HasFlashlight)
		net.Broadcast()
	end
end)

concommand.Add("hmcd_dropammo",function(ply,cmd,args)
	local Num=0
	for amm,fuck in pairs(HMCD_AmmoWeights)do
		local Amt=ply:GetAmmoCount(amm) or 0
		Num=Num+Amt
	end
	if(Num>0)then
		net.Start("hmcd_openammomenu")
		net.Send(ply)
	end
end)

concommand.Add("hmcd_droprequest_ammo",function(ply,cmd,args)
	local Type,Amount=args[1],tonumber(args[2])
	local Amm=ply:GetAmmoCount(Type)
	if(Amm<Amount)then Amount=Amm end
	if(Amount>0)then
		ply:DropAmmo(Type,Amount)
	end
end)

concommand.Add("hmcd_lockedcontrols",function(ply,cmd,args)
	if(ply.ContainingContainer)then
		if not(ply.NextContainerShove)then ply.NextContainerShove=0 end
		if(args[1]=="+use")then
			ply:ExitContainer()
		elseif(ply.NextContainerShove<CurTime())then
			ply:SetPos(ply.ContainingContainer:LocalToWorld(ply.ContainingContainer:OBBCenter())-Vector(0,0,20))
			ply.NextContainerShove=CurTime()+1
			local Phys,Obj=ply.ContainingContainer:GetPhysicsObject(),ply.ContainingContainer
			if(Phys)then
				if(args[1]=="+moveleft")then
					Phys:ApplyForceCenter(-Obj:GetRight()*7000)
				elseif(args[1]=="+moveright")then
					Phys:ApplyForceCenter(Obj:GetRight()*7000)
				elseif(args[1]=="+forward")then
					Phys:ApplyForceCenter(Obj:GetForward()*7000)
				elseif(args[1]=="+back")then
					Phys:ApplyForceCenter(-Obj:GetForward()*7000)
				elseif(args[1]=="+jump")then
					Phys:ApplyForceCenter(Obj:GetUp()*7000)
				elseif(args[1]=="+duck")then
					Phys:ApplyForceCenter(-Obj:GetUp()*7000)
				end
			end
		end
	end
end)

function PlayerMeta:DropAmmo(typ,amt)
	if not(amt)then amt=self:GetAmmoCount(typ) end
	if not(amt>0)then return end
	ply:DoAnimationEvent(ACT_GMOD_GESTURE_ITEM_DROP)
	self:RemoveAmmo(amt,typ)
	local Ammo=ents.Create("ent_jack_hmcd_ammo")
	Ammo.HmcdSpawned=true
	Ammo.AmmoType=typ
	Ammo.Rounds=amt
	Ammo:SetPos(self:GetShootPos()+self:GetAimVector()*20)
	Ammo:Spawn();Ammo:Activate()
	Ammo:GetPhysicsObject():SetVelocity(self:GetVelocity()+self:GetAimVector()*100)
end

function PlayerMeta:AddMerit(amt)
	--print("MERIT",self,amt)
	if(GetConVar("sv_cheats"):GetBool())then return end
	local Old=tonumber(self:GetPData("JackHMCD_TotalMerit")) or 0
	self:SetPData("JackHMCD_TotalMerit",math.abs(Old+amt))
end
function PlayerMeta:AddDemerit(amt)
	--print("DEMERIT",self,amt)
	if(GetConVar("sv_cheats"):GetBool())then return end
	local Old=tonumber(self:GetPData("JackHMCD_TotalDemerit")) or 0
	self:SetPData("JackHMCD_TotalDemerit",math.abs(Old+amt))
end
function PlayerMeta:AddExperience(amt)
	--print("EXPERIENCE",self,amt)
	if(GetConVar("sv_cheats"):GetBool())then return end
	local Num=0
	for key,playah in pairs(team.GetPlayers(2))do if not(playah:IsBot())then Num=Num+1 end end
	if(Num<2)then return end
	local Old=tonumber(self:GetPData("JackHMCD_TotalExperience")) or 0
	self:SetPData("JackHMCD_TotalExperience",math.abs(Old+amt))
end
function PlayerMeta:GetAwardStats()
	return tonumber(self:GetPData("JackHMCD_TotalMerit")) or 0,tonumber(self:GetPData("JackHMCD_TotalDemerit")) or 1,tonumber(self:GetPData("JackHMCD_TotalExperience")) or 0
end