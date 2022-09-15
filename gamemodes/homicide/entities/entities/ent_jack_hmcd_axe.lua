AddCSLuaFile()
ENT.Type="anim"
ENT.Base="ent_jack_hmcd_loot_base"
ENT.PrintName		= "Axe"
ENT.SWEP="wep_jack_hmcd_axe"
ENT.ImpactSound="physics/wood/wood_plank_impact_soft1.wav"
ENT.MurdererLoot=true
if(SERVER)then
	function ENT:Initialize()
		self.Entity:SetModel("models/props/cs_militia/axe.mdl")
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		self:SetUseType(SIMPLE_USE)
		self:DrawShadow(true)
		local phys=self:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetMass(25)
			phys:Wake()
			phys:EnableMotion(true)
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
	--
end