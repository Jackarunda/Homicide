local PlayerMeta = FindMetaTable("Player")
local EntityMeta = FindMetaTable("Entity")

net.Receive("hmcd_playersilent",function()
	local Ply=net.ReadEntity()
	Ply.SilentStepping=tobool(net.ReadBit())
end)

net.Receive("hmcd_armor",function()
	local Ply=net.ReadEntity()
	Ply.HeadArmor=net.ReadString()
	Ply.ChestArmor=net.ReadString()
end)

net.Receive("hmcd_flashlightpickup",function()
	local Dude=net.ReadEntity()
	Dude.HasFlashlight=tobool(net.ReadBit())
end)

net.Receive("hmcd_player_accessory",function()
	local Ply=net.ReadEntity()
	Ply.ModelSex=net.ReadString()
	Ply.Accessory=net.ReadString()
	Ply.AccessoryModel=nil
end)

local AppearanceMenuOpen,Frame=false,nil
local function OpenMenu()
	if(AppearanceMenuOpen)then return end
	AppearanceMenuOpen=true
	Frame=vgui.Create("DFrame")
	Frame:SetPos(40,80)
	Frame:SetSize(300,450)
	Frame:SetTitle(translate.appearanceTitle)
	Frame:SetVisible(true)
	Frame:SetDraggable(true)
	Frame:ShowCloseButton(true)
	Frame:MakePopup()
	Frame:Center()
	Frame.OnClose=function()
		AppearanceMenuOpen=false
	end
	local MainPanel=vgui.Create("DPanel",Frame)
	MainPanel:SetPos(5,25)
	MainPanel:SetSize(290,420)
	MainPanel.Paint=function()
		surface.SetDrawColor(21,37,51,255)
		surface.DrawRect(0,0,MainPanel:GetWide(),MainPanel:GetTall()+3)
	end
	local TLabel=vgui.Create("DLabel",MainPanel)
	TLabel:SetPos(10,0)
	TLabel:SetSize(100,40)
	TLabel:SetText(translate.appearanceName)
	local Text=vgui.Create("DTextEntry",MainPanel)
	Text:SetPos(10,30)
	Text:SetSize(270,20)
	local MdlSelect=vgui.Create("DComboBox",MainPanel)
	MdlSelect:SetPos(10,60)
	MdlSelect:SetSize(150,20)
	MdlSelect:SetValue(translate.appearanceModel)
	for k,v in pairs(HMCD_ValidModels)do MdlSelect:AddChoice(v) end
	MdlSelect.OnSelect=function(panel,index,value) end
	local upsback=vgui.Create("DPanel",MainPanel)
	upsback:SetPos(115,85)
	upsback:SetSize(125,20)
	upsback.Paint=function()
		surface.SetDrawColor(128,128,128,255)
		surface.DrawRect(0,0,upsback:GetWide(),upsback:GetTall()+3)
	end
	local uppselect=vgui.Create("DNumSlider",MainPanel)
	uppselect:SetPos(10,78)
	uppselect:SetWide(250)
	uppselect:SetText(translate.appearanceUBodySize)
	uppselect:SetMin(80)
	uppselect:SetMax(130)
	uppselect:SetDecimals(0)
	uppselect:SetValue(100)
	uppselect.OnValueChanged=function(panel,val) end
	local mdsback=vgui.Create("DPanel",MainPanel)
	mdsback:SetPos(115,110)
	mdsback:SetSize(125,20)
	mdsback.Paint=function()
		surface.SetDrawColor(128,128,128,255)
		surface.DrawRect(0,0,mdsback:GetWide(),mdsback:GetTall()+3)
	end
	local midselect=vgui.Create("DNumSlider",MainPanel)
	midselect:SetPos(10,103)
	midselect:SetWide(250)
	midselect:SetText(translate.appearanceWaistSize)
	midselect:SetMin(80)
	midselect:SetMax(130)
	midselect:SetDecimals(0)
	midselect:SetValue(100)
	midselect.OnValueChanged=function(panel,val) end
	local lwsback=vgui.Create("DPanel",MainPanel)
	lwsback:SetPos(115,135)
	lwsback:SetSize(125,20)
	lwsback.Paint=function()
		surface.SetDrawColor(128,128,128,255)
		surface.DrawRect(0,0,lwsback:GetWide(),lwsback:GetTall()+3)
	end
	local lowselect=vgui.Create("DNumSlider",MainPanel)
	lowselect:SetPos(10,128)
	lowselect:SetWide(250)
	lowselect:SetText(translate.appearanceLBodySize)
	lowselect:SetMin(80)
	lowselect:SetMax(130)
	lowselect:SetDecimals(0)
	lowselect:SetValue(100)
	lowselect.OnValueChanged=function(panel,val) end
	local CLabel=vgui.Create("DLabel",MainPanel)
	CLabel:SetPos(10,160)
	CLabel:SetSize(100,40)
	CLabel:SetText(translate.appearanceCColor)
	local Mixer=vgui.Create("DColorMixer",MainPanel)
	Mixer:SetPos(10,190)
	Mixer:SetSize(200,100)
	Mixer:SetPalette(false)
	Mixer:SetAlphaBar(false)
	Mixer:SetWangs(false)
	Mixer:SetColor(Color(128,128,128))
	local CSelect=vgui.Create("DComboBox",MainPanel)
	CSelect:SetPos(10,300)
	CSelect:SetSize(150,20)
	CSelect:SetValue(translate.appearanceCStyle)
	for k,v in pairs(HMCD_ValidClothes)do CSelect:AddChoice(v) end
	local ASelect=vgui.Create("DComboBox",MainPanel)
	ASelect:SetPos(10,330)
	ASelect:SetSize(150,20)
	ASelect:SetValue(translate.appearanceAccessory)
	for k,v in pairs(HMCD_Accessories)do ASelect:AddChoice(k) end
	local DermaButton=vgui.Create("DButton",MainPanel)
	DermaButton:SetText(translate.appearanceSet)
	DermaButton:SetPos(10,370)
	DermaButton:SetSize(270,40)
	DermaButton.DoClick=function()
		local Name,Maudel,R,G,B,Upper,Core,Lower,Clothes,Accessory=Text:GetValue(),MdlSelect:GetValue(),Mixer:GetColor().r/255,Mixer:GetColor().g/255,Mixer:GetColor().b/255,uppselect:GetValue(),midselect:GetValue(),lowselect:GetValue(),CSelect:GetValue(),ASelect:GetValue()
		RunConsoleCommand("homicide_identity",Name,Maudel,R,G,B,Upper,Core,Lower,Clothes,Accessory)
		local RawData=tostring(Name).."\n"..tostring(Maudel).."\n"..tostring(R).."\n"..tostring(G).."\n"..tostring(B).."\n"..tostring(Upper).."\n"..tostring(Core).."\n"..tostring(Lower).."\n"..tostring(Clothes).."\n"..tostring(Accessory)
		file.Write("homicide_identity.txt",RawData)
		Frame:Close()
		AppearanceMenuOpen=false
	end
