----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------[[
--           JJJJJJJJJJJ                                   kkkkkkkk                                                                                            d::::::d                       --
--           J:::::::::J                                   k::::::k                                                                                            d::::::d                       --
--           J:::::::::J                                   k::::::k                                                                                            d::::::d                       --
--           JJ:::::::JJ                                   k::::::k                                                                                            d:::::d                        --
--             J:::::J  aaaaaaaaaaaaa      cccccccccccccccc k:::::k    kkkkkkkaaaaaaaaaaaaa  rrrrr   rrrrrrrrr   uuuuuu    uuuuuunnnn  nnnnnnnn        ddddddddd:::::d   aaaaaaaaaaaaa        --
--             J:::::J  a::::::::::::a   cc:::::::::::::::c k:::::k   k:::::k a::::::::::::a r::::rrr:::::::::r  u::::u    u::::un:::nn::::::::nn    dd::::::::::::::d   a::::::::::::a       --
--             J:::::J  aaaaaaaaa:::::a c:::::::::::::::::c k:::::k  k:::::k  aaaaaaaaa:::::ar:::::::::::::::::r u::::u    u::::un::::::::::::::nn  d::::::::::::::::d   aaaaaaaaa:::::a      --
--             J:::::j           a::::ac:::::::cccccc:::::c k:::::k k:::::k            a::::arr::::::rrrrr::::::ru::::u    u::::unn:::::::::::::::nd:::::::ddddd:::::d            a::::a      --
--             J:::::J    aaaaaaa:::::ac::::::c     ccccccc k::::::k:::::k      aaaaaaa:::::a r:::::r     r:::::ru::::u    u::::u  n:::::nnnn:::::nd::::::d    d:::::d     aaaaaaa:::::a      --
-- JJJJJJJ     J:::::J  aa::::::::::::ac:::::c              k:::::::::::k     aa::::::::::::a r:::::r     rrrrrrru::::u    u::::u  n::::n    n::::nd:::::d     d:::::d   aa::::::::::::a      --
-- J:::::J     J:::::J a::::aaaa::::::ac:::::c              k:::::::::::k    a::::aaaa::::::a r:::::r            u::::u    u::::u  n::::n    n::::nd:::::d     d:::::d  a::::aaaa::::::a      --
-- J::::::J   J::::::Ja::::a    a:::::ac::::::c     ccccccc k::::::k:::::k  a::::a    a:::::a r:::::r            u:::::uuuu:::::u  n::::n    n::::nd:::::d     d:::::d a::::a    a:::::a      --
-- J:::::::JJJ:::::::Ja::::a    a:::::ac:::::::cccccc:::::ck::::::k k:::::k a::::a    a:::::a r:::::r            u:::::::::::::::uun::::n    n::::nd::::::ddddd::::::dda::::a    a:::::a      --
--  JJ:::::::::::::JJ a:::::aaaa::::::a c:::::::::::::::::ck::::::k  k:::::ka:::::aaaa::::::a r:::::r             u:::::::::::::::un::::n    n::::n d:::::::::::::::::da:::::aaaa::::::a      --
--    JJ:::::::::JJ    a::::::::::aa:::a cc:::::::::::::::ck::::::k   k:::::ka::::::::::aa:::ar:::::r              uu::::::::uu:::un::::n    n::::n  d:::::::::ddd::::d a::::::::::aa:::a     --
--      JJJJJJJJJ       aaaaaaaaaa  aaaa   cccccccccccccccckkkkkkkk    kkkkkkkaaaaaaaaaa  aaaarrrrrrr                uuuuuuuu  uuuunnnnnn    nnnnnn   ddddddddd   ddddd  aaaaaaaaaa  aaaa     --
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------]]
GM.Name 	= "Homicide"
GM.Author 	= "Jackarunda"
GM.Email 	= ""
GM.Website 	= ""
GM.Version = "35"
game.AddParticles("particles/pcfs_jack_muzzleflashes.pcf")
game.AddParticles("particles/pcfs_jack_explosions_small3.pcf")
game.AddParticles("particles/pcfs_jack_explosions_incendiary2.pcf")
game.AddDecal("hmcd_jackanail","decals/mat_jack_hmcd_nailhead")
game.AddDecal("hmcd_jackatape","decals/mat_jack_hmcd_ducttape")
player_manager.AddValidModel("Homicide Murderer","models/player/mkx_jajon.mdl")
player_manager.AddValidHands("Homicide Murderer","models/player/mkx_jajon_hands.mdl",0,"10000000")
player_manager.AddValidModel("Homicide Alpha-Zombie","models/player/zombie_classic.mdl")
---- TODO: ----
-- remove the medal shit from the tips
-- the prop of the arrow kills, why
-- hiding in object when the round ends
-- speed up wep aiming, reduce wep wobble, fix bug with containers getting you stuck, add sounds to container enter/exit, make knife quieter, make the pedestrian indicator shorter ranged in DM
-- the living respawn as cops at coptime
-- export the css glock18 pistol model
-- make a different wepselect system
-- change loot to containers you gotta open
-- the dead have a deathmatch with 1 ethereal firearm
-- the dead have a range of ethereal weapons of powers corresponding to how long they lived
-- multiple killers when there are enough players
-- blowdart
-- stungun
-- peperspray
----
HMCD_SkillAwards={
	{"pt",4.6,999999},
	{"au",3.7,4.6},
	{"pd",2.9,3.7},
	{"ir",2.2,2.9},
	{"os",1.6,2.2},
	{"ru",1.1,1.6},
	{"ag",.7,1.1},
	{"sn",.4,.7},
	{"ni",.2,.4},
	{"cu",0,.2}
}
HMCD_ExperienceAwards={
	{"10",15360,999999},
	{"9",7680,15360},
	{"8",3840,7680},
	{"7",1920,3840},
	{"6",960,1920},
	{"5",480,960},
	{"4",240,480},
	{"3",120,240},
	{"2",60,120},
	{"1",0,60}
}

