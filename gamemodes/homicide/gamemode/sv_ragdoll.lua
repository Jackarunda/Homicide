local PlayerMeta=FindMetaTable("Player")
local EntityMeta=FindMetaTable("Entity")

local dtypes={}
dtypes[DMG_GENERIC]=""
dtypes[DMG_CRUSH]="Blunt Force"
dtypes[DMG_BULLET]="Bullet"
dtypes[DMG_SLASH]="Laceration"
dtypes[DMG_BURN]="Fire"
dtypes[DMG_VEHICLE]="Blunt Force"
dtypes[DMG_FALL]="Fall force"
dtypes[DMG_BLAST]="Explosion"
dtypes[DMG_CLUB]="Blunt Force"
dtypes[DMG_SHOCK]="Shock"
dtypes[DMG_SONIC]="Sonic"
dtypes[DMG_ENERGYBEAM]="Enery"
dtypes[DMG_DROWN]="Hydration"
dtypes[DMG_PARALYZE]="Paralyzation" -- you mean PARALYSIS? Fucking moron.
dtypes[DMG_NERVEGAS]="Nervegas"
dtypes[DMG_POISON]="Poison"
dtypes[DMG_RADIATION]="Radiation"
dtypes[DMG_DROWNRECOVER]=""
dtypes[DMG_ACID]="Acid"
dtypes[DMG_PLASMA]="Plasma"
dtypes[DMG_AIRBOAT]="Energy"
dtypes[DMG_DISSOLVE]="Energy"
dtypes[DMG_BLAST_SURFACE]=""
dtypes[DMG_DIRECT]="Fire"
dtypes[DMG_BUCKSHOT]="Bullet"


local DeathRagdollsPerPlayer=3
local DeathRagdollsPerServer=22

if !PlayerMeta.CreateRagdollOld then
	PlayerMeta.CreateRagdollOld=PlayerMeta.CreateRagdoll
end
function PlayerMeta:CreateRagdoll(attacker, dmginfo)
	local Data=duplicator.CopyEntTable( self )
	local ent=ents.Create( "prop_ragdoll" )
	ent.HmcdSpawned=true
	duplicator.DoGeneric( ent, Data )
	ent:Spawn()
	ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	if ent.SetPlayerColor then
		ent:SetPlayerColor(self:GetPlayerColor())
	end
	ent:SetNWEntity("RagdollOwner", self)
	
	ent:SetBodyProportions(self.UpperBody,self.CoreBody,self.LowerBody)
	ent.ClothingMatIndex=self.ClothingMatIndex
	ent.ModelSex=self.ModelSex
	ent:SetClothing(self.ClothingType)
	ent:SetAccessory(self.Accessory)
	ent:SetChestArmor(self.ChestArmor)
	ent:SetHeadArmor(self.HeadArmor)

	// set velocities
	local Vel=self:GetVelocity()/5

	local iNumPhysObjects=ent:GetPhysicsObjectCount()
	for Bone=0, iNumPhysObjects-1 do

		local PhysObj=ent:GetPhysicsObjectNum( Bone )
		if IsValid(PhysObj) then

			local Pos, Ang=self:GetBonePosition( ent:TranslatePhysBoneToBone( Bone ) )
			PhysObj:SetPos( Pos )
			PhysObj:SetAngles( Ang )
			PhysObj:AddVelocity( Vel )

		end

	end

	// finish up
	self:SetNWEntity("DeathRagdoll", ent )
end

if !PlayerMeta.GetRagdollEntityOld then
	PlayerMeta.GetRagdollEntityOld=PlayerMeta.GetRagdollEntity
end
function PlayerMeta:GetRagdollEntity()
	local ent=self:GetNWEntity("DeathRagdoll")
	if IsValid(ent) then
		return ent
	end
	return self:GetRagdollEntityOld()
end

if !PlayerMeta.GetRagdollOwnerOld then
	PlayerMeta.GetRagdollOwnerOld=PlayerMeta.GetRagdollOwner