end
net.Receive("hmcd_openappearancemenu",function()
	OpenMenu()
end)

function GM:PrePlayerDraw(ply)
	if not(self.Murderer)then
		for key,shroud in pairs(ents.FindByClass("ent_jack_hmcd_smokebomb"))do
			if(shroud:GetDTBool(0))then
				local Dist=(ply:GetPos()-shroud:GetPos()):Length()
				if(Dist<150)then return true end
			end
		end
	end
end

local matLight=Material("sprites/light_ignorez")
function GM:PostPlayerDraw(ply)
	if((ply:Alive())and(ply:Team()==2))then
		self:RenderAccessories(ply)
		if(ply.HMCD_Flashlight)then
			local SelfPos,PlyPos=LocalPlayer():GetShootPos(),ply:GetShootPos()
			local ToVec=SelfPos-PlyPos
			local DotProduct=ToVec:GetNormalized():Dot(ply:GetAimVector())
			if(DotProduct>0)then
				local Pos,Ang=ply:GetBonePosition(ply:LookupBone("ValveBiped.Bip01_R_Hand"))
				local Visible=!util.QuickTrace(SelfPos,-ToVec,{LocalPlayer(),ply}).Hit
				if(Visible)then
					DotProduct=DotProduct^10
					local Col=ply:GetPlayerColor()
					render.SetMaterial(matLight)
					render.DrawSprite(Pos,300*DotProduct,300*DotProduct,Color(128+127*Col.x,128+127*Col.y,128+127*Col.z,150*DotProduct))
					render.DrawSprite(Pos,100*DotProduct,100*DotProduct,Color(255,255,255,255*DotProduct))
				end
			end
		end
	end
end

