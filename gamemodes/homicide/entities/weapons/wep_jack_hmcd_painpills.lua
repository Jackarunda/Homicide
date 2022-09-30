if(SERVER)then
	AddCSLuaFile()
elseif(CLIENT)then
	SWEP.DrawAmmo=false
	SWEP.DrawCrosshair=false

	SWEP.ViewModelFOV=55

	SWEP.Slot=3
	SWEP.SlotPos=4

	killicon.AddFont("wep_jack_hmcd_painpills", "HL2MPTypeDeath", "5", Color(0, 0, 255, 255))

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

SWEP.ViewModel="models/w_models/weapons/w_eq_painpills.mdl"
SWEP.WorldModel="models/w_models/weapons/w_eq_painpills.mdl"
if(CLIENT)then SWEP.WepSelectIcon=surface.GetTextureID("vgui/wep_jack_hmcd_painpills");SWEP.BounceWeaponIcon=false end
SWEP.PrintName=translate.weaponPills
SWEP.Instructions	= translate.weaponPillsDesc
SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.BobScale=3
SWEP.SwayScale=3
SWEP.Weight	= 3
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= false

SWEP.CommandDroppable=true

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

SWEP.ENT="ent_jack_hmcd_painpills"
SWEP.DownAmt=0
SWEP.HomicideSWEP=true
SWEP.CarryWeight=200

function SWEP:Initialize()
	self:SetHoldType("slam")
	self.DownAmt=20
	self.PrintName=translate.weaponPills
	self.Instructions	= translate.weaponPillsDesc
end

function SWEP:SetupDataTables()
	--
end

function SWEP:PrimaryAttack()
	if(self.Owner:KeyDown(IN_SPEED))then return end
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	if(SERVER)then
		if(self.Owner:Health()>99)then return end
		sound.Play("snd_jack_hmcd_pillsuse.wav",self.Owner:GetShootPos(),60,math.random(90,110))
		self.Owner:ViewPunch(Angle(-30,0,0))
		local Boost=math.Clamp(self.Owner.PainBoost-CurTime(),0,1000)
		Boost=Boost+40
		self.Owner.PainBoost=CurTime()+Boost
		umsg.Start("HMCD_PainBoost",self.Owner)
		umsg.Short(Boost)
		umsg.End()
		if(self.Poisoned)then HMCD_Poison(self.Owner,self.Poisoner) end
		self:Remove()
	end
end

function SWEP:Deploy()
	self:SetNextPrimaryFire(CurTime()+1)
	self.DownAmt=20
	return true
end

function SWEP:SecondaryAttack()
	--
end

function SWEP:Think()
	if(SERVER)then
		local HoldType="slam"
		if(self.Owner:KeyDown(IN_SPEED))then
			HoldType="normal"
		end
		self:SetHoldType(HoldType)
	end
end

function SWEP:Reload()
	--
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
		pos=pos-ang:Up()*(self.DownAmt+11)+ang:Forward()*25+ang:Right()*7
		ang:RotateAroundAxis(ang:Up(),-40)
		ang:RotateAroundAxis(ang:Right(),-10)
		ang:RotateAroundAxis(ang:Forward(),-10)
		return pos,ang
	end
	function SWEP:DrawWorldModel()
		local Pos,Ang=self.Owner:GetBonePosition(self.Owner:LookupBone("ValveBiped.Bip01_R_Hand"))
		if(self.DatWorldModel)then
			if((Pos)and(Ang)and(GAMEMODE:ShouldDrawWeaponWorldModel(self)))then
				self.DatWorldModel:SetRenderOrigin(Pos+Ang:Forward()*3.5+Ang:Right()*2-Ang:Up()*-1)
				Ang:RotateAroundAxis(Ang:Right(),180)
				--Ang:RotateAroundAxis(Ang:Right(),90)
				self.DatWorldModel:SetRenderAngles(Ang)
				self.DatWorldModel:DrawModel()
			end
		else
			self.DatWorldModel=ClientsideModel("models/w_models/weapons/w_eq_painpills.mdl")
			self.DatWorldModel:SetPos(self:GetPos())
			self.DatWorldModel:SetParent(self)
			self.DatWorldModel:SetNoDraw(true)
			--self.DatWorldModel:SetModelScale(1,0)
		end
	end
end