HMCD_Tips=translate.table.tips

HMCD_ValidModels={
	"male01","male02","male03",
	"male04","male05","male06",
	"male07","male08","male09",
	"female01","female02","female03",
	"female04","female05","female06"
}

HMCD_ValidClothes={
	"normal","casual","formal","young","cold","striped","plaid"
}

HMCD_AllowedEntities={
	"logic_","phys_","gmod_","manipulate_","predicted_","physics_",
	"player_","reserved_","ai_","info_","hint","npc_zombie_torso",
	"npc_fastzombie_torso","prop_physics","prop_physics_multiplayer",
	"prop_dynamic","prop_ragdoll","worldspawn","soundent","prop_static",
	"func_","beam","spotlight_","ambient_","scene_","npc_heli_",
	"env_","trigger_","sky_","bodyque","move_","keyframe_","shadow_",
	"water_","network","light","point_","_firesmoke","raggib","prop_door",
	"prop_door_rotating","ally_","script_","math_","prop_scalable","aiscripted_",
	"path_","filter_","cycler","relationship","color_","scripted_","goal_",
	"npc_event","npc_template","gib","material_","vort_","entityflame","npc_furniture",
	"sound","npc_enemyfinder","lua_run","fish","momentary_","game_",
	"infodecal","entity_"
}

HMCD_SurfaceHardness={
	[MAT_METAL]=.95,[MAT_COMPUTER]=.95,[MAT_VENT]=.95,[MAT_GRATE]=.95,[MAT_FLESH]=.5,[MAT_ALIENFLESH]=.3,
	[MAT_SAND]=.1,[MAT_DIRT]=.3,[74]=.1,[85]=.2,[MAT_WOOD]=.5,[MAT_FOLIAGE]=.5,
	[MAT_CONCRETE]=.9,[MAT_TILE]=.8,[MAT_SLOSH]=.05,[MAT_PLASTIC]=.3,[MAT_GLASS]=.6
}

HMCD_DamageTypes={
	[DMG_SLASH]=translate.attSlash,
	[DMG_CLUB]=translate.attClub,
	[DMG_BURN]=translate.attBurn,
	[DMG_DIRECT]=translate.attDirect,
	[DMG_CRUSH]=translate.attCrush,
	[DMG_GENERIC]=translate.attGeneric,
	[DMG_SHOCK]=translate.attShock,
	[DMG_BULLET]=translate.attBullet,
	[DMG_BUCKSHOT]=translate.attBuckshot,
	[DMG_POISON]=translate.attPoison,
	[DMG_BLAST]=translate.attBlast,
	[DMG_DROWN]=translate.attDrown
}

HMCD_FlammableModels={
	"models/props_c17/canister01a.mdl",
	"models/props_c17/canister02a.mdl",
	"models/props_c17/oildrum001_explosive.mdl",
	"models/props_junk/gascan001a.mdl",
	"models/props_junk/metalgascan.mdl",
	"models/props_junk/propane_tank001a.mdl",
	"models/props_junk/propanecanister001a.mdl"
}
HMCD_ContainerModels={
	"models/props_junk/cardboard_box001a.mdl",
	"models/props_junk/cardboard_box001b.mdl",
	"models/props_junk/cardboard_box002a.mdl",
	"models/props_junk/cardboard_box002b.mdl",
	"models/props_junk/cardboard_box003a.mdl",
	"models/props_junk/cardboard_box003b.mdl",
	"models/props_junk/wood_crate001a.mdl",
	"models/props_junk/wood_crate001a_damaged.mdl",
	"models/props_junk/wood_crate001a_damagedmax.mdl",
	"models/props_junk/wood_crate002a.mdl",
	"models/props_c17/furnituredrawer001a.mdl",
	"models/props_c17/furnituredrawer003a.mdl",
	"models/props_c17/furnituredresser001a.mdl",
	"models/props_c17/woodbarrel001.mdl",
	"models/props_lab/dogobject_wood_crate001a_damagedmax.mdl",
	"models/items/item_item_crate.mdl",
	"models/props/de_inferno/claypot02.mdl",
	"models/props/de_inferno/claypot01.mdl"
}
HMCD_JunkLootModels={
	-- breakable containers
	"models/props_junk/cardboard_box001a.mdl",
	"models/props_junk/cardboard_box001b.mdl",
	"models/props_junk/cardboard_box002a.mdl",
	"models/props_junk/cardboard_box002b.mdl",
	"models/props_junk/cardboard_box003a.mdl",
	"models/props_junk/cardboard_box003b.mdl",
	"models/props_junk/cardboard_box004a.mdl",
	"models/props_junk/wood_crate001a.mdl",
	"models/props_junk/wood_crate001a_damaged.mdl",
	"models/props_junk/wood_crate001a_damagedmax.mdl",
	"models/props_junk/wood_crate002a.mdl",
	"models/props_c17/furnituredrawer001a.mdl",
	"models/props_c17/furnituredrawer003a.mdl",
	"models/props_lab/dogobject_wood_crate001a_damagedmax.mdl",
	-- flammable
	"models/props_c17/canister01a.mdl",
	"models/props_c17/canister02a.mdl",
	"models/props_junk/gascan001a.mdl",
	"models/props_junk/metalgascan.mdl",
	"models/props_junk/propane_tank001a.mdl",
	"models/props_junk/propanecanister001a.mdl",
	-- frag-able
	"models/props_interiors/pot01a.mdl",
	"models/props_c17/oildrum001.mdl",
	"models/props_junk/metal_paintcan001a.mdl",
	"models/props_wasteland/controlroom_filecabinet001a.mdl",
	"models/props_junk/metal_paintcan001b.mdl",
	"models/props_trainstation/trashcan_indoor001a.mdl",
	-- good for bombs
	"models/props_c17/suitcase001a.mdl",
	"models/props_c17/suitcase_passenger_physics.mdl",
	"models/props_c17/briefcase001a.mdl",
	-- good for construction
	"models/props_phx/construct/metal_plate1.mdl",
	"models/props_phx/construct/metal_plate1_tri.mdl",
	"models/props_phx/construct/glass/glass_plate1x1.mdl",
	"models/props_phx/construct/glass/glass_plate1x2.mdl",
	"models/hunter/plates/plate1x1.mdl",
	"models/hunter/plates/plate1x2.mdl",
	"models/props_phx/construct/wood/wood_panel1x1.mdl",
	"models/props_phx/construct/wood/wood_panel1x2.mdl",
	"models/props_phx/construct/wood/wood_panel2x2.mdl",
	"models/props_phx/construct/wood/wood_boardx1.mdl",
	"models/props_phx/construct/wood/wood_boardx2.mdl"
}

