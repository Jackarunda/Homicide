if(SERVER)then
	AddCSLuaFile()
elseif(CLIENT)then
	SWEP.DrawAmmo=false
	SWEP.DrawCrosshair=false

	SWEP.ViewModelFOV=55

	SWEP.Slot=4
	SWEP.SlotPos=5

	killicon.AddFont("wep_jack_hmcd_ducttape", "HL2MPTypeDeath", "5", Color(0, 0, 255, 255))

	function SWEP:Initialize()
		--wat
	end

	function SWEP:DrawViewModel()	
		return false
	end

	function SWEP:DrawWorldModel()	
		self:DrawModel()
	end

	function SWEP:DrawHUD()
		local Go,TrOne,TrTwo=self:FindObjects()
		if(Go)then
			local Rand=math.random(100,200)
			surface.DrawCircle(ScrW()/2,ScrH()/2,50,Color(Rand,Rand,Rand,200))
			surface.DrawCircle(ScrW()/2,ScrH()/2,49,Color(Rand,Rand,Rand,200))
			surface.DrawCircle(ScrW()/2,ScrH()/2,48,Color(Rand,Rand,Rand,200))
		end
	end
end

SWEP.Base="weapon_base"

SWEP.ViewModel="models/props_phx/wheels/drugster_front.mdl"
SWEP.WorldModel="models/props_phx/wheels/drugster_front.mdl"
if(CLIENT)then SWEP.WepSelectIcon=surface.GetTextureID("vgui/wep_jack_hmcd_ducttape");SWEP.BounceWeaponIcon=false end
SWEP.PrintName=translate.weaponDuctTape
SWEP.Instructions	= translate.weaponDuctTapeDesc
SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.BobScale=3
SWEP.SwayScale=3
SWEP.Weight	= 3
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= false

SWEP.CommandDroppable=true

SWEP.Spawnable			= true
SWEP.AdminOnly			= true

SWEP.Primary.Delay			= 0.5
SWEP.Primary.Recoil			= 3
SWEP.Primary.Damage			= 120
SWEP.Primary.NumShots		= 1	
SWEP.Primary.Cone			= 0.04
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Force			= 900
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "none"

SWEP.Secondary.Delay		= 0.9
SWEP.Secondary.Recoil		= 0
SWEP.Secondary.Damage		= 0
SWEP.Secondary.NumShots		= 1
SWEP.Secondary.Cone			= 0
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic   	= false
SWEP.Secondary.Ammo        ="none"

SWEP.ENT="ent_jack_hmcd_ducttape"
SWEP.DownAmt=0
SWEP.HomicideSWEP=true
SWEP.CanAmmoShow=false
SWEP.UnTapeables={MAT_SAND,MAT_SLOSH,MAT_SNOW}
SWEP.CarryWeight=400

function SWEP:Initialize()
	self:SetHoldType("slam")
	self.DownAmt=20
	self.PrintName=translate.weaponDuctTape
	self.Instructions	= translate.weaponDuctTapeDesc
end

function SWEP:SetupDataTables()
	--
end

function SWEP:FindObjects()
	local Pos,Vec,GotOne,Tries,TrOne,TrTwo=self.Owner:GetShootPos(),self.Owner:GetAimVector(),false,0,nil,nil
	while(not(GotOne)and(Tries<100))do
		local Tr=util.QuickTrace(Pos,Vec*60+VectorRand()*2,{self.Owner})
		if((Tr.Hit)and not(Tr.HitSky)and not(table.HasValue(self.UnTapeables,Tr.MatType)))then
			GotOne=true
			TrOne=Tr
		end
		Tries=Tries+1
	end
	if(GotOne)then
		GotOne=false
		Tries=0
		while(not(GotOne)and(Tries<100))do
			local Tr=util.QuickTrace(Pos,Vec*60+VectorRand()*2,{self.Owner})
			if((Tr.Hit)and not(Tr.HitSky)and not(table.HasValue(self.UnTapeables,Tr.MatType))and not(Tr.Entity==TrOne.Entity))then
				GotOne=true
				TrTwo=Tr
			end
			Tries=Tries+1
		end
	end
	if((TrOne)and(TrTwo))then return true,TrOne,TrTwo else return false,nil,nil end
