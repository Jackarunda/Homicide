AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "ent_jack_hmcd_loot_base"
ENT.PrintName		= "Hatchet"
ENT.SWEP="wep_jack_hmcd_hatchet"
ENT.ImpactSound="physics/metal/metal_solid_impact_soft1.wav"
ENT.MurdererLoot=true
if(SERVER)then
	function ENT:Initialize()
		self.Entity:SetModel("models/props/cs_militia/axe.mdl")
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
		self:SetUseType(SIMPLE_USE)
		self:DrawShadow(true)
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetMass(5)
			phys:Wake()
			phys:EnableMotion(true)
		end
		self.HitSomething=false
		if not(self.Thrown)then self:SetCollisionGroup(COLLISION_GROUP_WEAPON) end
	end
	function ENT:PhysicsCollide(data,phys)
		if((self.Thrown)and not(self.HitSomething))then
			self.HitSomething=true
			if(data.HitEntity:GetClass()=="func_breakable_surf")then
				data.HitEntity:Fire("break","",0)
			end
			if(math.Rand(0,1)<.6666)then
				-- head hit
				local Dmg,DmgAmt=DamageInfo(),math.random(20,30)
				Dmg:SetDamage(DmgAmt)
				Dmg:SetDamageForce(data.OurOldVelocity)
				Dmg:SetDamagePosition(self:GetPos())
				Dmg:SetDamageType(DMG_SLASH)
				Dmg:SetAttacker(self.Owner)
				Dmg:SetInflictor(self)
				data.HitEntity:TakeDamageInfo(Dmg)
				if((data.HitEntity:IsPlayer())or(data.HitEntity:IsNPC()))then
					self:EmitSound("snd_jack_hmcd_axehit.wav",75,math.random(110,130))
					if(data.HitEntity:IsPlayer())then
						if(self.Poisoned)then
							self.Poisoned=false
							HMCD_Poison(data.HitEntity,self.Owner)
						end
					end
					local edata=EffectData()
					edata:SetStart(self:GetPos())
					edata:SetOrigin(self:GetPos())
					edata:SetNormal(vector_up)
					edata:SetEntity(data.HitEntity)
					util.Effect("BloodImpact",edata,true,true)
					timer.Simple(.05,function()
						for i=1,2 do
							local BloodTr=util.QuickTrace(data.HitPos-data.OurOldVelocity:GetNormalized()*10,data.OurOldVelocity:GetNormalized()*50,{self})
							if(BloodTr.Hit)then util.Decal("Blood",BloodTr.HitPos+BloodTr.HitNormal,BloodTr.HitPos-BloodTr.HitNormal) end
						end
					end)
				else
					self:EmitSound("physics/metal/metal_solid_impact_hard1.wav",75,math.random(90,110))
				end
			else
				-- handle hit
				self:EmitSound(self.ImpactSound,70,math.random(90,110))
			end
			self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		else
			if(data.DeltaTime>.2)then self:EmitSound(self.ImpactSound,65,math.random(90,110)) end
		end
	end
	function ENT:PickUp(ply)
		local SWEP=self.SWEP
		if(((ply.Murderer)or(GAMEMODE.ZOMBIE))and not(ply:HasWeapon(SWEP)))then
			ply:Give(SWEP)
			ply:GetWeapon(self.SWEP).HmcdSpawned=self.HmcdSpawned
			ply:GetWeapon(SWEP).Poisoned=self.Poisoned
			ply:SelectWeapon(SWEP)
			self:Remove()
			ply:SelectWeapon(SWEP)
		end
	end
elseif(CLIENT)then
	function ENT:Initialize()
		--
	end
	function ENT:Draw()
		local Mat=Matrix()
		Mat:Scale(Vector(.9,.4,.9))
		self:EnableMatrix("RenderMultiply",Mat)
		self:DrawModel()
	end
end