HMCD_PersonContainers={
	"models/props_junk/wood_crate001a.mdl",
	"models/props_junk/wood_crate001a_damaged.mdl",
	"models/props_junk/wood_crate001a_damagedmax.mdl",
	"models/props_junk/wood_crate002a.mdl",
	"models/props_borealis/bluebarrel001.mdl",
	"models/props_c17/oildrum001.mdl",
	"models/props_junk/trashbin01a.mdl",
	"models/props_c17/furnituredresser001a.mdl",
	"models/props_c17/woodbarrel001.mdl",
	"models/props_lab/dogobject_wood_crate001a_damagedmax.mdl",
	"models/props_wasteland/controlroom_storagecloset001a.mdl",
	"models/props_wasteland/controlroom_storagecloset001b.mdl",
	"models/props/cs_assault/dryer_box.mdl",
	"models/props/cs_assault/dryer_box2.mdl",
	"models/props/cs_assault/washer_box.mdl",
	"models/props/cs_assault/washer_box2.mdl",
	"models/props/cs_militia/crate_extrasmallmill.mdl",
	"models/props/de_dust/du_crate_64x64.mdl",
	"models/props/de_dust/du_crate_64x80.mdl",
	"models/props/de_inferno/wine_barrel.mdl",
	"models/props/de_nuke/crate_extrasmall.mdl",
	"models/props/de_nuke/crate_small.mdl",
	"models/props/de_prodigy/prodcratesb.mdl",
	"models/props_2fort/miningcrate002.mdl",
	"models/props_2fort/miningcrate001.mdl",
	"models/props_2fort/oildrum.mdl",
	"models/props_2fort/locker001.mdl",
	"models/props_junk/cardboard_box001a.mdl",
	"models/props_junk/cardboard_box001b.mdl",
	"models/props_junk/cardboard_box002a.mdl",
	"models/props_junk/cardboard_box002b.mdl",
	"models/props_trainstation/trashcan_indoor001a.mdl",
	"models/props_wasteland/kitchen_fridge001a.mdl",
	"models/props_wasteland/cargo_container01.mdl",
	"models/props_wasteland/laundry_washer001a.mdl",
	"models/props_c17/furniturefridge001a.mdl"--[[,
	"models/props_junk/trashdumpster01a.mdl",
	"models/props_trainstation/train003.mdl",
	"models/props_vehicles/car002a_physics.mdl",
	"models/props_vehicles/car002a.mdl",
	"models/props_vehicles/apc001.mdl",
	"models/props_vehicles/car004a_physics.mdl",
	"models/props_vehicles/car004a.mdl",
	"models/props_vehicles/car005a_physics.mdl",
	"models/props_vehicles/car005a.mdl",
	"models/props_vehicles/trailer001a.mdl",
	"models/props_vehicles/car003a_physics.mdl",
	"models/props_vehicles/car003a.mdl",
	"models/props_trainstation/train001.mdl"--]]
}

