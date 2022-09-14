AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "ent_jack_hmcd_loot_base"
ENT.PrintName		= "Pocket Knife"
ENT.SWEP="wep_jack_hmcd_pocketknife"
ENT.ImpactSound="physics/metal/metal_grenade_impact_hard1.wav"
if(SERVER)then
	function ENT:Initialize()
		self.Entity:SetModel("models/weapons/w_jnife_jj.mdl")
		self:PhysicsInitBox(Vector(-4,-4,-4),Vector(4,4,4))
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		self:SetUseType(SIMPLE_USE)
		self:DrawShadow(true)
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetMass(15)
			phys:Wake()
			phys:EnableMotion(true)
		end
	end
	function ENT:PickUp(ply)
		local SWEP=self.SWEP
		if not(ply:HasWeapon(SWEP))then
			ply:Give(SWEP)
			ply:GetWeapon(self.SWEP).HmcdSpawned=self.HmcdSpawned
			ply:GetWeapon(SWEP).Poisoned=self.Poisoned
			self:Remove()
			ply:SelectWeapon(SWEP)
		else
			ply:PickupObject(self)
		end
	end
elseif(CLIENT)then
	--
end