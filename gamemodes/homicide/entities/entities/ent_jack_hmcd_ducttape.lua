AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "ent_jack_hmcd_loot_base"
ENT.PrintName		= "Duct Tape"
ENT.SWEP="wep_jack_hmcd_ducttape"
ENT.ImpactSound="physics/body/body_medium_impact_soft5.wav"
if(SERVER)then
	function ENT:Initialize()
		self.Entity:SetModel("models/props_phx/wheels/drugster_front.mdl")
		self:SetModelScale(.2,0)
		self.Entity:SetMaterial("models/shiny")
		self.Entity:SetColor(Color(100,100,100,255))
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		self:SetUseType(SIMPLE_USE)
		self:DrawShadow(true)
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetMass(10)
			phys:Wake()
			phys:EnableMotion(true)
		end
	end
	function ENT:PickUp(ply)
		local SWEP=self.SWEP
		if not(ply:HasWeapon(SWEP))then
			self:EmitSound(self.ImpactSound,60,100)
			ply:Give(SWEP)
			ply:GetWeapon(self.SWEP).HmcdSpawned=self.HmcdSpawned
			if(self.TapeAmount)then ply:GetWeapon(SWEP).TapeAmount=self.TapeAmount end
			self:Remove()
			ply:SelectWeapon(SWEP)
		else
			ply:PickupObject(self)
		end
	end
elseif(CLIENT)then
	--
end