-- full disclosure: i made a spinoff of homicide called Apocalypse, meant to be my version of Zombie Survival
-- it got really far and is really cool but ultimately i decided to just make ZS a mini gamemode in homicide
-- because homicide is already successful and i was having a hard time making a good ZS without rounds
-- the whole round system stabilizes a game and gives players tangible objectives
-- so there's a lot of borrowed code in here from Apocalypse. I came up with a lot of cool shit in apoc that i imported to here
-- My time was not wasted :D
HMCD_ProjectileJunkModels={
	"models/props_junk/gascan001a.mdl",
	"models/props_junk/metalgascan.mdl",
	"models/props_junk/propanecanister001a.mdl",
	"models/props_interiors/pot01a.mdl",
	"models/props_interiors/pot02a.mdl",
	"models/props_interiors/refrigeratorDoor02a.mdl",
	"models/props_interiors/SinkKitchen01a.mdl",
	"models/props_junk/MetalBucket01a.mdl",
	"models/props_junk/MetalBucket02a.mdl",
	"models/props_junk/sawblade001a.mdl",
	"models/props_junk/TrafficCone001a.mdl",
	"models/props_lab/lockerdoorleft.mdl",
	"models/props_trainstation/TrackSign02.mdl",
	"models/props_vehicles/tire001c_car.mdl",
	"models/props_wasteland/barricade001a.mdl",
	"models/props_wasteland/controlroom_filecabinet001a.mdl",
	"models/props_wasteland/controlroom_chair001a.mdl",
	"models/props_c17/streetsign004f.mdl",
	"models/props_c17/tv_monitor01.mdl",
	"models/props_junk/PlasticCrate01a.mdl",
	"models/props_interiors/Furniture_chair01a.mdl",
	"models/props_interiors/Furniture_chair03a.mdl",
	"models/props_combine/breenglobe.mdl",
	"models/props_junk/watermelon01.mdl",
	"models/props_lab/desklamp01.mdl",
	"models/props_lab/monitor01a.mdl",
	"models/props_lab/monitor02.mdl",
	"models/props_lab/binderbluelabel.mdl",
	"models/props_lab/cactus.mdl",
	"models/props_junk/terracotta01.mdl",
	"models/props_lab/reciever01b.mdl",
	"models/props_lab/citizenradio.mdl",
	"models/props_vehicles/carparts_wheel01a.mdl",
	"models/props_vehicles/carparts_door01a.mdl",
	"models/props_lab/harddrive02.mdl",
	"models/props_lab/harddrive01.mdl",
	"models/props_lab/reciever01d.mdl",
	"models/props_junk/CinderBlock01a.mdl",
	"models/props_junk/metal_paintcan001a.mdl",
	"models/props_junk/metal_paintcan001b.mdl",
	"models/props_c17/suitcase001a.mdl",
	"models/props_c17/suitcase_passenger_physics.mdl",
	"models/props_c17/briefcase001a.mdl",
	"models/props_phx/construct/wood/wood_boardx1.mdl",
	"models/props_phx/construct/wood/wood_panel1x1.mdl",
	"models/props_c17/cashregister01a.mdl",
	"models/props_c17/consolebox03a.mdl",
	
}
HMCD_BigProjectileJunkModels={
	"models/props_borealis/bluebarrel001.mdl",
	"models/props_c17/canister01a.mdl",
	"models/props_c17/canister_propane01a.mdl",
	"models/props_c17/bench01a.mdl",
	"models/props_c17/door01_left.mdl",
	"models/props_c17/FurnitureBathtub001a.mdl",
	"models/props_c17/FurnitureCouch001a.mdl",
	"models/props_c17/FurnitureCouch002a.mdl",
	"models/props_c17/FurnitureDrawer001a.mdl",
	"models/props_c17/FurnitureDresser001a.mdl",
	"models/props_c17/FurnitureFireplace001a.mdl",
	"models/props_c17/FurnitureFridge001a.mdl",
	"models/props_c17/FurnitureRadiator001a.mdl",
	"models/props_c17/furnitureStove001a.mdl",
	"models/props_c17/FurnitureWashingmachine001a.mdl",
	"models/props_c17/oildrum001.mdl",
	"models/props_c17/Lockers001a.mdl",
	"models/props_c17/shelfunit01a.mdl",
	"models/props_combine/breenchair.mdl",
	"models/props_combine/breendesk.mdl",
	"models/props_interiors/BathTub01a.mdl",
	"models/props_interiors/Furniture_Couch01a.mdl",
	"models/props_interiors/Furniture_Couch02a.mdl",
	"models/props_interiors/Furniture_Lamp01a.mdl",
	"models/props_interiors/VendingMachineSoda01a.mdl",
	"models/props_junk/TrashDumpster01a.mdl",
	"models/props_junk/TrashBin01a.mdl",
	"models/props_junk/wood_crate002a.mdl",
	"models/props_junk/wood_crate001a_damaged.mdl",
	"models/props_junk/PushCart01a.mdl",
	"models/props_trainstation/trashcan_indoor001a.mdl",
	"models/props_trainstation/trashcan_indoor001b.mdl",
	"models/props_vehicles/apc_tire001.mdl",
	"models/props_wasteland/barricade002a.mdl",
	"models/props_wasteland/controlroom_filecabinet002a.mdl",
	"models/props_wasteland/controlroom_storagecloset001a.mdl",
	"models/props_wasteland/laundry_cart001.mdl",
	"models/props_wasteland/laundry_cart002.mdl",
	"models/props_wasteland/kitchen_fridge001a.mdl",
	"models/props_wasteland/kitchen_counter001b.mdl",
	"models/props_wasteland/kitchen_shelf001a.mdl",
	"models/props_wasteland/kitchen_stove001a.mdl",
	"models/props_c17/FurnitureWashingmachine001a.mdl",
	"models/props_lab/reciever_cart.mdl"
}

HMCD_LootReplacements={
	["prop_vehicle_jeep"]={"REPLACEVEHICLE",1},
	["prop_vehcle_jeep_old"]={"REPLACEVEHICLE",1},
	["prop_vehicle_airboat"]={"REPLACEVEHICLE",1},
	["weapon_crowbar"]={"ent_jack_hmcd_baseballbat",.5},
	["weapon_stunstick"]={"ent_jack_hmcd_pocketknife",.5},
	["weapon_pistol"]={"ent_jack_hmcd_pistol",.5},
	["weapon_357"]={"ent_jack_hmcd_revolver",.5,true},
	["weapon_shotgun"]={"ent_jack_hmcd_shotgun",.5,true},
	["weapon_crossbow"]={"ent_jack_hmcd_rifle",.5,true},
	["weapon_ar2"]={"ent_jack_hmcd_assaultrifle",.3,true},
	["weapon_smg1"]={"ent_jack_hmcd_assaultrifle",.3,true},
	["weapon_frag"]={"ent_jack_hmcd_pipebomb",.5,true},
	["weapon_slam"]={"ent_jack_hmcd_molotov",.5,true},
	["weapon_rpg"]={"ent_jack_hmcd_ammo",.5,true,"AlyxGun"},
	["item_ammo_ar2_altfire"]={"ent_jack_hmcd_molotov",.5,true},
	["item_ammo_357"]={"ent_jack_hmcd_ammo",.6,true,"357"},
	["item_ammo_357_large"]={"ent_jack_hmcd_ammo",.6,true,"357"},
	["item_ammo_pistol"]={"ent_jack_hmcd_ammo",.6,false,"Pistol"},
	["item_ammo_pistol_large"]={"ent_jack_hmcd_ammo",.6,false,"Pistol"},
	["item_ammo_ar2"]={"ent_jack_hmcd_ammo",.6,false,"AR2"},
	["item_ammo_ar2_large"]={"ent_jack_hmcd_ammo",.6,false,"AR2"},
	["item_ammo_ar2_smg1"]={"ent_jack_hmcd_ammo",.6,false,"SMG1"},
	["item_ammo_ar2_large"]={"ent_jack_hmcd_ammo",.6,false,"AR2"},
	["item_ammo_smg1"]={"ent_jack_hmcd_ammo",.6,false,"SMG1"},
	["item_ammo_smg1_large"]={"ent_jack_hmcd_ammo",.6,false,"SMG1"},
	["item_box_buckshot"]={"ent_jack_hmcd_ammo",.6,false,"Buckshot"},
	["item_box_buckshot_large"]={"ent_jack_hmcd_ammo",.6,false,"Buckshot"},
	["item_rpg_round"]={"ent_jack_hmcd_ammo",.6,true,"AlyxGun"},
	["item_ammo_crate"]={"ent_jack_hmcd_ammo",1,false,"Pistol"},
	["item_healthvial"]={"ent_jack_hmcd_bandage",.5},
	["item_healthkit"]={"ent_jack_hmcd_medkit",.5},
	["item_healthcharger"]={"ent_jack_hmcd_medkit",1},
	["item_suitcharger"]={"ent_jack_hmcd_painpills",1},
	["item_battery"]={"ent_jack_hmcd_painpills",.5}
}

