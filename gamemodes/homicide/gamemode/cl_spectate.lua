


net.Receive("spectating_status", function (length)
	GAMEMODE.SpectateMode=net.ReadInt(8)
	GAMEMODE.Spectating=false
	GAMEMODE.Spectatee=nil
	if GAMEMODE.SpectateMode >= 0 then
		GAMEMODE.Spectating=true
		GAMEMODE.Spectatee=net.ReadEntity()
	end

end)

function GM:IsCSpectating() -- wow, inefficient much?
	return self.Spectating -- a whole function call, scope, application stack, etc, all to return a single value
end -- a value that's already visible from the scope of the caller

function GM:GetCSpectatee() -- good job, MechanicalMind
	return self.Spectatee
end -- dumbass

function GM:ShouldDrawWeaponWorldModel(wep)
	if(self.Spectating)then
		local Dude=self.Spectatee
		if((Dude)and(IsValid(Dude))and(Dude:IsPlayer())and(Dude:Alive()))then
			if(Dude==wep.Owner)then
				return false
			end
		end
	end
	return true
end

function GM:GetCSpectateMode() 
	return self.SpectateMode
end


local function drawTextShadow(t,f,x,y,c,px,py)
	draw.SimpleText(t,f,x + 1,y + 1,Color(0,0,0,c.a),px,py)
	draw.SimpleText(t,f,x - 1,y - 1,Color(255,255,255,math.Clamp(c.a*.25,0,255)),px,py)
	draw.SimpleText(t,f,x,y,c,px,py)
end

local nextTipSwitch,tip=0,""
function GM:RenderSpectate()
	if self:IsCSpectating() then

		if IsValid(self:GetCSpectatee()) && self:GetCSpectatee():IsPlayer() then
			drawTextShadow(translate.spectating, "MersRadial", ScrW() / 2, 50, Color(20,120,255), 1)
		
			local h=draw.GetFontHeight("MersRadial")

			--drawTextShadow(self:GetCSpectatee():Nick(), "MersRadialSmall", ScrW() / 2, ScrH() - 100 + h, Color(190, 190, 190), 1)

			local Time=CurTime()
			if(nextTipSwitch<Time)then
				nextTipSwitch=Time+10
				tip=table.Random(HMCD_Tips)
			end
			draw.SimpleText(tip,"MersRadialSemiSuperS",ScrW()/2,ScrH()-75,Color(128,128,128,255),1)
			draw.SimpleText(tip,"MersRadialSemiSuperS",ScrW()/2+1,ScrH()-76,Color(0,0,0,255),1)
		end
	end
end