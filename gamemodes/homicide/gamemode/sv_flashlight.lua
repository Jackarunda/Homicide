
util.AddNetworkString("hmcd_flashlight_light")
util.AddNetworkString("stamina")

function GM:FlashlightThink()
	for k,ply in pairs(player.GetAll())do
		if((ply:Alive())and(ply.HasFlashlight)and(ply.HMCD_Light))then
			ply.HMCD_Light.RenderPos=LerpVector(.3,ply.HMCD_Light.RenderPos,ply:GetShootPos())
			ply.HMCD_Light.RenderAng=LerpAngle(.3,ply.HMCD_Light.RenderAng,ply:GetAimVector():Angle())
			ply.HMCD_Light:SetPos(ply.HMCD_Light.RenderPos)
			ply.HMCD_Light:SetAngles(ply.HMCD_Light.RenderAng)
		end
	end
end

function GM:PlayerSwitchFlashlight(ply,turningOn)
	if(ply.HasFlashlight)then
		if(ply.HMCD_Light)then
			ply:EmitSound("items/flashlight1.wav",65,110)
			SafeRemoveEntity(ply.HMCD_Light)
			ply.HMCD_Light=nil
			net.Start("hmcd_flashlight_light")
			net.WriteEntity(ply)
			net.WriteBit(false)
			net.Send(player.GetAll())
		elseif(turningOn)then
			ply:EmitSound("items/flashlight1.wav",65,130)
			ply.HMCD_Light=ents.Create("env_projectedtexture")
			ply.HMCD_Light.HmcdSpawned=true
			ply.HMCD_Light.RenderPos=ply:GetShootPos()
			ply.HMCD_Light.RenderAng=ply:GetAimVector():Angle()
			ply.HMCD_Light:SetKeyValue("enableshadows",1)
			if(self.SHTF)then ply.HMCD_Light:SetKeyValue("farz",1250) else ply.HMCD_Light:SetKeyValue("farz",750) end
			ply.HMCD_Light:SetKeyValue("nearz",12)
			ply.HMCD_Light:SetKeyValue("lightfov",60)
			local Col=ply:GetPlayerColor()
			local c,b=Color(128+127*Col.x,128+127*Col.y,128+127*Col.z),1.25
			if not(self.SHTF)then b=1 end
			ply.HMCD_Light:SetKeyValue("lightcolor",Format("%i %i %i 255",c.r*b,c.g*b,c.b*b))
			ply.HMCD_Light:Spawn()
			ply.HMCD_Light:Input("SpotlightTexture",NULL,NULL,"effects/flashlight001")
			net.Start("hmcd_flashlight_light")
			net.WriteEntity(ply)
			net.WriteBit(true)
			net.Send(player.GetAll())
		end
	end
	return false
end