if(SERVER)then
	AddCSLuaFile()
elseif(CLIENT)then
	SWEP.DrawAmmo=false
	SWEP.DrawCrosshair=false

	SWEP.ViewModelFOV=65

	SWEP.Slot=2
	SWEP.SlotPos=1

	killicon.AddFont("wep_jack_hmcd_shuriken", "HL2MPTypeDeath", "5", Color(0, 0, 255, 255))

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

SWEP.ViewModel="models/jaanus/w_shuriken.mdl"
SWEP.WorldModel="models/jaanus/w_shuriken.mdl"
if(CLIENT)then SWEP.WepSelectIcon=surface.GetTextureID("vgui/wep_jack_hmcd_shuriken");SWEP.BounceWeaponIcon=false end
SWEP.PrintName=translate.weaponShuriken
SWEP.Instructions	= translate.weaponShurikenDesc
SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.BobScale=3
SWEP.SwayScale=3
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
SWEP.Poisonable=true
SWEP.CarryWeight=300
function SWEP:Initialize()
	self:SetHoldType("grenade")
	self.Thrown=false
	self.PrintName=translate.weaponShuriken
	self.Instructions	= translate.weaponShurikenDesc
end

function SWEP:SetupDataTables()
	--
end

function SWEP:PrimaryAttack()
	if not(IsFirstTimePredicted())then return end
	if(self.Owner:KeyDown(IN_SPEED))then return end
	if(self.Thrown)then return end
	self:ThrowStar()
	self.Owner:SetAnimation(PLAYER_ATTACK1)
end

function SWEP:Deploy()
	if not(IsFirstTimePredicted())then return end
	self.DownAmt=10
	self.Thrown=false
	if(SERVER)then sound.Play("snd_jack_hmcd_knifedraw.wav",self.Owner:GetPos(),55,math.random(100,120)) end
	self:SetNextPrimaryFire(CurTime()+.5)
	return true
end

function SWEP:SecondaryAttack()
	--
end

function SWEP:ThrowStar(force)
	if(SERVER)then self.Owner:SetLagCompensated(true) end
	self.Thrown=true
	self.Owner:ViewPunch(Angle(2,0,0))
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	if(CLIENT)then return end
	sound.Play("weapons/slam/throw.wav",self:GetPos(),55,math.random(90,110))
	local ent=ents.Create("ent_jack_hmcd_shuriken")
	ent.HmcdSpawned=self.HmcdSpawned
	ent:SetOwner(self.Owner)
	ent:SetPos(self.Owner:GetShootPos())
	local knife_ang=self.Owner:EyeAngles()
	knife_ang:RotateAroundAxis(knife_ang:Up(), -90)
	ent:SetAngles(knife_ang)
	ent.Poisoned=self.Poisoned
	ent.Thrown=true
	ent:Spawn()

	local phys=ent:GetPhysicsObject()
	phys:SetVelocity(self.Owner:GetVelocity()+self.Owner:GetAimVector()*(1500))
	phys:AddAngleVelocity(Vector(0, 0, 3500))

	timer.Simple(.2,function()
		if(IsValid(self))then
			self:Remove()
		end
	end)
	if(SERVER)then self.Owner:SetLagCompensated(false) end
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

if(CLIENT)then
	local DownAmt=0
	function SWEP:GetViewModelPosition(pos,ang)
		if not(self.DownAmt)then self.DownAmt=8 end
		if(self.Owner:KeyDown(IN_SPEED))then
			self.DownAmt=math.Clamp(self.DownAmt+.1,0,8)
		else
			self.DownAmt=math.Clamp(self.DownAmt-.1,0,8)
		end
		--ang:RotateAroundAxis(ang:Right(),40)
		return pos+ang:Forward()*20+ang:Right()*10-ang:Up()*(7+self.DownAmt),ang
	end
	function SWEP:DrawWorldModel()
		if(GAMEMODE:ShouldDrawWeaponWorldModel(self))then
			self:DrawModel()
		end
	end
end