AddCSLuaFile()
ENT.Type="anim"
ENT.Base="ent_jack_hmcd_loot_base"
ENT.PrintName		= "Hard Body Armor"
ENT.ImpactSound="physics/body/body_medium_impact_soft5.wav"
ENT.SecondSound="physics/metal/metal_canister_impact_hard3.wav"
if(SERVER)then
	function ENT:Initialize()
		self.Entity:SetModel("models/jworld_equipment/kevlar.mdl")
		self.Entity:SetMaterial("models/mat_jack_hmcd_armor")
		self.Entity:SetColor(Color(50,50,50,255))
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		self:SetUseType(SIMPLE_USE)
		self:DrawShadow(true)
		local phys=self:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetMass(50)
			phys:Wake()
			phys:EnableMotion(true)
		end
	end
	function ENT:PickUp(ply)
		if((ply.ChestArmor)and(ply.ChestArmor=="Level III"))then
			ply:PickupObject(self)
		else
			if((ply.ChestArmor)and(ply.ChestArmor=="Level IIIA"))then
				local Armor=ents.Create("ent_jack_hmcd_softarmor")
				Armor:SetPos(ply:GetShootPos()+ply:GetAimVector()*20)
				Armor.HmcdSpawned=true
				Armor:Spawn();Armor:Activate()
				Armor:GetPhysicsObject():SetVelocity(ply:GetVelocity())
			end
			ply:SetChestArmor("Level III")
			sound.Play("snd_jack_hmcd_disguise.wav",ply:GetPos(),65,80)
			self:Remove()
		end
	end
elseif(CLIENT)then
	--
end