HMCD_AmmoWeights={
	["AlyxGun"]=4,
	["Pistol"]=12,
	["357"]=15,
	["AirboatGun"]=3,
	["Buckshot"]=60,
	["AR2"]=50,
	["SMG1"]=18,
	["XBowBolt"]=22
}

HMCD_AmmoNames={
	["AlyxGun"]=translate.ammoAlyxGun,
	["Pistol"]=translate.ammoPistol,
	["357"]=translate.ammo357,
	["SMG1"]=translate.ammoSMG1,
	["Buckshot"]=translate.ammoBuckshot,
	["AR2"]=translate.ammoAR2,
	["XBowBolt"]=translate.ammoXBowBolt,
	["AirboatGun"]=translate.ammoAirboatGun
	--["Battery"]="14x50mm Alkaline Battery"
	--["StriderMinigun"]="2x50mm Strike-Anywhere Match"
}

HMCD_PlayerModelInfoTable={}
function GM:addModel(model,sex,clothes)
	local t = {}
	t.model = model
	t.sex = sex
	t.clothes=clothes
	table.insert(HMCD_PlayerModelInfoTable,t)
end
GM:addModel("male01", "male",3)
GM:addModel("male02", "male",2)
GM:addModel("male03", "male",4)
GM:addModel("male04", "male",4)
GM:addModel("male05", "male",4)
GM:addModel("male06", "male",0)
GM:addModel("male07", "male",4)
GM:addModel("male08", "male",0)
GM:addModel("male09", "male",2)
GM:addModel("female01", "female",2)
GM:addModel("female02", "female",3)
GM:addModel("female03", "female",3)
GM:addModel("female04", "female",1)
GM:addModel("female05", "female",2)
GM:addModel("female06", "female",4)

