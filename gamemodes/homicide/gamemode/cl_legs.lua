-- imported from BFS2114
if(CLIENT)then
	local HMCD_Legs={}
	HMCD_Legs.LegEnt=nil
	function HMCD_Legs:ShouldDrawLegs()
		local ply=LocalPlayer()
		return IsValid(HMCD_Legs.LegEnt) and
		(ply:Alive() or (ply.IsGhosted and ply:IsGhosted()))and
		!HMCD_Legs:CheckDrawVehicle() and
		GetViewEntity()==ply and
		!ply:ShouldDrawLocalPlayer() and
		!ply:GetObserverTarget()
	end
	function HMCD_Legs:GetPlayerLegs(ply)
		local Ply=LocalPlayer()
		return ply and ply!=Ply and ply or (self:ShouldDrawLegs() and HMCD_Legs.LegEnt or Ply)
	end
	HMCD_Legs.FixedModelNames={
		["models/humans/group01/female_06.mdl"]="models/player/group01/female_06.mdl",
		["models/humans/group01/female_01.mdl"]="models/player/group01/female_01.mdl",
		["models/alyx.mdl"]="models/player/alyx.mdl",
		["models/humans/group01/female_07.mdl"]="models/player/group01/female_07.mdl",
		["models/charple01.mdl"]="models/player/charple01.mdl",
		["models/humans/group01/female_04.mdl"]="models/player/group01/female_04.mdl",
		["models/humans/group03/female_06.mdl"]="models/player/group03/female_06.mdl",
		["models/gasmask.mdl"]="models/player/gasmask.mdl",
		["models/humans/group01/female_02.mdl"]="models/player/group01/female_02.mdl",
		["models/gman_high.mdl"]="models/player/gman_high.mdl",
		["models/humans/group03/male_07.mdl"]="models/player/group03/male_07.mdl",
		["models/humans/group03/female_03.mdl"]="models/player/group03/female_03.mdl",
		["models/police.mdl"]="models/player/police.mdl",
		["models/breen.mdl"]="models/player/breen.mdl",
		["models/humans/group01/male_01.mdl"]="models/player/group01/male_01.mdl",
		["models/zombie_soldier.mdl"]="models/player/zombie_soldier.mdl",
		["models/humans/group01/male_03.mdl"]="models/player/group01/male_03.mdl",
		["models/humans/group03/female_04.mdl"]="models/player/group03/female_04.mdl",
		["models/humans/group01/male_02.mdl"]="models/player/group01/male_02.mdl",
		["models/kleiner.mdl"]="models/player/kleiner.mdl",
		["models/humans/group03/female_01.mdl"]="models/player/group03/female_01.mdl",
		["models/humans/group01/male_09.mdl"]="models/player/group01/male_09.mdl",
		["models/humans/group03/male_04.mdl"]="models/player/group03/male_04.mdl",
		["models/player/urban.mbl"]="models/player/urban.mdl",
		["models/humans/group03/male_01.mdl"]="models/player/group03/male_01.mdl",
		["models/mossman.mdl"]="models/player/mossman.mdl",
		["models/humans/group01/male_06.mdl"]="models/player/group01/male_06.mdl",
		["models/humans/group03/female_02.mdl"]="models/player/group03/female_02.mdl",
		["models/humans/group01/male_07.mdl"]="models/player/group01/male_07.mdl",
		["models/humans/group01/female_03.mdl"]="models/player/group01/female_03.mdl",
		["models/humans/group01/male_08.mdl"]="models/player/group01/male_08.mdl",
		["models/humans/group01/male_04.mdl"]="models/player/group01/male_04.mdl",
		["models/humans/group03/female_07.mdl"]="models/player/group03/female_07.mdl",
		["models/humans/group03/male_02.mdl"]="models/player/group03/male_02.mdl",
		["models/humans/group03/male_06.mdl"]="models/player/group03/male_06.mdl",
		["models/barney.mdl"]="models/player/barney.mdl",
		["models/humans/group03/male_03.mdl"]="models/player/group03/male_03.mdl",
		["models/humans/group03/male_05.mdl"]="models/player/group03/male_05.mdl",
		["models/odessa.mdl"]="models/player/odessa.mdl",
		["models/humans/group03/male_09.mdl"]="models/player/group03/male_09.mdl",
		["models/humans/group01/male_05.mdl"]="models/player/group01/male_05.mdl",
		["models/humans/group03/male_08.mdl"]="models/player/group03/male_08.mdl",
		["models/monk.mdl"]="models/player/monk.mdl",
		["models/eli.mdl"]="models/player/eli.mdl",
		["models/voxelzero/player/odst.mdl"]="models/voxelzero/player/jdst.mdl"
	}
	function HMCD_Legs:FixModelName(mdl)
		mdl=mdl:lower()
		return self.FixedModelNames[mdl] or mdl
	end
	function HMCD_Legs:SetUp()
		local ply=LocalPlayer()
		self.LegEnt=ClientsideModel(HMCD_Legs:FixModelName(ply:GetModel()),RENDER_GROUP_OPAQUE_ENTITY)
		self.LegEnt:SetNoDraw(true)
		self.LegEnt:SetSkin(ply:GetInfoNum("cl_playerskin",0))
		self.LegEnt:SetMaterial(ply:GetMaterial())
		self.LegEnt:SetColor(ply:GetColor())
		local groups=ply:GetInfo("cl_playerbodygroups")
		if(groups==nil)then groups="" end
		local groups=string.Explode(" ",groups)
		for k=0,ply:GetNumBodyGroups()-1 do
			self.LegEnt:SetBodygroup(k,tonumber(groups[k+1]) or 0)
		end
		self.LegEnt.GetPlayerColor=function() 
			return Vector(GetConVarString("cl_playercolor")) 
		end
		self.LegEnt.LastTick=0
	end
	HMCD_Legs.PlaybackRate=1
	HMCD_Legs.Sequence=nil
	HMCD_Legs.Velocity=0
	HMCD_Legs.OldWeapon=nil
	HMCD_Legs.HoldType=nil
	HMCD_Legs.BoneHoldTypes={["none"]={
			"ValveBiped.Bip01_Head1",
			"ValveBiped.Bip01_Neck1",
			"ValveBiped.Bip01_Spine4",
			"ValveBiped.Bip01_Spine2",
		},
		["default"]={
			"ValveBiped.Bip01_Head1",
			"ValveBiped.Bip01_Neck1",
			"ValveBiped.Bip01_Spine4",
			"ValveBiped.Bip01_Spine2",
			"ValveBiped.Bip01_L_Hand",
			"ValveBiped.Bip01_L_Forearm",
			"ValveBiped.Bip01_L_Upperarm",
			"ValveBiped.Bip01_L_Clavicle",
			"ValveBiped.Bip01_R_Hand",
			"ValveBiped.Bip01_R_Forearm",
			"ValveBiped.Bip01_R_Upperarm",
			"ValveBiped.Bip01_R_Clavicle",
			"ValveBiped.Bip01_L_Finger4",
			"ValveBiped.Bip01_L_Finger41",
			"ValveBiped.Bip01_L_Finger42",
			"ValveBiped.Bip01_L_Finger3",
			"ValveBiped.Bip01_L_Finger31",
			"ValveBiped.Bip01_L_Finger32",
			"ValveBiped.Bip01_L_Finger2",
			"ValveBiped.Bip01_L_Finger21",
			"ValveBiped.Bip01_L_Finger22",
			"ValveBiped.Bip01_L_Finger1",
			"ValveBiped.Bip01_L_Finger11",
			"ValveBiped.Bip01_L_Finger12",
			"ValveBiped.Bip01_L_Finger0",
			"ValveBiped.Bip01_L_Finger01",
			"ValveBiped.Bip01_L_Finger02",
			"ValveBiped.Bip01_R_Finger4",
			"ValveBiped.Bip01_R_Finger41",
			"ValveBiped.Bip01_R_Finger42",
			"ValveBiped.Bip01_R_Finger3",
			"ValveBiped.Bip01_R_Finger31",
			"ValveBiped.Bip01_R_Finger32",
			"ValveBiped.Bip01_R_Finger2",
			"ValveBiped.Bip01_R_Finger21",
			"ValveBiped.Bip01_R_Finger22",
			"ValveBiped.Bip01_R_Finger1",
			"ValveBiped.Bip01_R_Finger11",
			"ValveBiped.Bip01_R_Finger12",
			"ValveBiped.Bip01_R_Finger0",
			"ValveBiped.Bip01_R_Finger01",
			"ValveBiped.Bip01_R_Finger02"
		},
		["vehicle"]={
			"ValveBiped.Bip01_Head1",
			"ValveBiped.Bip01_Neck1",
			"ValveBiped.Bip01_Spine4",
			"ValveBiped.Bip01_Spine2",
		}
	}
	HMCD_Legs.BonesToRemove={}
	HMCD_Legs.BoneMatrix=nil
	function HMCD_Legs:WeaponChanged(weap)
		if IsValid(self.LegEnt) then
			if IsValid(weap) then
				self.HoldType=weap:GetHoldType()
			else
				self.HoldType="none"
			end
			for boneId=0,self.LegEnt:GetBoneCount() do
				self.LegEnt:ManipulateBoneScale(boneId,Vector(1,1,1))
				self.LegEnt:ManipulateBonePosition(boneId,Vector(0,0,0))
			end
			HMCD_Legs.BonesToRemove={
				"ValveBiped.Bip01_Head1"
			}
			if !LocalPlayer():InVehicle() then
				HMCD_Legs.BonesToRemove=HMCD_Legs.BoneHoldTypes[HMCD_Legs.HoldType] or HMCD_Legs.BoneHoldTypes["default"]
			else
				HMCD_Legs.BonesToRemove=HMCD_Legs.BoneHoldTypes["vehicle"]
			end
			for _, v in pairs( HMCD_Legs.BonesToRemove ) do
				local boneId=self.LegEnt:LookupBone(v)
				if boneId then
					self.LegEnt:ManipulateBoneScale(boneId, vector_origin)
					self.LegEnt:ManipulateBonePosition(boneId, Vector(-10,-10,0))
				end
			end
		end
	end
	HMCD_Legs.BreathScale=0.5
	HMCD_Legs.NextBreath=0
	function HMCD_Legs:Think(maxseqgroundspeed)
		local ply=LocalPlayer()
		local PlyMdl=self:FixModelName(ply:GetModel())
		if not ply:Alive() then
			HMCD_Legs:SetUp()
			return;
		end
		if IsValid(self.LegEnt) then
			if ply:GetActiveWeapon()!=self.OldWeapon then
				self.OldWeapon=ply:GetActiveWeapon()
				self:WeaponChanged(self.OldWeapon)
			end
			if self.LegEnt:GetModel()!=PlyMdl then
				self.LegEnt:SetModel(PlyMdl)
			end
			self.LegEnt:SetMaterial(ply:GetMaterial())
			self.LegEnt:SetSkin(ply:GetSkin())
			self.Velocity=ply:GetVelocity():Length2D()
			self.PlaybackRate=1
			if self.Velocity>.5 then
				if maxseqgroundspeed<.001 then
					self.PlaybackRate=.01
				else
					self.PlaybackRate=self.Velocity/maxseqgroundspeed
					self.PlaybackRate=math.Clamp(self.PlaybackRate,.01,10)
				end
			end
			self.LegEnt:SetPlaybackRate(self.PlaybackRate)
			self.Sequence=ply:GetSequence()
			if (self.LegEnt.Anim!=self.Sequence) then
				self.LegEnt.Anim=self.Sequence
				self.LegEnt:ResetSequence(self.Sequence)
			end
			self.LegEnt:FrameAdvance(CurTime()-self.LegEnt.LastTick)
			self.LegEnt.LastTick=CurTime()
			HMCD_Legs.BreathScale=.5
			if HMCD_Legs.NextBreath<=CurTime() then
				HMCD_Legs.NextBreath=CurTime()+1.95/HMCD_Legs.BreathScale
				self.LegEnt:SetPoseParameter("breathing",HMCD_Legs.BreathScale)
			end
			self.LegEnt:SetPoseParameter("move_x",(ply:GetPoseParameter("move_x")*2)-1)
			self.LegEnt:SetPoseParameter("move_y",(ply:GetPoseParameter("move_y")*2)-1)
			self.LegEnt:SetPoseParameter("move_yaw",(ply:GetPoseParameter("move_yaw")*360)-180)
			self.LegEnt:SetPoseParameter("body_yaw",(ply:GetPoseParameter("body_yaw" )*180)-90)
			self.LegEnt:SetPoseParameter("spine_yaw",(ply:GetPoseParameter("spine_yaw")*180)-90)
			if(LocalPlayer():InVehicle())then
				self.LegEnt:SetColor(color_transparent)
				self.LegEnt:SetPoseParameter("vehicle_steer",(ply:GetVehicle():GetPoseParameter("vehicle_steer")*2)-1)
			end
		end
	end
	hook.Add("UpdateAnimation","HMCD_Legs_UpdateAnimation",function(ply,velocity,maxseqgroundspeed)
		if ply==LocalPlayer() then
			if IsValid(HMCD_Legs.LegEnt) then
				HMCD_Legs:Think(maxseqgroundspeed)
			else
				HMCD_Legs:SetUp()
			end
		end
	end)
	HMCD_Legs.RenderAngle=nil
	HMCD_Legs.BiaisAngle=nil
	HMCD_Legs.RadAngle=nil
	HMCD_Legs.RenderPos=nil
	HMCD_Legs.RenderColor={}
	HMCD_Legs.ClipVector=vector_up*-1
	HMCD_Legs.ForwardOffset=-24
	function HMCD_Legs:CheckDrawVehicle()
		return LocalPlayer():InVehicle()
	end
	function GM:RenderLegs(ply)
		local ply=LocalPlayer()
		cam.Start3D(EyePos(),EyeAngles())
			if HMCD_Legs:ShouldDrawLegs() then
				HMCD_Legs.RenderPos=ply:GetPos()
				if ply:InVehicle() then
					HMCD_Legs.RenderAngle=LocalPlayer():GetVehicle():GetAngles()
					HMCD_Legs.RenderAngle:RotateAroundAxis( HMCD_Legs.RenderAngle:Up(), 90 )
				else
					HMCD_Legs.BiaisAngles=ply:EyeAngles()
					HMCD_Legs.RenderAngle=Angle(0,HMCD_Legs.BiaisAngles.y,0)
					HMCD_Legs.RadAngle=math.rad(HMCD_Legs.BiaisAngles.y)
					HMCD_Legs.ForwardOffset=-20
					HMCD_Legs.RenderPos.x=HMCD_Legs.RenderPos.x+math.cos(HMCD_Legs.RadAngle)*HMCD_Legs.ForwardOffset
					HMCD_Legs.RenderPos.y=HMCD_Legs.RenderPos.y+math.sin(HMCD_Legs.RadAngle)*HMCD_Legs.ForwardOffset
					if ply:GetGroundEntity()==NULL then
						HMCD_Legs.RenderPos.z=HMCD_Legs.RenderPos.z+8
						if ply:KeyDown(IN_DUCK) then
							HMCD_Legs.RenderPos.z=HMCD_Legs.RenderPos.z-28
						end
					end
				end
				HMCD_Legs.RenderColor=ply:GetColor()
				local bEnabled=render.EnableClipping(true)
					render.PushCustomClipPlane(HMCD_Legs.ClipVector,HMCD_Legs.ClipVector:Dot(EyePos())) 
						render.SetColorModulation(HMCD_Legs.RenderColor.r/255,HMCD_Legs.RenderColor.g/255,HMCD_Legs.RenderColor.b/255)
							render.SetBlend(HMCD_Legs.RenderColor.a/255)
								hook.Call("HMCD_PreLegsDraw",GAMEMODE,HMCD_Legs.LegEnt)	   
									HMCD_Legs.LegEnt:SetRenderOrigin(HMCD_Legs.RenderPos)
									HMCD_Legs.LegEnt:SetRenderAngles(HMCD_Legs.RenderAngle)
									HMCD_Legs.LegEnt:SetupBones()
									HMCD_Legs.LegEnt:DrawModel()
									HMCD_Legs.LegEnt:SetRenderOrigin()
									HMCD_Legs.LegEnt:SetRenderAngles()
								hook.Call("HMCD_PostLegsDraw",GAMEMODE,HMCD_Legs.LegEnt)
							render.SetBlend(1)
						render.SetColorModulation(1,1,1)
					render.PopCustomClipPlane()
				render.EnableClipping(bEnabled)
			end
		cam.End3D()
	end
	--hook.Add("RenderScreenspaceEffects","HMCD_Legs",LegsRenderFunction)
end