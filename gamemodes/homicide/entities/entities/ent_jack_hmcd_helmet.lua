AddCSLuaFile()
ENT.Type="anim"
ENT.Base="ent_jack_hmcd_loot_base"
ENT.PrintName		= "Ballistic Helmet"
ENT.ImpactSound="physics/body/body_medium_impact_soft5.wav"
if(SERVER)then
	function ENT:Initialize()
		self.Entity:SetModel("models/barney_helmet.mdl")
		self.Entity:SetMaterial("models/mat_jack_hmcd_armor")
		self.Entity:SetColor(Color(200,200,200,255))
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		self:SetUseType(SIMPLE_USE)
		self:DrawShadow(true)
		local phys=self:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetMass(20)
			phys:Wake()
			phys:EnableMotion(true)
		end
	end
	function ENT:PickUp(ply)
		if(not(ply.HeadArmor)or(ply.HeadArmor==""))then
			ply:SetHeadArmor("ACH")
			sound.Play("snd_jack_hmcd_disguise.wav",ply:GetPos(),65,120)
			self:Remove()
		else
			ply:PickupObject(self)
		end
	end
elseif(CLIENT)then
	--
end