end

function SWEP:PrimaryAttack()
	if(self.Owner:KeyDown(IN_SPEED))then return end
	if(SERVER)then
		local Go,TrOne,TrTwo=self:FindObjects()
		if(Go)then
			local DoorSealed=false
			if(HMCD_IsDoor(TrOne.Entity))then DoorSealed=true;TrOne.Entity:Fire("lock","",0) end
			if(HMCD_IsDoor(TrTwo.Entity))then DoorSealed=true;TrTwo.Entity:Fire("lock","",0) end
			if(DoorSealed)then
				if not(self.TapeAmount)then self.TapeAmount=100 end
				self.TapeAmount=self.TapeAmount-100
				sound.Play("snd_jack_hmcd_ducttape.wav",TrOne.HitPos,65,math.random(80,120))
				self.Owner:SetAnimation(PLAYER_ATTACK1)
				self.Owner:ViewPunch(Angle(3,0,0))
				self:SprayDecals()
				self.Owner:PrintMessage(HUD_PRINTCENTER,translate.weaponDoorSealed)
				timer.Simple(.1,function() if(self.TapeAmount<=0)then self:Remove() end end)
			else
				local Strength=HMCD_BindObjects(TrOne.Entity,TrOne.HitPos,TrTwo.Entity,TrTwo.HitPos)
				if not(self.TapeAmount)then self.TapeAmount=100 end
				self.TapeAmount=self.TapeAmount-10
				sound.Play("snd_jack_hmcd_ducttape.wav",TrOne.HitPos,65,math.random(80,120))
				self.Owner:SetAnimation(PLAYER_ATTACK1)
				self.Owner:ViewPunch(Angle(3,0,0))
				util.Decal("hmcd_jackatape",TrOne.HitPos+TrOne.HitNormal,TrOne.HitPos-TrOne.HitNormal)
				util.Decal("hmcd_jackatape",TrTwo.HitPos+TrTwo.HitNormal,TrTwo.HitPos-TrTwo.HitNormal)
				self.Owner:PrintMessage(HUD_PRINTCENTER,translate.weaponDuctTapeBondStrength..tostring(Strength))
				timer.Simple(.1,function() if(self.TapeAmount<=0)then self:Remove() end end)
			end
		end
	end
	self:SetNextPrimaryFire(CurTime()+2.5)
end

function SWEP:SprayDecals()
	local Tr=util.QuickTrace(self.Owner:GetShootPos(),self.Owner:GetAimVector()*70,{self.Owner})
	util.Decal("hmcd_jackatape",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal)
	local Tr2=util.QuickTrace(self.Owner:GetShootPos(),(self.Owner:GetAimVector()+Vector(0,0,.15))*70,{self.Owner})
	util.Decal("hmcd_jackatape",Tr2.HitPos+Tr2.HitNormal,Tr2.HitPos-Tr2.HitNormal)
	local Tr3=util.QuickTrace(self.Owner:GetShootPos(),(self.Owner:GetAimVector()+Vector(0,0,-.15))*70,{self.Owner})
	util.Decal("hmcd_jackatape",Tr3.HitPos+Tr3.HitNormal,Tr3.HitPos-Tr3.HitNormal)
	local Tr4=util.QuickTrace(self.Owner:GetShootPos(),(self.Owner:GetAimVector()+Vector(0,.15,0))*70,{self.Owner})
	util.Decal("hmcd_jackatape",Tr4.HitPos+Tr4.HitNormal,Tr4.HitPos-Tr4.HitNormal)
	local Tr5=util.QuickTrace(self.Owner:GetShootPos(),(self.Owner:GetAimVector()+Vector(0,-.15,0))*70,{self.Owner})
	util.Decal("hmcd_jackatape",Tr5.HitPos+Tr5.HitNormal,Tr5.HitPos-Tr5.HitNormal)
	local Tr6=util.QuickTrace(self.Owner:GetShootPos(),(self.Owner:GetAimVector()+Vector(.15,0,0))*70,{self.Owner})
	util.Decal("hmcd_jackatape",Tr6.HitPos+Tr6.HitNormal,Tr6.HitPos-Tr6.HitNormal)
	local Tr7=util.QuickTrace(self.Owner:GetShootPos(),(self.Owner:GetAimVector()+Vector(-.15,0,0))*70,{self.Owner})
	util.Decal("hmcd_jackatape",Tr7.HitPos+Tr7.HitNormal,Tr7.HitPos-Tr7.HitNormal)
