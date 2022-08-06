AddCSLuaFile()
ENT.Type="anim"
ENT.Base="base_anim"
ENT.PrintName		= "Grenade"
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
if(SERVER)then
	function ENT:Initialize()
		if(self.Rigged)then self:SetModel("models/weapons/w_jj_fraggrenade.mdl") else self:SetModel("models/weapons/w_jj_fraggrenade_thrown.mdl") end
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
		self:SetUseType(SIMPLE_USE)
		self:DrawShadow(true)
		local phys=self:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
			phys:SetMass(5)
		end
		--self.Detonated=false
		--self.Armed=false
		--self.Rigged=false
	end
	function ENT:Use(ply)
		if((GAMEMODE.ZOMBIE)and(ply.Murderer))then return end
		if not((ply:HasWeapon("wep_jack_hmcd_oldgrenade_dm"))or(self.Rigged)or(self.Armed))then
			ply:Give("wep_jack_hmcd_oldgrenade_dm")
			ply:SelectWeapon("wep_jack_hmcd_oldgrenade_dm")
			self:Remove()
		end
	end
	function ENT:Think()
		if((self.Armed)and(self.DetTime<CurTime()))then
			self:Detonate()
		elseif(not(self.Armed)and(self.Rigged))then
			if not(IsValid(self.Constraint))then
				self:Arm()
			else
				local Tr,WillArm=util.QuickTrace(self:GetPos(),VectorRand()*40,{self}),false
				if((Tr.Hit)and(Tr.Entity)and(Tr.Entity.GetVelocity))then
					if((Tr.Entity:GetVelocity()-self:GetVelocity()):Length()>=10)then WillArm=true end
					for key,ent in pairs(ents.FindInSphere(self:GetPos(),50))do if(ent.Murderer)then WillArm=false end end
					if(WillArm)then self:Arm() end
				end
			end
		end
		self:NextThink(CurTime()+.01)
		return true
	end
	function ENT:Arm()
		if(self.Armed)then return end
		self.Armed=true
		constraint.RemoveAll(self)
		sound.Play("snd_jack_hmcd_spoonfling.wav",self:GetPos(),65,100)
		local Spoon=ents.Create("prop_physics")
		Spoon.HmcdSpawned=self.HmcdSpawned
		Spoon:SetModel("models/shells/shell_gndspoon.mdl")
		Spoon:SetPos(self:GetPos()+VectorRand())
		Spoon:SetAngles(self:GetAngles())
		Spoon:SetMaterial("models/shiny")
		Spoon:SetColor(Color(50,40,0))
		Spoon:Spawn()
		Spoon:Activate()
		Spoon:GetPhysicsObject():SetMaterial("metal_bouncy")
		Spoon:GetPhysicsObject():SetVelocity(self:GetPhysicsObject():GetVelocity()+VectorRand()*300)
		if(self.Rigged)then self.DetTime=CurTime()+1 else self.DetTime=CurTime()+math.Rand(3,4) end
	end
	function ENT:NearGround()
		return util.QuickTrace(self:GetPos()+vector_up*10,-vector_up*50,{self}).Hit
	end
	function ENT:Detonate()
		if(self.Detonated)then return end
		self.Detonated=true
		local Pos,Ground,Attacker=self:LocalToWorld(self:OBBCenter())+Vector(0,0,5),self:NearGround(),self.Owner
		if(Ground)then
			ParticleEffect("pcf_jack_groundsplode_small3",Pos,vector_up:Angle())
		else
			ParticleEffect("pcf_jack_airsplode_small3",Pos,VectorRand():Angle())
		end
		local Foom=EffectData()
		Foom:SetOrigin(Pos)
		util.Effect("explosion",Foom,true,true)
		local Flash=EffectData()
		Flash:SetOrigin(Pos)
		Flash:SetScale(2)
		util.Effect("eff_jack_hmcd_dlight",Flash,true,true)
		timer.Simple(.01,function()
			sound.Play("snd_jack_hmcd_explosion_debris.mp3",Pos,85,math.random(90,110))
			sound.Play("snd_jack_hmcd_explosion_far.wav",Pos-vector_up,140,100)
			sound.Play("snd_jack_hmcd_debris.mp3",Pos+vector_up,85,math.random(90,110))
			for i=0,10 do
				local Tr=util.QuickTrace(Pos,VectorRand()*math.random(10,150),{self})
				if(Tr.Hit)then util.Decal("Scorch",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal) end
			end
		end)
		timer.Simple(.02,function()
			sound.Play("snd_jack_hmcd_explosion_close.wav",Pos,80,100)
			sound.Play("snd_jack_hmcd_explosion_close.wav",Pos+vector_up,80,100)
			sound.Play("snd_jack_hmcd_explosion_close.wav",Pos-vector_up,80,100)
		end)
		timer.Simple(.03,function()
			local Poof=EffectData()
			Poof:SetOrigin(Pos)
			Poof:SetScale(1)
			util.Effect("eff_jack_hmcd_shrapnel",Poof,true,true)
		end)
		timer.Simple(.04,function()
			local shake=ents.Create("env_shake")
			shake.HmcdSpawned=self.HmcdSpawned
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
			shake2.HmcdSpawned=self.HmcdSpawned
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
			util.BlastDamage(self,Attacker,Pos,150,50)
		end)
		timer.Simple(.05,function()
			local Shrap=DamageInfo()
			Shrap:SetAttacker(Attacker)
			if(IsValid(self))then
				Shrap:SetInflictor(self)
			else
				Shrap:SetInflictor(game.GetWorld())
			end
			Shrap:SetDamageType(DMG_BUCKSHOT)
			Shrap:SetDamage(100)
			util.BlastDamageInfo(Shrap,Pos,600)
			SafeRemoveEntity(self)
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
	function ENT:PhysicsCollide(data,physobj)
		if(data.DeltaTime>.1)then
			self:EmitSound("Grenade.ImpactHard")
			self:GetPhysicsObject():SetVelocity(self:GetPhysicsObject():GetVelocity()*.9)
		end
	end
	function ENT:StartTouch(ply)
		--
	end
elseif(CLIENT)then
	function ENT:Initialize()
		--
	end
	function ENT:Draw()
		self:DrawModel()
	end
	function ENT:Think()
		--
	end
	function ENT:OnRemove()
		--
	end
end