local PlayerMeta=FindMetaTable("Player")
local EntityMeta=FindMetaTable("Entity")

util.AddNetworkString("hmcd_tker")

function PlayerMeta:SetTKer(bool)
	--if not(GAMEMODE.TeamKillPenalties)then return end
	-- wat
end

function PlayerMeta:AddToShitList(amt)
	local ID,Existing=self:SteamID(),0
	local Record=GAMEMODE.SHITLIST[ID]
	if(Record)then Existing=Record end
	GAMEMODE.SHITLIST[ID]=math.Clamp(Existing+amt,0,100000)
	if((Existing+amt)>GAMEMODE.InstantPunishmentThreshold)then
		self:KickForTeamKilling()
	end
end

function PlayerMeta:AddAttackerDmg(att,dmg)
	local Steam=att:SteamID()
	self.AttackerRecord[Steam]=(self.AttackerRecord[Steam] or 0)+dmg
end

net.Receive("hmcd_forgive",function(length,ply)
	if((ply.ForgiveTime)and(ply.ForgiveTime>CurTime()))then
		for id,dmg in pairs(ply.AttackerRecord)do
			local Dude=player.GetBySteamID(id)
			if(Dude)then Dude:AddToShitList(-dmg) end
		end
		ply.ForgiveTime=0
	end
end)

function PlayerMeta:KickForTeamKilling()
	local Pos=self:GetShootPos()
	local SteamID,Name=self:SteamID(),self:Nick()
	if not(self:IsListenServerHost())then
		for key,wep in pairs(self:GetWeapons())do
			if(wep.DeathDroppable)then self:DropWeapon(wep) end
		end
		GAMEMODE.SHITLIST[SteamID]=0 -- reset guilt
		self:Ban(3,true)
		print("PLAYER BANNED FOR 3 MINUTES:",Name,SteamID)
		for key,playah in pairs(player.GetAll())do playah:PrintMessage(HUD_PRINTTALK,Name.." has been temporarily banned for repeatedly attacking or killing innocents.") end
	elseif(self:Alive())then
		for key,playah in pairs(player.GetAll())do playah:PrintMessage(HUD_PRINTCENTER,Name.." can't be banned because is listen server host.") end
		self:SetVelocity(VectorRand()*9000)
		self:Kill()
	end
end

function PlayerMeta:GetTKer()
	return self.LastTKTime and true or false
end