if(SERVER)then
	AddCSLuaFile()
elseif(CLIENT)then
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false

	SWEP.ViewModelFOV = 65

	SWEP.Slot = 3
	SWEP.SlotPos = 3

	killicon.AddFont("wep_jack_hmcd_poisonliquid", "HL2MPTypeDeath", "5", Color(0, 0, 255, 255))

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

SWEP.ViewModel = "models/Items/Flare.mdl"
SWEP.WorldModel = "models/Items/Flare.mdl"
if(CLIENT)then SWEP.WepSelectIcon=surface.GetTextureID("vgui/wep_jack_hmcd_poisonliquid");SWEP.BounceWeaponIcon=false end
SWEP.PrintName = translate.weaponPoisonLiq
SWEP.Instructions	= translate.weaponPoisonLiqDesc
SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.BobScale=2
SWEP.SwayScale=2
SWEP.Weight	= 3
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= false

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

function SWEP:Initialize()
	self:SetHoldType("normal")
	self.PrintName = translate.weaponPoisonLiq
	self.Instructions	= translate.weaponPoisonLiqDesc
end

function SWEP:SetupDataTables()
	--
end

function SWEP:PrimaryAttack()
	if not(IsFirstTimePredicted())then return end
	if(self.Owner:KeyDown(IN_SPEED))then return end
	self:SetNextPrimaryFire(CurTime()+1)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:AttackFront()
end

function SWEP:Deploy()
	if not(IsFirstTimePredicted())then return end
	self.DownAmt=8
	self:SetNextPrimaryFire(CurTime()+1)
	return true
end

function SWEP:Holster()
	self:OnRemove()
	return true
end

function SWEP:OnRemove()
	if(IsValid(self.Owner) && CLIENT && self.Owner:IsPlayer())then
		local vm=self.Owner:GetViewModel()
		if(IsValid(vm)) then vm:SetMaterial("") end
	end
end

function SWEP:SecondaryAttack()
	--
end

function SWEP:Think()
	--
end

function SWEP:AttackFront()
	if(CLIENT)then return end
	self.Owner:LagCompensation(true)
	local Ent,HitPos,HitNorm=HMCD_WhomILookinAt(self.Owner,.2,65)
	local AimVec,Mul=self.Owner:GetAimVector(),1
	if((IsValid(Ent))and((Ent.IsLoot)or(Ent:GetClass()=="prop_physics")or(Ent:GetClass()=="prop_physics_mutiplayer")))then
		sound.Play("snd_jack_hmcd_needleprick.wav",self.Owner:GetShootPos(),45,math.random(90,110))
		sound.Play("snd_jack_hmcd_needleprick.wav",HitPos,40,math.random(90,110))
		self.Owner:ViewPunch(Angle(1,0,0))
		Ent.ContactPoisoned=true
		Ent.Poisoner=self.Owner
		Ent.GameSpawned=false
		net.Start("hmcd_hudhalo")
		net.WriteEntity(Ent)
		net.WriteInt(3,32)
		net.Send(self.Owner)
		self:Remove()
	else
		sound.Play("snd_jack_hmcd_tinyswish.wav",self.Owner:GetShootPos(),45,math.random(90,110))
	end
	self.Owner:LagCompensation(false)
end

function SWEP:Reload()
	--
end

if(CLIENT)then
	function SWEP:PreDrawViewModel(vm,ply,wep)
		vm:SetMaterial("debug/env_cubemap_model")
	end
	function SWEP:GetViewModelPosition(pos,ang)
		if not(self.DownAmt)then self.DownAmt=8 end
		if(self.Owner:KeyDown(IN_SPEED))then
			self.DownAmt=math.Clamp(self.DownAmt+.1,0,8)
		else
			self.DownAmt=math.Clamp(self.DownAmt-.1,0,8)
		end
		local NewPos=pos+ang:Forward()*40-ang:Up()*(18+self.DownAmt)+ang:Right()*15
		return NewPos,ang
	end
	function SWEP:DrawWorldModel()
		local Pos,Ang=self.Owner:GetBonePosition(self.Owner:LookupBone("ValveBiped.Bip01_R_Hand"))
		if(self.DatWorldModel)then
			if((Pos)and(Ang)and(GAMEMODE:ShouldDrawWeaponWorldModel(self)))then
				self.DatWorldModel:SetRenderOrigin(Pos+Ang:Forward()*4-Ang:Up()*0+Ang:Right()*1.5)
				self.DatWorldModel:SetRenderAngles(Ang)
				self.DatWorldModel:DrawModel()
			end
		else
			self.DatWorldModel=ClientsideModel("models/Items/Flare.mdl")
			self.DatWorldModel:SetPos(self:GetPos())
			self.DatWorldModel:SetParent(self)
			self.DatWorldModel:SetMaterial("debug/env_cubemap_model")
			self.DatWorldModel:SetNoDraw(true)
			self.DatWorldModel:SetModelScale(.5,0)
		end
	end
	function SWEP:ViewModelDrawn()
		--
	end
end