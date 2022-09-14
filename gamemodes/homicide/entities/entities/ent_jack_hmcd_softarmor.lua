AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "ent_jack_hmcd_loot_base"
ENT.PrintName		= "Soft Body Armor"
ENT.ImpactSound="physics/body/body_medium_impact_soft5.wav"
if(SERVER)then
	function ENT:Initialize()
		self.Entity:SetModel("models/jworld_equipment/kevlar.mdl")
		self.Entity:SetMaterial("models/mat_jack_hmcd_armor")
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
		if((ply.ChestArmor)and(ply.ChestArmor=="Level IIIA"))then
			ply:PickupObject(self)
		else
			if((ply.ChestArmor)and(ply.ChestArmor=="Level III"))then
				local Armor=ents.Create("ent_jack_hmcd_hardarmor")
				Armor:SetPos(ply:GetShootPos()+ply:GetAimVector()*20)
				Armor.HmcdSpawned=true
				Armor:Spawn();Armor:Activate()
				Armor:GetPhysicsObject():SetVelocity(ply:GetVelocity())
			end
			ply:SetChestArmor("Level IIIA")
			sound.Play("snd_jack_hmcd_disguise.wav",ply:GetPos(),65,80)
			self:Remove()
		end
	end
elseif(CLIENT)then
	--
end