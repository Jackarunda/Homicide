if SERVER then
	AddCSLuaFile()

	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
	
else
	SWEP.PrintName			= translate and translate.hands or "Hands"
	SWEP.Slot				= 0
	SWEP.SlotPos			= 1
	SWEP.DrawAmmo			= false
	SWEP.DrawCrosshair		= true

	SWEP.ViewModelFOV		= 45
	SWEP.WepSelectIcon=surface.GetTextureID("vgui/wep_jack_hmcd_zombhands")
	SWEP.BounceWeaponIcon=false
end

SWEP.SwayScale=3
SWEP.BobScale=3

SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= "These are your zombified hands. They're no energy sword, but they still pack a wallop.\n\nLMB clobber.\nRMB to direct fellow zombies.\nRELOAD to recall fellow zombies."

SWEP.Spawnable			= false
SWEP.AdminOnly		= true

SWEP.HoldType="normal"

SWEP.ViewModel	= Model("models/Weapons/v_zombiearms.mdl")
SWEP.WorldModel	= "models/weapons/w_crowbar.mdl"

SWEP.AttackSlowDown=.1

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.ReachDistance=65
SWEP.HomicideSWEP=true

function SWEP:SetupDataTables()
	self:NetworkVar("Float",0,"NextIdle")
end

function SWEP:PreDrawViewModel(vm,wep,ply)
	--vm:SetMaterial("engine/occlusionproxy") -- Hide that view model with hacky material
end

function SWEP:Initialize()
	self:SetNextIdle(CurTime()+5)
	self:SetHoldType(self.HoldType)
	--[[
	if(SERVER)then
		timer.Simple(1,function()
			if((IsValid(self))and(IsValid(self.Owner)))then
				self.Owner:SetHealth(200)
				self.Owner:SetMaxHealth(200)
			end
		end)
	end
	--]]
end

function SWEP:Deploy()
	self:SetNextPrimaryFire(CurTime()+.1)
	return true
end

function SWEP:Holster()
	self:OnRemove()
	return true
end

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:PlayHitSound()
	self.Owner:EmitSound("npc/zombie/claw_strike"..math.random(3)..".wav")
end

function SWEP:PlayHitObjectSound()
	sound.Play("Flesh.ImpactHard",self:GetPos(),65,math.random(90,110))
end

function SWEP:PlayMissSound()
	self.Owner:EmitSound("npc/zombie/claw_miss"..math.random(2)..".wav")
end

function SWEP:PlayAttackSound()
	self.Owner:EmitSound("npc/zombie/zo_attack"..math.random(2)..".wav")
end

function SWEP:PlayIdleSound()
	self.Owner:EmitSound("npc/zombie/zombie_voice_idle"..math.random(14)..".wav")
end

function SWEP:PlayAlertSound()
	self.Owner:EmitSound("npc/zombie/zombie_alert"..math.random(3)..".wav")
end

function SWEP:SecondaryAttack()
	self:SetNextPrimaryFire(CurTime()+1)
	self:SetNextSecondaryFire(CurTime()+2)
	if(SERVER)then
		local Zombs=GAMEMODE:GetZombies()
		local Tr=self.Owner:GetEyeTrace()
		if(Tr.Hit)then
			self:PlayAlertSound()
			self.Owner:DoAnimationEvent(ACT_GMOD_GESTURE_POINT)
			self:DirectZombies(Tr.HitPos+Tr.HitNormal*10,Zombs)
		end
	end
end

function SWEP:OnRemove()
	if(IsValid(self.Owner) && CLIENT && self.Owner:IsPlayer())then
		local vm=self.Owner:GetViewModel()
		if(IsValid(vm)) then vm:SetMaterial("") end
	end
end

function SWEP:Think()
	local HoldType="fist"
	local Time=CurTime()
	if(self:GetNextIdle()<Time)then
		self:SendWeaponAnim(ACT_VM_IDLE)
		self:UpdateNextIdle()
	end
	if(SERVER)then self:SetHoldType(HoldType) end
end

function SWEP:PrimaryAttack()
	local side=ACT_VM_HITCENTER
	if(math.random(1,2)==1)then side=ACT_VM_SECONDARYATTACK end
	if not(IsFirstTimePredicted())then
		self:SendWeaponAnim(side)
		return
	end
	local DamMul=1
	if(self.Owner:KeyDown(IN_SPEED))then DamMul=.25 end
	self.Owner:ViewPunch(Angle(0,0,math.random(-2,2)))
	self:SendWeaponAnim(side)
	self:UpdateNextIdle()
	self.Owner:DoAttackEvent()
	if(SERVER)then self:PlayAttackSound() end
	if(SERVER)then
		timer.Simple(.65,function()
			if(IsValid(self))then
				self:AttackFront()
			end
		end)
	end
	self:SetNextPrimaryFire(CurTime()+1.5)
	self:SetNextSecondaryFire(CurTime()+1)
