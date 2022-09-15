if(SERVER)then
	AddCSLuaFile()
elseif(CLIENT)then
	SWEP.DrawAmmo=false
	SWEP.DrawCrosshair=false
	SWEP.ViewModelFOV=75
	SWEP.Slot=2
	SWEP.SlotPos=2
	killicon.AddFont("wep_jack_hmcd_bow", "HL2MPTypeDeath", "5", Color(0, 0, 255, 255))
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
SWEP.ViewModel="models/weapons/v_snij_awp.mdl"
SWEP.WorldModel="models/weapons/w_snij_awp.mdl"
if(CLIENT)then SWEP.WepSelectIcon=surface.GetTextureID("vgui/wep_jack_hmcd_bow");SWEP.BounceWeaponIcon=false end
SWEP.PrintName=translate.weaponBow
SWEP.Instructions	= translate.weaponBowDesc
SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.BobScale=2
SWEP.SwayScale=2
SWEP.Weight	= 3
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= false
SWEP.ViewModelFlip=false
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
SWEP.Primary.Ammo         	= "XBowBolt"
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
SWEP.NextCheck=0
SWEP.ENT="ent_jack_hmcd_bow"
SWEP.CommandDroppable=true
SWEP.DeathDroppable=true
SWEP.HolsterSlot=1
SWEP.HolsterPos=Vector(3,-10,-5)
SWEP.HolsterAng=Angle(90,5,180)
SWEP.CanAmmoShow=true
SWEP.AmmoType="XBowBolt"
SWEP.AmmoName="Broadhead Arrow"
SWEP.AmmoPoisonable=true
SWEP.CarryWeight=3500
function SWEP:Initialize()
	self:SetHoldType("ar2")
	self:SetAiming(0)
	self.PrintName=translate.weaponBow
	self.Instructions	= translate.weaponBowDesc
end
function SWEP:SetupDataTables()
	self:NetworkVar("Int",0,"Aiming")
	self:NetworkVar("Bool",0,"Reloading")
end
function SWEP:PrimaryAttack()
	--for i=0,10 do PrintTable(self.Owner:GetViewModel():GetAnimInfo(i)) end
	if not(IsFirstTimePredicted())then return end
	if(self.Owner:KeyDown(IN_SPEED))then return end
	if(self:GetReloading())then return end
	if(self.Owner:GetAmmoCount(self.Primary.Ammo)<1)then
		if(SERVER)then
			umsg.Start("HMCD_AmmoShow",self.Owner)
			umsg.End()
		end
		return
	end
	if(self:GetAiming()<100)then return end
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:DoBFSAnimation("awm_fire")
	self.Owner:GetViewModel():SetPlaybackRate(.45)
	local Pitch=math.random(90,110)
	self:EmitSound("snd_jack_hmcd_bowshoot.wav",50,Pitch)
	if(SERVER)then
		sound.Play("snd_jack_hmcd_bowshoot.wav",self.Owner:GetShootPos(),60,Pitch)
		sound.Play("snd_jack_hmcd_arrowwhiz.wav",self.Owner:GetShootPos()+self.Owner:GetAimVector()*50,60,Pitch)
	end
	self:FireArrow()
	self:TakePrimaryAmmo(1)
	self:SetReloading(true)
	util.ScreenShake(self.Owner:GetShootPos(),7,255,.1,20)
	timer.Simple(.01,function()
		if(self.Owner:GetAmmoCount(self.Primary.Ammo)>0)then self:EmitSound("snd_jack_hmcd_bowload.wav",55,100) end
	end)
	timer.Simple(2.5,function()
		if(IsValid(self))then
			self:SetReloading(false)
			self:DoBFSAnimation("awm_idle")
			if(SERVER)then
				umsg.Start("HMCD_AmmoShow",self.Owner)
				umsg.End()
			end
		end
	end)
	self.Owner:ViewPunch(Angle(0,-1,0))
	self:SetNextPrimaryFire(CurTime()+2.75)
end
function SWEP:FireArrow()
	if(CLIENT)then return end
	self.Owner:SetLagCompensated(true)
	local Arrow=ents.Create("ent_jack_hmcd_arrow")
	Arrow.HmcdSpawned=self.HmcdSpawned
	Arrow:SetPos(self.Owner:GetShootPos()+self.Owner:GetAimVector()*60)
	Arrow.Owner=self.Owner
	local Ang=self.Owner:GetAimVector():Angle()
	Ang:RotateAroundAxis(Ang:Right(),-90)
	Arrow:SetAngles(Ang)
	Arrow.Fired=true
	Arrow.InitialDir=self.Owner:GetAimVector()
	Arrow.InitialVel=self.Owner:GetVelocity()
	Arrow.Poisoned=self.Owner.HMCD_AmmoPoisoned
	self.Owner.HMCD_AmmoPoisoned=false
	Arrow:Spawn()
	Arrow:Activate()
	self.Owner:SetLagCompensated(false)
end
function SWEP:Deploy()
	if not(IsFirstTimePredicted())then return end
	if not((self)and(self.Owner)and(self.Owner.GetViewModel))then return end
	self.DownAmt=10
	self:DoBFSAnimation("awm_draw")
	if(self.Owner:GetAmmoCount(self.Primary.Ammo)>0)then self:EmitSound("snd_jack_hmcd_bowload.wav",55,150) end
	self.Owner:GetViewModel():SetPlaybackRate(.5)
	self:SetNextPrimaryFire(CurTime()+2)
	self:EnforceHolsterRules(self)
	return true
