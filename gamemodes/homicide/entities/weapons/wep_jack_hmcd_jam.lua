if(SERVER)then
	AddCSLuaFile()
elseif(CLIENT)then
	SWEP.DrawAmmo=false
	SWEP.DrawCrosshair=false

	SWEP.ViewModelFOV=55

	SWEP.Slot=5
	SWEP.SlotPos=5

	killicon.AddFont("wep_jack_hmcd_phone", "HL2MPTypeDeath", "5", Color(0, 0, 255, 255))

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

SWEP.ViewModel="models/props_junk/wood_pallet001a_chunka1.mdl"
SWEP.WorldModel="models/props_junk/wood_pallet001a_chunka1.mdl"
if(CLIENT)then SWEP.WepSelectIcon=surface.GetTextureID("vgui/wep_jack_hmcd_jam");SWEP.BounceWeaponIcon=false end
SWEP.PrintName=translate.weaponJam
SWEP.Instructions	= translate.weaponJamDesc
SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.BobScale=3
SWEP.SwayScale=3
SWEP.Weight	= 3
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= false

SWEP.CommandDroppable=false
SWEP.DeathDroppable=false

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

SWEP.ENT="ent_jack_hmcd_jam"
SWEP.DownAmt=0
SWEP.HomicideSWEP=true

function SWEP:Initialize()
	self:SetHoldType("slam")
	self.DownAmt=20
	self.PrintName=translate.weaponJam
	self.Instructions	= translate.weaponJamDesc
end
function SWEP:PrimaryAttack()
	if(self.Owner:KeyDown(IN_SPEED))then return end
	self:SetNextPrimaryFire(CurTime()+1)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	if(SERVER)then
		local Tr=util.QuickTrace(self.Owner:GetShootPos(),self.Owner:GetAimVector()*65,{self.Owner})
		if((Tr.Hit)and(Tr.Entity))then
			if(HMCD_IsDoor(Tr.Entity))then
				local Doors={Tr.Entity}
				for key,other in pairs(ents.FindInSphere(Tr.HitPos,65))do if(HMCD_IsDoor(other))then table.insert(Doors,other) end end
				local Block=ents.Create(self.ENT)
				Block.HmcdSpawned=self.HmcdSpawned
				Block:SetPos(Tr.HitPos+Tr.HitNormal*5)
				local Ang=Tr.HitNormal:Angle()
				Ang:RotateAroundAxis(Ang:Up(),-90)
				Block:SetAngles(Ang)
				Block:Spawn()
				Block:Activate()
				Block:Block(Doors)
				self:Remove()
			end
		end
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
		pos=pos-ang:Up()*(self.DownAmt+3)+ang:Forward()*12+ang:Right()*6
		ang:RotateAroundAxis(ang:Right(),-90)
		ang:RotateAroundAxis(ang:Up(),10)
		ang:RotateAroundAxis(ang:Forward(),-110)
		return pos,ang
	end
	function SWEP:DrawWorldModel()
		local Pos,Ang=self.Owner:GetBonePosition(self.Owner:LookupBone("ValveBiped.Bip01_R_Hand"))
		if(self.DatWorldModel)then
			if((Pos)and(Ang)and(GAMEMODE:ShouldDrawWeaponWorldModel(self)))then
				self.DatWorldModel:SetRenderOrigin(Pos+Ang:Forward()*4+Ang:Right()*2-Ang:Up()*2)
				Ang:RotateAroundAxis(Ang:Right(),120)
				--Ang:RotateAroundAxis(Ang:Right(),90)
				self.DatWorldModel:SetRenderAngles(Ang)
				self.DatWorldModel:DrawModel()
			end
		else
			self.DatWorldModel=ClientsideModel("models/props_junk/wood_pallet001a_chunka1.mdl")
			self.DatWorldModel:SetPos(self:GetPos())
			self.DatWorldModel:SetParent(self)
			self.DatWorldModel:SetNoDraw(true)
			self.DatWorldModel:SetModelScale(.5,0)
		end
	end
end