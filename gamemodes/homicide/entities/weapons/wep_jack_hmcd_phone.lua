if(SERVER)then
	AddCSLuaFile()
elseif(CLIENT)then
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false

	SWEP.ViewModelFOV = 55

	SWEP.Slot = 5
	SWEP.SlotPos = 4

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

SWEP.ViewModel = "models/lt_c/tech/cellphone.mdl"
SWEP.WorldModel = "models/lt_c/tech/cellphone.mdl"
if(CLIENT)then SWEP.WepSelectIcon=surface.GetTextureID("vgui/wep_jack_hmcd_phone");SWEP.BounceWeaponIcon=false end
SWEP.PrintName = translate.weaponPhone
SWEP.Instructions	= translate.weaponPhoneDesc
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
SWEP.Secondary.Ammo         = "none"

SWEP.ENT="ent_jack_hmcd_phone"
SWEP.DownAmt=0
SWEP.HomicideSWEP=true
SWEP.CarryWeight=500

function SWEP:Initialize()
	self:SetHoldType("slam")
	self.DownAmt=20
	self:SetCalling(false)
	self.PrintName = translate.weaponPhone
	self.Instructions	= translate.weaponPhoneDesc
end

function SWEP:SetupDataTables()
	self:NetworkVar("Bool",0,"Calling")
end

function SWEP:PrimaryAttack()
	if(self.Owner:KeyDown(IN_SPEED))then return end
	if(self:GetCalling())then return end
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:SetNextPrimaryFire(CurTime()+1)
	if(SERVER)then
		--[[
		if(self.Owner:GetMurderer())then
			self.Throw=true
			timer.Simple(.01,function() self.Owner:DropWeapon(self) end)
			return
		end
		--]]
		self:SetCalling(true)
		sound.Play("snd_jack_hmcd_phone_dial.wav",self.Owner:GetShootPos(),60,100)
		local DatTime=nil
		timer.Simple(.7,function()
			if((IsValid(self))and(IsValid(self.Owner)))then
				if not(self.Owner.Murderer)then
					umsg.Start("HMCD_SurfaceSound",self.Owner)
					umsg.String("snd_jack_hmcd_phone_voice.wav")
					umsg.End()
				end
			end
		end)
		timer.Simple(2,function()
			if((IsValid(self.Owner))and(self.Owner:Alive()))then
				self.Owner:ConCommand("hmcd_taunt help")
				if(self.Owner.Murderer)then
					self.Owner:PrintMessage(HUD_PRINTTALK,translate.weaponPhonePretend)
				else
					local Until=GAMEMODE.PoliceTime-CurTime()
					if(Until>0)then
						DatTime=Until/2
						GAMEMODE.PoliceTime=CurTime()+DatTime
					end
				end
			end
		end)
		timer.Simple(4,function()
			if(IsValid(self))then
				if not(self.Owner.Murderer)then
					if(GAMEMODE.SHTF)then
						if(DatTime)then
							if(DatTime>60)then
								local argh = Translator:AdvVarTranslate(translate.guardIn, {
									mins = {text = math.ceil(DatTime/60)}
								})
								aargh = ""
								for k, msg in pairs(argh) do
									aargh = aargh..msg.text
								end
								self.Owner:PrintMessage(HUD_PRINTTALK,aargh)
							else
								local argh = Translator:AdvVarTranslate(translate.guardInSeconds, {
									secs = {text = math.ceil(DatTime)}
								})
								aargh = ""
								for k, msg in pairs(argh) do
									aargh = aargh..msg.text
								end
								self.Owner:PrintMessage(HUD_PRINTTALK,aargh)
							end
						end
						for key,ply in pairs(team.GetPlayers(2))do
							if(ply.Murderer)then
								ply:PrintMessage(HUD_PRINTTALK,translate.weaponPhoneCalledGuard)
							end
						end
					else
						if(DatTime)then
							if(DatTime>60)then
								local argh = Translator:AdvVarTranslate(translate.policeIn, {
									mins = {text = math.ceil(DatTime/60)}
								})
								aargh = ""
								for k, msg in pairs(argh) do
									aargh = aargh..msg.text
								end
								self.Owner:PrintMessage(HUD_PRINTTALK,aargh)
							else
								local argh = Translator:AdvVarTranslate(translate.policeInSeconds, {
									secs = {text = math.ceil(DatTime)}
								})
								aargh = ""
								for k, msg in pairs(argh) do
									aargh = aargh..msg.text
								end
								self.Owner:PrintMessage(HUD_PRINTTALK,aargh)
							end
						end
						for key,ply in pairs(team.GetPlayers(2))do
							if(ply.Murderer)then
								ply:PrintMessage(HUD_PRINTTALK,translate.weaponPhoneCalledPolice)
							end
						end
					end
				end
				self:Remove()
			end
		end)
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
	if(self.Throw)then
		Ent:GetPhysicsObject():SetVelocity(self:GetVelocity()*2)
	else
		Ent:GetPhysicsObject():SetVelocity(self:GetVelocity()/2)
	end
	self:Remove()
end

if(CLIENT)then
	function SWEP:PreDrawViewModel(vm,ply,wep)
		if(self:GetCalling())then
			vm:SetSkin(3)
		else
			vm:SetSkin(2)
		end
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
			self.DatWorldModel=ClientsideModel("models/lt_c/tech/cellphone.mdl")
			self.DatWorldModel:SetPos(self:GetPos())
			self.DatWorldModel:SetParent(self)
			self.DatWorldModel:SetNoDraw(true)
			self.DatWorldModel:SetSkin(2)
		end
	end
end