-- name = model, bone, male{pos,ang,scale}, female{pos,ang,scale}, is a hat (optional)
HMCD_Accessories={
	["none"]={},
	["eyeglasses"]={"models/captainbigbutt/skeyler/accessories/glasses01.mdl","ValveBiped.Bip01_Head1",{Vector(2.1,3,0),Angle(0,-70,-90),.9},{Vector(2.75,2,0),Angle(0,-70,-90),.8},false,0},
	["bugeye sunglasses"]={"models/captainbigbutt/skeyler/accessories/glasses02.mdl","ValveBiped.Bip01_Head1",{Vector(2.9,2.2,0),Angle(0,-70,-90),.9},{Vector(3.5,1.25,0),Angle(0,-70,-90),.8},false,0},
	["large sunglasses"]={"models/captainbigbutt/skeyler/accessories/glasses04.mdl","ValveBiped.Bip01_Head1",{Vector(3.25,2.4,0),Angle(0,-70,-90),.9},{Vector(3.5,1.25,0),Angle(0,-70,-90),.8},false,0},
	["aviators"]={"models/gmod_tower/aviators.mdl","ValveBiped.Bip01_Head1",{Vector(2.2,2.9,0),Angle(0,-75,-90),.9},{Vector(2.8,1.9,0),Angle(0,-75,-90),.85},false,0},
	["nerd glasses"]={"models/gmod_tower/klienerglasses.mdl","ValveBiped.Bip01_Head1",{Vector(2.6,2.9,0),Angle(0,-75,-90),1},{Vector(2.6,2.3,0),Angle(0,-80,-90),.9},false,0},
	["headphones"]={"models/gmod_tower/headphones.mdl","ValveBiped.Bip01_Head1",{Vector(.5,3,0),Angle(0,-90,-90),.9},{Vector(1,2.3,0),Angle(0,-90,-90),.8},false,0},
	["baseball cap"]={"models/gmod_tower/jaseballcap.mdl","ValveBiped.Bip01_Head1",{Vector(.05,5.1,0),Angle(0,-75,-90),1.125},{Vector(0,4.2,0),Angle(0,-75,-90),1.1},true,0},
	["fedora"]={"models/captainbigbutt/skeyler/hats/fedora.mdl","ValveBiped.Bip01_Head1",{Vector(.25,5.5,0),Angle(0,-75,-90),.7},{Vector(0,4.8,0),Angle(0,-75,-90),.65},true,0},
	["stetson"]={"models/captainbigbutt/skeyler/hats/cowboyhat.mdl","ValveBiped.Bip01_Head1",{Vector(.3,6,0),Angle(0,-70,-90),.75},{Vector(.25,5.6,0),Angle(0,-75,-90),.7},true,0},
	["straw hat"]={"models/captainbigbutt/skeyler/hats/strawhat.mdl","ValveBiped.Bip01_Head1",{Vector(.75,5,0),Angle(0,-75,-90),.85},{Vector(.5,4.5,0),Angle(0,-75,-90),.75},true,0},
	["sun hat"]={"models/captainbigbutt/skeyler/hats/sunhat.mdl","ValveBiped.Bip01_Head1",{Vector(-1.5,3.5,0),Angle(0,-75,-90),.8},{Vector(-1.5,3,0),Angle(0,-75,-90),.75},true,0},
	["bling cap"]={"models/captainbigbutt/skeyler/hats/zhat.mdl","ValveBiped.Bip01_Head1",{Vector(.7,3.75,.3),Angle(0,-75,-90),.75},{Vector(.3,3,.25),Angle(0,-75,-90),.75},true,0},
	["top hat"]={"models/player/items/humans/top_hat.mdl","ValveBiped.Bip01_Head1",{Vector(2,-1,0),Angle(0,-80,-90),1.025},{Vector(2,-1,0),Angle(0,-80,-90),.95},true,0},
	["backpack"]={"models/makka12/bag/jag.mdl","ValveBiped.Bip01_Spine4",{Vector(0,-3,0),Angle(0,90,90),.7},{Vector(.5,-3,0),Angle(0,90,90),.6},false,0},
	["purse"]={"models/props_c17/BriefCase001a.mdl","ValveBiped.Bip01_Spine1",{Vector(-3,-10,7),Angle(0,90,90),.6},{Vector(-3,-10,7),Angle(0,90,90),.6},false,0},
	-- gen 2
	["gray cap"]={"models/modified/hat07.mdl","ValveBiped.Bip01_Head1",{Vector(.1,4.5,.2),Angle(0,-75,-90),1},{Vector(0,4.5,0),Angle(0,-75,-90),.95},true,0},
	["light gray cap"]={"models/modified/hat07.mdl","ValveBiped.Bip01_Head1",{Vector(.1,4.5,.2),Angle(0,-75,-90),1},{Vector(0,4.5,0),Angle(0,-75,-90),.95},true,2},
	["white cap"]={"models/modified/hat07.mdl","ValveBiped.Bip01_Head1",{Vector(.1,4.5,.2),Angle(0,-75,-90),1},{Vector(0,4.5,0),Angle(0,-75,-90),.95},true,3},
	["green cap"]={"models/modified/hat07.mdl","ValveBiped.Bip01_Head1",{Vector(.1,4.5,.2),Angle(0,-75,-90),1},{Vector(0,4.5,0),Angle(0,-75,-90),.95},true,4},
	["dark green cap"]={"models/modified/hat07.mdl","ValveBiped.Bip01_Head1",{Vector(.1,4.5,.2),Angle(0,-75,-90),1},{Vector(0,4.5,0),Angle(0,-75,-90),.95},true,5},
	["brown cap"]={"models/modified/hat07.mdl","ValveBiped.Bip01_Head1",{Vector(.1,4.5,.2),Angle(0,-75,-90),1},{Vector(0,4.5,0),Angle(0,-75,-90),.95},true,6},
	["blue cap"]={"models/modified/hat07.mdl","ValveBiped.Bip01_Head1",{Vector(.1,4.5,.2),Angle(0,-75,-90),1},{Vector(0,4.5,0),Angle(0,-75,-90),.95},true,7},

	["bandana"]={"models/modified/bandana.mdl","ValveBiped.Bip01_Head1",{Vector(1.1,-1.2,0),Angle(0,-75,-90),1},{Vector(1,-1.5,0),Angle(0,-80,-90),.9},false,0},

	["white scarf"]={"models/sal/acc/fix/scarf01.mdl","ValveBiped.Bip01_Spine4",{Vector(-10,-17,0),Angle(0,70,90),1},{Vector(-9,-19.5,0),Angle(0,70,90),1},false,0},
	["gray scarf"]={"models/sal/acc/fix/scarf01.mdl","ValveBiped.Bip01_Spine4",{Vector(-10,-17,0),Angle(0,70,90),1},{Vector(-9,-19.5,0),Angle(0,70,90),1},false,1},
	["black scarf"]={"models/sal/acc/fix/scarf01.mdl","ValveBiped.Bip01_Spine4",{Vector(-10,-17,0),Angle(0,70,90),1},{Vector(-9,-19.5,0),Angle(0,70,90),1},false,2},
	["blue scarf"]={"models/sal/acc/fix/scarf01.mdl","ValveBiped.Bip01_Spine4",{Vector(-10,-17,0),Angle(0,70,90),1},{Vector(-9,-19.5,0),Angle(0,70,90),1},false,3},
	["red scarf"]={"models/sal/acc/fix/scarf01.mdl","ValveBiped.Bip01_Spine4",{Vector(-10,-17,0),Angle(0,70,90),1},{Vector(-9,-19.5,0),Angle(0,70,90),1},false,4},
	["green scarf"]={"models/sal/acc/fix/scarf01.mdl","ValveBiped.Bip01_Spine4",{Vector(-10,-17,0),Angle(0,70,90),1},{Vector(-9,-19.5,0),Angle(0,70,90),1},false,5},
	["pink scarf"]={"models/sal/acc/fix/scarf01.mdl","ValveBiped.Bip01_Spine4",{Vector(-10,-17,0),Angle(0,70,90),1},{Vector(-9,-19.5,0),Angle(0,70,90),1},false,6},

	["red earmuffs"]={"models/modified/headphones.mdl","ValveBiped.Bip01_Head1",{Vector(1,2.5,0),Angle(0,-90,-90),.9},{Vector(1,2,0),Angle(0,-90,-90),.9},false,0},
	["pink earmuffs"]={"models/modified/headphones.mdl","ValveBiped.Bip01_Head1",{Vector(1,2.5,0),Angle(0,-90,-90),.9},{Vector(1,2,0),Angle(0,-90,-90),.9},false,1},
	["green earmuffs"]={"models/modified/headphones.mdl","ValveBiped.Bip01_Head1",{Vector(1,2.5,0),Angle(0,-90,-90),.9},{Vector(1,2,0),Angle(0,-90,-90),.9},false,2},
	["yellow earmuffs"]={"models/modified/headphones.mdl","ValveBiped.Bip01_Head1",{Vector(1,2.5,0),Angle(0,-90,-90),.9},{Vector(1,2,0),Angle(0,-90,-90),.9},false,3},

	["gray fedora"]={"models/modified/hat01_fix.mdl","ValveBiped.Bip01_Head1",{Vector(-.1,4.1,0),Angle(0,-75,-90),.9},{Vector(-.5,4,0),Angle(0,-75,-90),.9},true,0},
	["black fedora"]={"models/modified/hat01_fix.mdl","ValveBiped.Bip01_Head1",{Vector(-.1,4.1,0),Angle(0,-75,-90),.9},{Vector(-.5,4,0),Angle(0,-75,-90),.9},true,1},
	["white fedora"]={"models/modified/hat01_fix.mdl","ValveBiped.Bip01_Head1",{Vector(-.1,4.1,0),Angle(0,-75,-90),.9},{Vector(-.5,4,0),Angle(0,-75,-90),.9},true,2},
	["beige fedora"]={"models/modified/hat01_fix.mdl","ValveBiped.Bip01_Head1",{Vector(-.1,4.1,0),Angle(0,-75,-90),.9},{Vector(-.5,4,0),Angle(0,-75,-90),.9},true,3},
	["black/red fedora"]={"models/modified/hat01_fix.mdl","ValveBiped.Bip01_Head1",{Vector(-.1,4.1,0),Angle(0,-75,-90),.9},{Vector(-.5,4,0),Angle(0,-75,-90),.9},true,5},
	["blue fedora"]={"models/modified/hat01_fix.mdl","ValveBiped.Bip01_Head1",{Vector(-.1,4.1,0),Angle(0,-75,-90),.9},{Vector(-.5,4,0),Angle(0,-75,-90),.9},true,7},

	["striped beanie"]={"models/modified/hat03.mdl","ValveBiped.Bip01_Head1",{Vector(.1,4,0),Angle(0,-75,-90),1},{Vector(-.2,3.5,0),Angle(0,-75,-90),1},true,0},
	["periwinkle beanie"]={"models/modified/hat03.mdl","ValveBiped.Bip01_Head1",{Vector(.1,4,0),Angle(0,-75,-90),1},{Vector(-.2,3.5,0),Angle(0,-75,-90),1},true,1},
	["fuschia beanie"]={"models/modified/hat03.mdl","ValveBiped.Bip01_Head1",{Vector(.1,4,0),Angle(0,-75,-90),1},{Vector(-.2,3.5,0),Angle(0,-75,-90),1},true,2},
	["white beanie"]={"models/modified/hat03.mdl","ValveBiped.Bip01_Head1",{Vector(.1,4,0),Angle(0,-75,-90),1},{Vector(-.2,3.5,0),Angle(0,-75,-90),1},true,3},
	["gray beanie"]={"models/modified/hat03.mdl","ValveBiped.Bip01_Head1",{Vector(.1,4,0),Angle(0,-75,-90),1},{Vector(-.2,3.5,0),Angle(0,-75,-90),1},true,4},

	["large red backpack"]={"models/modified/backpack_1.mdl","ValveBiped.Bip01_Spine4",{Vector(-2,-8,0),Angle(0,90,90),1},{Vector(-2,-8,0),Angle(0,90,90),.9},false,0},
	["large gray backpack"]={"models/modified/backpack_1.mdl","ValveBiped.Bip01_Spine4",{Vector(-2,-8,0),Angle(0,90,90),1},{Vector(-2,-8,0),Angle(0,90,90),.9},false,1},

	["medium backpack"]={"models/modified/backpack_3.mdl","ValveBiped.Bip01_Spine4",{Vector(-3,-6,0),Angle(0,90,90),.9},{Vector(-3,-6,0),Angle(0,90,90),.8},false,0},
	["medium gray backpack"]={"models/modified/backpack_3.mdl","ValveBiped.Bip01_Spine4",{Vector(-3,-6,0),Angle(0,90,90),.9},{Vector(-3,-6,0),Angle(0,90,90),.8},false,1}
}

