if ( SERVER ) then
	AddCSLuaFile()
else
	killicon.AddFont( "wep_jack_hmcd_fakepistol", "HL2MPTypeDeath", "1", Color( 255, 0, 0 ) )
	SWEP.WepSelectIcon=surface.GetTextureID("vgui/wep_jack_hmcd_fakepistol")
	SWEP.BounceWeaponIcon=false
end
SWEP.Base="weapon_base"
SWEP.PrintName		= "Fake Pistol"
SWEP.Instructions	= "This is an empty, black-spraypainted airsoft gun. Use it to trick innocents and lure them to their doom, either by pretending to be the gunman or pressing LMB to drop as bait."
SWEP.Slot			= 5
SWEP.SlotPos		= 3
SWEP.DrawAmmo		= false
SWEP.DrawCrosshair	= false
SWEP.ViewModelFlip	= true
SWEP.ViewModelFOV	= 75
SWEP.ViewModel		= "models/weapons/v_pist_jivejevej.mdl"
SWEP.WorldModel		= "models/weapons/w_pist_usp.mdl"
SWEP.HoldType		= "pistol"
SWEP.BobScale=1.5
SWEP.SwayScale=1.5
SWEP.Weight			= 5
SWEP.AutoSwitchTo	= true
SWEP.AutoSwitchFrom	= false
SWEP.Spawnable		= true
SWEP.AdminOnly		= true

SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""

SWEP.Primary.Sound				= ""
SWEP.Primary.Damage				= 0
SWEP.Primary.NumShots			= 0
SWEP.Primary.Recoil				= 0
SWEP.Primary.Cone				= 0
SWEP.Primary.Delay				= 0
SWEP.Primary.ClipSize			= 0
SWEP.Primary.DefaultClip		= 0
SWEP.Primary.Tracer				= 0
SWEP.Primary.Force				= 0
SWEP.Primary.TakeAmmoPerBullet	= false
SWEP.Primary.Automatic			= false
SWEP.Primary.Ammo				= "none"
SWEP.Primary.ReloadTime=0
SWEP.ReloadFinishedSound		= Sound("Weapon_Crossbow.BoltElectrify")
SWEP.ReloadSound=Sound("Weapon_357.Reload")

SWEP.Secondary.Sound				= ""
SWEP.Secondary.Damage				= 0
SWEP.Secondary.NumShots				= 0
SWEP.Secondary.Recoil				= 0
SWEP.Secondary.Cone					= 0
SWEP.Secondary.Delay				= 0
SWEP.Secondary.ClipSize				= 0
SWEP.Secondary.DefaultClip			= 0
SWEP.Secondary.Tracer				= 0
SWEP.Secondary.Force				= 0
SWEP.Secondary.TakeAmmoPerBullet	= false
SWEP.Secondary.Automatic			= false
SWEP.Secondary.Ammo					= "none"

SWEP.BarrelMustSmoke=false
SWEP.AimTime=3
SWEP.BearTime=3
SWEP.SprintPos=Vector(-4,0,-10)
SWEP.SprintAng=Angle(80,0,0)
SWEP.AimPos=Vector(1.75,0,1.22)
SWEP.DeathDroppable=false
SWEP.CanAmmoShow=false
SWEP.InitialLoaded=false
SWEP.CommandDroppable=false
SWEP.HomicideSWEP=true
SWEP.ENT="ent_jack_hmcd_fakepistol"
SWEP.BarrelLength=10

function SWEP:Initialize()
	self.NextFrontBlockCheckTime=CurTime()
	self:SetHoldType("pistol")
	self:SetAiming(0)
	self:SetSprinting(0)
	self:SetReady(true)
	self:SetColor(Color(50,50,50,255))
end

function SWEP:SetupDataTables()
	self:NetworkVar("Bool",0,"Ready")
	self:NetworkVar("Int",0,"Aiming")
	self:NetworkVar("Int",1,"Sprinting")
end

function SWEP:BulletCallback(att, tr, dmg)
	return {effects=true, damage=true}
end

function SWEP:PrimaryAttack()
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	if(SERVER)then
		local Fake=ents.Create(self.ENT)
		Fake.HmcdSpawned=self.HmcdSpawned
		Fake:SetPos(self.Owner:GetPos()+self.Owner:GetForward()+Vector(0,0,10))
		Fake:Spawn()
		Fake:Activate()
		Fake:GetPhysicsObject():SetVelocity(self.Owner:GetVelocity())
		self:Remove()
	end
end

function SWEP:SecondaryAttack()
	-- wat
end

