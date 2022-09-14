AddCSLuaFile()
SWEP.Author		= "Jackarunda"
SWEP.Base       = "weapon_base"
SWEP.Purpose	= "The answer? Use a gun. An' if that don't work, use more gun."
SWEP.Spawnable	= false
SWEP.Primary.ClipSize		= 10
SWEP.Primary.DefaultClip	= 10
SWEP.Primary.Ammo			= "none"
SWEP.Secondary.ClipSize		= 10
SWEP.Secondary.DefaultClip	= 10
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"
SWEP.ShowViewModel=true
SWEP.ShowWorldModel=false
SWEP.WorldModel	= "models/weapons/w_rif_m4a1.mdl"
SWEP.ViewModelFOV	= 75
SWEP.Primary.Automatic=false
SWEP.NextChaseTime=0
SWEP.MagSize=30
SWEP.MuzzleEffect="pcf_jack_mf_mrifle2"
SWEP.MaxRange=3000
SWEP.AltRate=30
SWEP.FireRate=.05
SWEP.CloseFireSound="snd_jack_hmcd_ar_close.wav"
SWEP.FarFireSound="snd_jack_hmcd_ar_far.wav"
SWEP.ReloadSound="snd_jack_hmcd_arreload.wav"
SWEP.HomicideNPCSWEP=true
-------------------
AccessorFunc(SWEP,"fNPCMinBurst","NPCMinBurst")
AccessorFunc(SWEP,"fNPCMaxBurst","NPCMaxBurst")
AccessorFunc(SWEP,"fNPCFireRate","NPCFireRate")
AccessorFunc(SWEP,"fNPCMinRestTime","NPCMinRest")
AccessorFunc(SWEP,"fNPCMaxRestTime","NPCMaxRest")
function SWEP:SetupWeaponHoldTypeForAI(t)
	self.ActivityTranslateAI = {}
	self.ActivityTranslateAI [ ACT_RANGE_ATTACK1 ] 				= ACT_RANGE_ATTACK_AR2
	self.ActivityTranslateAI [ ACT_RELOAD ] 					= ACT_RELOAD_SMG1
	self.ActivityTranslateAI [ ACT_IDLE ] 						= ACT_IDLE_RIFLE
	self.ActivityTranslateAI [ ACT_IDLE_ANGRY ] 				= ACT_IDLE_ANGRY_SMG1
	self.ActivityTranslateAI [ ACT_WALK ] 						= ACT_WALK_RIFLE
	self.ActivityTranslateAI [ ACT_IDLE_RELAXED ] 				= ACT_IDLE_SMG1_RELAXED
	self.ActivityTranslateAI [ ACT_IDLE_STIMULATED ] 			= ACT_IDLE_SMG1_STIMULATED
	self.ActivityTranslateAI [ ACT_IDLE_AGITATED ] 				= ACT_IDLE_ANGRY_SMG1
	self.ActivityTranslateAI [ ACT_WALK_RELAXED ] 				= ACT_WALK_RIFLE_RELAXED
	self.ActivityTranslateAI [ ACT_WALK_STIMULATED ] 			= ACT_WALK_RIFLE_STIMULATED
	self.ActivityTranslateAI [ ACT_WALK_AGITATED ] 				= ACT_WALK_AIM_RIFLE
	self.ActivityTranslateAI [ ACT_RUN_RELAXED ] 				= ACT_RUN_RIFLE_RELAXED
	self.ActivityTranslateAI [ ACT_RUN_STIMULATED ] 			= ACT_RUN_RIFLE_STIMULATED
	self.ActivityTranslateAI [ ACT_RUN_AGITATED ] 				= ACT_RUN_AIM_RIFLE
	self.ActivityTranslateAI [ ACT_IDLE_AIM_RELAXED ] 			= ACT_IDLE_SMG1_RELAXED
	self.ActivityTranslateAI [ ACT_IDLE_AIM_STIMULATED ] 		= ACT_IDLE_AIM_RIFLE_STIMULATED
	self.ActivityTranslateAI [ ACT_IDLE_AIM_AGITATED ] 			= ACT_IDLE_ANGRY_SMG1
	self.ActivityTranslateAI [ ACT_WALK_AIM_RELAXED ] 			= ACT_WALK_RIFLE_RELAXED
	self.ActivityTranslateAI [ ACT_WALK_AIM_STIMULATED ] 		= ACT_WALK_AIM_RIFLE_STIMULATED
	self.ActivityTranslateAI [ ACT_WALK_AIM_AGITATED ] 			= ACT_WALK_AIM_RIFLE
	self.ActivityTranslateAI [ ACT_RUN_AIM_RELAXED ] 			= ACT_RUN_RIFLE_RELAXED
	self.ActivityTranslateAI [ ACT_RUN_AIM_STIMULATED ] 		= ACT_RUN_AIM_RIFLE_STIMULATED
	self.ActivityTranslateAI [ ACT_RUN_AIM_AGITATED ] 			= ACT_RUN_AIM_RIFLE
	self.ActivityTranslateAI [ ACT_WALK_AIM ] 					= ACT_WALK_AIM_RIFLE
	self.ActivityTranslateAI [ ACT_WALK_CROUCH ] 				= ACT_WALK_CROUCH_RIFLE
	self.ActivityTranslateAI [ ACT_WALK_CROUCH_AIM ] 			= ACT_WALK_CROUCH_AIM_RIFLE
	self.ActivityTranslateAI [ ACT_RUN ] 						= ACT_RUN_RIFLE
	self.ActivityTranslateAI [ ACT_RUN_AIM ] 					= ACT_RUN_AIM_RIFLE
	self.ActivityTranslateAI [ ACT_RUN_CROUCH ] 				= ACT_RUN_CROUCH_RIFLE
	self.ActivityTranslateAI [ ACT_RUN_CROUCH_AIM ] 			= ACT_RUN_CROUCH_AIM_RIFLE
	self.ActivityTranslateAI [ ACT_GESTURE_RANGE_ATTACK1 ] 		= ACT_GESTURE_RANGE_ATTACK_AR2
	self.ActivityTranslateAI [ ACT_COVER_LOW ] 					= ACT_COVER_SMG1_LOW
	self.ActivityTranslateAI [ ACT_RANGE_AIM_LOW ] 				= ACT_RANGE_AIM_AR2_LOW
	self.ActivityTranslateAI [ ACT_RANGE_ATTACK1_LOW ] 			= ACT_RANGE_ATTACK_SMG1_LOW
	self.ActivityTranslateAI [ ACT_RELOAD_LOW ] 				= ACT_RELOAD_SMG1_LOW
	self.ActivityTranslateAI [ ACT_GESTURE_RELOAD ] 			= ACT_GESTURE_RELOAD_SMG1
	self.ActivityTranslateAI [ ACT_MELEE_ATTACK1 ] 				= ACT_MELEE_ATTACK1
