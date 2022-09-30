if(SERVER)then
	AddCSLuaFile()
elseif(CLIENT)then
	SWEP.DrawAmmo=false
	SWEP.DrawCrosshair=false

	SWEP.ViewModelFOV=65

	SWEP.Slot=5
	SWEP.SlotPos=2

	killicon.AddFont("wep_jack_hmcd_adrenaline", "HL2MPTypeDeath", "5", Color(0, 0, 255, 255))

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

SWEP.ViewModel="models/weapons/w_models/w_jyringe_jroj.mdl"
SWEP.WorldModel="models/weapons/w_models/w_jyringe_jroj.mdl"
if(CLIENT)then SWEP.WepSelectIcon=surface.GetTextureID("vgui/wep_jack_hmcd_adrenaline");SWEP.BounceWeaponIcon=false end
SWEP.PrintName=translate.weaponAdrenaline
SWEP.Instructions	= translate.weaponAdrenalineDesc
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

function SWEP:Initialize()
	self:SetHoldType("normal")
	self.PrintName=translate.weaponAdrenaline
	self.Instructions	= translate.weaponAdrenalineDesc
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
	sound.Play("snd_jack_hmcd_needleprick.wav",self.Owner:GetShootPos()+VectorRand(),60,math.random(90,110))
	sound.Play("snd_jack_hmcd_needleprick.wav",self.Owner:GetShootPos()+VectorRand(),50,math.random(90,110))
	sound.Play("snd_jack_hmcd_needleprick.wav",self.Owner:GetShootPos()+VectorRand(),40,math.random(90,110))
	local Ply,LifeID=self.Owner,self.Owner.LifeID
	self:Remove()
	timer.Simple(2,function()
		if((IsValid(Ply))and(Ply:Alive()))then
			Ply:SetHighOnDrugs(true)
		end
	end)
	timer.Simple(22,function()
		if((IsValid(Ply))and(Ply:Alive())and(Ply.LifeID==LifeID))then
			Ply:SetHighOnDrugs(false)
		end
	end)
end

function SWEP:Deploy()
	if not(IsFirstTimePredicted())then return end
	self.DownAmt=8
	self:SetNextPrimaryFire(CurTime()+1)
	return true
end

function SWEP:Holster()
	return true
end

function SWEP:OnRemove()
	--
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
	function SWEP:GetViewModelPosition(pos,ang)
		if not(self.DownAmt)then self.DownAmt=8 end
		if(self.Owner:KeyDown(IN_SPEED))then
			self.DownAmt=math.Clamp(self.DownAmt+.1,0,8)
		else
			self.DownAmt=math.Clamp(self.DownAmt-.1,0,8)
		end
		local NewPos=pos+ang:Forward()*30-ang:Up()*(8+self.DownAmt)+ang:Right()*10
		ang:RotateAroundAxis(ang:Right(),60)
		return NewPos,ang
	end
	function SWEP:DrawWorldModel()
		local Pos,Ang=self.Owner:GetBonePosition(self.Owner:LookupBone("ValveBiped.Bip01_R_Hand"))
		if(self.DatWorldModel)then
			if((Pos)and(Ang)and(GAMEMODE:ShouldDrawWeaponWorldModel(self)))then
				self.DatWorldModel:SetRenderOrigin(Pos+Ang:Forward()*6-Ang:Up()*2+Ang:Right()*1)
				Ang:RotateAroundAxis(Ang:Right(),-30)
				self.DatWorldModel:SetRenderAngles(Ang)
				self.DatWorldModel:DrawModel()
			end
		else
			self.DatWorldModel=ClientsideModel("models/weapons/w_models/w_jyringe_jroj.mdl")
			self.DatWorldModel:SetPos(self:GetPos())
			self.DatWorldModel:SetParent(self)
			self.DatWorldModel:SetNoDraw(true)
			self.DatWorldModel:SetModelScale(.5,0)
		end
	end
	function SWEP:ViewModelDrawn()
		--
	end
end