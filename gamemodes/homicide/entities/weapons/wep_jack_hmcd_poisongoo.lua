if(SERVER)then
	AddCSLuaFile()
elseif(CLIENT)then
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false

	SWEP.ViewModelFOV = 65

	SWEP.Slot = 3
	SWEP.SlotPos = 4

	killicon.AddFont("wep_jack_hmcd_poisongoo", "HL2MPTypeDeath", "5", Color(0, 0, 255, 255))

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
if(CLIENT)then SWEP.WepSelectIcon=surface.GetTextureID("vgui/wep_jack_hmcd_poisongoo");SWEP.BounceWeaponIcon=false end
SWEP.PrintName = translate.weaponPoisonGoo
SWEP.Instructions	= translate.weaponPoisonGooDesc
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
SWEP.NoHolsterForce=true
SWEP.LastMenuOpen=0

function SWEP:Initialize()
	self:SetHoldType("normal")
	self.PrintName = translate.weaponPoisonGoo
	self.Instructions	= translate.weaponPoisonGooDesc
end

function SWEP:SetupDataTables()
	--
end

function SWEP:PrimaryAttack()
	if not(IsFirstTimePredicted())then return end
	if(self.Owner:KeyDown(IN_SPEED))then return end
	self:SetNextPrimaryFire(CurTime()+1)
	if not(IsFirstTimePredicted())then return end
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	if(CLIENT)then
		if(self.LastMenuOpen+1<CurTime())then
			self.LastMenuOpen=CurTime()
			self:OpenTheMenu()
		end
	end
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
	function SWEP:OpenTheMenu()
		if not(self.Owner:Alive())then return end
		local DermaPanel,Ply,W,H,Weps,Poisonables=vgui.Create("DFrame"),LocalPlayer(),ScrW(),ScrH(),self.Owner:GetWeapons(),{}
		for key,wep in pairs(Weps)do
			if((wep.Poisonable)or((wep.AmmoPoisonable)and(self.Owner:GetAmmoCount(wep.AmmoType)>0)))then table.insert(Poisonables,wep) end
		end
		DermaPanel:SetPos(0,0)
		DermaPanel:SetSize(210,35+#Poisonables*55)
		DermaPanel:SetTitle(translate.weaponPoisonGooMenuTitle)
		DermaPanel:SetVisible(true)
		DermaPanel:SetDraggable(true)
		DermaPanel:ShowCloseButton(true)
		DermaPanel:MakePopup()
		DermaPanel:Center()
		local MainPanel=vgui.Create("DPanel",DermaPanel)
		MainPanel:SetPos(5,25)
		MainPanel:SetSize(200,5+#Poisonables*55)
		MainPanel:SetVisible(true)
		MainPanel.Paint=function()
			surface.SetDrawColor(0,20,40,255)
			surface.DrawRect(0,0,MainPanel:GetWide(),MainPanel:GetTall())
		end
		for key,wep in pairs(Poisonables)do
			local PButton=vgui.Create("Button",MainPanel)
			PButton:SetSize(190,50)
			PButton:SetPos(5,-50+key*55)
			if(wep.Poisonable)then
				PButton:SetText(translate.weaponPoisonGooPoison..wep:GetPrintName())
			elseif(wep.AmmoPoisonable)then
				PButton:SetText(translate.weaponPoisonGooPoison..wep.AmmoName)
			end
			PButton:SetVisible(true)
			PButton.DoClick=function()
				self.Owner:ConCommand("hmcd_apply_poison "..wep:GetClass())
				DermaPanel:Close()
			end
		end
	end
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
	function SWEP:OpenMenu()
		local ply,weps=self.Owner,self.Owner:GetWeapons()
		--
	end
elseif(SERVER)then
	local function Poison(ply,cmd,args)
		if not(ply:Alive())then return end
		local wep=args[1]
		if((ply:HasWeapon(wep))and(ply:HasWeapon("wep_jack_hmcd_poisongoo")))then
			wep=ply:GetWeapon(wep)
			if not(wep.Poisoned)then
				if(wep.Poisonable)then
					wep.Poisoned=true
					ply:StripWeapon("wep_jack_hmcd_poisongoo")
					ply:SelectWeapon(wep:GetClass())
					ply:EmitSound("snd_jack_hmcd_drink1.wav",55,120)
				elseif((wep.AmmoPoisonable)and(ply:GetAmmoCount(wep.AmmoType)>0))then
					ply.HMCD_AmmoPoisoned=true
					ply:StripWeapon("wep_jack_hmcd_poisongoo")
					ply:SelectWeapon(wep:GetClass())
					ply:EmitSound("snd_jack_hmcd_drink1.wav",55,120)
				end
			end
		end
	end
	concommand.Add("hmcd_apply_poison",Poison)
end