end
function SWEP:EnforceHolsterRules(newWep)
	if(CLIENT)then return end
	if not(newWep==self)then return end -- only enforce rules for us
	for key,wep in pairs(self.Owner:GetWeapons())do
		if((wep.HolsterSlot)and(self.HolsterSlot)and(wep.HolsterSlot==self.HolsterSlot)and not(wep==self))then -- conflict
			self.Owner:DropWeapon(wep)
		end
	end
end
function SWEP:SecondaryAttack()
	--
end
function SWEP:Think()
	if(SERVER)then
		local HoldType="ar2"
		if(self.Owner:KeyDown(IN_SPEED))then
			HoldType="passive"
		end
		self:SetHoldType(HoldType)
	end
	if(self.NextCheck<CurTime())then
		self.NextCheck=CurTime()+.1
		if((self.Owner:KeyDown(IN_ATTACK2))and not(self:GetReloading())and(self.Owner:GetAmmoCount(self.Primary.Ammo)>0)and not(self.Owner:KeyDown(IN_SPEED))and(self.Owner:OnGround()))then
			self:SetAiming(math.Clamp(self:GetAiming()+10,0,100))
		else
			self:SetAiming(math.Clamp(self:GetAiming()-10,0,100))
		end
	end
	if((self.Owner:GetAmmoCount(self.Primary.Ammo)<1)or(self.Owner:KeyDown(IN_SPEED)))then self:DoBFSAnimation("awm_draw") end
end
function SWEP:Reload()
	if(SERVER)then
		umsg.Start("HMCD_AmmoShow",self.Owner)
		umsg.End()
	end
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
function SWEP:Holster(newWep)
	self:EnforceHolsterRules(newWep)
	return true
end
function SWEP:OnDrop()
	local Ent=ents.Create(self.ENT)
	Ent.HmcdSpawned=self.HmcdSpawned
	Ent:SetPos(self:GetPos())
	Ent:SetAngles(self:GetAngles())
	Ent:Spawn()
	Ent:Activate()
	Ent:GetPhysicsObject():SetVelocity(self:GetVelocity()/2)
	self:Remove()
end
if(CLIENT)then
	local Aim,Forward,Passive,Sprinting=0,0,0,0
	function SWEP:PreDrawViewModel(vm,wep,ply)
		if(self.Owner:GetAmmoCount(self.Primary.Ammo)<1)then
			vm:SendViewModelMatchingSequence(vm:LookupSequence("awm_draw"))
		end
	end
	function SWEP:GetViewModelPosition(pos,ang)
		local Ft=FrameTime()
		Aim=Lerp(4*Ft,Aim,self:GetAiming())
		if(Aim==100)then self.Crosshair=true else self.Crosshair=false end
		if(self:GetReloading())then Forward=math.Clamp(Forward+1*Ft,-1,0) else Forward=math.Clamp(Forward-1*Ft,-1,0) end
		pos=pos-ang:Forward()*(Aim/19+2*Forward)-ang:Up()*Aim/34-ang:Right()*Aim/48
		if(self.Owner:KeyDown(IN_SPEED))then Sprinting=Lerp(4*Ft,Sprinting,1) else Sprinting=Lerp(2*Ft,Sprinting,0) end
		if(self.Owner:GetAmmoCount(self.Primary.Ammo)<1)then Passive=Lerp(Ft,Passive,1) else Passive=Lerp(Ft,Passive,0) end
		pos=pos-ang:Up()*20*Sprinting-ang:Forward()*5*Sprinting
		pos=pos-ang:Right()*17*Passive-ang:Up()*5*Passive
		ang:RotateAroundAxis(ang:Forward(),-60*Passive)
		ang:RotateAroundAxis(ang:Right(),20*Passive)
		ang:RotateAroundAxis(ang:Forward(),-Aim*.69)
		return pos,ang
	end
	local SightTex=Material("sprites/mat_jack_hmcd_bowsight")
	function SWEP:DrawHUD()
		if((self:GetAiming()==100)and not((self.Owner:KeyDown(IN_MOVERIGHT))or(self.Owner:KeyDown(IN_BACK))or(self.Owner:KeyDown(IN_FORWARD))or(self.Owner:KeyDown(IN_MOVELEFT))))then
			local Col=render.GetLightColor(self.Owner:GetShootPos()+self.Owner:GetAimVector()*20)
			surface.SetDrawColor(math.Clamp(510*Col.x,0,255),math.Clamp(510*Col.y,0,255),math.Clamp(510*Col.z,0,255))
			surface.SetMaterial(SightTex)
			surface.DrawTexturedRect(ScrW()/2-43,ScrH()/2-65,128,128)
		end
	end
	function SWEP:ViewModelDrawn(vm)
		--
	end
	function SWEP:DrawWorldModel()
		local Pos,Ang=self.Owner:GetBonePosition(self.Owner:LookupBone("ValveBiped.Bip01_R_Hand"))
		if(self.DatWorldModel)then
			if((Pos)and(Ang)and(GAMEMODE:ShouldDrawWeaponWorldModel(self)))then
				self.DatWorldModel:SetRenderOrigin(Pos+Ang:Forward()*3)
				Ang:RotateAroundAxis(Ang:Up(),0)
				Ang:RotateAroundAxis(Ang:Right(),0)
				Ang:RotateAroundAxis(Ang:Forward(),180)
				self.DatWorldModel:SetRenderAngles(Ang)
				self.DatWorldModel:DrawModel()
			end
		else
			self.DatWorldModel=ClientsideModel("models/weapons/w_snij_awp.mdl")
			self.DatWorldModel:SetPos(self:GetPos())
			self.DatWorldModel:SetParent(self)
			self.DatWorldModel:SetNoDraw(true)
		end
	end
end