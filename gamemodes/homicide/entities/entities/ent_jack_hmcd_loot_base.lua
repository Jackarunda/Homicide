AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName		= "Loot"
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.IsLoot=true
if(SERVER)then
	ENT.ImpactSound="Drywall.ImpactHard"
	function ENT:Initialize()
		self.Entity:SetModel("models/weapons/w_pist_usp.mdl")
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		self:SetUseType(SIMPLE_USE)
		self:DrawShadow(true)
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetMass(20)
			phys:Wake()
			phys:EnableMotion(true)
		end
	end
	function ENT:Use(ply)
		if((GAMEMODE.ZOMBIE)and(ply.Murderer))then return end
		if(self.ContactPoisoned)then
			if(ply.Murderer)then
				ply:PrintMessage(HUD_PRINTTALK,translate.poisoned)
				return
			else
				self.ContactPoisoned=false
				HMCD_Poison(ply,self.Poisoner)
			end
		end
		self.Touched=true
		self:PickUp(ply)
	end
	function ENT:Think()
		if((self.GameSpawned)and not(self.Touched))then
			if not(self.Untouched)then self.Untouched=0 end
			local Near,Pos,MaxDist=false,self:GetPos(),500
			if(GAMEMODE.SHTF)then MaxDist=1000 end
			for key,found in pairs(team.GetPlayers(2))do
				if((found:GetPos()-Pos):Length()<MaxDist)then Near=true break end
			end
			if(Near)then
				self.Untouched=0
			else
				self.Untouched=self.Untouched+1
			end
			if(self.Untouched>10)then
				self:Remove()
				return
			end
		end
		self:NextThink(CurTime()+5)
		return true
	end
	function ENT:PhysicsCollide(data,ent)
		if(data.DeltaTime>.1)then
			self:EmitSound(self.ImpactSound,math.Clamp(data.Speed/3,20,65),math.random(100,120))
			if(self.SecondSound)then sound.Play(self.SecondSound,self:GetPos(),math.Clamp(data.Speed/3,20,65),math.random(100,120)) end
		end
	end
elseif(CLIENT)then
	function ENT:Initialize()
		--
	end
	function ENT:Draw()
		self:DrawModel()
	end
end