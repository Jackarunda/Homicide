if(SERVER)then
	AddCSLuaFile()
elseif(CLIENT)then
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false

	SWEP.ViewModelFOV = 55

	SWEP.Slot = 1
	SWEP.SlotPos = 2

	killicon.AddFont("wep_jack_hmcd_pocketknife", "HL2MPTypeDeath", "5", Color(0, 0, 255, 255))

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

SWEP.ViewModel = "models/weapons/v_jnife_j.mdl"
SWEP.WorldModel = "models/weapons/w_jnife_jj.mdl"
if(CLIENT)then SWEP.WepSelectIcon=surface.GetTextureID("vgui/wep_jack_hmcd_pocketknife");SWEP.BounceWeaponIcon=false end
SWEP.PrintName = translate.weaponPocketKnife
SWEP.Instructions	= translate.weaponPocketKnifeDesc
SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.BobScale=3
SWEP.SwayScale=3
SWEP.Weight	= 3
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= false

SWEP.AttackSlowDown=.75
SWEP.CommandDroppable=true
--SWEP.SHTF_NoDrop=true

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
SWEP.Secondary.Ammo         = "none"
SWEP.HomicideSWEP=true
SWEP.ENT="ent_jack_hmcd_pocketknife"
SWEP.Poisonable=true
SWEP.CarryWeight=500
function SWEP:Initialize()
	self:SetNextIdle(CurTime()+1)
	self:SetHoldType("normal")
	self.NextDownTime=CurTime()
	self.PrintName = translate.weaponPocketKnife
	self.Instructions	= translate.weaponPocketKnifeDesc
end

function SWEP:SetupDataTables()
	self:NetworkVar("Float",0,"NextIdle")
end

function SWEP:PrimaryAttack()
	if not(IsFirstTimePredicted())then
		self:DoBFSAnimation("slash1")
		self.Owner:GetViewModel():SetPlaybackRate(2)
		return
	end
	if(self.Owner.Stamina<5)then return end
	if(self.Owner:KeyDown(IN_SPEED))then return end
	self:DoBFSAnimation("slash1")
	self:UpdateNextIdle()
	self:SetHoldType("melee")
	self.Owner:GetViewModel():SetPlaybackRate(2)
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	local FirstStrike=false
	if(self.NextDownTime<CurTime())then FirstStrike=true end
	self.NextDownTime=CurTime()+1
	self:SetNextPrimaryFire(CurTime()+.5)
	self.Owner:ViewPunch(Angle(0,-3,0))
	if(SERVER)then sound.Play("weapons/slam/throw.wav",self.Owner:GetPos(),60,math.random(90,110)) end
	timer.Simple(.05,function()
		if(IsValid(self))then
			if(FirstStrike)then self.Owner:SetAnimation(PLAYER_ATTACK1) end
			self:AttackFront()
		end
	end)
end

function SWEP:Deploy()
	if not(IsFirstTimePredicted())then
		self:DoBFSAnimation("draw")
		self.Owner:GetViewModel():SetPlaybackRate(.1)
		return
	end
	self:DoBFSAnimation("draw")
	self:UpdateNextIdle()
	if(SERVER)then sound.Play("snd_jack_hmcd_crkt.wav",self.Owner:GetPos(),60,math.random(90,110)) end
	return true
end

function SWEP:SecondaryAttack()
	--
end

function SWEP:Think()
	local Time=CurTime()
	if(self:GetNextIdle()<Time)then
		self:DoBFSAnimation("idle")
		self:UpdateNextIdle()
	end
	if self.FistCanAttack && self.FistCanAttack < CurTime() then
		self.FistCanAttack = nil
		--self:SendWeaponAnim( ACT_VM_IDLE )
		self.IdleTime = CurTime() + 0.1
	end	
	if self.FistHit && self.FistHit < CurTime() then
		self.FistHit = nil
		--self:AttackTrace()
	end
	if(SERVER)then
		local HoldType="normal"
		if(self.Owner:KeyDown(IN_SPEED))then
			HoldType="normal"
		else
			if(self.NextDownTime>CurTime())then
				HoldType="melee"
			end
		end
		self:SetHoldType(HoldType)
	end