end
function EntityMeta:GetRagdollOwner()
	local ent=self:GetNWEntity("RagdollOwner")
	if IsValid(ent) then
		return ent
	end
	return self:GetRagdollOwnerOld()
end

function EntityMeta:SetChestArmor(typ)
	self.ChestArmor=typ
	timer.Simple(.1,function()
		net.Start("hmcd_armor")
		net.WriteEntity(self)
		net.WriteString(self.HeadArmor or "")
		net.WriteString(typ or "")
		net.Send(player.GetAll())
	end)
end

function EntityMeta:SetHeadArmor(typ)
	self.HeadArmor=typ
	timer.Simple(.1,function()
		net.Start("hmcd_armor")
		net.WriteEntity(self)
		net.WriteString(typ or "")
		net.WriteString(self.ChestArmor or "")
		net.Send(player.GetAll())
	end)
end

function GM:RagdollSetDeathDetails(victim, inflictor, attacker) 
	local rag=victim:GetRagdollEntity()
	if rag then
		-- fuck you and your weird shit
	end
end

function EntityMeta:NearGround()
	return util.QuickTrace(self:GetPos()+vector_up*10,-vector_up*50,{self}).Hit
end
function EntityMeta:CanSee(ent)
	local pos,filterent=ent,nil
	if(type(ent)=="Entity")then pos=ent:LocalToWorld(ent:OBBCenter());filterent=ent end
	local Tr={
		start=self:LocalToWorld(self:OBBCenter()),
		endpos=pos,
		filter={self,filterent}
	}
	return !Tr.Hit
end

local function ClearLoS(pos1,pos2,filter)
	if not(filter)then filter={} end
	local Tr=util.TraceLine({
		start=pos1,
		endpos=pos2
	})
	return !Tr.Hit
end

