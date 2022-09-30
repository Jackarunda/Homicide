AddCSLuaFile()
ENT.Type="anim"
ENT.Base="base_anim"
ENT.PrintName		= "Molotov"
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.IsLoot=true
ENT.SWEP="wep_jack_hmcd_molotov"
if(SERVER)then
	function ENT:Initialize()
		self:SetModel("models/w_models/weapons/w_eq_molotov.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
		self:SetUseType(SIMPLE_USE)
		self:DrawShadow(true)
		local phys=self:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
			phys:SetMass(5)
		end
		self.Detonated=false
		self.Ignited=false
	end
	function ENT:Use(ply)
		if((GAMEMODE.ZOMBIE)and(ply.Murderer))then return end
		if(self.Armed)then return end
		if(self.ContactPoisoned)then
			if(ply.Murderer)then
				ply:PrintMessage(HUD_PRINTTALK,translate.poisoned)
				return
			else
				self.ContactPoisoned=false
				HMCD_Poison(ply,self.Poisoner)
			end
		end
		local SWEP=self.SWEP
		if not(ply:HasWeapon(self.SWEP))then
			self:EmitSound("GlassBottle.ImpactHard",60,90)
			ply:Give(self.SWEP)
			ply:GetWeapon(self.SWEP).HmcdSpawned=self.HmcdSpawned
			self:Remove()
			ply:SelectWeapon(SWEP)
		else
			ply:PickupObject(self)
		end
	end
	function ENT:Think()
		--
	end
	function ENT:NearGround()
		return util.QuickTrace(self:GetPos()+vector_up*10,-vector_up*50,{self}).Hit
	end
	function ENT:Detonate()
		if(self.Detonated)then return end
		self.Detonated=true
		local Pos,Ground,Attacker=self:LocalToWorld(self:OBBCenter())+Vector(0,0,5),self:NearGround(),self.Owner
		ParticleEffect("pcf_jack_incendiary_air_sm2",Pos,VectorRand():Angle())
		--local Foom=EffectData()
		--Foom:SetOrigin(Pos)
		--util.Effect("explosion",Foom,true,true)
		local Flash=EffectData()
		Flash:SetOrigin(Pos)
		Flash:SetScale(2)
		util.Effect("eff_jack_hmcd_dlight",Flash,true,true)
		timer.Simple(.01,function()
			for i=0,10 do
				local Tr=util.QuickTrace(Pos,VectorRand()*math.random(10,150),{self})
				if(Tr.Hit)then util.Decal("Scorch",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal) end
			end
		end)
		timer.Simple(.02,function()
			sound.Play("snd_jack_firebomb.wav",Pos,80,100)
			for i=1,10 do sound.Play("GlassBottle.Break",Pos,80+i,100) end
		end)
		timer.Simple(.03,function()
			local Fire=ents.Create("ent_jack_hmcd_fire")
			Fire.HmcdSpawned=self.HmcdSpawned
			Fire.Initiator=Attacker
			Fire.Small=true
			Fire:SetPos(Pos)
			Fire:Spawn()
			Fire:Activate()
		end)
		timer.Simple(.04,function()
			SafeRemoveEntity(self)
		end)
	end
	function ENT:PhysicsCollide(data,physobj)
		if(data.DeltaTime>.1)then
			self:EmitSound("GlassBottle.ImpactHard")
			self:GetPhysicsObject():SetVelocity(self:GetPhysicsObject():GetVelocity()*.9)
			if(self.Ignited)then
				data.HitEntity:Ignite(100)
				self:Detonate()
			end
		end
	end
	function ENT:Light()
		self.Ignited=true
		self:Ignite(25)
		self:SetDTBool(0,true)
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