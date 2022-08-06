AddCSLuaFile()
ENT.Type="anim"
ENT.Base="ent_jack_hmcd_loot_base"
ENT.PrintName		= "Walkie Talkie"
ENT.SWEP="wep_jack_hmcd_walkietalkie"
ENT.ImpactSound="physics/metal/weapon_impact_soft3.wav"
if(SERVER)then
	function ENT:Initialize()
		self.Entity:SetModel("models/sirgibs/ragdoll/css/terror_arctic_radio.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		self:SetUseType(SIMPLE_USE)
		self:DrawShadow(true)
		local phys=self:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetMass(10)
			phys:Wake()
			phys:EnableMotion(true)
		end
	end
	function ENT:PickUp(ply)
		local SWEP=self.SWEP
		if(not(ply:HasWeapon(self.SWEP))or(ply.Murderer))then
			self:EmitSound(self.ImpactSound,60,100)
			ply:Give(self.SWEP)
			ply:GetWeapon(self.SWEP).HmcdSpawned=self.HmcdSpawned
			self:Remove()
			ply:SelectWeapon(SWEP)
			if((ply.Murderer)and(ply:HasWeapon(self.SWEP)))then ply:PrintMessage(HUD_PRINTTALK,"You hide the additional walkie talkie.") end
		end
	end
elseif(CLIENT)then
	--
end