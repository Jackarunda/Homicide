
function GM:RenderDeathOverlay()
	local client = LocalPlayer()
	local sw, sh = ScrW(), ScrH()

	if((GAMEMODE.SpectateTime>CurTime())and(false))then

		// render black screen
		surface.SetDrawColor(0,0,0,255)
		surface.DrawRect(-1,-1,sw + 2,sh + 2)

		render.SetColorModulation(1, 1, 1)
		render.SetBlend(1)

		
		// render body
		cam.Start3D( EyePos(), EyeAngles() )
		cam.IgnoreZ(true)
		local ent = client:GetRagdollEntity()
		if IsValid(ent) then
			ent:DrawModel()
		end
		cam.IgnoreZ(false)
		cam.End3D()
	end
end

GM.DeathEndTime = 0
GM.SpectateTime = 0
usermessage.Hook("rp_death",function (um)
	GAMEMODE.DeathEndTime = CurTime() + um:ReadLong()
	GAMEMODE.SpectateTime = CurTime() + um:ReadLong()
end)

function GM:RenderRespawnText()
	local client=LocalPlayer()
	local sw,sh=ScrW(),ScrH()
	if((client.ForgiveTime)and(client.ForgiveTime>CurTime()))then
		draw.DrawText(translate.wrongfullyKilled,"MersRadialSemiSuperS",sw/2,sh-150,Color(255,255,255,128),1)
	end
end

net.Receive("hmcd_forgive",function()
	LocalPlayer().ForgiveTime=CurTime()+10
end)