end
function SWEP:SetupDataTables()
	-- no
end
function SWEP:Initialize()
	self.NextThinkTime=CurTime()+.01
	self:SetHoldType("ar2")
	self.CurrentAmmo=self.MagSize
	hook.Add("Think",self,function() self:Think() end)
	self.LastHealth=150
	self.WanderDirection=VectorRand()
	self.SocialityType=math.random(-1,1)
	self.NextFireTime=0
end
function SWEP:GetCapabilities()
	return bit.bor(CAP_WEAPON_RANGE_ATTACK1,CAP_INNATE_RANGE_ATTACK1,CAP_WEAPON_MELEE_ATTACK1,CAP_INNATE_MELEE_ATTACK1)
end
function SWEP:PrimaryAttack()
	if(math.random(1,self.AltRate)==2)then
		self:SecondaryAttack()
		return
	end
	if(self.CurrentAmmo>0)then
		if(self.NextFireTime<CurTime())then
			self.NextFireTime=CurTime()+self.FireRate
			self:Fiah()
		end
	else
		self:Reload()
	end
end
function SWEP:Deploy()
	return true
end
function SWEP:Think()
	if not(self)then return end
	if not(IsValid(self))then return end
	if not(IsValid(self.Owner))then return end
	if(CLIENT)then return end
	local Time=CurTime()
	if(self.NextThinkTime<=Time)then
		self.NextThinkTime=Time+math.Rand(.025,.2)
		local Health=self.Owner:Health()
		if(Health<self.LastHealth)then
			self.LastHealth=Health
			self:GotHurt()
		end
		local BG=self:BadGuy()
		local SelfPos=self.Owner:GetPos()
		local Act=self.Owner:GetActivity()
		if((BG)and(IsValid(BG))and(Act==ACT_IDLE)and(self.Owner:Visible(BG)))then
			local Dist=(BG:GetPos()-self.Owner:GetPos()):Length()
			if(Dist>self.MaxRange)then
				if(self.NextChaseTime<CurTime())then self:Chase(BG) end
			end
		elseif((BG)and(Act==ACT_IDLE))then
			if(math.random(1,50)==2)then
				self:RandomMove()
			end
		elseif(not(BG)and(Act==ACT_IDLE))then
			if(math.random(1,30)==2)then
				self:RandomMove()
			end
		end
	end
end
function SWEP:GotHurt()
	self:RandomMove()
end
function SWEP:RandomMove()
	local SelfPos=self.Owner:GetPos()
	local Vec=VectorRand()
	local NewPos=SelfPos+Vec*math.Rand(20,300)
	self.Owner:SetLastPosition(NewPos)
	if(math.random(1,2)==1)then
		self.Owner:SetSchedule(SCHED_FORCED_GO)
	else
		self.Owner:SetSchedule(SCHED_FORCED_GO_RUN)
	end
