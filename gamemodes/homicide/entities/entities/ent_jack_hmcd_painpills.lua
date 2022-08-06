AddCSLuaFile()
ENT.Type="anim"
ENT.Base="ent_jack_hmcd_loot_base"
ENT.PrintName		= "Pain Pills"
ENT.SWEP="wep_jack_hmcd_painpills"
ENT.ImpactSound="snd_jack_hmcd_pillsbounce.wav"
if(SERVER)then
	function ENT:Initialize()
		self.Entity:SetModel("models/w_models/weapons/w_eq_painpills.mdl")
		self:PhysicsInit( SOLID_VPHYSICS )
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
		if not(ply:HasWeapon(SWEP))then
			self:EmitSound(self.ImpactSound,60,100)
			ply:Give(SWEP)
			ply:GetWeapon(self.SWEP).HmcdSpawned=self.HmcdSpawned
			ply:GetWeapon(SWEP).Poisoned=self.Poisoned
			ply:GetWeapon(SWEP).Poisoner=self.Poisoner
			self:Remove()
			ply:SelectWeapon(SWEP)
		else
			ply:PickupObject(self)
		end
	end
elseif(CLIENT)then
	--
end