function EntityMeta:ExplodeIED()
	local Pos,Ground,Attacker,SplodeType,Mul=self:LocalToWorld(self:OBBCenter())+Vector(0,0,5),self:NearGround(),self.IEDAttacker,HMCD_ExplosiveType(self),1
	if(self:IsPlayer())then
		Attacker=self
		SplodeType=1
		self:KillSilent()
		SplodeType=2
	end
	if(SplodeType==3)then
		if(Ground)then
			ParticleEffect("pcf_jack_incendiary_ground_sm2",Pos,vector_up:Angle())
		else
			ParticleEffect("pcf_jack_incendiary_air_sm2",Pos,VectorRand():Angle())
		end
	else
		if(Ground)then
			ParticleEffect("pcf_jack_groundsplode_small3",Pos,vector_up:Angle())
		else
			ParticleEffect("pcf_jack_airsplode_small3",Pos,VectorRand():Angle())
		end
	end
	local Foom=EffectData()
	Foom:SetOrigin(Pos)
	util.Effect("explosion",Foom,true,true)
	local Flash=EffectData()
	Flash:SetOrigin(Pos)
	Flash:SetScale(2)
	util.Effect("eff_jack_hmcd_dlight",Flash,true,true)
	timer.Simple(.01,function()
		if not(SplodeType==3)then
			sound.Play("snd_jack_hmcd_explosion_debris.mp3",Pos,85,math.random(90,110))
			sound.Play("snd_jack_hmcd_explosion_far.wav",Pos-vector_up,140,100)
			sound.Play("snd_jack_hmcd_debris.mp3",Pos+vector_up,85,math.random(90,110))
		end
		for i=0,10 do
			local Tr=util.QuickTrace(Pos,VectorRand()*math.random(10,150),{self})
			if(Tr.Hit)then util.Decal("Scorch",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal) end
		end
	end)
	timer.Simple(.02,function()
		if(SplodeType==3)then
			sound.Play("snd_jack_hmcd_explosion_close.wav",Pos,70,100)
			sound.Play("snd_jack_firebomb.wav",Pos,80,100)
		else
			sound.Play("snd_jack_hmcd_explosion_close.wav",Pos,80,100)
			sound.Play("snd_jack_hmcd_explosion_close.wav",Pos+vector_up,80,100)
			sound.Play("snd_jack_hmcd_explosion_close.wav",Pos-vector_up,80,100)
		end
	end)
	timer.Simple(.03,function()
		if not(SplodeType==3)then
			if not(SplodeType==2)then
				for key,ent in pairs(ents.FindInSphere(Pos,75))do
					if((ent!=self)and(ent:GetClass()=="func_breakable")and(ent:CanSee(Pos)))then
						ent:Fire("break","",0)
					elseif((ent!=self)and(HMCD_IsDoor(ent))and not(ent:GetNoDraw())and(ent:CanSee(Pos)))then
						HMCD_BlastThatDoor(ent)
					end
				end
			else
				local Poof=EffectData()
				Poof:SetOrigin(Pos)
				Poof:SetScale(1)
				util.Effect("eff_jack_hmcd_shrapnel",Poof,true,true)
			end
		else
			local Fire=ents.Create("ent_jack_hmcd_fire")
			Fire.HmcdSpawned=true
			Fire.Initiator=Attacker
			Fire:SetPos(Pos)
			Fire:Spawn()
			Fire:Activate()
		end
	end)
	timer.Simple(.04,function()
		if not(SplodeType==3)then
			util.BlastDamage(self,Attacker,Pos,150*Mul,75*Mul)
			local shake=ents.Create("env_shake")
			shake.HmcdSpawned=true
			shake:SetPos(Pos)
			shake:SetKeyValue("amplitude",tostring(100))
			shake:SetKeyValue("radius",tostring(200))
			shake:SetKeyValue("duration",tostring(1))
			shake:SetKeyValue("frequency",tostring(200))
			shake:SetKeyValue("spawnflags",bit.bor(4,8,16))
			shake:Spawn()
			shake:Activate()
			shake:Fire("StartShake","",0)
			SafeRemoveEntityDelayed(shake,2) -- don't clutter up the world
			local shake2=ents.Create("env_shake")
			shake2.HmcdSpawned=true
			shake2:SetPos(Pos)
			shake2:SetKeyValue("amplitude",tostring(100))
			shake2:SetKeyValue("radius",tostring(400))
			shake2:SetKeyValue("duration",tostring(1))
			shake2:SetKeyValue("frequency",tostring(200))
			shake2:SetKeyValue("spawnflags",bit.bor(4))
			shake2:Spawn()
			shake2:Activate()
			shake2:Fire("StartShake","",0)
			SafeRemoveEntityDelayed(shake2,2) -- don't clutter up the world
			util.BlastDamage(self,Attacker,Pos,500*Mul,50*Mul)
		end
	end)
	timer.Simple(.05,function()
		if(SplodeType==2)then
			local Shrap=DamageInfo()
			Shrap:SetAttacker(Attacker)
			if(IsValid(self))then
				Shrap:SetInflictor(self)
			else
				Shrap:SetInflictor(game.GetWorld())
			end
			Shrap:SetDamageType(DMG_BUCKSHOT)
			Shrap:SetDamage(100*Mul)
			util.BlastDamageInfo(Shrap,Pos,750*Mul)
		end
		if not(self:IsPlayer())then SafeRemoveEntity(self) end
	end)
	timer.Simple(.1,function()
		for key,rag in pairs(ents.FindInSphere(Pos,750))do
			if((rag:GetClass()=="prop_ragdoll")or(rag:IsPlayer()))then
				for i=1,20 do
					local Tr=util.TraceLine({start=Pos,endpos=rag:GetPos()+VectorRand()*50})
					if((Tr.Hit)and(Tr.Entity==rag))then util.Decal("Blood",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal) end
				end
			end
		end
	end)
end

function EntityMeta:SetAccessory(acc)
	if not(acc)then return end
	self.Accessory=acc
	local ent,sex=self,self.ModelSex -- delay to ensure the entity exists on the client
	timer.Simple(.1,function()
		net.Start("hmcd_player_accessory")
		net.WriteEntity(ent)
		net.WriteString(sex)
		net.WriteString(acc)
		net.Send(player.GetAll())
	end)
