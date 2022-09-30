if(SERVER)then
	AddCSLuaFile()
elseif(CLIENT)then
	SWEP.DrawAmmo=false
	SWEP.DrawCrosshair=false

	SWEP.ViewModelFOV=55

	SWEP.Slot=5
	SWEP.SlotPos=3

	killicon.AddFont("wep_jack_hmcd_mask", "HL2MPTypeDeath", "5", Color(0, 0, 255, 255))

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

SWEP.ViewModel="models/props_c17/SuitCase_Passenger_Physics.mdl"
SWEP.WorldModel="models/props_c17/SuitCase_Passenger_Physics.mdl"
if(CLIENT)then SWEP.WepSelectIcon=surface.GetTextureID("vgui/wep_jack_hmcd_mask");SWEP.BounceWeaponIcon=false end
SWEP.PrintName=translate.weaponMask
SWEP.Instructions	= translate.weaponMaskDesc
SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.BobScale=3
SWEP.SwayScale=3
SWEP.Weight	= 3
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= false

SWEP.CommandDroppable=false

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

SWEP.DownAmt=0
SWEP.HomicideSWEP=true
SWEP.DeathDroppable=false

function SWEP:Initialize()
	self:SetHoldType("normal")
	self.DownAmt=20
	self.PrintName=translate.weaponMask
	self.Instructions	= translate.weaponMaskDesc
end

function SWEP:SetupDataTables()
	--
end

function SWEP:PrimaryAttack()
	if(self.Owner:KeyDown(IN_SPEED))then return end
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	if(SERVER)then
		self.Owner:MurdererHideIdentity()
	end
	self:SetNextPrimaryFire(CurTime()+1)
	self:SetNextSecondaryFire(CurTime()+1)
	timer.Simple(.5,function()
		if(IsValid(self))then
			if(SERVER)then self.Owner:SelectWeapon("wep_jack_hmcd_knife") end
		end
	end)
end

function SWEP:Deploy()
	self:SetNextPrimaryFire(CurTime()+1)
	self:SetNextSecondaryFire(CurTime()+1)
	self.DownAmt=20
	return true
end

function SWEP:SecondaryAttack()
	if(self.Owner:KeyDown(IN_SPEED))then return end
	if(SERVER)then
		self.Owner:MurdererShowIdentity()
	end
	self:SetNextPrimaryFire(CurTime()+1)
	self:SetNextSecondaryFire(CurTime()+1)
	timer.Simple(.5,function()
		if(IsValid(self))then
			if(SERVER)then self.Owner:SelectWeapon("wep_jack_hmcd_hands") end
		end
	end)
end

function SWEP:Think()
	--
end

function SWEP:Reload()
	--
end

function SWEP:OnDrop()
	--
end

if(CLIENT)then
	function SWEP:PreDrawViewModel(vm,ply,wep)
		--
	end
	function SWEP:GetViewModelPosition(pos,ang)
		if not(self.DownAmt)then self.DownAmt=0 end
		if(self.Owner:KeyDown(IN_SPEED))then
			self.DownAmt=math.Clamp(self.DownAmt+.2,0,20)
		else
			self.DownAmt=math.Clamp(self.DownAmt-.2,0,20)
		end
		pos=pos-ang:Up()*(self.DownAmt+8)+ang:Forward()*45+ang:Right()*22
		--ang:RotateAroundAxis(ang:Forward(),-90)
		return pos,ang
	end
	function SWEP:DrawWorldModel()
		local Pos,Ang=self.Owner:GetBonePosition(self.Owner:LookupBone("ValveBiped.Bip01_R_Hand"))
		if(self.DatWorldModel)then
			if((Pos)and(Ang)and(GAMEMODE:ShouldDrawWeaponWorldModel(self)))then
				self.DatWorldModel:SetRenderOrigin(Pos+Ang:Forward()*3)
				--Ang:RotateAroundAxis(Ang:Up(),90)
				Ang:RotateAroundAxis(Ang:Right(),90)
				self.DatWorldModel:SetRenderAngles(Ang)
				self.DatWorldModel:DrawModel()
			end
		else
			self.DatWorldModel=ClientsideModel("models/props_c17/SuitCase_Passenger_Physics.mdl")
			self.DatWorldModel:SetPos(self:GetPos())
			self.DatWorldModel:SetParent(self)
			self.DatWorldModel:SetNoDraw(true)
			self.DatWorldModel:SetModelScale(.75,0)
		end
	end
end