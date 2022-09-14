AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "ent_jack_hmcd_loot_base"
ENT.PrintName		= "Fake Pistol"
ENT.SWEP="wep_jack_hmcd_fakepistol"
ENT.ImpactSound="physics/metal/weapon_impact_soft3.wav"
if(SERVER)then
	function ENT:Initialize()
		self.Entity:SetModel("models/weapons/w_pist_usp.mdl")
		self:SetColor(Color(50,50,50,255))
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
	function ENT:PickUp(ply)
		local SWEP=self.SWEP
		if(ply.Murderer)then
			ply:Give(SWEP)
			ply:GetWeapon(self.SWEP).HmcdSpawned=self.HmcdSpawned
			ply:SelectWeapon(self.SWEP)
			self:Remove()
		end
	end
elseif(CLIENT)then
	--
end