end
function SWEP:Chase(dude)
	self.Owner:SetSchedule(SCHED_CHASE_ENEMY)
	self.NextChaseTime=CurTime()+.5
end
function SWEP:TargetMove()
	if not(self:BadGuy())then return end
	if(math.random(1,2)==1)then
		self.Owner:SetSchedule(SCHED_CHASE_ENEMY)
	else
		local NewPos=self:BadGuy():GetPos()
		self.Owner:SetLastPosition(NewPos)
		if(math.random(1,2)==1)then
			self.Owner:SetSchedule(SCHED_FORCED_GO)
		else
			self.Owner:SetSchedule(SCHED_FORCED_GO_RUN)
		end
	end
end
function SWEP:BadGuy()
	local Enem=self.Owner:GetEnemy()
	if((IsValid(Enem))and(Enem:Health()>0))then
		return Enem
	else
		return nil
	end
end
function SWEP:Reload()
	self.Owner:IdleSound()
	self.CurrentAmmo=self.MagSize
	self.Owner:SetSchedule(SCHED_RELOAD)
	self:EmitSound(self.ReloadSound,70,110)
	self:SetNextPrimaryFire(CurTime()+3)
end
function SWEP:Fiah()
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	local SelfPos=self.Owner:GetPos()
	local PosAng=self:GetAttachment(self:LookupAttachment("muzzle")) --fuck this
	local AimVec=self.Owner:GetAimVector()
	local ShootPos=self.Owner:GetShootPos()
	local Enem=self.Owner:GetEnemy()
	local EnemPos=Enem:BodyTarget(ShootPos)
	local Muzz,AngPos=self.MuzzleEffect,self:GetAttachment(self:LookupAttachment("shell"))
	ParticleEffectAttach(Muzz,PATTACH_POINT_FOLLOW,self,1)
	if((SERVER)and(AngPos))then
		local effectdata=EffectData()
		effectdata:SetOrigin(AngPos.Pos)
		effectdata:SetAngles(AngPos.Ang)
		effectdata:SetEntity(self.Owner)
		util.Effect("RifleShellEject",effectdata,true,true)
	end
	local Acc=math.Rand(.001,.02)
	if((Enem:GetPhysicsObject():GetVelocity():Length()>100)or(self.Owner:GetPhysicsObject():GetVelocity():Length()>100))then Acc=Acc+.02 end
	local Vec=(EnemPos-self.Owner:GetShootPos()):GetNormalized()
	local BulletTrajectory=(Vec+VectorRand()*Acc):GetNormalized()
	self:FireBullets({
		Src=self.Owner:GetShootPos(),
		Dir=BulletTrajectory,
		Tracer=0,
		Damage=math.random(80,90),
		Num=1,
		Attacker=self.Owner,
		Spread=Vector(0,0,0)
	})
	self:BallisticSnap(BulletTrajectory)
	local Pitch=math.random(85,95)
	self:EmitSound(self.CloseFireSound,75,Pitch)
	sound.Play(self.CloseFireSound,SelfPos,75,Pitch)
	sound.Play(self.FarFireSound,SelfPos+Vector(0,0,1),160,Pitch)
	self.CurrentAmmo=self.CurrentAmmo-1
end
function SWEP:BallisticSnap(traj)
	if(CLIENT)then return end
	local Src=self.Owner:GetShootPos()
	local TrDat={
		start=Src,
		endpos=Src+traj*20000,
		filter={self.Owner}
	}
	local Tr,EndPos=util.TraceLine(TrDat),Src+traj*20000
	if((Tr.Hit)or(Tr.HitSky))then
		EndPos=Tr.HitPos
	end
	local Dist=(EndPos-Src):Length()
	if(Dist>1000)then
		for i=1,math.floor(Dist/500)do
			local SoundSrc=Src+traj*i*500
			for key,ply in pairs(player.GetAll())do
				if not(ply==self.Owner)then
					local PlyPos=ply:GetPos()
					if((PlyPos-SoundSrc):Length()<500)then
						local Snd="snd_jack_hmcd_bc_"..math.random(1,7)..".wav"
						local Pitch=math.random(90,110)
						sound.Play(Snd,ply:GetShootPos(),50,Pitch)
					end
				end
			end
		end
	end
end
function SWEP:SecondaryAttack()
	--
end
function SWEP:OnRemove()
	--
end
function SWEP:OnDrop()
	self:Remove()
end
if(CLIENT)then
	function SWEP:ViewModelDrawn()
		--
	end
	function SWEP:DrawWorldModel()
		self:DrawModel()
	end
end