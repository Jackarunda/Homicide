/*---------------------------------------------------------
   Init( data table )
---------------------------------------------------------*/
function EFFECT:Init( data )

	self.Position=data:GetOrigin()
	self.Position.z=self.Position.z+4
	self.TimeLeft=CurTime()+1
	self.GAlpha=254
	self.DerpAlpha=254
	self.GSize=200
	self.CloudHeight =1*2.5
	
	self.Refract=0
	self.Size=48
	
	self.SplodeDist=2000
	self.BlastSpeed=6000
	self.lastThink=0
	self.MinSplodeTime=CurTime()+self.CloudHeight/self.BlastSpeed
	self.MaxSplodeTime=CurTime()+6
	self.GroundPos=self.Position - Vector(0,0,self.CloudHeight)
	
	local Pos=self.Position

	self.smokeparticles={}
	self.Emitter=ParticleEmitter( Pos )

	local spawnpos=Pos
	
	local Scayul=data:GetScale()
	self.Scayul=Scayul
	
	local AddVel=Vector(0,0,0)
	for k=0,100*Scayul do
		local sprite
		local chance=math.random(1,3)
		if(chance==1)then
			sprite="particle/smokestack"
		elseif(chance==2)then
			sprite="effects/thick_smoke"
		elseif(chance==3)then
			sprite="effects/thick_smoke2"
		end
		local particle=self.Emitter:Add(sprite,Pos+VectorRand()*math.Rand(1,80))
		particle:SetVelocity(VectorRand()*math.Rand(1,25)*Scayul)
		particle:SetAirResistance(100)
		particle:SetGravity(Vector(math.Rand(-300,300),math.Rand(-300,300),math.Rand(-100,100)))
		particle:SetDieTime(math.Rand(.1,1)*Scayul)
		particle:SetStartAlpha(math.Rand(200,255))
		particle:SetEndAlpha(0)
		local Size=math.random(10,100)
		particle:SetStartSize(Size/3)
		particle:SetEndSize(Size)
		particle:SetRoll(0)
		if(math.random(1,2)==1)then
			particle:SetRollDelta(0)
		else
			particle:SetRollDelta(math.Rand(-2,2))
		end
		local Amt=math.random(10,40)
		particle:SetColor(Amt,Amt,Amt)
		particle:SetLighting(true)
		particle:SetCollide(false)
	end
	
	self.Emitter:Finish()
end

/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )
	return false
end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render( )


end