function table.FullCopy(tab)
	if (!tab) then return nil end
	local res = {}
	for k, v in pairs( tab ) do
		if (type(v) == "table") then
			res[k] = table.FullCopy(v) // recursion ho!
		elseif (type(v) == "Vector") then
			res[k] = Vector(v.x, v.y, v.z)
		elseif (type(v) == "Angle") then
			res[k] = Angle(v.p, v.y, v.r)
		else
			res[k] = v
		end
	end
	return res
end

function GM:CreateTeams()
	team.SetUp(1,translate.teamSpectators,Color(150,150,150))
	team.SetUp(2,translate.teamPlayers,Color(26,120,245))
end

-- you can only sprint forwards, for fuck's sake
function GM:SetupMove(ply,mov,cmd)
	if((CLIENT)and(!ply:Alive())and(ply.ForgiveTime)and(ply.ForgiveTime>CurTime())and(input.IsKeyDown(KEY_F))and not(ply:IsTyping()))then
		net.Start("hmcd_forgive")
		net.SendToServer()
		ply.ForgiveTime=0
	end
end

function GM:EntityEmitSound(t) -- this is so cool for making videos
	local SoundModded=false
	if((t.OriginalSoundName=="Weapon_Shotgun.Special1")and(IsValid(t.Entity))and(t.Entity:IsPlayer()))then -- stupid garry shit
		t.Volume=.01
		SoundModded=true
	end
	--if((CLIENT)and(true))then
	--	PrintTable(t)
	--	t.Volume=1
	--	t.SoundLevel=100
	--	SoundModded=true
	--end
	local p=t.Pitch
	if(game.GetTimeScale()!= 1)then p=p*game.GetTimeScale() end
	if(GetConVarNumber("host_timescale")!=1 && GetConVarNumber("sv_cheats")>= 1)then p=p*GetConVarNumber("host_timescale") end
	if(p!=t.Pitch)then t.Pitch=math.Clamp(p,0,255);SoundModded=true end
	if(CLIENT && engine.GetDemoPlaybackTimeScale()!=1)then t.Pitch=math.Clamp(t.Pitch*engine.GetDemoPlaybackTimeScale(),0,255);SoundModded=true end
	if(SoundModded)then return true end
