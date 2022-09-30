if(SERVER)then
	AddCSLuaFile()
elseif(CLIENT)then
	SWEP.DrawAmmo=false
	SWEP.DrawCrosshair=false

	SWEP.ViewModelFOV=65

	SWEP.Slot=3
	SWEP.SlotPos=2

	killicon.AddFont("wep_jack_hmcd_poisoncanister", "HL2MPTypeDeath", "5", Color(0, 0, 255, 255))

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

SWEP.ViewModel="models/jordfood/jtun.mdl"
SWEP.WorldModel="models/jordfood/jtun.mdl"
if(CLIENT)then SWEP.WepSelectIcon=surface.GetTextureID("vgui/wep_jack_hmcd_poisoncanister");SWEP.BounceWeaponIcon=false end
SWEP.PrintName=translate.weaponPoisonCan
SWEP.Instructions	= translate.weaponPoisonCanDesc
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
SWEP.Secondary.Ammo        ="none"
SWEP.HomicideSWEP=true
SWEP.DeathDroppable=false
SWEP.CommandDroppable=false

function SWEP:Initialize()
	self:SetHoldType("slam")
	self.PrintName=translate.weaponPoisonCan
	self.Instructions	= translate.weaponPoisonCanDesc
end

function SWEP:SetupDataTables()
	--
end

function SWEP:PrimaryAttack()
	if not(IsFirstTimePredicted())then return end
	if(self.Owner:KeyDown(IN_SPEED))then return end
	self:SetNextPrimaryFire(CurTime()+1)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	if(CLIENT)then return end
	local Can=ents.Create("ent_jack_hmcd_poisoncanister")
	Can:SetPos(self.Owner:GetShootPos()+self.Owner:GetAimVector()*20)
	Can.Owner=self.Owner
	Can.HmcdSpawned=self.HmcdSpawned
	Can:Spawn()
	Can:Activate()
	Can:GetPhysicsObject():SetVelocity(self.Owner:GetVelocity())
	self.Owner:LagCompensation(false)
	sound.Play("physics/metal/soda_can_impact_hard2.wav",Can:GetPos(),55,math.random(70,90))
	self:Remove()
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

function SWEP:Reload()
	--
end

if(CLIENT)then
	function SWEP:PreDrawViewModel(vm,ply,wep)
		--
	end
	function SWEP:GetViewModelPosition(pos,ang)
		if not(self.DownAmt)then self.DownAmt=8 end
		if(self.Owner:KeyDown(IN_SPEED))then
			self.DownAmt=math.Clamp(self.DownAmt+.1,0,8)
		else
			self.DownAmt=math.Clamp(self.DownAmt-.1,0,8)
		end
		local NewPos=pos+ang:Forward()*10-ang:Up()*(4+self.DownAmt)+ang:Right()*5
		ang:RotateAroundAxis(ang:Up(),70)
		ang:RotateAroundAxis(ang:Forward(),5)
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
			self.DatWorldModel=ClientsideModel("models/jordfood/jtun.mdl")
			self.DatWorldModel:SetPos(self:GetPos())
			self.DatWorldModel:SetParent(self)
			self.DatWorldModel:SetNoDraw(true)
		end
	end
	function SWEP:ViewModelDrawn()
		--
	end
end