function SWEP:Think()
	if(SERVER)then
		local Sprintin,Aimin,AimAmt,SprintAmt=self.Owner:KeyDown(IN_SPEED),self.Owner:KeyDown(IN_ATTACK2),self:GetAiming(),self:GetSprinting()
		if((Sprintin)or(self:FrontBlocked()))then
			self:SetSprinting(math.Clamp(SprintAmt+40*(1/(self.BearTime)),0,100))
			self:SetAiming(math.Clamp(AimAmt-30*(1/(self.AimTime)),0,100))
		elseif((Aimin)and(self.Owner:OnGround()))then
			self:SetAiming(math.Clamp(AimAmt+30*(1/(self.AimTime)),0,100))
			self:SetSprinting(math.Clamp(SprintAmt-30*(1/(self.BearTime)),0,100))
		else
			self:SetAiming(math.Clamp(AimAmt-30*(1/(self.AimTime)),0,100))
			self:SetSprinting(math.Clamp(SprintAmt-30*(1/(self.BearTime)),0,100))
		end
		local HoldType="normal"
		if(SprintAmt>90)then
			HoldType="normal"
		elseif((Aimin)and not(self.Owner:Crouching()))then
			HoldType="revolver"
		else
			HoldType="pistol"
		end
		self:SetHoldType(HoldType)
	end
end

function SWEP:Reload()
	-- nothin
end

function SWEP:Deploy()
	if not(IsFirstTimePredicted())then
		self:DoBFSAnimation("draw")
		self.Owner:GetViewModel():SetPlaybackRate(.1)
		return
	end
	self:DoBFSAnimation("draw")
	self.Owner:GetViewModel():SetPlaybackRate(.75)
	self:SetReady(false)
	self:EmitSound("snd_jack_hmcd_pistoldraw.wav",70,110)
	timer.Simple(1,function() if(IsValid(self))then self:SetReady(true) end end)
	return true
end

function SWEP:DoBFSAnimation(anim)
	--print(CLIENT,SERVER,IsFirstTimePredicted(),anim,CurTime())
	local vm=self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence(vm:LookupSequence(anim))
end

function SWEP:UpdateNextIdle()
	local vm=self.Owner:GetViewModel()
	self:SetNextIdle(CurTime()+vm:SequenceDuration())
end

function SWEP:Holster()
	if not(self:GetReady())then return false end
	self:SetReady(false)
	return true
end

function SWEP:OnRemove()
end

function SWEP:OnRestore()
end

function SWEP:Precache()
end

function SWEP:OwnerChanged()
end

function SWEP:FrontBlocked()
	local Time=CurTime()
	if(self.NextFrontBlockCheckTime<Time)then
		self.NextFrontBlockCheckTime=Time+.25
		local ShootVec,Ang,ShootPos=self.Owner:GetAimVector(),self.Owner:GetAngles(),self.Owner:GetShootPos()
		--print(ShootVec,Ang,ShootPos)
		ShootPos=ShootPos+ShootVec*15
		Ang.p=0;Ang.r=0
		local Tr=util.TraceLine({
			start=ShootPos-Ang:Forward()*5,
			endpos=ShootPos+(ShootVec*self.BarrelLength)+Ang:Forward()*15,
			filter={self.Owner}
		})
		if(Tr.Hit)then
			if not(Tr.Entity.JIBFS_NoBlock)then self.FrontallyBlocked=true end
		else
			self.FrontallyBlocked=false
		end
	end
	return self.FrontallyBlocked
end

if(CLIENT)then
	local Crouched=0
	local LastSprintGotten=0
	local LastAimGotten=0
	function SWEP:GetViewModelPosition(pos,ang)
		if not(IsValid(self.Owner))then return pos,ang end
		local SprintGotten=Lerp(.1,LastSprintGotten,self:GetSprinting())
		LastSprintGotten=SprintGotten
		local AimGotten=Lerp(.1,LastAimGotten,self:GetAiming())
		LastAimGotten=AimGotten
		local Aim,Sprint,Up,Forward,Right=AimGotten,SprintGotten/100,ang:Up(),ang:Forward(),ang:Right()
		local Vec=self.AimPos*(Aim/100)
		if((Sprint>0)and(self:GetReady()))then
			pos=pos+Up*self.SprintPos.z*Sprint+Forward*self.SprintPos.y*Sprint+Right*self.SprintPos.x*Sprint
			ang:RotateAroundAxis(ang:Right(),self.SprintAng.p*Sprint)
			ang:RotateAroundAxis(ang:Up(),self.SprintAng.y*Sprint)
			ang:RotateAroundAxis(ang:Forward(),self.SprintAng.r*Sprint)
		end
		pos=pos+Vec.x*Right+Vec.y*Forward+Vec.z*Up
		if(self.Owner:KeyDown(IN_DUCK))then Crouched=math.Clamp(Crouched+.01,0,1) else Crouched=math.Clamp(Crouched-.01,0,1) end
		Crouched=Crouched*(1-(Aim/100))
		pos=pos+Up*Crouched*2
		return pos,ang
	end
end