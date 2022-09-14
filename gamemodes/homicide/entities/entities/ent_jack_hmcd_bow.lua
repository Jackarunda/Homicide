AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "ent_jack_hmcd_loot_base"
ENT.PrintName		= "Bow"
ENT.SWEP="wep_jack_hmcd_bow"
ENT.ImpactSound="physics/metal/weapon_impact_soft3.wav"
if(SERVER)then
	function ENT:Initialize()
		self.Entity:SetModel("models/weapons/w_snij_awp.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
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
	function ENT:PickUp(ply)
		local SWEP=self.SWEP
		if not(self.RoundsInMag)then self.RoundsInMag=30 end
		if(ply:HasWeapon(self.SWEP))then
			ply:PickupObject(self)
		else
			ply:Give(self.SWEP)
			ply:GetWeapon(self.SWEP).HmcdSpawned=self.HmcdSpawned
			if(self.GameSpawned)then ply:GiveAmmo(1,"XBowBolt",true) end
			self:Remove()
			ply:SelectWeapon(SWEP)
		end
	end
elseif(CLIENT)then
	--
end