if !TeamSpawns then
	TeamSpawns={}
end

function GM:LoadSpawns() 
	local jason=file.ReadDataAndContent("homicide/"..game.GetMap()..".txt")
	if jason then
		local tbl=util.JSONToTable(jason)
		TeamSpawns=tbl
	end
end

function GM:SaveSpawns()

	// ensure the folders are there
	if !file.Exists("homicide/","DATA") then
		file.CreateDir("homicide")
	end

	// JSON!
	local jason=util.TableToJSON(TeamSpawns)
	file.Write("homicide/"..game.GetMap()..".txt",jason)
end

local function getPosPrintString(pos, plyPos) 
	return math.Round(pos.x) .. "," .. math.Round(pos.y) .. "," .. math.Round(pos.z) .. " " .. math.Round(pos:Distance(plyPos)/12) .. "ft"
end

concommand.Add("hmcd_spawn_add", function (ply, com, args, full)
	if(!ply:IsAdmin())then return end

	local spawnList=TeamSpawns
	if !spawnList then
		ply:ChatPrint("Invalid list")
		return
	end

	table.insert(spawnList,ply:GetPos())

	ply:ChatPrint("Added "..#spawnList ..": "..getPosPrintString(ply:GetPos(),ply:GetPos()))

	GAMEMODE:SaveSpawns()
end)