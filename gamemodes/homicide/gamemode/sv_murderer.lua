local PlayerMeta = FindMetaTable("Player")

util.AddNetworkString("you_are_a_murderer")

function PlayerMeta:SetMurderer(bool)
	self.Murderer = bool
	net.Start( "you_are_a_murderer" )
	net.WriteEntity(self)
	net.WriteBit(bool)
	net.Broadcast()
end

local NO_KNIFE_TIME = 30
function GM:MurdererThink()
	local players = team.GetPlayers(2)
	local murderer
	for k,ply in pairs(players) do
		if ply.Murderer then
			murderer = ply
			break
		end
	end

	// regenerate knife if on ground
	if((IsValid(murderer))and(murderer:Alive())and(not(self.SHTF))and(murderer.InfiniShuriken))then
		if murderer:HasWeapon("wep_jack_hmcd_shuriken") then
			murderer.LastHadKnife = CurTime()
		else
			if murderer.LastHadKnife && murderer.LastHadKnife + NO_KNIFE_TIME < CurTime() then
				for k, ent in pairs(ents.FindByClass("ent_jack_hmcd_shuriken")) do
					ent:Remove()
				end
				for k, ent in pairs(ents.FindByClass("wep_jack_hmcd_shuriken")) do
					ent:Remove()
				end
				murderer:Give("wep_jack_hmcd_shuriken")
				murderer:GetWeapon("wep_jack_hmcd_shuriken").HmcdSpawned=true
			end
		end
	end
end