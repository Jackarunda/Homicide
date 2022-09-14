local PlayerMeta = FindMetaTable("Player")
local EntityMeta = FindMetaTable("Entity")

local AmmoTypes={
	"AirboatGun","AlyxGun","357","Pistol","Buckshot","AR2","SMG1","XBowBolt","AirboatGun" -- nails twice as likely
}
local CivilianAmmoTypes={
	"AirboatGun","Pistol","AirboatGun" -- nails twice as likely
}
local LootTable={
	{"ent_jack_hmcd_fooddrink",27},
	{"ent_jack_hmcd_fooddrinkbig",17},
	{"ent_jack_hmcd_bandage",8},
	{"ent_jack_hmcd_pocketknife",7},
	{"ent_jack_hmcd_flashlight",7},
	{"ent_jack_hmcd_painpills",6},
	{"ent_jack_hmcd_ducttape",6},
	{"ent_jack_hmcd_baseballbat",5},
	{"ent_jack_hmcd_axe",5},
	{"ent_jack_hmcd_bandagebig",4},
	{"ent_jack_hmcd_hatchet",4},
	{"ent_jack_hmcd_phone",4},
	{"ent_jack_hmcd_hammer",4},
	{"ent_jack_hmcd_ammo",2.5},
	{"ent_jack_hmcd_smallpistol",.5}
}
local SHTF_LootTable={
	{"ent_jack_hmcd_fooddrink",12.5},
	{"ent_jack_hmcd_fooddrinkbig",12.5},
	{"ent_jack_hmcd_painpills",8},
	{"ent_jack_hmcd_walkietalkie",8},
	{"ent_jack_hmcd_bandage",7},
	{"ent_jack_hmcd_ducttape",6},
	{"ent_jack_hmcd_hammer",6},
	{"ent_jack_hmcd_flashlight",4},
	{"ent_jack_hmcd_medkit",4},
	{"ent_jack_hmcd_baseballbat",4},
	{"ent_jack_hmcd_pocketknife",4},
	{"ent_jack_hmcd_revolver",4},
	{"ent_jack_hmcd_grapl",4},
	{"ent_jack_hmcd_bandagebig",3},
	{"ent_jack_hmcd_ammo",3},
	{"ent_jack_hmcd_bow",2},
	{"ent_jack_hmcd_pistol",2},
	{"ent_jack_hmcd_shotgun",1},
	{"ent_jack_hmcd_rifle",1},
	{"ent_jack_hmcd_softarmor",1},
	{"ent_jack_hmcd_axe",1},
	{"ent_jack_hmcd_hatchet",1},
	{"ent_jack_hmcd_helmet",1},
	{"ent_jack_hmcd_molotov",.5},
	{"ent_jack_hmcd_pipebomb",.5},
	{"ent_jack_hmcd_hardarmor",.5},
	{"ent_jack_hmcd_assaultrifle",.5},
	{"ent_jack_hmcd_suppressedrifle",.5}
}
local SHTF_TraitorLootTable={
	{"ent_jack_hmcd_flashlight",.5},
	{"ent_jack_hmcd_walkietalkie",.5},
	{"ent_jack_hmcd_fooddrink",.25},
	{"ent_jack_hmcd_fooddrinkbig",.25},
	{"ent_jack_hmcd_baseballbat",.5},
	{"ent_jack_hmcd_ducttape",.5},
	{"ent_jack_hmcd_hammer",.5},
	{"ent_jack_hmcd_pocketknife",1},
	{"ent_jack_hmcd_bandage",1},
	{"ent_jack_hmcd_bandagebig",1},
	{"ent_jack_hmcd_revolver",3},
	{"ent_jack_hmcd_painpills",3},
	{"ent_jack_hmcd_molotov",3},
	{"ent_jack_hmcd_suppressedrifle",3},
	{"ent_jack_hmcd_grapl",4},
	{"ent_jack_hmcd_medkit",4},
	{"ent_jack_hmcd_pistol",4},
	{"ent_jack_hmcd_softarmor",4},
	{"ent_jack_hmcd_helmet",4},
	{"ent_jack_hmcd_shotgun",4},
	{"ent_jack_hmcd_hatchet",4},
	{"ent_jack_hmcd_hardarmor",4},
	{"ent_jack_hmcd_axe",4},
	{"ent_jack_hmcd_rifle",4},
	{"ent_jack_hmcd_bow",4},
	{"ent_jack_hmcd_assaultrifle",4},
	{"ent_jack_hmcd_pipebomb",4},
	{"ent_jack_hmcd_ammo",30}
}
function GM:SelectLootItem(goodShit)
	local Item,Rand,DemLoots="ent_jack_hmcd_smallpistol",math.Rand(0,100),LootTable
	if(self.DEATHMATCH)then goodShit=(math.random(1,2)==1) end
	if(self.SHTF)then
		if(goodShit)then DemLoots=SHTF_TraitorLootTable else DemLoots=SHTF_LootTable end
	end
	local Place=0
	for key,element in pairs(DemLoots)do
		local Low,High=Place,Place+element[2]
		if((Rand>Low)and(Rand<=High))then Item=element[1] break end
		Place=High
	end
	if(self.PUSSY)then -- HERE'S JOHNNY
		if(math.random(1,5)==4)then
			Item=table.Random({"ent_jack_hmcd_hatchet","ent_jack_hmcd_axe"})
		end
	end
	return Item