end

function SWEP:Deploy()
	self:SetNextPrimaryFire(CurTime()+1)
	self.DownAmt=60
	return true
end

function SWEP:Holster()
	self:OnRemove()
	return true
end

function SWEP:SecondaryAttack()
	--
end

function SWEP:Think()
	if(SERVER)then
		local HoldType="slam"
		if(self.Owner:KeyDown(IN_SPEED))then
			HoldType="normal"
		end
		self:SetHoldType(HoldType)
	end
end

function SWEP:Reload()
	if(SERVER)then self.Owner:PrintMessage(HUD_PRINTCENTER,tostring(self.TapeAmount or 100)..translate.weaponDuctTapeRemaining) end
end

function SWEP:OnDrop()
	local Ent=ents.Create(self.ENT)
	Ent.HmcdSpawned=self.HmcdSpawned
	Ent:SetPos(self:GetPos())
	Ent:SetAngles(self:GetAngles())
	if(self.TapeAmount)then Ent.TapeAmount=self.TapeAmount end
	Ent:Spawn()
	Ent:Activate()
	Ent:GetPhysicsObject():SetVelocity(self:GetVelocity()/2)
	self:Remove()
end
function SWEP:OnRemove()
	if(IsValid(self.Owner) && CLIENT && self.Owner:IsPlayer())then
		local vm=self.Owner:GetViewModel()
		if(IsValid(vm)) then vm:SetMaterial("");vm:SetColor(Color(255,255,255,255)) end
	end
end
if(CLIENT)then
	function SWEP:PreDrawViewModel(vm,ply,wep)
		vm:SetMaterial("models/shiny")
		vm:SetColor(Color(100,100,100,255))
	end
	function SWEP:GetViewModelPosition(pos,ang)
		if not(self.DownAmt)then self.DownAmt=0 end
		if(self.Owner:KeyDown(IN_SPEED))then
			self.DownAmt=math.Clamp(self.DownAmt+1,0,60)
		else
			self.DownAmt=math.Clamp(self.DownAmt-1,0,60)
		end
		pos=pos-ang:Up()*(self.DownAmt+30)+ang:Forward()*100+ang:Right()*50
		--ang:RotateAroundAxis(ang:Up(),0)
		ang:RotateAroundAxis(ang:Right(),90)
		ang:RotateAroundAxis(ang:Forward(),-90)
		return pos,ang
	end
	function SWEP:DrawWorldModel()
		local Pos,Ang=self.Owner:GetBonePosition(self.Owner:LookupBone("ValveBiped.Bip01_R_Hand"))
		if(self.DatWorldModel)then
			if((Pos)and(Ang)and(GAMEMODE:ShouldDrawWeaponWorldModel(self)))then
				self.DatWorldModel:SetRenderOrigin(Pos+Ang:Forward()*3.5+Ang:Right()*5-Ang:Up()*-1)
				Ang:RotateAroundAxis(Ang:Right(),180)
				--Ang:RotateAroundAxis(Ang:Right(),90)
				self.DatWorldModel:SetRenderAngles(Ang)
				self.DatWorldModel:DrawModel()
			end
		else
			self.DatWorldModel=ClientsideModel("models/props_phx/wheels/drugster_front.mdl")
			self.DatWorldModel:SetPos(self:GetPos())
			self.DatWorldModel:SetParent(self)
			self.DatWorldModel:SetNoDraw(true)
			self.DatWorldModel:SetModelScale(.2,0)
			self.DatWorldModel:SetMaterial("models/shiny")
			self.DatWorldModel:SetColor(Color(100,100,100,255))
		end
	end
end