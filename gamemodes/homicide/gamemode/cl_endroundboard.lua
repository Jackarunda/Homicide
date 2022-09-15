
local menu
function GM:DisplayEndRoundBoard(data)
	if IsValid(menu) then
		menu:Close()
	end

	local Showin,Dude=false,self:GetVictor()
	if(Dude)then Showin=true end

	menu=vgui.Create("DFrame")
	menu:SetSize(ScrW() * 0.8, ScrH() * 0.8)
	menu:Center()
	if(Showin)then
		menu:SetSize(ScrW()*.45,ScrH()*.9)
		menu:SetPos(ScrW()*.525,ScrH()*.05)
	end
	menu:SetTitle("")
	menu:MakePopup()
	menu:SetKeyboardInputEnabled(false)
	--menu:SetDeleteOnClose(false)

	function menu:Paint()
		surface.SetDrawColor(Color(40,40,40,255))
		surface.DrawRect(0, 0, menu:GetWide(), menu:GetTall())
	end

	local winnerPnl=vgui.Create("DPanel", menu)
	winnerPnl:DockPadding(24,24,24,24)
	winnerPnl:Dock(TOP)
	function winnerPnl:PerformLayout()
		self:SizeToChildren(false, true)
	end
	function winnerPnl:Paint(w, h) 
		surface.SetDrawColor(Color(50,50,50,255))
		surface.DrawRect(2, 2, w - 4, h - 4)
	end

	local winner=vgui.Create("DLabel", winnerPnl)
	winner:Dock(TOP)
	winner:SetFont("MersRadialBig")
	winner:SetAutoStretchVertical(true)

	if (data.murderer.ModelSex == "male") then
		s=translate.ms
	else
		s=translate.fs
	end

	if(data.reason==4)then
		if(self.ZOMBIE)then
			winner:SetText(translate.endroundZombieGaveUp)
		elseif(self.SHTF)then
			winner:SetText(translate.endroundTraitorGaveUp)
		else
			winner:SetText(translate.endroundMurdererGaveUp)
		end
		winner:SetTextColor(Color(255, 255, 255))
	elseif data.reason == 3 then
		if(self.ZOMBIE)then
			winner:SetText(translate.endroundZombieQuit)
		elseif(self.SHTF)then
			winner:SetText(translate.endroundTraitorQuit)
		else
			winner:SetText(translate.endroundMurdererQuit)
		end
		winner:SetTextColor(Color(255, 255, 255))
	elseif data.reason == 2 then
		if(self.ZOMBIE)then
			winner:SetText(translate.endroundSurvivorsWin)
		elseif(self.SHTF)then
			winner:SetText(translate.endroundInnocentsWin)
		else
			winner:SetText(translate.endroundBystandersWin)
		end
		winner:SetTextColor(Color(20, 120, 255))
	elseif data.reason == 1 then
		if(self.ZOMBIE)then
			winner:SetText(translate.endroundZombiesWin)
		elseif(self.SHTF)then
			winner:SetText(translate.endroundTraitorWins)
		else
			winner:SetText(translate.endroundMurdererWins)
		end
		winner:SetTextColor(Color(190, 20, 20))
	elseif data.reason == 5 then
		local argh=Translator:AdvVarTranslate(translate.endroundDMWins, {
			murderer={text=data.murdererName},
			s={text=s}
		})
		local aargh=""
		for k, msg in pairs(argh) do
			aargh=aargh..msg.text
		end
		winner:SetText(aargh)
		winner:SetTextColor(Color(200, 200, 200))
	elseif data.reason == 6 then
		winner:SetText(translate.endroundEveryoneDied)
		winner:SetTextColor(Color(100, 100, 100))
	elseif data.reason == 7 then
		winner:SetText(translate.endroundTimesUp)
		winner:SetTextColor(Color(100, 100, 100))
	end

	local murdererPnl=vgui.Create("DPanel", winnerPnl)
	murdererPnl:Dock(TOP)
	murdererPnl:SetTall(draw.GetFontHeight("MersRadialSmall"))
	function murdererPnl:Paint()
		--
	end

	if data.murdererName and not self.DEATHMATCH then
		local col=data.murdererColor
		local msgs
		if(self.SHTF)then
			msgs=Translator:AdvVarTranslate(translate.endroundTraitorWas, {
				murderer={text=data.murdererName, color=Color(col.x * 255, col.y * 255, col.z * 255)},
				s={text=s}
			})
		else
			msgs=Translator:AdvVarTranslate(translate.endroundMurdererWas, {
				murderer={text=data.murdererName, color=Color(col.x * 255, col.y * 255, col.z * 255)},
				s={text=s}
			})
		end

		for k, msg in pairs(msgs) do
			local was=vgui.Create("DLabel", murdererPnl)
			was:Dock(LEFT)
			was:SetText(msg.text)
			was:SetFont("MersRadialSmall")
			was:SetTextColor(msg.color or color_white)
			was:SetAutoStretchVertical(true)
			was:SizeToContentsX()
		end
	end

	local lootPnl=vgui.Create("DPanel", menu)
	lootPnl:Dock(FILL)
	lootPnl:DockPadding(24,24,24,24)
	function lootPnl:Paint(w, h) 
		surface.SetDrawColor(Color(50,50,50,255))
		surface.DrawRect(2, 2, w - 4, h - 4)
	end
	
	local desc=vgui.Create("DLabel", lootPnl)
	desc:Dock(TOP)
	desc:SetFont("MersRadial")
	desc:SetAutoStretchVertical(true)
	desc:SetText(translate.teamPlayers)
	desc:SetTextColor(color_white)
	
	local lootList=vgui.Create("DPanelList", lootPnl)
	lootList:Dock(FILL)

	table.sort(data.collectedLoot, function (a, b)
		return a.count > b.count
	end)

	for k,v in pairs(team.GetPlayers(2)) do
		if not(v.HMCD_Merit)then v.HMCD_Merit=0 end
		if not(v.HMCD_Demerit)then v.HMCD_Demerit=1 end
		if not(v.HMCD_Experience)then v.HMCD_Experience=0 end
		local Demerit=v.HMCD_Demerit
		if(Demerit<1)then Demerit=1 end
		
		local pnl=vgui.Create("DPanel")
		pnl:SetTall(draw.GetFontHeight("MersRadialSmall"))
		function pnl:Paint(w, h)
			--
		end
		function pnl:PerformLayout()
			if self.NamePnl then
				self.NamePnl:SetWidth(self:GetWide() * 0.4)
			end
			if self.BNamePnl then
				self.BNamePnl:SetWidth(self:GetWide() * 0.3)
			end
			if self.SNamePnl then
				self.SNamePnl:SetWidth(self:GetWide() * 0.4)
			end
			self:SizeToChildren(false, true)
		end

		local name=vgui.Create("DButton", pnl)
		pnl.NamePnl=name
		name:Dock(LEFT)
		name:SetAutoStretchVertical(true)
		name:SetText(v:Nick())
		name:SetFont("MersRadialSmall")
		name:SetTextColor(color_white)
		name:SetContentAlignment(4)
		function name:Paint() end
		function name:DoClick()
			if IsValid(v) then
				GAMEMODE:DoScoreboardActionPopup(v)
			end
		end

		local bname=vgui.Create("DButton", pnl)
		pnl.BNamePnl=bname
		bname:Dock(LEFT)
		bname:SetAutoStretchVertical(true)
		local col
		if(v.MurdererIdentityHidden)then
			bname:SetText(v.TrueIdentity[5])
			col=v.TrueIdentity[7]
		else
			bname:SetText(v:GetBystanderName())
			col=v:GetPlayerColor()
		end
		bname:SetFont("MersRadialSmall")
		bname:SetTextColor(Color(col.x * 255, col.y * 255, col.z * 255))
		bname:SetContentAlignment(4)
		function bname:Paint() end
		bname.DoClick=name.DoClick
		
		--[[
		local sname=vgui.Create("DButton", pnl)
		pnl.SNamePnl=sname
		sname:Dock(LEFT)
		sname:SetAutoStretchVertical(true)
		sname:SetText("(XP: "..tostring(v.HMCD_Experience).."  SK: "..tostring(math.Round(v.HMCD_Merit/Demerit,2)*100)..")")
		sname:SetFont("MersRadialSmall")
		sname:SetTextColor(color_white)
		sname:SetContentAlignment(4)
		function sname:Paint() end
		function sname:DoClick()
			if IsValid(v) then
				GAMEMODE:DoScoreboardActionPopup(v)
			end
		end
		--]]

		lootList:AddItem(pnl)
	end
	
	if(Showin)then
		local Top,Bottom
		--[[
		Top=vgui.Create("DFrame")
		function Top:Paint()
			surface.SetDrawColor(Color(40,40,40,255))
			surface.DrawRect(0,0,Top:GetWide(),Top:GetTall())
		end
		Top:ShowCloseButton(false)
		Top:SetPos(ScrW()*.05,ScrH()*.05)
		Top:SetSize(600,60)
		Top:SetTitle("")
		Top:SetKeyboardInputEnabled(false)
		Top:SetDeleteOnClose(false)
		Top:MakePopup()
		local Pnl1=vgui.Create("DPanel",Top)
		Pnl1:Dock(FILL)
		Pnl1:DockPadding(24,24,24,24)
		function Pnl1:Paint(w,h) 
			surface.SetDrawColor(Color(50,50,50,255))
			surface.DrawRect(0,0,w,h)
		end
		local title=vgui.Create("DLabel",Top)
		title:SetFont("MersRadialBig")
		title:SetText("Winner: ")
		title:SetSize(300,50)
		title:SetTextColor(Color(255,255,255,255))
		title:SetPos(10,6)
		local wew=vgui.Create("DLabel",Top)
		wew:SetFont("MersRadialBig")
		wew:SetText(Dude:GetBystanderName())
		local Col=Dude:GetPlayerColor()
		wew:SetTextColor(Color(Col.r*255,Col.g*255,Col.b*255,255))
		wew:SetPos(180,6)
		wew:SetSize(430,50)
		--]]
		Bottom=vgui.Create("DFrame")
		function Bottom:Paint()
			surface.SetDrawColor(Color(40,40,40,255))
			surface.DrawRect(0,0,Bottom:GetWide(),Bottom:GetTall())
		end
		Bottom:ShowCloseButton(false)
		Bottom:SetSize(600,75)
		Bottom:SetPos(ScrW()*.05,ScrH()*.05)
		Bottom:SetTitle(translate.endroundMVP..Dude:GetBystanderName())
		Bottom:MakePopup()
		Bottom:SetKeyboardInputEnabled(false)
		--Bottom:SetDeleteOnClose(false)
		local Pnl2=vgui.Create("DPanel",Bottom)
		Pnl2:Dock(FILL)
		Pnl2:DockPadding(24,24,24,24)
		function Pnl2:Paint(w,h) 
			surface.SetDrawColor(Color(50,50,50,255))
			surface.DrawRect(0,0,w,h)
		end
		local av=vgui.Create("AvatarImage",Bottom)
		av:SetSize(64,64)
		av:SetPos(5,5)
		av:SetPlayer(Dude,64)
		local wow=vgui.Create("DLabel",Bottom)
		wow:SetFont("MersRadialBig")
		wow:SetText(Dude:Nick())
		local Col=Dude:GetPlayerColor()
		wow:SetTextColor(Color(255,255,255,255))
		wow:SetPos(80,20)
		wow:SetSize(530,50)
		
		--[[
		local Medal
		local Aw,Yeah=Dude:GetAward()
		if((Aw)and(Yeah))then
			Medal=vgui.Create("DFrame")
			function Medal:Paint()
				surface.SetDrawColor(Color(40,40,40,255))
				surface.DrawRect(0,0,Medal:GetWide(),Medal:GetTall())
			end
			Medal:ShowCloseButton(false)
			Medal:SetSize(150,285)
			Medal:SetPos(ScrW()*.05,ScrH()*.05+80)
			Medal:SetTitle("XP: "..tostring(Dude.HMCD_Experience).."  SK: "..tostring(math.Round(Dude.HMCD_Merit/Dude.HMCD_Experience,2)))
			Medal:MakePopup()
			Medal:SetKeyboardInputEnabled(false)
			--Medal:SetDeleteOnClose(false)
			local Pnl3=vgui.Create("DPanel",Medal)
			Pnl3:Dock(FILL)
			Pnl3:DockPadding(24,24,24,24)
			function Pnl3:Paint(w,h)
				surface.SetDrawColor(Color(75,75,75,255*(math.sin(CurTime()*2)/2+.5)))
				surface.DrawRect(0,0,w,h)
			end
			-- you're the best, around, nothin's gonna ever keep ya down
			local The=vgui.Create("DImage",Medal)
			The:SetPos(-45,30)
			The:SetSize(240,240)
			The:SetImage(Aw)
			local Best=vgui.Create("DImage",Medal)
			Best:SetPos(-45,33)
			Best:SetSize(240,240)
			Best:SetImage(Yeah)
		end
		--]]
		
		menu.OnClose=function()
			Bottom:Close()
			--Top:Close()
			if(Medal)then Medal:Close() end
		end
	end
end

net.Receive("reopen_round_board", function ()
	if IsValid(menu) then
		menu:SetVisible(true)
	end
end)