end

function SWEP:AttackFront()
	if(CLIENT)then return end
	self.Owner:LagCompensation(true)
	local Ent,HitPos,HitNorm=HMCD_WhomILookinAt(self.Owner,.4,60)
	local AimVec=self.Owner:GetAimVector()
	--self.Owner:SetAnimation(PLAYER_ATTACK1)
	if((IsValid(Ent))or((Ent)and(Ent.IsWorld)and(Ent:IsWorld())))then
		local SelfForce,Mul,Soft=10,1,false
		if(self:IsEntSoft(Ent))then
			Soft=true
			SelfForce=5
			self:PlayHitSound()
			util.Decal("Blood",HitPos+HitNorm,HitPos-HitNorm)
			local edata=EffectData()
			edata:SetStart(self.Owner:GetShootPos())
			edata:SetOrigin(HitPos)
			edata:SetNormal(HitNorm)
			edata:SetEntity(Ent)
			util.Effect("BloodImpact",edata,true,true)
		else
			self:PlayHitObjectSound()
			Mul=.25
		end
		local DamageAmt=math.random(20,40)
		if((Ent)and(Ent.HMCD_Zomb))then DamageAmt=DamageAmt/2 end
		local Dam=DamageInfo()
		Dam:SetAttacker(self.Owner)
		Dam:SetInflictor(self.Weapon)
		Dam:SetDamage(DamageAmt*Mul)
		Dam:SetDamageForce(AimVec*Mul^3)
		Dam:SetDamagePosition(self.Owner:GetShootPos())
		if(math.random(1,2)==2)then Dam:SetDamageType(DMG_CLUB) else Dam:SetDamageType(DMG_SLASH) end
		Dam:SetDamagePosition(HitPos)
		Ent:TakeDamageInfo(Dam)
		local Phys=Ent:GetPhysicsObject()
		if(IsValid(Phys))then
			Ent:SetPhysicsAttacker(self.Owner)
			if(Ent:IsPlayer())then Ent:SetVelocity(AimVec*SelfForce*1.5) end
			if(Soft)then
				Phys:ApplyForceOffset(AimVec*5000*Mul,HitPos)
			else
				Phys:ApplyForceOffset(AimVec*50000,HitPos)
			end
			self.Owner:SetVelocity(-AimVec*SelfForce*.8)
		end
		if(Ent:GetClass()=="func_breakable_surf")then
			if(math.random(1,10)==10)then Ent:Fire("break","",0) end
		elseif((HMCD_IsDoor(Ent))and(math.random(1,10)==5))then
			HMCD_BlastThatDoor(Ent)
		end
		if(Ent.HMCD_Zomb)then
			Ent:SetGroundEntity(nil)
			Ent:SetVelocity(self.Owner:GetAimVector()*1000+Vector(0,0,200))
		end
	else
		self:PlayMissSound()
	end
	self.Owner:LagCompensation(false)
end

local NextReload=0
function SWEP:Reload()
	self:SetNextPrimaryFire(CurTime()+2)
	self:SetNextSecondaryFire(CurTime()+2)
	if(NextReload>CurTime())then return end
	NextReload=CurTime()+2
	if(SERVER)then
		local Zombs=GAMEMODE:GetZombies()
		self:PlayIdleSound()
		self.Owner:DoAnimationEvent(ACT_SIGNAL_HALT)
		for k,v in pairs(Zombs)do
			v:SetSchedule(SCHED_ALERT_SCAN)
		end
	end
end

function SWEP:DrawWorldModel()
	-- no, do nothing
end

function SWEP:DirectZombies(pos,zombs)
	local SelfPos=self.Owner:GetShootPos()
	for key,npc in pairs(zombs)do
		local NPCPos=npc:GetPos()
		local Vec=(pos-NPCPos):GetNormalized()
		if(math.random(1,3)==2)then
			npc:SetLastPosition(NPCPos+Vec*400)
		else
			npc:SetLastPosition(pos)
		end
		npc:SetSchedule(SCHED_FORCED_GO_RUN)
	end
end

function SWEP:UpdateNextIdle()
	local vm=self.Owner:GetViewModel()
	self:SetNextIdle(CurTime()+vm:SequenceDuration())
end

function SWEP:IsEntSoft(ent)
	return ((ent:IsNPC())or(ent:IsPlayer())or(ent:GetClass()=="prop_ragdoll"))
end

if(CLIENT)then
	local BlockAmt=0
	function SWEP:GetViewModelPosition(pos,ang)
		BlockAmt=math.Clamp(BlockAmt-FrameTime()*1.5,0,1)
		pos=pos-ang:Up()*15*BlockAmt
		ang:RotateAroundAxis(ang:Right(),BlockAmt*60)
		return pos,ang
	end
end