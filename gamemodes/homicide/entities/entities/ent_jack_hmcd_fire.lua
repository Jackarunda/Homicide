AddCSLuaFile()
ENT.Type="anim"
ENT.Base="base_anim"
ENT.PrintName		= "Fire"
if(SERVER)then
	function ENT:Initialize()
		self.Entity:SetMoveType( MOVETYPE_NONE )
		self.Entity:DrawShadow( false )
		self.Entity:SetNoDraw(true)
		
		self.Entity:SetCollisionBounds( Vector( -20, -20, -10 ), Vector( 20, 20, 10 ) )
		self.Entity:PhysicsInitBox( Vector( -20, -20, -10 ), Vector( 20, 20, 10 ) )
		
		local phys=self.Entity:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:EnableCollisions( false )		
		end
		self.Entity:SetNotSolid(true)
		self.Radius=200
		self.NextSound=0
		SafeRemoveEntityDelayed(self,30)
	end
	function ENT:Think()
		local SelfPos=self:GetPos()+Vector(0,0,math.random(0,100))+VectorRand()*math.random(0,100)
		if(self.Radius>275)then
			local Foof=EffectData()
			Foof:SetOrigin(SelfPos)
			Foof:SetRadius(self.Radius)
			util.Effect("eff_jack_hmcd_fire",Foof,true,true)
		end
		for key,obj in pairs(ents.FindInSphere(SelfPos,self.Radius))do
			if((obj!=self)and(obj.GetPhysicsObject)and(IsValid(obj:GetPhysicsObject())))then
				local Dist=(obj:GetPos()-self:GetPos()):Length()
				local Frac=1-(Dist/self.Radius)
				if(self:Visible(obj))then
					local Dmg=DamageInfo()
					Dmg:SetAttacker(self.Initiator or game.GetWorld())
					Dmg:SetInflictor(self)
					Dmg:SetDamageType(DMG_BURN)
					Dmg:SetDamagePosition(SelfPos)
					Dmg:SetDamageForce(Vector(0,0,0))
					Dmg:SetDamage(Frac*3)
					obj:TakeDamageInfo(Dmg)
					local SpectPly=((obj:IsPlayer())and(obj:IsCSpectating()))
					if not((obj:IsOnFire())or(obj:WaterLevel()>0)or(SpectPly))then
						obj:Ignite(Frac*30)
					end
				end
			end
		end
		if(self.NextSound<CurTime())then
			self.NextSound=CurTime()+7
			sound.Play("snd_jack_firebomb.wav",SelfPos,80,100)
		end
		if(self.Small)then
			self.Radius=self.Radius+3
		else
			self.Radius=self.Radius+6
		end
		self:NextThink(CurTime()+.2)
		return true
	end
elseif(CLIENT)then
	--
end