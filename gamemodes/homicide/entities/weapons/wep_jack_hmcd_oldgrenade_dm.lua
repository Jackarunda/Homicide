if(SERVER)then
	AddCSLuaFile()
elseif(CLIENT)then
	SWEP.DrawAmmo=false
	SWEP.DrawCrosshair=false
	SWEP.ViewModelFOV=65
	SWEP.Slot=4
	SWEP.SlotPos=2
	killicon.AddFont("wep_jack_hmcd_oldgrenade_dm", "HL2MPTypeDeath", "5", Color(0, 0, 255, 255))
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
		--
	end
end
SWEP.Base="weapon_base"
SWEP.ViewModel="models/weapons/v_jj_fraggrenade.mdl"
SWEP.WorldModel="models/weapons/w_jj_fraggrenade.mdl"
if(CLIENT)then SWEP.WepSelectIcon=surface.GetTextureID("vgui/wep_jack_hmcd_oldgrenade");SWEP.BounceWeaponIcon=false end
SWEP.PrintName=translate.weaponGrenade
SWEP.Instructions	= translate.weaponGrenadeDescDM
SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.BobScale=3
SWEP.SwayScale=3
SWEP.Weight	= 3
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= false
SWEP.ViewModelFlip=true
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
SWEP.Primary.Automatic   	= false
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
SWEP.HomicideSWEP=true
SWEP.CommandDroppable=true
SWEP.CarryWeight=1000
function SWEP:Initialize()
	self:SetHoldType("grenade")
	self.Thrown=false
	self.PrintName=translate.weaponGrenade
	self.Instructions	= translate.weaponGrenadeDescDM
end
function SWEP:SetupDataTables()
	--
end
function SWEP:PrimaryAttack()
	if not(IsFirstTimePredicted())then return end
	if(self.Owner:KeyDown(IN_SPEED))then return end
	self:DoBFSAnimation("throw")
	self.Owner:GetViewModel():SetPlaybackRate(1.5)
	self:EmitSound("snd_jack_hmcd_throw.wav")
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Owner:ViewPunch(Angle(-10,-5,0))
	timer.Simple(.2,function()
		if(IsValid(self))then
			self.Owner:ViewPunch(Angle(20,10,0))
		end
	end)
	timer.Simple(.25,function()
		if(IsValid(self))then
			self:ThrowGrenade()
		end
	end)
	self:SetNextPrimaryFire(CurTime()+1)
	self:SetNextSecondaryFire(CurTime()+1)
end
function SWEP:Deploy()
	if not(IsFirstTimePredicted())then return end
	--for i=0,10 do PrintTable(self.Owner:GetViewModel():GetAnimInfo(i)) end
	self.DownAmt=10
	self:DoBFSAnimation("deploy")
	self.Owner:GetViewModel():SetPlaybackRate(.6)
	timer.Simple(1,function()
		if(IsValid(self))then
			self:DoBFSAnimation("pullpin")
			self.Owner:GetViewModel():SetPlaybackRate(.75)
			timer.Simple(.8,function() if(IsValid(self))then self:EmitSound("snd_jack_hmcd_pinpull.wav") end end)
		end
	end)
	self:SetNextPrimaryFire(CurTime()+2.5)
	self:SetNextSecondaryFire(CurTime()+2.5)
	return true
end
function SWEP:ThrowGrenade()
	if(CLIENT)then return end
	self.Owner:SetLagCompensated(true)
	local Grenade=ents.Create("ent_jack_hmcd_oldgrenade_dm")
	Grenade.HmcdSpawned=self.HmcdSpawned
	Grenade:SetAngles(VectorRand():Angle())
	Grenade:SetPos(self.Owner:GetShootPos()+self.Owner:GetAimVector()*20)
	Grenade.Owner=self.Owner
	Grenade:Spawn()
	Grenade:Activate()
	Grenade:GetPhysicsObject():SetVelocity(self.Owner:GetVelocity()+self.Owner:GetAimVector()*1000)
	Grenade:Arm()
	self.Owner:SetLagCompensated(false)
	timer.Simple(.1,function() if(IsValid(self))then self:Remove() end end)
end
function SWEP:RigGrenade()
	if(CLIENT)then return end
	self.Owner:SetLagCompensated(true)
	local Tr=util.QuickTrace(self.Owner:GetShootPos(),self.Owner:GetAimVector()*65,{self.Owner})
	if(Tr.Hit)then
		local Grenade=ents.Create("ent_jack_hmcd_oldgrenade_dm")
		Grenade.HmcdSpawned=self.HmcdSpawned
		Grenade:SetAngles(Tr.HitNormal:Angle())
		Grenade:SetPos(Tr.HitPos+Tr.HitNormal*2)
		Grenade.Owner=self.Owner
		Grenade.Rigged=true
		Grenade:Spawn()
		Grenade:Activate()
		sound.Play("snd_jack_hmcd_click.wav",Tr.HitPos,60,100)
		Grenade.Constraint=constraint.Weld(Grenade,Tr.Entity,0,0,300,true,false)
		sound.Play("snd_jack_hmcd_detonator.wav",Tr.HitPos,60,100)
		local Ply=self.Owner
		timer.Simple(.3,function()
			net.Start("hmcd_hudhalo")
			net.WriteEntity(Grenade)
			net.WriteInt(4,32)
			net.Send(Ply)
		end)
		timer.Simple(.2,function() if(IsValid(self))then self:Remove() end end)
	end
	self.Owner:SetLagCompensated(false)
end
function SWEP:SecondaryAttack()
	if not(IsFirstTimePredicted())then return end
	if(self.Owner:KeyDown(IN_SPEED))then return end
	self:RigGrenade()
	self:SetNextPrimaryFire(CurTime()+1)
	self:SetNextSecondaryFire(CurTime()+1)
end
function SWEP:Think()
	if(SERVER)then
		local HoldType="grenade"
		if(self.Owner:KeyDown(IN_SPEED))then
			HoldType="normal"
		end
		self:SetHoldType(HoldType)
	end
end
function SWEP:Reload()
	--
end
function SWEP:DoBFSAnimation(anim)
	if((self.Owner)and(self.Owner.GetViewModel))then
		local vm=self.Owner:GetViewModel()
		vm:SendViewModelMatchingSequence(vm:LookupSequence(anim))
	end
end
function SWEP:FireAnimationEvent(pos,ang,event,name)
	return true -- I do all this, bitch
end
if(CLIENT)then
	local DownAmt=0
	function SWEP:GetViewModelPosition(pos,ang)
		--
	end
	function SWEP:DrawWorldModel()
		if(GAMEMODE:ShouldDrawWeaponWorldModel(self))then
			self:DrawModel()
		end
	end
end