end

function EntityMeta:IsUsingValidModel()
	local Mod=string.lower(self:GetModel())
	for key,maud in pairs(HMCD_ValidModels)do
		local ValidModel=string.lower(player_manager.TranslatePlayerModel(maud))
		if(ValidModel==Mod)then return true end
	end
	if((GAMEMODE.ZOMBIE)and(Mod=="models/player/zombie_classic.mdl"))then return true end
	if(self:IsPlayer())then self:PrintMessage(HUD_PRINTTALK,"WANRING: unsupported playermodel") end
	return false
end

function EntityMeta:SetClothing(outfit)
	self:SetMaterial() -- reset
	self:SetSubMaterial() -- reset
	if not(outfit)then return end
	if not(self:IsUsingValidModel())then return end
	if((GAMEMODE.ZOMBIE)and(self:GetModel()=="models/player/zombie_classic.mdl"))then return end
	self:SetSubMaterial(self.ClothingMatIndex,"models/humans/"..self.ModelSex.."/group01/"..outfit)
	self.ClothingType=outfit
	if(self:IsPlayer())then
		net.Start("hmcd_legsreset")
		net.Send(self)
	end
end

function EntityMeta:SetBodyProportions(upper,core,lower)
	if not((upper)and(core)and(lower))then return end
	self.UpperBody=upper
	self.CoreBody=core
	self.LowerBody=lower
	local Chest,Arms=1,1
	self:ManipulateBoneScale(self:LookupBone("ValveBiped.Bip01_R_UpperArm"),Vector(1,upper^1.2,upper^1.2))
	self:ManipulateBoneScale(self:LookupBone("ValveBiped.Bip01_L_UpperArm"),Vector(1,upper^1.2,upper^1.2))
	self:ManipulateBoneScale(self:LookupBone("ValveBiped.Bip01_Spine4"),Vector(upper,upper^1.05,upper^1.05))
	self:ManipulateBoneScale(self:LookupBone("ValveBiped.Bip01_Spine1"),Vector(1,core^1.4,core^1.4))
	self:ManipulateBoneScale(self:LookupBone("ValveBiped.Bip01_Pelvis"),Vector(core^.5,core^.5,core^.5))
	self:ManipulateBoneScale(self:LookupBone("ValveBiped.Bip01_R_Thigh"),Vector(1,lower^1.1,lower^1.1))
	self:ManipulateBoneScale(self:LookupBone("ValveBiped.Bip01_L_Thigh"),Vector(1,lower^1.1,lower^1.1))
end

function EntityMeta:HideBody(body)
	self.HMCD_HiddenBody=true
	HMCD_HideBody(body)
	self:GetPhysicsObject():SetMass(self:GetPhysicsObject():GetMass()+150)
	for i=1,10 do timer.Simple(i/10*math.Rand(.75,1.25),function() self:EmitSound("Flesh.ImpactSoft") end) end
end

function EntityMeta:GenerateBody()
	local Stature,Upper,Core,Lower=math.Rand(.95,1.05),math.Rand(.8,1.3),math.Rand(.75,1.2),math.Rand(.8,1.3)
	--if(self.CustomStature)then Stature=self.CustomStature/100 end -- player scaling causes strange movement bugs
	--self:SetModelScale(Stature,.1)
	timer.Simple(3,function()
		--[[
		if((IsValid(self))and(self.Alive)and(self:Alive()))then
			--self:SetViewOffset(Vector(0,0,64*Stature))
			self:SetViewOffsetDucked(Vector(0,0,37))
			self:SetHull(Vector(-10,-10,0),Vector(10,10,72))
			self:SetHullDuck(Vector(-10,-10,0),Vector(10,10,41))
		end
		--]]
	end)
	if(self:IsPlayer())then
		umsg.Start("HMCD_Stature",self) -- necessary for prediction
		--umsg.Float(Stature)
		umsg.End()
	end
	--self.Stature=Stature
	if(self.CustomUpperBody)then Upper=self.CustomUpperBody/100 end
	if(self.CustomCoreBody)then Core=self.CustomCoreBody/100 end
	if(self.CustomLowerBody)then Lower=self.CustomLowerBody/100 end
	self:SetBodyProportions(Upper,Core,Lower)
