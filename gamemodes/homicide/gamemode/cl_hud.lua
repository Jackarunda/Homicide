
surface.CreateFont( "MersText1" , {
	font = "Tahoma",
	size = 16,
	weight = 1000,
	antialias = true,
	italic = false
})

local ext = (translate.nocoolvetica == "<nocoolvetica>")

surface.CreateFont( "MersHead1" , {
	font = "Coolvetica Rg",
	size = 26,
	weight = 500,
	antialias = true,
	italic = false,
	extended = ext
})

local basesize = ScrH() / 19.125 * 1.07829597918913 // we have to multiply because coolvetica v1 is just bigger than coolvetica v5 for some reason
surface.CreateFont( "MersRadial" , {
	font = "Coolvetica Rg",
	size = math.ceil(basesize),
	weight = 500,
	antialias = true,
	italic = false,
	extended = ext
})

surface.CreateFont( "MersRadial_QM" , {
	font = "Coolvetica Rg",
	size = math.ceil(basesize*.89),
	weight = 500,
	antialias = true,
	italic = false,
	extended = ext
})

surface.CreateFont( "MersRadialS" , {
	font = "Coolvetica Rg",
	size = math.ceil(basesize*.76),
	weight = 400,
	antialias = true,
	italic = false,
	extended = ext
})

surface.CreateFont( "MersRadialSemiSuperS" , {
	font = "Coolvetica Rg",
	size = math.ceil(basesize*.62),
	weight = 125,
	antialias = true,
	italic = false,
	extended = ext
})

surface.CreateFont( "MersRadialSuperS" , {
	font = "Coolvetica Rg",
	size = math.ceil(basesize*.425),
	weight = 100,
	antialias = true,
	italic = false,
	extended = ext
})

surface.CreateFont( "MersRadialBig" , {
	font = "Coolvetica Rg",
	size = math.ceil(basesize*1.42),
	weight = 500,
	antialias = true,
	italic = false,
	extended = ext
})

surface.CreateFont( "MersRadialSmall" , {
	font = "Coolvetica Rg",
	size = math.ceil(basesize*.57),
	weight = 100,
	antialias = true,
	italic = false,
	extended = ext
})

surface.CreateFont( "MersRadialSmall_QM" , {
	font = "Coolvetica Rg",
	size = math.ceil(basesize*.425),
	weight = 100,
	antialias = true,
	italic = false,
	extended = ext
})

surface.CreateFont( "MersDeathBig" , {
	font = "Coolvetica Rg",
	size = math.ceil(basesize*1.89),
	weight = 500,
	antialias = true,
	italic = false,
	extended = ext
})

net.Receive("hmcd_noscopeaberration",function()
	LocalPlayer().JackaHMCDNoScopeAberration=true
end)

net.Receive("hmcd_painvision",function()
	LocalPlayer().PainVision=100
end)

net.Receive("hmcd_seizure",function()
	LocalPlayer().Seizuring=tobool(net.ReadBit())
end)

local function drawTextShadow(t,f,x,y,c,px,py)
	draw.SimpleText(t,f,x + 1,y + 1,Color(0,0,0,c.a),px,py)
	draw.SimpleText(t,f,x - 1,y - 1,Color(255,255,255,math.Clamp(c.a*.25,0,255)),px,py)
	draw.SimpleText(t,f,x,y,c,px,py)
end