end

function HMCD_WhomILookinAt(ply,cone,dist)
	local CreatureTr,ObjTr,OtherTr=nil,nil,nil
	for i=1,(150*cone) do
		local Vec=(ply:GetAimVector()+VectorRand()*cone):GetNormalized()
		local Tr=util.QuickTrace(ply:GetShootPos(),Vec*dist,{ply})
		if((Tr.Hit)and not(Tr.HitSky)and(Tr.Entity))then
			local Ent,Class=Tr.Entity,Tr.Entity:GetClass()
			if((Ent:IsPlayer())or(Ent:IsNPC()))then
				CreatureTr=Tr
			elseif((Class=="prop_physics")or(Class=="prop_physics_multiplayer")or(Class=="prop_ragdoll")or(Ent.IsLoot))then
				ObjTr=Tr
			else
				OtherTr=Tr
			end
		end
	end
	if(CreatureTr)then return CreatureTr.Entity,CreatureTr.HitPos,CreatureTr.HitNormal end
	if(ObjTr)then return ObjTr.Entity,ObjTr.HitPos,ObjTr.HitNormal end
	if(OtherTr)then return OtherTr.Entity,OtherTr.HitPos,OtherTr.HitNormal end
	return nil,nil,nil
end

local FragMats={
	"canister","chain","combine_metal","floating_metal_barrel","grenade","metal","metal_barrel","metal_bouncy","Metal_Box",
	"metal_seafloorcar","metalgrate","metalpanel","metalvent","metalvehicle","paintcan","roller","slipperymetal","solidmetal","weapon",
	"glass","combine_glass","computer"
}
function HMCD_ExplosiveType(self)
	-- 1 = inert (default HE), 2 = fragmentary, 3 = incendiary
	if not(IsValid(self))then return 1 end
	local Phys=self:GetPhysicsObject()
	if(IsValid(Phys))then
		if(table.HasValue(HMCD_FlammableModels,string.lower(self:GetModel())))then return 3 end
		local Mass,Volume,Mat,MassRequirement=Phys:GetMass(),Phys:GetVolume(),Phys:GetMaterial(),5
		if((Mat=="weapon")or(Mat=="computer"))then MassRequirement=20 end
		local Density=Mass/(self:OBBMaxs():Length())
		--JackaPrint(Mat,Volume,Mass,Density)
		if((Mass)and(tonumber(Mass))and(Mass>=MassRequirement)and(Mass<=100)and(Volume)and(tonumber(Volume))and(Volume>=300)and(Volume<=30000)and(Density>=.38))then
			if(table.HasValue(FragMats,Mat))then return 2 end
		end
	end
	return 1
end

function HMCD_IsDoor(ent)
	local Class=ent:GetClass()
	return ((Class=="prop_door")or(Class=="prop_door_rotating")or(Class=="func_door")or(Class=="func_door_rotating")or(Class=="func_breakable"))
end

function GM:ShouldCollide(ent1,ent2)
	if(ent1.HmcdGas)then
		return ent2:IsWorld() or HMCD_IsDoor(ent2)
	elseif(ent2.HmcdGas)then
		return ent1:IsWorld() or HMCD_IsDoor(ent1)
	end
end

function GM:OnEntityCreated(ent)
	if(self.ZOMBIE)then
		local Class=ent:GetClass()
		if(SERVER)then
			if((Class=="npc_headcrab")or(Class=="npc_headcrab_fast")or(Class=="npc_headcrab_black"))then
				SafeRemoveEntity(ent)
				return
			elseif(Class=="npc_headcrab_poison")then -- thrown
				timer.Simple(0,function()
					if((IsValid(ent))and(ent:GetVelocity():Length()>200))then
						local Prop=ents.Create("prop_physics")
						Prop:SetModel(table.Random(HMCD_ProjectileJunkModels))
						Prop:SetPos(ent:GetPos())
						Prop:SetAngles(VectorRand():Angle())
						Prop.HmcdSpawned=true
						Prop:Spawn();Prop:Activate()
						local Dir,Spd=ent:GetVelocity():GetNormalized(),ent:GetVelocity():Length()
						Prop:GetPhysicsObject():SetMass(Prop:GetPhysicsObject():GetMass()*2)
						Prop:GetPhysicsObject():AddAngleVelocity(VectorRand()*1000)
						Prop:GetPhysicsObject():SetVelocity((Dir+Vector(math.Rand(-.1,.1),math.Rand(-.1,.1),math.Rand(-.3,-.1)))*Spd*2)
					end
					if(IsValid(ent))then ent:Remove() end
				end)
				return
			end
		elseif(CLIENT)then
			if(Class=="class C_ClientRagdoll")then
				local Mod=ent:GetModel()
				if((Mod=="models/headcrabclassic.mdl")or(Mod=="models/headcrabfast.mdl")or(Mod=="models/headcrabblack.mdl"))then ent:Remove() end
			end
		end
	end
end

function GM:DoAnimationEvent(pl,event,data)
	if((event==PLAYERANIMEVENT_ATTACK_PRIMARY)and(self.ZOMBIE)and(pl.Murderer))then
		pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD,ACT_GMOD_GESTURE_RANGE_ZOMBIE,true)
		return ACT_INVALID
	end
end

function GM:CanPlayerEnterVehicle(ply,veh,role)
	if((self.ZOMBIE)and(ply.Murderer))then return false end
end