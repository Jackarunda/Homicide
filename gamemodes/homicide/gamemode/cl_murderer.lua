net.Receive( "you_are_a_murderer", function( length, client )
	local playa=net.ReadEntity()
	playa.Murderer=tobool(net.ReadBit())
end)

local NextPsycho=0
hook.Add("Think","HMCD_PsychoVoices",function()
	local Time=CurTime()
	if(NextPsycho<Time)then
		NextPsycho=Time+math.random(15,25)
		if(LocalPlayer().Murderer)then
			surface.PlaySound("snds_jack_hmcd_voices/"..math.random(1,15)..".mp3")
		end
	end
end)