AddCSLuaFile()
ENT.Type="anim"
ENT.Base="base_anim"
ENT.PrintName		= "Rauchbombe"
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
if(SERVER)then
	function ENT:Initialize()
		self.Entity:SetModel("models/props_junk/jlare.mdl")
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		self:SetUseType(SIMPLE_USE)
		self:DrawShadow(true)
		local phys=self:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
			phys:EnableMotion(true)
		end
		self.BurnoutTime=CurTime()+30
		self.NextSmokeTime=CurTime()+.25
		self:SetDTBool(0,false)
		self.NextHide=CurTime()+5
	end

	function ENT:Use(ply)
		--
	end

	function ENT:Think()
		if(self:WaterLevel()>=3)then self:Remove() return end
		if(self.NextSmokeTime<CurTime())then
			self.NextSmokeTime=CurTime()+.5
			ParticleEffect("pcf_jack_smokebomb3",self:GetPos(),Angle(0,0,0),self)
		end
		if(self.NextHide<CurTime())then
			self:SetDTBool(0,true)
		end
		self:EmitSound("snd_jack_hmcd_flare.wav",65,math.random(95,105))
		self:NextThink(CurTime()+.15)
		if(self.BurnoutTime<CurTime())then self:Remove() end
		return true
	end
elseif(CLIENT)then
	local Glow=Material("sprites/mat_jack_basicglow")
	function ENT:Initialize()
		--
	end
	function ENT:Draw()
		local Pos=self:GetPos()
		render.SetMaterial(Glow)
		render.DrawSprite(Pos,50,50,Color(255,math.random(150,220),math.random(125,150),255))
		self:DrawModel()
	end
end