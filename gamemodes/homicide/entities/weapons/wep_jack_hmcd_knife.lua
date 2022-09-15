if(SERVER)then
	AddCSLuaFile()
elseif(CLIENT)then
	SWEP.DrawAmmo=false
	SWEP.DrawCrosshair=false

	SWEP.ViewModelFOV=65

	SWEP.Slot=1
	SWEP.SlotPos=1

	killicon.AddFont("wep_jack_hmcd_knife", "HL2MPTypeDeath", "5", Color(0, 0, 255, 255))

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

SWEP.ViewModel="models/weapons/v_jnife_t.mdl"
SWEP.WorldModel="models/weapons/w_knife_t.mdl"
if(CLIENT)then SWEP.WepSelectIcon=surface.GetTextureID("vgui/wep_jack_hmcd_knife");SWEP.BounceWeaponIcon=false end
SWEP.PrintName=translate.weaponKnife
SWEP.Instructions	= translate.weaponKnifeDesc
SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.BobScale=3
SWEP.SwayScale=3
SWEP.Weight	= 3
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= false

SWEP.AttackSlowDown=.1

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
SWEP.HomicideSWEP=true
SWEP.Poisonable=true
SWEP.CarryWeight=500
function SWEP:Initialize()
	self:SetNextIdle(CurTime()+1)
	self:SetHoldType("knife")
	self.PrintName=translate.weaponKnife
	self.Instructions	= translate.weaponKnifeDesc
end

function SWEP:SetupDataTables()
	self:NetworkVar("Float",0,"NextIdle")
end

function SWEP:PrimaryAttack()
	if not(IsFirstTimePredicted())then
		self:DoBFSAnimation("stab_miss")
		self.Owner:GetViewModel():SetPlaybackRate(1.5)
		return
	end
	if(self.Owner.Stamina<5)then return end
	if(self.Owner:KeyDown(IN_SPEED))then return end
	self:DoBFSAnimation("stab_miss")
	self:UpdateNextIdle()
	self.Owner:GetViewModel():SetPlaybackRate(1.5)
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self:SetNextPrimaryFire(CurTime()+.65)
	if(SERVER)then timer.Simple(.05,function() if(IsValid(self))then sound.Play("weapons/slam/throw.wav",self:GetPos(),55,math.random(90,110)) end end) end
	timer.Simple(.15,function()
		if(IsValid(self))then
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
	if(SERVER)then sound.Play("snd_jack_hmcd_knifedraw.wav",self.Owner:GetPos(),55,math.random(90,110)) end
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
		self.FistCanAttack=nil
		--self:SendWeaponAnim( ACT_VM_IDLE )
		self.IdleTime=CurTime()+0.1
	end	
	if self.FistHit && self.FistHit < CurTime() then
		self.FistHit=nil
		--self:AttackTrace()
	end
	if(SERVER)then
		local HoldType="normal"
		if(self.Owner:KeyDown(IN_SPEED))then
			HoldType="normal"
		else
			HoldType="knife"
		end
		self:SetHoldType(HoldType)
	end
end

function SWEP:AttackFront()
	self.Owner:ViewPunch(Angle(2,0,0))
	if(CLIENT)then return end
	self.Owner:LagCompensation(true)
	HMCD_StaminaPenalize(self.Owner,6)
	local Ent,HitPos,HitNorm=HMCD_WhomILookinAt(self.Owner,.35,80)
	local AimVec,Mul=self.Owner:GetAimVector(),1
	if((IsValid(Ent))or((Ent)and(Ent.IsWorld)and(Ent:IsWorld())))then
		local SelfForce=125
		if(self:IsEntSoft(Ent))then
			if((self.Poisoned)and(Ent:IsPlayer()))then
				HMCD_Poison(Ent,self.Owner)
				self.Poisoned=false
			end
			SelfForce=25
			sound.Play("snd_jack_hmcd_knifestab.wav",HitPos,50,math.random(90,110))
			util.Decal("Blood",HitPos+HitNorm,HitPos-HitNorm)
			local edata=EffectData()
			edata:SetStart(self.Owner:GetShootPos())
			edata:SetOrigin(HitPos)
			edata:SetNormal(HitNorm)
			edata:SetEntity(Ent)
			util.Effect("BloodImpact",edata,true,true)
			if(self:CanBackStab(Ent))then Mul=2 end
			timer.Simple(.05,function()
				if(IsValid(self))then
					for i=1,2 do
						local BloodTr=util.QuickTrace(HitPos-AimVec*10,AimVec*100+VectorRand()*25,{self,self.Owner})
						if(BloodTr.Hit)then util.Decal("Blood",BloodTr.HitPos+BloodTr.HitNormal,BloodTr.HitPos-BloodTr.HitNormal) end
					end
				end
			end)
			--if(Ent:GetClass()=="prop_ragdoll")then
			--	if not(Ent.Hiddenness)then Ent.Hiddenness=0 end
			--	Ent.Hiddenness=Ent.Hiddenness+1
			--	if(Ent.Hiddenness>=4)then HMCD_HideBody(Ent) end
			--end
		else
			sound.Play("snd_jack_hmcd_knifehit.wav",HitPos,60,math.random(90,110))
		end
		local DamageAmt=math.random(15,25)
		local Dam=DamageInfo()
		Dam:SetAttacker(self.Owner)
		Dam:SetInflictor(self.Weapon)
		Dam:SetDamage(DamageAmt*Mul)
		Dam:SetDamageForce(AimVec*Mul/100)
		Dam:SetDamageType(DMG_SLASH)
		Dam:SetDamagePosition(HitPos)
		Ent:TakeDamageInfo(Dam)
		local Phys=Ent:GetPhysicsObject()
		if(IsValid(Phys))then
			if(Ent:IsPlayer())then Ent:SetVelocity(-Ent:GetVelocity()/2) end
			Phys:ApplyForceOffset(AimVec*25*Mul,HitPos)
			self.Owner:SetVelocity(-AimVec*SelfForce/100)
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

function SWEP:CanBackStab(ent)
	if not(ent:IsPlayer())then return false end
	local TrueVec=(self.Owner:GetPos()-ent:GetPos()):GetNormalized()
	local LookVec=ent:GetAimVector()
	local DotProduct=LookVec:DotProduct(TrueVec)
	local ApproachAngle=(-math.deg(math.asin(DotProduct))+90)
	local RelSpeed=(ent:GetPhysicsObject():GetVelocity()-self.Owner:GetVelocity()):Length()
	if((ApproachAngle<=120)or(RelSpeed>100))then
		return false
	else
		return true
	end
end

if(CLIENT)then
	local DownAmt=0
	function SWEP:GetViewModelPosition(pos,ang)
		if(self.Owner:KeyDown(IN_SPEED))then
			DownAmt=math.Clamp(DownAmt+.1,0,8)
		else
			DownAmt=math.Clamp(DownAmt-.1,0,8)
		end
		ang:RotateAroundAxis(ang:Right(),40)
		return pos-ang:Up()*7-ang:Forward()*(3+DownAmt)-ang:Up()*DownAmt,ang
	end
	function SWEP:DrawWorldModel()
		if(GAMEMODE:ShouldDrawWeaponWorldModel(self))then
			self:DrawModel()
		end
	end
end