end

local Clothes={"normal","normal","normal","striped","plaid","casual","formal","young","cold"} -- some styles are more common
function EntityMeta:GenerateClothes()
	local Type=table.Random(Clothes)
	if(self.CustomClothes)then Type=self.CustomClothes end
	self:SetSubMaterial() -- reset
	timer.Simple(2,function()
		if(IsValid(self))then
			self:SetClothing(Type)
		end
	end)
end

function EntityMeta:GenerateColor()
	local vec=Vector(math.Rand(0,1),math.Rand(0,1),math.Rand(0,1))
	local Avg=(vec.x+vec.y+vec.z)/3
	vec.x=Lerp(.2,vec.x,Avg);vec.y=Lerp(.2,vec.y,Avg);vec.z=Lerp(.2,vec.z,Avg); -- muted colors more common
	if(self.CustomColor)then vec=self.CustomColor end
	self:SetPlayerColor(vec)
end

function EntityMeta:GenerateAccessories()
	local AccTable=table.GetKeys(HMCD_Accessories)
	table.insert(AccTable,"eyeglasses") -- eyeglasses are the most common accessory
	table.insert(AccTable,"eyeglasses")
	table.insert(AccTable,"nerd glasses")
	local AccessoryName=table.Random(AccTable)
	if(math.random(1,3)==2)then AccessoryName="none" end
	if(self.CustomAccessory)then AccessoryName=self.CustomAccessory end
	self:SetAccessory(AccessoryName)
end

function GM:CreateFirstVictim()
	if(self.DEATHMATCH)then return end
	if(self.ZOMBIE)then return end
	local ply=ents.Create("prop_ragdoll")
	if(math.random(1,2)==2)then
		ply:SetModel("models/player/group01/male_0"..math.random(1,9)..".mdl")
		ply.ModelSex="male"
	else
		ply:SetModel("models/player/group01/female_0"..math.random(1,6)..".mdl")
		ply.ModelSex="female"
	end
	local spawnPoint=self:PlayerSelectTeamSpawn(2,ply)
	if(IsValid(spawnPoint))then ply:SetPos(spawnPoint:GetPos()+vector_up*20) end
	--player.GetAll()[1]:SetPos(ply:GetPos())
	ply:SetAngles(Angle(0,0,0))
	ply:Spawn()
	ply:Activate()
	ply:GenerateClothes()
	ply:GenerateBystanderName()
	ply:GenerateBody()
	ply:GenerateColor()
	ply:GenerateAccessories()
	for i=0,50 do
		local Ph=ply:GetPhysicsObjectNum(i)
		if(Ph)then
			Ph:ApplyForceCenter(VectorRand()*math.Rand(1,4000))
			Ph:AddAngleVelocity(VectorRand()*math.Rand(0,1000))
		end
	end
	timer.Simple(10,function()
		if(IsValid(ply))then
			local Pit=math.random(70,140)
			sound.Play("ambient/creatures/town_child_scream1.wav",ply:GetPos(),90,pit)
			sound.Play("ambient/creatures/town_child_scream1.wav",ply:GetPos()+vector_up,60,pit)
			sound.Play("ambient/creatures/town_child_scream1.wav",ply:GetPos()+vector_up*2,50,pit)
		end
	end)
	self.FirstVictim=ply
	timer.Simple(.1,function()
		for i=1,5 do
			local Tr=util.TraceLine({
				start=ply:GetPos()+vector_up*50+VectorRand()*math.Rand(0,40),
				endpos=ply:GetPos()-vector_up*200+VectorRand()*math.Rand(0,40)
			})
			if(Tr.Hit)then util.Decal("Blood",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal) end
		end
	end)
end