function GM:PlayerFootstep(ply, pos, foot, snd, volume, filter)
	self:FootStepsFootstep(ply, pos, foot, snd, volume, filter)
	if(ply.SilentStepping)then
		return true -- murderer can choose to walk silently
	end
	if(ply:GetModel()=="models/player/zombie_classic.mdl")then
		if(math.random(1,2)==1)then
			sound.Play("npc/zombie/foot"..math.random(3)..".wav",pos,70,math.random(90,110))
		else
			sound.Play("npc/zombie/foot_slide"..math.random(3)..".wav",pos,70,math.random(90,110))
		end
		return true
	end
end

function EntityMeta:GetPlayerColor()
	return self:GetNWVector("playerColor") or Vector()
end

function EntityMeta:GetBystanderName()
	local name = self:GetNWString("bystanderName")
	if !name || name == "" then
		return translate.bystander
	end
	return name
end

net.Receive("hmcd_tempspeedmul",function(len,pl)
	LocalPlayer().TempSpeedMul=net.ReadFloat()
end)

function GM:AdjustMouseSensitivity(num)
	local Mul,Ply=1,LocalPlayer()
	if not(Ply.TempSpeedMul)then return -1 end
	local Wep=Ply:GetActiveWeapon()
	if(Ply:KeyDown(IN_SPEED))then
		Mul=Mul*.25
	elseif((IsValid(Wep))and(Wep.GetAiming))then
		if(Wep:GetAiming()>99)then
			if(Wep.Scoped)then
				Mul=Mul*Wep.ScopedSensitivity
			else
				Mul=Mul*.5
			end
		end
	end
	Mul=Mul*Ply.TempSpeedMul
	if(Ply:Alive())then
		local Helth=100
		if(Ply.Health)then
			Helth=Ply:Health()
			if(((Helth)and(tonumber(Helth)))and(Helth>0))then
				Mul=Mul*math.Clamp(((Helth*.5+50)/100),.01,1)
				return Mul
			end
		end
	end
	return -1
end

local WDir,Overriding,MovDir=VectorRand():GetNormalized(),false,1000
function GM:CreateMove(cmd)
	local ply,Amt,Sporadicness=LocalPlayer(),20,15
	local Wep=ply:GetActiveWeapon()
	if(ply:Crouching())then Amt=Amt/2 end
	if(LocalPlayer().Murderer)then Amt=Amt/2 end
	if(ply.Seizuring)then Amt=1500;Sporadicness=20 end
	if(((Wep)and(IsValid(Wep))and(Wep.GetAiming)and(Wep:GetAiming()>=99))or(ply.Seizuring))then
		if((Wep.Scoped)and((ply:KeyDown(IN_FORWARD))or(ply:KeyDown(IN_BACK))or(ply:KeyDown(IN_MOVELEFT))or(ply:KeyDown(IN_MOVERIGHT))))then
			Sporadicness=Sporadicness*2
			Amt=Amt*2
		end
		local S=.05
		local EAng=cmd:GetViewAngles()
		local FT=FrameTime()
		WDir=(WDir+FT*VectorRand()*Sporadicness):GetNormalized()
		EAng.pitch=math.NormalizeAngle(EAng.pitch+WDir.z*FT*Amt*S)
		EAng.yaw=math.NormalizeAngle(EAng.yaw+WDir.x*FT*Amt*S)
		cmd:SetViewAngles(EAng)
	end
	if(ply.Seizuring)then
		if(math.random(1,100)==2)then Overriding=!Overriding end
		if(math.random(1,100)==8)then MovDir=-MovDir end
		if(Overriding)then cmd:SetForwardMove(MovDir);cmd:SetButtons(IN_ATTACK) end
	end
end

function PlayerMeta:GetAward()
	local Ribbon,Medal,Merit,Demerit,XP=nil,nil,self.HMCD_Merit or 0,self.HMCD_Demerit or 1,self.HMCD_Experience or 0
	if(XP<10)then return Ribbon,Medal end
	local SK=Merit/Demerit
	for key,tab in pairs(HMCD_SkillAwards)do
		if((SK>tab[2])and(SK<=tab[3]))then Medal="vgui/mats_jack_awards/"..tab[1] break end
	end
	for key,tab in pairs(HMCD_ExperienceAwards)do
		if((XP>tab[2])and(XP<=tab[3]))then Ribbon="vgui/mats_jack_awards/"..tab[1] break end
	end
	return Ribbon,Medal
end