end
function GM:SpawnLoot(SpawnPos,noJunk,goodShit)
	if not(SpawnPos)then SpawnPos,goodShit=self:FindSpawnLocation() end
	if(SpawnPos)then
		local AllObjects,GoodJunk,Minimum=table.Add(ents.FindByClass("prop_physics"),ents.FindByClass("prop_physics_multiplayer")),0,5+#team.GetPlayers(2)*2
		if(self.SHTF)then Minimum=Minimum*1.4 end
		for key,item in pairs(AllObjects)do
			local Maud=string.lower(item:GetModel())
			if(table.HasValue(HMCD_JunkLootModels,Maud))then
				GoodJunk=GoodJunk+1
			end
		end
		if((GoodJunk<Minimum)and not(noJunk)and(math.random(1,2)==1))then
			local Ent,Junk=ents.Create("prop_physics"),HMCD_JunkLootModels
			if((self.PUSSY)and(math.Rand(0,1)>.3))then Junk=HMCD_PersonContainers end
			Ent.HmcdSpawned=true
			Ent:SetModel(table.Random(Junk))
			Ent:SetPos(SpawnPos)
			Ent:Spawn()
			Ent:Activate()
			if(math.random(1,2)==2)then Ent.SpawnRepellent=true end
			local Health=Ent:GetPhysicsObject():GetMass()*5
			Ent:Fire("SetHealth",tostring(Health),0)
			return Ent
		else
			local Item=self:SelectLootItem(goodShit)
			if(Item)then
				Loot=ents.Create(Item)
				Loot.HmcdSpawned=true
				if(Item=="ent_jack_hmcd_ammo")then
					if(self.SHTF)then
						Loot.AmmoType=table.Random(AmmoTypes)
					else
						Loot.AmmoType=table.Random(CivilianAmmoTypes)
					end
				end
				Loot:SetPos(SpawnPos)
				Loot:Spawn()
				Loot:Activate()
				Loot.GameSpawned=true
				Loot.TouchedTime=CurTime()
			end
		end
		return Loot
	end
	return nil
end

function GM:LootThink()
	if self:GetRound() == 1 then
		local LootDelay=3
		if(self.SHTF)then LootDelay=2 end
		if((self.DEATHMATCH)or(self.ZOMBIE))then LootDelay=1 end
		LootDelay=math.Clamp(LootDelay-#player.GetAll()*.3,1,10)
		LootDelay=LootDelay/self.LOOT_SPAWN_MUL
		if !self.LastSpawnLoot || self.LastSpawnLoot < CurTime() then
			self.LastSpawnLoot = CurTime() + LootDelay
			local Amt=0
			for key,exist in pairs(ents.GetAll())do
				if(exist.IsLoot)then Amt=Amt+1 end
			end
			if(Amt<(40+5*#team.GetPlayers(2)))then
				self:PutLootOnMap()
			end
		end
	end
end

function GM:PutLootOnMap()
	local Objs,Containers=table.Add(ents.FindByClass("prop_physics"),ents.FindByClass("prop_physics_multiplayer")),{}
	for key,item in pairs(Objs)do
		if((table.HasValue(HMCD_ContainerModels,string.lower(item:GetModel())))and not(item.LootFilled))then
			table.ForceInsert(Containers,item)
		end
	end
	if(#Containers>0)then
		table.Random(Containers).LootFilled=true
	else
		self:SpawnLoot()
	end
end

function GM:PropBreak(dude,prop)
	if(prop.PlayerHiddenInside)then prop.PlayerHiddenInside:ExitContainer() end
	if(prop.HMCD_HiddenBody)then
		local Skelly=ents.Create("prop_ragdoll")
		Skelly.HmcdSpawned=true
		Skelly:SetModel("models/skeleton/skeleton_whole_noskins.mdl")
		Skelly:SetPos(prop:GetPos())
		Skelly:SetAngles(prop:GetAngles())
		Skelly:Spawn()
		Skelly:Activate()
		Skelly:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	elseif(prop.LootFilled)then
		local goodShit=false
		for key,ply in pairs(player.GetAll())do
			if(((ply:GetPos()-prop:GetPos()):Length()<100)and(ply.Murderer))then goodShit=true break end
		end
		self:SpawnLoot(prop:LocalToWorld(prop:OBBCenter()),true,goodShit)
	end
end