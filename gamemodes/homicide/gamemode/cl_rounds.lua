
GM.RoundStage = 0
GM.LootCollected = 0
GM.RoundSettings = {}
if GAMEMODE then
	GM.RoundStage = GAMEMODE.RoundStage
	GM.LootCollected = GAMEMODE.LootCollected
	GM.RoundSettings = GAMEMODE.RoundSettings
end

function GM:GetRound()
	return self.RoundStage or 0
end

net.Receive("SetRound", function (length)
	local r = net.ReadUInt(8)
	local start = net.ReadDouble()
	GAMEMODE.RoundStage = r
	GAMEMODE.RoundStart = start
	if(GAMEMODE.DEATHMATCH)then GAMEMODE.PlayerAttackTime=start+20 end
	GAMEMODE.RoundSettings = {}
	local settings = net.ReadUInt(8)
	if r == 1 then
		timer.Simple(0.2, function ()
			local pitch = math.random(95, 105)
			if IsValid(LocalPlayer()) then
				if(GAMEMODE.ZOMBIE)then
					LocalPlayer():EmitSound("snd_jack_hmcd_zombies.mp3",100,pitch)
				elseif(GAMEMODE.DEATHMATCH)then
					LocalPlayer():EmitSound("snd_jack_hmcd_deathmatch.mp3",100,pitch)
				elseif(GAMEMODE.EPIC)then
					LocalPlayer():EmitSound("snd_jack_hmcd_wildwest.mp3",100,pitch)
				elseif(GAMEMODE.PUSSY)then
					LocalPlayer():EmitSound("snd_jack_hmcd_panic.mp3",100,pitch)
				elseif(GAMEMODE.ISLAM)then
					LocalPlayer():EmitSound("snd_jack_hmcd_islam.mp3",100,pitch)
				elseif(GAMEMODE.SHTF)then
					LocalPlayer():EmitSound("snd_jack_hmcd_disaster.mp3",100,pitch)
				else
					local Ran=math.random(1,3)
					if(Ran==1)then
						LocalPlayer():EmitSound("snd_jack_hmcd_psycho.mp3",100,pitch)
					elseif(Ran==2)then
						LocalPlayer():EmitSound("snd_jack_hmcd_halloween.mp3",100,pitch)
					elseif(Ran==3)then
						LocalPlayer():EmitSound("snd_jack_hmcd_shining.mp3",100,pitch)
					end
				end
				-- LocalPlayer():EmitSound("ambient/creatures/town_child_scream1.wav", 100, pitch)
			end
		end)
		GAMEMODE.LootCollected = 0
	end
end)

net.Receive("DeclareWinner" , function (length)
	local data = {}
	data.reason = net.ReadUInt(8)
	GAMEMODE.WinCondition=data.reason
	GAMEMODE.HeroPlayer=net.ReadEntity()
	data.murderer = net.ReadEntity()
	GAMEMODE.VillainPlayer=data.murderer
	data.murdererColor = net.ReadVector()
	data.murdererName = net.ReadString()
	data.collectedLoot = {}
	while true do
		local cont = net.ReadUInt(8)
		if cont == 0 then break end

		local t = {}
		t.player = net.ReadEntity()
		if IsValid(t.player) then
			t.playerName = t.player:Nick()
		end
		t.count = net.ReadUInt(32)
		t.playerColor = net.ReadVector()
		t.playerBystanderName = net.ReadString()
		table.insert(data.collectedLoot, t)
		t.player.HMCD_Merit=net.ReadFloat()
		t.player.HMCD_Demerit=net.ReadFloat()
		t.player.HMCD_Experience=net.ReadFloat()
	end

	GAMEMODE:DisplayEndRoundBoard(data)

	local pitch = math.random(80, 120)
	if IsValid(LocalPlayer()) then
		LocalPlayer():EmitSound("ambient/alarms/warningbell1.wav", 100, pitch)
	end
end)

--net.Receive("GrabLoot", function (length)
--	GAMEMODE.LootCollected = net.ReadUInt(32)
--end)

--net.Receive("SetLoot", function (length)
--	GAMEMODE.LootCollected = net.ReadUInt(32)
--end)