end

function SWEP:AttackFront()
	if(CLIENT)then return end
	self.Owner:ViewPunch(Angle(0,3,0))
	self.Owner:LagCompensation(true)
	HMCD_StaminaPenalize(self.Owner,6)
	local Ent,HitPos,HitNorm=HMCD_WhomILookinAt(self.Owner,.3,60)
	local AimVec,Mul=self.Owner:GetAimVector(),1
	if((IsValid(Ent))or((Ent)and(Ent.IsWorld)and(Ent:IsWorld())))then
		local SelfForce=125
		if(self:IsEntSoft(Ent))then
			if((self.Poisoned)and(Ent:IsPlayer()))then
				HMCD_Poison(Ent,self.Owner)
				self.Poisoned=false
			end
			SelfForce=25
			sound.Play("snd_jack_hmcd_slash.wav",HitPos,60,math.random(90,110))
			util.Decal("Impact.Flesh",HitPos+HitNorm,HitPos-HitNorm)
		else
			sound.Play("snd_jack_hmcd_knifehit.wav",HitPos,65,math.random(100,120))
		end
		local DamageAmt=math.random(5,9)
		local Dam=DamageInfo()
		Dam:SetAttacker(self.Owner)
		Dam:SetInflictor(self.Weapon)
		Dam:SetDamage(DamageAmt*Mul)
		Dam:SetDamageForce(AimVec*Mul/5)
		Dam:SetDamageType(DMG_SLASH)
		Dam:SetDamagePosition(HitPos)
		Ent:TakeDamageInfo(Dam)
		local Phys=Ent:GetPhysicsObject()
		if(IsValid(Phys))then
			if(Ent:IsPlayer())then Ent:SetVelocity(AimVec*SelfForce/5) end
			Phys:ApplyForceOffset(AimVec*2500*Mul,HitPos)
			self.Owner:SetVelocity(-AimVec*SelfForce/10)
		end
	end
	self.Owner:LagCompensation(false)
end

function SWEP:Reload()
	--
end

function SWEP:DoBFSAnimation(anim)
	local vm=self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence(vm:LookupSequence(anim))
end

function SWEP:UpdateNextIdle()
	local vm=self.Owner:GetViewModel()
	self:SetNextIdle(CurTime()+vm:SequenceDuration())
end

function SWEP:IsEntSoft(ent)
	return ((ent:IsNPC())or(ent:IsPlayer())or(ent:GetClass()=="prop_ragdoll"))
end

function SWEP:OnDrop()
	local Ent=ents.Create(self.ENT)
	Ent.HmcdSpawned=self.HmcdSpawned
	Ent:SetPos(self:GetPos())
	Ent:SetAngles(self:GetAngles())
	Ent.Poisoned=self.Poisoned
	Ent:Spawn()
	Ent:Activate()
	Ent:GetPhysicsObject():SetVelocity(self:GetVelocity()/2)
	self:Remove()
end

if(CLIENT)then
	local DownAmt=0
	function SWEP:GetViewModelPosition(pos,ang)
		if(self.Owner:KeyDown(IN_SPEED))then
			DownAmt=math.Clamp(DownAmt+.6,0,50)
		else
			DownAmt=math.Clamp(DownAmt-.6,0,50)
		end
		ang:RotateAroundAxis(ang:Up(),-30)
		return pos+ang:Up()*3-ang:Forward()*(DownAmt-10)-ang:Up()*DownAmt-ang:Right()*25,ang
	end
	function SWEP:DrawWorldModel()
		if(GAMEMODE:ShouldDrawWeaponWorldModel(self))then
			self:DrawModel()
		end
	end
end