local healthCol = Color(120,255,20)
function GM:HUDPaint()
	local round = self:GetRound()
	local client = LocalPlayer()

	if round == 0 then
		drawTextShadow(translate.minimumPlayers, "MersRadial", ScrW() / 2, ScrH() - 75, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end

	if client:Team() == 2 then
		if !client:Alive() then
			self:RenderRespawnText()
		else

			if round == 1 then
				if self.RoundStart && self.RoundStart + 10 > CurTime() then
					self:DrawStartRoundInformation()
				else
					self:DrawGameHUD(LocalPlayer())
				end
			elseif round == 2 then
				-- display who won
				self:DrawGameHUD(LocalPlayer())
			else -- round = 0

			end
		end
	end

	self:RenderSpectate()

	self:DrawRadialMenu()
end

function GM:DrawStartRoundInformation()
	local client = LocalPlayer()
	local t1 = translate.startHelpBystanderTitle
	local t2 = nil
	local c = Color(20,120,255)
	local desc = translate.table.startHelpBystander
	local timeLeft=((self.RoundStart+10)-CurTime())/10
	if(self.DEATHMATCH)then
		t1=translate.startHelpDMTitle
		desc=translate.table.startHelpDM
	elseif(self.ZOMBIE)then
		t1=translate.startHelpSurvivorTitle
		desc=translate.table.startHelpSurvivor
	elseif(self.SHTF)then
		t1=translate.startHelpInnocentTitle
		desc=translate.table.startHelpInnocent
	end

	if LocalPlayer().Murderer then
		t1 = translate.startHelpMurdererTitle
		desc = translate.table.startHelpMurderer
		if(self.ZOMBIE)then
			t1=translate.startHelpZombieTitle
			desc=translate.table.startHelpZombie
		elseif(self.SHTF)then
			t1=translate.startHelpTraitorTitle
			desc=translate.table.startHelpTraitor
		end
		c = Color(190, 20, 20)
	end

	local hasMagnum = false
	for k, wep in pairs(client:GetWeapons()) do
		local Class=wep:GetClass()
		if((Class=="wep_jack_hmcd_smallpistol")or(Class=="wep_jack_hmcd_shotgun")or(Class=="wep_jack_hmcd_rifle"))then
			hasMagnum = true
			break
		end
	end
	if hasMagnum then
		t1 = translate.startHelpGunTitle
		t2 = translate.startHelpGunSubtitle
		desc = translate.table.startHelpGun
		if(self.ZOMBIE)then
			t1=translate.startHelpSurvivorTitle
			t2=translate.startHelpBigGunSubtitle
			desc=translate.table.startHelpSurvgun
		elseif(self.SHTF)then
			t1=translate.startHelpInnocentTitle
			t2=translate.startHelpBigGunSubtitle
			desc=translate.table.startHelpIngun
		end
	end
	
	local Col=255*timeLeft^2
	local Col1,Col2,Txt=Color(Col,Col,Col,255),Color(Col,Col,Col,128),"Homicide: "
	if(self.SHTF)then
		if(self.DEATHMATCH)then
			Txt=Txt..translate.roundDM
			draw.SimpleText(translate.roundDMDesc, "MersRadialSmall",ScrW()/2,ScrH()*.15,Col2,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		elseif(self.ZOMBIE)then
			Txt=Txt..translate.roundZS
			draw.SimpleText(translate.roundZSDesc, "MersRadialSmall",ScrW()/2,ScrH()*.15,Col2,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)		
		else
			Txt=Txt..translate.roundSOE
			draw.SimpleText(translate.roundSOEDesc, "MersRadialSmall",ScrW()/2,ScrH()*.15,Col2,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
	else
		if(self.PUSSY)then
			Txt=Txt..translate.roundGFZ
			draw.SimpleText(translate.roundGFZDesc, "MersRadialSmall",ScrW()/2,ScrH()*.15,Col2,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		elseif(self.EPIC)then
			Txt=Txt..translate.roundWW
			draw.SimpleText(translate.roundWWDesc, "MersRadialSmall",ScrW()/2,ScrH()*.15,Col2,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		elseif(self.ISLAM)then
			Txt=Txt..translate.roundJM
			draw.SimpleText(translate.roundJMDesc, "MersRadialSmall",ScrW()/2,ScrH()*.15,Col2,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		else
			Txt=Txt..translate.roundSM
			draw.SimpleText(translate.roundSMDesc, "MersRadialSmall",ScrW()/2,ScrH()*.15,Col2,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
	end
	draw.SimpleText(Txt, "MersRadial",ScrW()/2-20,ScrH()*.1,Col1,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

	draw.SimpleText(t1, "MersRadial", ScrW() / 2, ScrH()  * 0.35, c, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	if t2 then
		local h = draw.GetFontHeight("MersRadial")
		draw.SimpleText(t2, "MersRadialSmall", ScrW() / 2, ScrH() * 0.35 + h * 0.7, Color(120, 70, 245), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	if desc then
		local fontHeight = draw.GetFontHeight("MersRadialSmall")
		for k,v in pairs(desc) do
			draw.SimpleText(v, "MersRadialSmall", ScrW() / 2, ScrH() * 0.8 + (k - 1) * fontHeight, c, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
end

local tex = surface.GetTextureID("SGM/playercircle")
local gradR = surface.GetTextureID("gui/gradient")

local function StatusEffect(data)
	LocalPlayer().StatusEffect=data:ReadString()
	LocalPlayer().StatusEffectShow=CurTime()+1.5
end
usermessage.Hook("HMCD_StatusEffect",StatusEffect)

local function FoodBoost(data)
	LocalPlayer().FoodBoost=CurTime()+data:ReadShort()
end
usermessage.Hook("HMCD_FoodBoost",FoodBoost)

local function PainBoost(data)
	LocalPlayer().PainBoost=CurTime()+data:ReadShort()
end
usermessage.Hook("HMCD_PainBoost",PainBoost)

local function colorDif(col1, col2)
	local x = col1.x - col2.x
	local y = col1.y - col2.y
	local z = col1.z - col2.z
	x = x > 0 and x or -x
	y = y > 0 and y or -y
	z = z > 0 and z or -z
	return x + y + z
end
local Health,Stamina,PersonTex,StamTex,HelTex,BGTex=0,0,surface.GetTextureID("vgui/hud/hmcd_person"),surface.GetTextureID("vgui/hud/hmcd_stamina"),surface.GetTextureID("vgui/hud/hmcd_health"),surface.GetTextureID("vgui/hud/hmcd_background")
function GM:DrawGameHUD(ply)
	if !IsValid(ply) then return end
	local health = ply:Health()
	if !IsValid(ply) then return end
	if not(LocalPlayer()==ply)then return end
	if(self:GetVictor())then return end
	
	local W,H,Bleedout,Vary=ScrW(),ScrH(),ply.Bleedout,math.sin(CurTime()*10)/2+.5
	Health=Lerp(.1,Health,ply:Health())
	Stamina=Lerp(.05,Stamina,ply.Stamina)
	if not(Stamina)then Stamina=0 end
	if not(Bleedout)then Bleedout=0 end
	local Bright=Color(255,255,255,255)
	if((ply.FoodBoost)and(ply.FoodBoost>CurTime()))then Bright=Color(175,235,255,255) end
	
	local tr = ply:GetEyeTraceNoCursor()

	local shouldDraw = hook.Run("HUDShouldDraw","MurderPlayerNames")
	if shouldDraw != false then
		// draw names
		if IsValid(tr.Entity) && ((tr.Entity:IsPlayer() || tr.Entity:GetClass() == "prop_ragdoll") || tr.Entity:GetClass()=="npc_metropolice" || tr.Entity:GetClass()=="npc_citizen") && tr.HitPos:Distance(tr.StartPos) < 60 then
			self.LastLooked = tr.Entity
			self.LookedFade = CurTime()
		end
		if IsValid(self.LastLooked) && self.LookedFade + 1 > CurTime() then
			local name = self.LastLooked:GetBystanderName() or "error"
			local col = self.LastLooked:GetPlayerColor() or Vector()
			col = Color(col.x * 255, col.y * 255, col.z * 255)
			col.a = (1 - (CurTime() - self.LookedFade) / 1) * 255
			drawTextShadow(name, "MersRadial", ScrW() / 2, ScrH() / 2 + 80, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end

	local shouldDraw = hook.Run("HUDShouldDraw", "MurderDisguise")
	if shouldDraw != false then
		if(GetViewEntity()==LocalPlayer())then
			if IsValid(tr.Entity) && LocalPlayer().Murderer && tr.Entity:GetClass() == "prop_ragdoll" && tr.HitPos:Distance(tr.StartPos) < 60 and not(self.ZOMBIE) then
				if tr.Entity:GetBystanderName() != ply:GetBystanderName() || colorDif(tr.Entity:GetPlayerColor(), ply:GetPlayerColor()) > 0.1 then 
					local h = draw.GetFontHeight("MersRadial")
					drawTextShadow(translate.pressEToDisguiseFor1Loot, "MersRadialSmall", ScrW() / 2, ScrH() / 2 + 80 + h * 0.7, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
			elseif((IsValid(tr.Entity))and(table.HasValue(HMCD_PersonContainers,string.lower(tr.Entity:GetModel())))and(tr.HitPos:Distance(tr.StartPos)<60))then
				local h = draw.GetFontHeight("MersRadial")
				drawTextShadow(translate.hideInThing, "MersRadialSmall", ScrW() / 2, ScrH() / 2 + 80 + h * 0.7, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
	end

	local shouldDraw = hook.Run("HUDShouldDraw", "MurderHealthBall")
	if shouldDraw != false then
		local BarSize,BarLow,HFrac,SFrac=W*.75,H*.01-10,math.Clamp(Health/100,.01,1),math.Clamp(Stamina/100,.01,1)
		if(SFrac<.99)then
			surface.SetTexture(StamTex)
			surface.SetDrawColor(Color(Bright.r*Vary,Bright.g*Vary,Bright.b*Vary,255*(1-SFrac^2)))
			surface.DrawTexturedRect(W/2-500*SFrac,BarLow,1000*SFrac,40)
		end
		surface.SetTexture(BGTex)
		surface.SetDrawColor(color_black)
		surface.DrawTexturedRect(W/2-500,BarLow,1000,40)
		surface.SetTexture(HelTex)
		if((ply.PainBoost)and(ply.PainBoost>CurTime()))then
			surface.SetDrawColor(Color(Bright.r*Vary,Bright.g*Vary,Bright.b*Vary,255))
			surface.DrawTexturedRect(W/2-500*math.Clamp(HFrac,.99,1),BarLow,1000*math.Clamp(HFrac,.9,1),40)
		end
		if(Bleedout>1)then
			surface.SetDrawColor(Color(Bright.r,Bright.g*Vary,Bright.b*Vary,255))
		else
			surface.SetDrawColor(Bright)
		end
		surface.DrawTexturedRect(W/2-500*HFrac,BarLow,1000*HFrac,40)
		
		if((ply.StatusEffect)and(ply.StatusEffectShow)and(ply.StatusEffectShow>CurTime()))then
			local Size,col=surface.GetTextSize(ply.StatusEffect),Color(128,0,0,255)
			surface.SetDrawColor(col)
			surface.SetFont("MersRadialS")
			drawTextShadow(ply.StatusEffect,"MersRadialS",W/2-Size/2,BarLow+37,col,0,TEXT_ALIGN_TOP)
		end
		
		local col,Name=ply:GetPlayerColor(),ply:GetBystanderName()
		if((Name==translate.murderer)or(Name==translate.traitor))then
			col=Color(255*Vary,0,0)
		else
			col=Color(col.x*255,col.y*255,col.z*255)
		end
		surface.SetDrawColor(col)
		surface.SetFont("MersRadialS")
		local Size=surface.GetTextSize(Name)
		drawTextShadow(Name,"MersRadialS",W/2-470-Size,BarLow+10,col,0,TEXT_ALIGN_TOP)
		
		if((ply.ChestArmor)and(ply.ChestArmor!=""))then
			local tca
			if (ply.ChestArmor == "Level III") then
				tca = translate.armorLevelIII
			else
				tca = translate.armorLevelIIIA
			end
			local str=translate.chest..tca
			surface.SetDrawColor(color_white)
			surface.SetFont("MersRadialS")
			drawTextShadow(str,"MersRadialSuperS",W/2-430,BarLow+30,color_white,0,TEXT_ALIGN_TOP)
		end
		
		if((ply.HeadArmor)and(ply.HeadArmor!=""))then
			local str=translate.head..ply.HeadArmor
			surface.SetDrawColor(color_white)
			surface.SetFont("MersRadialS")
			local Size=surface.GetTextSize(str)
			drawTextShadow(str,"MersRadialSuperS",W/2+470-Size,BarLow+30,color_white,0,TEXT_ALIGN_TOP)
		end
		
		local shouldDraw=hook.Run("HUDShouldDraw","MurderPlayerType")
		if shouldDraw!=false then
			local Name=translate.bystander
			if(self.SHTF)then Name=translate.innocent end
			if(self.DEATHMATCH)then Name=translate.fighter end
			if(self.ZOMBIE)then Name=translate.survivor end
			if LocalPlayer()==ply && LocalPlayer().Murderer then
				if(self.ZOMBIE)then
					Name=translate.zombie
				elseif(self.SHTF)then
					Name=translate.traitor
				else
					Name=translate.murderer
				end
			end
			drawTextShadow(Name,"MersRadialS",W/2+455,BarLow+10,col,0,TEXT_ALIGN_TOP)
		end
	end
	
	local RoundTextures={
		["Pistol"]=surface.GetTextureID("vgui/hud/hmcd_round_9"),
		["357"]=surface.GetTextureID("vgui/hud/hmcd_round_38"),
		["AlyxGun"]=surface.GetTextureID("vgui/hud/hmcd_round_22"),
		["Buckshot"]=surface.GetTextureID("vgui/hud/hmcd_round_12"),
		["AR2"]=surface.GetTextureID("vgui/hud/hmcd_round_792"),
		["SMG1"]=surface.GetTextureID("vgui/hud/hmcd_round_556"),
		["XBowBolt"]=surface.GetTextureID("vgui/hud/hmcd_round_arrow"),
		["AirboatGun"]=surface.GetTextureID("vgui/hud/hmcd_nail")
	}

	local FlashTex=surface.GetTextureID("vgui/hud/hmcd_flash")
	local shouldDraw = hook.Run("HUDShouldDraw", "MurderFlashlightCharge")
	if shouldDraw != false then
		if LocalPlayer() == ply && (ply:FlashlightIsOn()) then
			local col=Color(255,255,255,255)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetTexture(FlashTex)
			surface.DrawTexturedRect(W*.3-150,H*.85,128,128)
			--drawTextShadow(math.Round(charge*100).."%","MersRadialSmall",W*.3-140,H*.85+50,col,0,TEXT_ALIGN_TOP)
		end
	end

	if((ply.AmmoShow)and(ply.AmmoShow>CurTime()))then
		local Wep,TimeLeft,Opacity=ply:GetActiveWeapon(),ply.AmmoShow-CurTime(),255
		if(TimeLeft<1)then Opacity=150 end
		if(Wep.CanAmmoShow)then
			surface.SetTexture(RoundTextures[Wep.AmmoType])
			surface.SetDrawColor(Color(255,255,255,Opacity))
			surface.DrawTexturedRect(W*.7+20,H*.825,128,128)
			local Mag,Message,Cnt=Wep:Clip1(),"",ply:GetAmmoCount(Wep.AmmoType)
			if(Mag>=0)then
				Message=tostring(Mag)
				if(Cnt>0)then Message=Message.." + "..tostring(Cnt) end
			else
				Message=tostring(Cnt)
			end
			drawTextShadow(Message,"MersRadialSmall",W*.7+30,H*.8+45,Color(255,255,255,Opacity),0,TEXT_ALIGN_TOP)
		end
	end
	
	-- a simple grouping feature that will allows players to find eachother (and play) on large maps
	local Barycenter,Num=Vector(0,0,0),0
	for key,playa in pairs(player.GetAll())do
		if((playa:Alive())and not(playa==ply))then
			Barycenter=Barycenter+playa:GetPos()
			Num=Num+1
		end
	end
	Barycenter=Vector(Barycenter.x/Num,Barycenter.y/Num,Barycenter.z/Num)
	local Dist,MaxDist=(Barycenter-ply:GetPos()):Length(),1000
	if(self.SHTF)then MaxDist=2000 end
	if((self.DEATHMATCH)or(self.ZOMBIE))then MaxDist=4000 end
	if((self.ZOMBIE)and(LocalPlayer():HasWeapon("wep_jack_hmcd_zombhands")))then MaxDist=500 end
	local Wep=ply:GetActiveWeapon()
	if(Dist>MaxDist)then
		if not((Wep)and(IsValid(Wep))and(Wep.GetAiming)and(Wep:GetAiming()>1))then
			local ScreenPos=Barycenter:ToScreen()
			surface.SetTexture(PersonTex)
			surface.SetDrawColor(Color(255,255,255,math.Clamp((Dist-MaxDist)*.085,0,255)))
			surface.DrawTexturedRect(ScreenPos.x-25-5*Vary,ScreenPos.y-25-5*Vary,45+10*Vary,45+10*Vary)
		end
	end
end

local function ShowAmmo(data)
	LocalPlayer().AmmoShow=CurTime()+2
end
usermessage.Hook("HMCD_AmmoShow",ShowAmmo)

local function Drugs(data)
	LocalPlayer().HighOnDrugs=data:ReadBool()
end
usermessage.Hook("HMCD_DrugsHigh",Drugs)

function GM:GUIMousePressed(code, vector)
	--
end

local WHOTBackTab={
	["$pp_colour_addr"]=0,
	["$pp_colour_addg"]=0,
	["$pp_colour_addb"]=0,
	["$pp_colour_brightness"]=-.05,
	["$pp_colour_contrast"]=1,
	["$pp_colour_colour"]=0,
	["$pp_colour_mulr"]=0,
	["$pp_colour_mulg"]=0,
	["$pp_colour_mulb"]=0
}
local RedVision={
	["$pp_colour_addr"]=0,
	["$pp_colour_addg"]=0,
	["$pp_colour_addb"]=0,
	["$pp_colour_brightness"]=0,
	["$pp_colour_contrast"]=1,
	["$pp_colour_colour"]=1,
	["$pp_colour_mulr"]=0,
	["$pp_colour_mulg"]=0,
	["$pp_colour_mulb"]=0
}

local AbbMat,ScpMat,Helm,Narrow=surface.GetTextureID("sprites/mat_jack_hmcd_scope_aberration"),surface.GetTextureID("sprites/mat_jack_hmcd_scope_diffuse"),"sprites/mat_jack_hmcd_helmover","sprites/mat_jack_hmcd_narrow"
function GM:RenderScreenspaceEffects()
	local client,ViewEnt,SelfPos,Victor,FT=LocalPlayer(),GetViewEntity(),LocalPlayer():GetPos(),self:GetVictor(),FrameTime()
	if(self:GetVictor())then return end
	if !client:Alive() then
		client.PainVision=false
		client.Seizuring=false
		self:RenderDeathOverlay()
	else
		self:RenderLegs(client)
		if(ViewEnt!=client)then
			DrawMaterialOverlay(Narrow,1)
		elseif((client.HeadArmor)and(client.HeadArmor!=""))then
			DrawMaterialOverlay(Helm,1)
		end
		if((self.ZOMBIE)and(client.Murderer)and not(Victor))then
			local Close,Playa,Red=100000,nil,0
			for key,ply in pairs(team.GetPlayers(2))do
				if(not(ply==client)and(ply:Alive()))then
					local Dist=ply:GetPos():Distance(SelfPos)
					if(Dist<Close)then Close=Dist;Playa=ply end
				end
			end
			if(Playa)then
				local DotProduct=client:GetAimVector():DotProduct((Playa:GetPos()-SelfPos):GetNormalized())
				local ApproachAngle=(-math.deg(math.asin(DotProduct))+90)
				local AngFrac=1-(ApproachAngle/180)
				Red=Red+(AngFrac^5)
				local DistFrac=math.Clamp(1-(Close/2000),0,1)
				Red=Red+DistFrac*2
				WHOTBackTab["$pp_colour_mulr"]=Red/2
				WHOTBackTab["$pp_colour_addr"]=Red/15
			end
			DrawColorModify(WHOTBackTab)
			DrawToyTown(1,ScrH())
		elseif(not(Victor)and(client.PainVision)and(client.PainVision>0))then
			RedVision["$pp_colour_addr"]=client.PainVision/100
			DrawColorModify(RedVision)
			client.PainVision=client.PainVision-FT*100
		end
		local Wep=client:GetActiveWeapon()
		if(IsValid(Wep))then
			if((Wep.GetAiming)and(Wep:GetAiming()>5))then
				if(Wep.Scoped)then
					if(Wep:GetAiming()>=99)then
						local W,H=ScrW(),ScrH()
						surface.SetDrawColor(255,255,255,255)
						--[[ -- disabled entirely, because fuck people
						if not(client.JackaHMCDNoScopeAberration)then
							surface.SetTexture(AbbMat)
							surface.DrawTexturedRect(-1,-1,W+1,H+1)
						end
						--]]
						surface.SetTexture(ScpMat)
						surface.DrawTexturedRect(-1,-1,W+1,H+1)
						surface.SetDrawColor(0,0,0,255)
						surface.DrawRect(-1,(H/2),W+1,2)
						surface.DrawRect((W/2)+5,-1,2,H+1)
					end
				else
					DrawToyTown(2,Wep:GetAiming()*ScrH()/200)
				end
			end
		end
		if(client.HighOnDrugs)then
			DrawSharpen(2,1.2)
		end
	end
	
	local ply=client
	if((self:IsCSpectating())and(IsValid(self:GetCSpectatee())))then ply=self:GetCSpectatee() end
	local Health=ply:Health()
	if(((ply:IsPlayer())and(ply:Alive())or(GAMEMODE.SpectateTime>CurTime()))and not((self.ZOMBIE)and(ply.Murderer)))then
		if(Health<50)then
			local Frac=math.Clamp(Health/50,.01,1)
			DrawColorModify({
				["$pp_colour_addr"]=0,
				["$pp_colour_addg"]=0,
				["$pp_colour_addb"]=0,
				["$pp_colour_brightness"]=-(1-Frac)*.1,
				["$pp_colour_contrast"]=1+(1-Frac)*.5,
				["$pp_colour_colour"]=Frac,
				["$pp_colour_mulr"]=0,
				["$pp_colour_mulg"]=0,
				["$pp_colour_mulb"]=0
			})
		end
		if(Health<10)then DrawToyTown(1,ScrH()) end
	end

	if not(self.RoundStart)then self.RoundStart=CurTime() end
	if self:GetRound() == 1 && self.RoundStart && self.RoundStart + 10 > CurTime() then
		local sw, sh = ScrW(), ScrH()
		surface.SetDrawColor(0,0,0,255)
		surface.DrawRect(-1,-1,sw + 2,sh + 2)
	end
end

net.Receive("hmcd_innocence",function()
	net.ReadEntity().InnocenceLost=CurTime()+1.5
end)

function GM:PostDrawHUD()
	if self:GetRound() == 1 then
		local AlreadyDrawn=false
		if(self.TKerPentalty!=0)then
			if(self.TKerUnShowTime>CurTime())then
				if(self.TKerPenalty==1)then
					surface.SetDrawColor(10,10,10,50)
					if(self.SHTF)then
						drawTextShadow(translate.ywbaInnocent, "MersRadial", ScrW() * 0.5, ScrH()/2, Color(90,20,20), 1, TEXT_ALIGN_CENTER)
					else
						drawTextShadow(translate.ywbaBystander, "MersRadial", ScrW() * 0.5, ScrH()/2, Color(90,20,20), 1, TEXT_ALIGN_CENTER)
					end
					AlreadyDrawn=true
				elseif(self.TKerPenalty==2)then
					surface.SetDrawColor(10,10,10,50)
					drawTextShadow(translate.ywbaSpectator, "MersRadial", ScrW() * 0.5, ScrH()/2, Color(90,20,20), 1, TEXT_ALIGN_CENTER)
					AlreadyDrawn=true
				end
			end
		end
		if not(AlreadyDrawn)then
			local Ply=LocalPlayer()
			if((Ply.InnocenceLost)and(Ply.InnocenceLost>CurTime()))then
				surface.SetDrawColor(10,10,10,50)
				drawTextShadow(translate.noInnocence, "MersRadial", ScrW() * .5, ScrH()*.85, Color(90,20,20), 1, TEXT_ALIGN_CENTER)
			end
		end
	end
end

function GM:HUDShouldDraw( name )
	// hide health and armor AND AMMO YOU FAGGOT
	--print(name)
	if name == "CHudHealth" || name == "CHudBattery" || name == "CHudAmmo" then
		return false
	end

	// allow weapon hiding
	local ply = LocalPlayer()
	if IsValid(ply) then
		local wep = ply:GetActiveWeapon()
		if IsValid(wep) && wep.HUDShouldDraw then
			return wep.HUDShouldDraw(wep, name)
		end
	end

	return true
end

function GM:GUIMousePressed(code, vector)
	return self:RadialMousePressed(code,vector)
end


--[[-------------------------------------------
--              LEGS TIME NIGGAS             --
---------------------------------------------]]
-- imported from BFS2114
local HMCD_Legs={}
net.Receive("hmcd_legsreset",function()
	timer.Simple(1,function()
		HMCD_Legs.LegEnt=nil
	end)
	LocalPlayer().ShouldDisableLegs=true -- disable Legs Mod 3
end)
HMCD_Legs.LegEnt=nil
function HMCD_Legs:ShouldDrawLegs()
	local ply=LocalPlayer()
	return IsValid(HMCD_Legs.LegEnt) and
	(ply:Alive() or (ply.IsGhosted and ply:IsGhosted()))and
	GetViewEntity()==ply and
	!ply:ShouldDrawLocalPlayer() and
	!ply:GetObserverTarget()
end
function HMCD_Legs:GetPlayerLegs(ply)
	local Ply=LocalPlayer()
	return ply and ply!=Ply and ply or (self:ShouldDrawLegs() and HMCD_Legs.LegEnt or Ply)
end
HMCD_Legs.FixedModelNames={
	["models/humans/group01/female_06.mdl"]="models/player/group01/female_06.mdl",
	["models/humans/group01/female_01.mdl"]="models/player/group01/female_01.mdl",
	["models/alyx.mdl"]="models/player/alyx.mdl",
	["models/humans/group01/female_07.mdl"]="models/player/group01/female_07.mdl",
	["models/charple01.mdl"]="models/player/charple01.mdl",
	["models/humans/group01/female_04.mdl"]="models/player/group01/female_04.mdl",
	["models/humans/group03/female_06.mdl"]="models/player/group03/female_06.mdl",
	["models/gasmask.mdl"]="models/player/gasmask.mdl",
	["models/humans/group01/female_02.mdl"]="models/player/group01/female_02.mdl",
	["models/gman_high.mdl"]="models/player/gman_high.mdl",
	["models/humans/group03/male_07.mdl"]="models/player/group03/male_07.mdl",
	["models/humans/group03/female_03.mdl"]="models/player/group03/female_03.mdl",
	["models/police.mdl"]="models/player/police.mdl",
	["models/breen.mdl"]="models/player/breen.mdl",
	["models/humans/group01/male_01.mdl"]="models/player/group01/male_01.mdl",
	["models/zombie_soldier.mdl"]="models/player/zombie_soldier.mdl",
	["models/humans/group01/male_03.mdl"]="models/player/group01/male_03.mdl",
	["models/humans/group03/female_04.mdl"]="models/player/group03/female_04.mdl",
	["models/humans/group01/male_02.mdl"]="models/player/group01/male_02.mdl",
	["models/kleiner.mdl"]="models/player/kleiner.mdl",
	["models/humans/group03/female_01.mdl"]="models/player/group03/female_01.mdl",
	["models/humans/group01/male_09.mdl"]="models/player/group01/male_09.mdl",
	["models/humans/group03/male_04.mdl"]="models/player/group03/male_04.mdl",
	["models/player/urban.mbl"]="models/player/urban.mdl",
	["models/humans/group03/male_01.mdl"]="models/player/group03/male_01.mdl",
	["models/mossman.mdl"]="models/player/mossman.mdl",
	["models/humans/group01/male_06.mdl"]="models/player/group01/male_06.mdl",
	["models/humans/group03/female_02.mdl"]="models/player/group03/female_02.mdl",
	["models/humans/group01/male_07.mdl"]="models/player/group01/male_07.mdl",
	["models/humans/group01/female_03.mdl"]="models/player/group01/female_03.mdl",
	["models/humans/group01/male_08.mdl"]="models/player/group01/male_08.mdl",
	["models/humans/group01/male_04.mdl"]="models/player/group01/male_04.mdl",
	["models/humans/group03/female_07.mdl"]="models/player/group03/female_07.mdl",
	["models/humans/group03/male_02.mdl"]="models/player/group03/male_02.mdl",
	["models/humans/group03/male_06.mdl"]="models/player/group03/male_06.mdl",
	["models/barney.mdl"]="models/player/barney.mdl",
	["models/humans/group03/male_03.mdl"]="models/player/group03/male_03.mdl",
	["models/humans/group03/male_05.mdl"]="models/player/group03/male_05.mdl",
	["models/odessa.mdl"]="models/player/odessa.mdl",
	["models/humans/group03/male_09.mdl"]="models/player/group03/male_09.mdl",
	["models/humans/group01/male_05.mdl"]="models/player/group01/male_05.mdl",
	["models/humans/group03/male_08.mdl"]="models/player/group03/male_08.mdl",
	["models/monk.mdl"]="models/player/monk.mdl",
	["models/eli.mdl"]="models/player/eli.mdl",
	["models/voxelzero/player/odst.mdl"]="models/voxelzero/player/jdst.mdl"
}
function HMCD_Legs:FixModelName(mdl)
	mdl=mdl:lower()
	return self.FixedModelNames[mdl] or mdl
end
function HMCD_Legs:SetUp()
	local ply=LocalPlayer()
	self.LegEnt=ClientsideModel(HMCD_Legs:FixModelName(ply:GetModel()),RENDER_GROUP_OPAQUE_ENTITY)
	self.LegEnt:SetNoDraw(true)
	self.LegEnt:SetSkin(ply:GetInfoNum("cl_playerskin",0))
	self.LegEnt:SetMaterial(ply:GetMaterial())
	self.LegEnt:SetColor(ply:GetColor())
	local groups=ply:GetInfo("cl_playerbodygroups")
	if(groups==nil)then groups="" end
	local groups=string.Explode(" ",groups)
	for k=0,ply:GetNumBodyGroups()-1 do
		self.LegEnt:SetBodygroup(k,tonumber(groups[k+1]) or 0)
	end
	self.LegEnt.GetPlayerColor=function() 
		return Vector(GetConVarString("cl_playercolor"))
	end
	self.LegEnt.LastTick=0
end
HMCD_Legs.PlaybackRate=1
HMCD_Legs.Sequence=nil
HMCD_Legs.Velocity=0
HMCD_Legs.OldWeapon=nil
HMCD_Legs.HoldType=nil
HMCD_Legs.BoneHoldTypes={["none"]={
		"ValveBiped.Bip01_Head1",
		"ValveBiped.Bip01_Neck1",
		"ValveBiped.Bip01_Spine4",
		"ValveBiped.Bip01_Spine2",
	},
	["default"]={
		"ValveBiped.Bip01_Head1",
		"ValveBiped.Bip01_Neck1",
		"ValveBiped.Bip01_Spine4",
		"ValveBiped.Bip01_Spine2",
		"ValveBiped.Bip01_L_Hand",
		"ValveBiped.Bip01_L_Forearm",
		"ValveBiped.Bip01_L_Upperarm",
		"ValveBiped.Bip01_L_Clavicle",
		"ValveBiped.Bip01_R_Hand",
		"ValveBiped.Bip01_R_Forearm",
		"ValveBiped.Bip01_R_Upperarm",
		"ValveBiped.Bip01_R_Clavicle",
		"ValveBiped.Bip01_L_Finger4",
		"ValveBiped.Bip01_L_Finger41",
		"ValveBiped.Bip01_L_Finger42",
		"ValveBiped.Bip01_L_Finger3",
		"ValveBiped.Bip01_L_Finger31",
		"ValveBiped.Bip01_L_Finger32",
		"ValveBiped.Bip01_L_Finger2",
		"ValveBiped.Bip01_L_Finger21",
		"ValveBiped.Bip01_L_Finger22",
		"ValveBiped.Bip01_L_Finger1",
		"ValveBiped.Bip01_L_Finger11",
		"ValveBiped.Bip01_L_Finger12",
		"ValveBiped.Bip01_L_Finger0",
		"ValveBiped.Bip01_L_Finger01",
		"ValveBiped.Bip01_L_Finger02",
		"ValveBiped.Bip01_R_Finger4",
		"ValveBiped.Bip01_R_Finger41",
		"ValveBiped.Bip01_R_Finger42",
		"ValveBiped.Bip01_R_Finger3",
		"ValveBiped.Bip01_R_Finger31",
		"ValveBiped.Bip01_R_Finger32",
		"ValveBiped.Bip01_R_Finger2",
		"ValveBiped.Bip01_R_Finger21",
		"ValveBiped.Bip01_R_Finger22",
		"ValveBiped.Bip01_R_Finger1",
		"ValveBiped.Bip01_R_Finger11",
		"ValveBiped.Bip01_R_Finger12",
		"ValveBiped.Bip01_R_Finger0",
		"ValveBiped.Bip01_R_Finger01",
		"ValveBiped.Bip01_R_Finger02"
	},
	["vehicle"]={
		"ValveBiped.Bip01_Head1",
		"ValveBiped.Bip01_Neck1",
		"ValveBiped.Bip01_Spine4",
		"ValveBiped.Bip01_Spine2",
	}
}
HMCD_Legs.BonesToRemove={}
HMCD_Legs.BoneMatrix=nil
function HMCD_Legs:WeaponChanged(weap)
	if IsValid(self.LegEnt) then
		if IsValid(weap) then
			self.HoldType=weap:GetHoldType()
		else
			self.HoldType="none"
		end
		for boneId=0,self.LegEnt:GetBoneCount() do
			self.LegEnt:ManipulateBoneScale(boneId,Vector(1,1,1))
			self.LegEnt:ManipulateBonePosition(boneId,Vector(0,0,0))
		end
		HMCD_Legs.BonesToRemove={
			"ValveBiped.Bip01_Head1"
		}
		if !LocalPlayer():InVehicle() then
			HMCD_Legs.BonesToRemove=HMCD_Legs.BoneHoldTypes[HMCD_Legs.HoldType] or HMCD_Legs.BoneHoldTypes["default"]
		else
			HMCD_Legs.BonesToRemove=HMCD_Legs.BoneHoldTypes["vehicle"]
		end
		for _, v in pairs( HMCD_Legs.BonesToRemove ) do
			local boneId=self.LegEnt:LookupBone(v)
			if boneId then
				self.LegEnt:ManipulateBoneScale(boneId, vector_origin)
				self.LegEnt:ManipulateBonePosition(boneId, Vector(-100,-100,0))
			end
		end
	end
end
HMCD_Legs.BreathScale=0.5
HMCD_Legs.NextBreath=0
function HMCD_Legs:Think(maxseqgroundspeed)
	local ply=LocalPlayer()
	local PlyMdl=self:FixModelName(ply:GetModel())
	if not ply:Alive() then
		HMCD_Legs:SetUp()
		return;
	end
	if IsValid(self.LegEnt) then
		if ply:GetActiveWeapon()!=self.OldWeapon then
			self.OldWeapon=ply:GetActiveWeapon()
			self:WeaponChanged(self.OldWeapon)
		else
			self:WeaponChanged( LocalPlayer():GetActiveWeapon() )
		end
		if self.LegEnt:GetModel()!=PlyMdl then
			self.LegEnt:SetModel(PlyMdl)
		end
		self.LegEnt:SetMaterial(ply:GetMaterial())
		self.LegEnt:SetSkin(ply:GetSkin())
		self.Velocity=ply:GetVelocity():Length2D()
		self.PlaybackRate=1
		if self.Velocity>.5 then
			if maxseqgroundspeed<.001 then
				self.PlaybackRate=.01
			else
				self.PlaybackRate=self.Velocity/maxseqgroundspeed
				self.PlaybackRate=math.Clamp(self.PlaybackRate,.01,10)
			end
		end
		self.LegEnt:SetPlaybackRate(self.PlaybackRate)
		self.Sequence=ply:GetSequence()
		if (self.LegEnt.Anim!=self.Sequence) then
			self.LegEnt.Anim=self.Sequence
			self.LegEnt:ResetSequence(self.Sequence)
		end
		self.LegEnt:FrameAdvance(CurTime()-self.LegEnt.LastTick)
		self.LegEnt.LastTick=CurTime()
		HMCD_Legs.BreathScale=.5
		if HMCD_Legs.NextBreath<=CurTime() then
			HMCD_Legs.NextBreath=CurTime()+1.95/HMCD_Legs.BreathScale
			self.LegEnt:SetPoseParameter("breathing",HMCD_Legs.BreathScale)
		end
		self.LegEnt:SetPoseParameter("move_x",(ply:GetPoseParameter("move_x")*2)-1)
		self.LegEnt:SetPoseParameter("move_y",(ply:GetPoseParameter("move_y")*2)-1)
		self.LegEnt:SetPoseParameter("move_yaw",(ply:GetPoseParameter("move_yaw")*360)-180)
		self.LegEnt:SetPoseParameter("body_yaw",(ply:GetPoseParameter("body_yaw" )*180)-90)
		self.LegEnt:SetPoseParameter("spine_yaw",(ply:GetPoseParameter("spine_yaw")*180)-90)
		if(LocalPlayer():InVehicle())then
			self.LegEnt:SetColor(color_transparent)
			self.LegEnt:SetPoseParameter("vehicle_steer",(ply:GetVehicle():GetPoseParameter("vehicle_steer")*2)-1)
		end
	end
end
hook.Add("UpdateAnimation","HMCD_Legs_UpdateAnimation",function(ply,velocity,maxseqgroundspeed)
	if ply==LocalPlayer() then
		if IsValid(HMCD_Legs.LegEnt) then
			HMCD_Legs:Think(maxseqgroundspeed)
		else
			HMCD_Legs:SetUp()
		end
	end
end)
HMCD_Legs.RenderAngle=nil
HMCD_Legs.BiaisAngle=nil
HMCD_Legs.RadAngle=nil
HMCD_Legs.RenderPos=nil
HMCD_Legs.RenderColor={}
HMCD_Legs.ClipVector=vector_up * -1
HMCD_Legs.ForwardOffset=-24
function HMCD_Legs:CheckDrawVehicle()
	return LocalPlayer():InVehicle()
end
function GM:RenderLegs(ply)
	local ply=LocalPlayer()
	cam.Start3D(EyePos(),EyeAngles())
		if HMCD_Legs:ShouldDrawLegs() then
			HMCD_Legs.RenderPos=ply:GetPos()
			if ply:InVehicle() then
				HMCD_Legs.RenderAngle=LocalPlayer():GetVehicle():GetAngles()
				HMCD_Legs.RenderAngle:RotateAroundAxis( HMCD_Legs.RenderAngle:Up(), 90 )
			else
				HMCD_Legs.BiaisAngles=ply:EyeAngles()
				HMCD_Legs.RenderAngle=Angle(0,HMCD_Legs.BiaisAngles.y,0)
				HMCD_Legs.RadAngle=math.rad(HMCD_Legs.BiaisAngles.y)
				HMCD_Legs.ForwardOffset=-20
				HMCD_Legs.RenderPos.x=HMCD_Legs.RenderPos.x+math.cos(HMCD_Legs.RadAngle)*HMCD_Legs.ForwardOffset
				HMCD_Legs.RenderPos.y=HMCD_Legs.RenderPos.y+math.sin(HMCD_Legs.RadAngle)*HMCD_Legs.ForwardOffset
				if ply:GetGroundEntity()==NULL then
					HMCD_Legs.RenderPos.z=HMCD_Legs.RenderPos.z+8
					if ply:KeyDown(IN_DUCK) then
						HMCD_Legs.RenderPos.z=HMCD_Legs.RenderPos.z-28
					end
				end
			end
			HMCD_Legs.RenderColor=ply:GetColor()
			local bEnabled=render.EnableClipping(true)
				render.PushCustomClipPlane(HMCD_Legs.ClipVector,HMCD_Legs.ClipVector:Dot(EyePos())) 
					render.SetColorModulation(HMCD_Legs.RenderColor.r/255,HMCD_Legs.RenderColor.g/255,HMCD_Legs.RenderColor.b/255)
						render.SetBlend(HMCD_Legs.RenderColor.a/255)
							hook.Call("HMCD_PreLegsDraw",GAMEMODE,HMCD_Legs.LegEnt)	   
								HMCD_Legs.LegEnt:SetRenderOrigin(HMCD_Legs.RenderPos)
								HMCD_Legs.LegEnt:SetRenderAngles(HMCD_Legs.RenderAngle)
								HMCD_Legs.LegEnt:SetupBones()
								HMCD_Legs.LegEnt:DrawModel()
								HMCD_Legs.LegEnt:SetRenderOrigin()
								HMCD_Legs.LegEnt:SetRenderAngles()
							hook.Call("HMCD_PostLegsDraw",GAMEMODE,HMCD_Legs.LegEnt)
						render.SetBlend(1)
					render.SetColorModulation(1,1,1)
				render.PopCustomClipPlane()
			render.EnableClipping(bEnabled)
		end
	cam.End3D()
end
--hook.Add("RenderScreenspaceEffects","HMCD_Legs",LegsRenderFunction)

--[[--------------------------------------------------------------
	I hate desiging derma UIs so damn much
---------------------------------------------------------------]]--
net.Receive("hmcd_openammomenu",function()
	GAMEMODE:OpenAmmoDropMenu()
end)
function GM:OpenAmmoDropMenu()
	local Ply,AmmoType,AmmoAmt,Ammos=LocalPlayer(),"Pistol",1,{}
	
	for key,name in pairs(HMCD_AmmoNames)do
		local Amownt=Ply:GetAmmoCount(key)
		if(Amownt>0)then Ammos[key]=Amownt end
	end
	
	if(#table.GetKeys(Ammos)<=0)then
		Ply:ChatPrint(translate.ammoNo)
		return
	end
	
	AmmoType=table.GetKeys(Ammos)[1]
	AmmoAmt=Ammos[AmmoType]

	local DermaPanel=vgui.Create("DFrame")
	DermaPanel:SetPos(40,80)
	DermaPanel:SetSize(300,300)
	DermaPanel:SetTitle(translate.ammoDrop)
	DermaPanel:SetVisible(true)
	DermaPanel:SetDraggable(true)
	DermaPanel:ShowCloseButton(true)
	DermaPanel:MakePopup()
	DermaPanel:Center()

	local MainPanel=vgui.Create("DPanel",DermaPanel)
	MainPanel:SetPos(5,25)
	MainPanel:SetSize(290,270)
	MainPanel.Paint=function()
		surface.SetDrawColor(0,20,40,255)
		surface.DrawRect(0,0,MainPanel:GetWide(),MainPanel:GetTall()+3)
	end
	
	local SecondPanel=vgui.Create("DPanel",MainPanel)
	SecondPanel:SetPos(100,177)
	SecondPanel:SetSize(180,20)
	SecondPanel.Paint=function()
		surface.SetDrawColor(100,100,100,255)
		surface.DrawRect(0,0,SecondPanel:GetWide(),SecondPanel:GetTall()+3)
	end
	
	local amtselect=vgui.Create("DNumSlider",MainPanel)
	amtselect:SetPos(10,170)
	amtselect:SetWide(290)
	amtselect:SetText(translate.ammoAmount)
	amtselect:SetMin(1)
	amtselect:SetMax(AmmoAmt)
	amtselect:SetDecimals(0)
	amtselect:SetValue(AmmoAmt)
	amtselect.OnValueChanged=function(panel,val)
		AmmoAmt=math.Round(val)
	end
	
	local AmmoList=vgui.Create("DListView",MainPanel)
	AmmoList:SetMultiSelect(false)
	AmmoList:AddColumn(translate.ammoType)
	for key,amm in pairs(Ammos)do
		AmmoList:AddLine(HMCD_AmmoNames[key]).Type=key
	end
	AmmoList:SetPos(5,5)
	AmmoList:SetSize(280,150)
	AmmoList.OnRowSelected=function(panel,ind,row)
		AmmoType=row.Type
		AmmoAmt=Ammos[AmmoType]
		amtselect:SetMax(AmmoAmt)
		amtselect:SetValue(AmmoAmt)
	end
	AmmoList:SelectFirstItem()
	
	local gobutton=vgui.Create("Button",MainPanel)
	gobutton:SetSize(270,40)
	gobutton:SetPos(10,220)
	gobutton:SetText(translate.ammoDropShort)
	gobutton:SetVisible(true)
	gobutton.DoClick=function()
		DermaPanel:Close()
		RunConsoleCommand("hmcd_droprequest_ammo",AmmoType,tostring(AmmoAmt))
	end
end
