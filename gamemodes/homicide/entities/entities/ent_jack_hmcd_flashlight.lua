AddCSLuaFile()
ENT.Type="anim"
ENT.Base="ent_jack_hmcd_loot_base"
ENT.PrintName		= "Light"
ENT.ImpactSound="physics/metal/weapon_impact_soft3.wav"
if(SERVER)then
	function ENT:Initialize()
		self.Entity:SetModel("models/maxofs2d/lamp_flashlight.mdl")
		self.Entity:SetColor(Color(100,100,100,255))
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		self:SetUseType(SIMPLE_USE)
		self:DrawShadow(true)
		local phys=self:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetMass(15)
			phys:Wake()
			phys:EnableMotion(true)
		end
		if(self:GetModelScale()==1)then
			self:SetModelScale(.5,0)
			self:Activate()
			self.Entity:SetColor(Color(100,100,100,255))
		end
	end
	function ENT:PickUp(ply)
		if(not(ply.HasFlashlight)or(ply.Murderer))then -- the murderer can destroy lights
			if((ply.Murderer)and(ply.HasFlashlight))then ply:PrintMessage(HUD_PRINTTALK,translate.additionalFlashlight) end
			ply.HasFlashlight=true -- he can also pretend that he can't pick one up
			self:EmitSound("snd_jack_hmcd_flashlight.wav",65,100) -- all for the sake of plausible deniability
			self:Remove() -- so people can't use anything to prove innocence
			net.Start("hmcd_flashlightpickup")
			net.WriteEntity(ply)
			net.WriteBit(ply.HasFlashlight)
			net.Broadcast()
		end
	end
elseif(CLIENT)then
	--
end