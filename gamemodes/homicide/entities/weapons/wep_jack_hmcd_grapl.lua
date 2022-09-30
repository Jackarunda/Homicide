if(SERVER)then
	AddCSLuaFile()
elseif(CLIENT)then
	SWEP.DrawAmmo=false
	SWEP.DrawCrosshair=false
	SWEP.ViewModelFOV=65
	SWEP.Slot=2
	SWEP.SlotPos=1
	killicon.AddFont("wep_jack_hmcd_grapl", "HL2MPTypeDeath", "5", Color(0, 0, 255, 255))
	function SWEP:Initialize()
		--wat
	end
	function SWEP:DrawViewModel()	
		return false
	end
	function SWEP:DrawWorldModel()
		self:DrawModel()
	end
	function SWEP:DrawHUD()
		--
	end
end
SWEP.PrintName	= translate.weaponGrapl
-- This was imported from BFS2114
--SWEP.Author		= "Jackarunda :3"
SWEP.Instructions	= translate.weaponGraplDesc
SWEP.Base="weapon_base"
if(CLIENT)then SWEP.WepSelectIcon=surface.GetTextureID("vgui/wep_jack_hmcd_grapl");SWEP.BounceWeaponIcon=false end
SWEP.ViewModel="models/weapons/c_models/c_grappling_hook/c_grappling_hook.mdl"
SWEP.BobScale=3
SWEP.SwayScale=3
SWEP.Weight	= 3
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= false

SWEP.Spawnable			= true
SWEP.AdminOnly			= true

SWEP.Primary.Delay			= 0.5
SWEP.Primary.Recoil			= 3
SWEP.Primary.Damage			= 120
SWEP.Primary.NumShots		= 1	
SWEP.Primary.Cone			= 0.04
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Force			= 900
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= false
SWEP.Primary.Ammo         	= "none"

SWEP.Secondary.Delay		= 0.9
SWEP.Secondary.Recoil		= 0
SWEP.Secondary.Damage		= 0
SWEP.Secondary.NumShots		= 1
SWEP.Secondary.Cone			= 0
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo        ="none"
SWEP.HomicideSWEP=true

SWEP.JustThrew=false
SWEP.ThrowAbility=1.5
SWEP.ThrowChargeSpeed=.15
SWEP.ShowViewModel=true
SWEP.ShowWorldModel=false
SWEP.NextThinkTime=0
SWEP.Moddable=false
SWEP.DrawTime=.5
SWEP.DesiredDist=1000
SWEP.Tight=false
SWEP.NextSpinWhooshTime=0
SWEP.CommandDroppable=true
SWEP.ENT="ent_jack_hmcd_grapl"
SWEP.CarryWeight=2500
function SWEP:SetupDataTables()
	self:NetworkVar("String",0,"CurrentState")
	self:NetworkVar("Float",0,"Hidden")
	self:NetworkVar("Float",1,"Back")
	self:NetworkVar("Float",2,"ThrowPower")
	self:NetworkVar("Float",3,"Spin")
	self:NetworkVar("Bool",0,"ShouldHideWorldModel")
end
function SWEP:Initialize()
	self:SetSpin(0)
	self.NextThinkTime=CurTime()+.01
	self:SetHoldType("normal")
	self:SetCurrentState("Hidden")
	self:SetHidden(100)
	self:SetShouldHideWorldModel(false)
	self.PrintName	= translate.weaponGrapl
	self.Instructions	= translate.weaponGraplDesc
end
function SWEP:OnDrop()
	if(self:GetCurrentState()!="Nothing")then
		local Ent=ents.Create(self.ENT)
		Ent.HmcdSpawned=self.HmcdSpawned
		Ent:SetPos(self:GetPos())
		Ent:SetAngles(self:GetAngles())
		Ent:Spawn()
		Ent:Activate()
		Ent:GetPhysicsObject():SetVelocity(self:GetVelocity()/2)
	end
	if(SERVER)then self:Remove() end
end
function SWEP:PrimaryAttack()
	if(CLIENT)then return end
	self.NextSpinWho0shTime=CurTime()+1
	if(self:GetCurrentState()=="Nothing")then
		if(IsValid(self.GrapplinHook))then
			if not(self.Tight)then
				self.Tight=true
				self:PullTaut()
			else
				self.DesiredDist=math.Clamp(self.DesiredDist-20,50,5000)
				local Tr=util.QuickTrace(self.Owner:GetShootPos(),self.Owner:GetAimVector()*60,{self.Owner})
				if(Tr.Hit)then
					self.Owner:SetVelocity(-self.Owner:GetAimVector()*300)
				end
			end
			HMCD_StaminaPenalize(self.Owner,4)
			-- sound.Play("snds_jack_clothmove/"..math.random(1,9)..".wav",self.Owner:GetPos(),70,math.random(90,110))
			self.Owner:DoAnimationEvent(ACT_GMOD_GESTURE_MELEE_SHOVE_1HAND)
			self.Owner:ViewPunch(Angle(-1,0,0))
		end
		self:SetNextPrimaryFire(CurTime()+.2)
	end
end
function SWEP:PullTaut()
	self.DesiredDist=(self.Owner:GetPos()-self.GrapplinHook:GetPos()):Length()+50
	self.GrapplinHook:GetPhysicsObject():SetVelocity(self.Owner:GetVelocity())
end
function SWEP:SecondaryAttack()
	if(CLIENT)then return end
	if(self:GetCurrentState()=="Nothing")then
		if(IsValid(self.GrapplinHook))then
			self.DesiredDist=math.Clamp(self.DesiredDist+50,10,4000)
			HMCD_StaminaPenalize(self.Owner,2)
			-- sound.Play("snds_jack_clothmove/"..math.random(1,9)..".wav",self.Owner:GetPos(),70,math.random(90,110))
			self.Owner:ViewPunch(Angle(-1,0,0))
		end
		self:SetNextSecondaryFire(CurTime()+.25)
	end
end
function SWEP:Reload()
	if(self:GetCurrentState()=="Nothing")then
		self:Deploy()
		self.GrapplinHook=nil
		if((self.Rope)and(self.Rope.Remove)and(IsValid(self.Rope))and(SERVER))then self.Rope:Remove() end
		self.Rope=nil
		self:SetHoldType("normal")
		if(SERVER)then self:Remove() end
	end
end
function SWEP:Think()
	local Time=CurTime()
	if(self.NextThinkTime<=Time)then
		self.NextThinkTime=Time+.025
		local State=self:GetCurrentState()
		if not(State=="Nothing")then
			local Sprintin=self.Owner:KeyDown(IN_SPEED)
			local HiddenAmt=self:GetHidden()
			local BackAmt=self:GetBack()
			if(State=="Idling")then
				if(self.Owner:KeyDown(IN_ATTACK))then
					self:Windup()
				end
			elseif(State=="Hidden")then
				if(math.random(1,19)==18)then
					self.Owner:ViewPunch(Angle(1,0,0))
					-- local Nam,Vol,Pit="snds_jack_clothmove/"..math.random(1,9)..".wav",65,math.random(90,110)
					-- self.Weapon:EmitSound(Nam,Vol,Pit)
				end
			elseif(State=="Drawing")then
				self:SetHidden(math.Clamp(HiddenAmt-10/self.DrawTime,0,100))
				if(HiddenAmt<=0)then self:SetCurrentState("Idling") end
			elseif((State=="Winding")and not(self.JustThrew))then
				self:SetHoldType("Grenade")
				if not(self.Owner:KeyDown(IN_ATTACK))then
					if(self:GetThrowPower()>5)then
						self:SetCurrentState("Drawing")
						self:SetHidden(100)
						self:SetBack(0)
						self:Throw()
						return
					end
				end
				self:SetBack(math.Clamp(BackAmt+15,0,100))
				self:SetThrowPower(math.Clamp(self:GetThrowPower()+9*self.ThrowChargeSpeed,1,130))
			end
		end
		self:CustomThink(State,Sprintin,HiddenAmt,BackAmt)
	end
	self:NextThink(Time+.025)
	return true
end
function SWEP:Windup()
	if(self:GetCurrentState()=="Winding")then return end
	self:SetCurrentState("Winding")
	self:SetThrowPower(1)
	self.JustThrew=false
	--self:SetHoldType("grenade")
	self:CustomWindup()
end
function SWEP:Throw()
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	if(CLIENT)then return end
	self.JustThrew=true
	self:SetCurrentState("Nothing")
	self:SetShouldHideWorldModel(true)
	self.DesiredDist=2000
	self.Tight=false
	local Vec=self.Owner:GetAimVector()
	local Pos=self.Owner:GetShootPos()
	local ThrowPos=Pos+Vec*30
	local Tr=util.QuickTrace(Pos,Vec*35,{self.Owner})
	if(Tr.Hit)then ThrowPos=Pos+Vec*10 end
	sound.Play("weapons/slam/throw.wav",self:GetPos(),75,80)
	sound.Play("weapons/slam/throw.wav",self:GetPos(),70,80)
	sound.Play("weapons/slam/throw.wav",self:GetPos(),65,80)
	local Gr=ents.Create("ent_jack_hmcd_grapl")
	Gr.HmcdSpawned=self.HmcdSpawned
	Gr:SetPos(ThrowPos)
	Gr.Owner=self.Owner
	Gr:SetAngles(VectorRand():Angle())
	Gr:Spawn()
	Gr:Activate()
	Gr.Rope=self
	self.GrapplinHook=Gr
	-- JIBFS.CloakPenalize(self.Owner)
	Gr:GetPhysicsObject():SetVelocity(self.Owner:GetVelocity()+Vec*self:GetThrowPower()*6*self.ThrowAbility)
	Gr:SetPhysicsAttacker(self.Owner)
	timer.Simple(.5,function()
		if(IsValid(self))then self:SetHoldType("melee2") end
	end)
	if((self.Rope)and(self.Rope.Remove)and(SERVER))then self.Rope:Remove() end
	self.Rope=self:CollisionlessKeyFrameRope(self.Owner,self.GrapplinHook,Vector(0,0,10),Vector(0,0,0),1000,2,"cable/rope")
end
function SWEP:CollisionlessKeyFrameRope(Ent1,Ent2,LPos1,LPos2,length,width,material)
	if (width<=0) then return nil end
	width=math.Clamp(width,1,100)
	local rope=ents.Create("keyframe_rope")
	rope:SetPos(Ent1:GetPos())
	rope:SetKeyValue("Width",width)
	if(material)then rope:SetKeyValue("RopeMaterial",material) end
	rope:SetEntity("StartEntity",Ent1)
	rope:SetKeyValue("StartOffset",tostring(LPos1))
	rope:SetKeyValue("StartBone",0)
	rope:SetEntity("EndEntity",Ent2)
	rope:SetKeyValue("EndOffset",tostring(LPos2))
	rope:SetKeyValue("EndBone",0)
	local kv={
		Length=length,
		Collide=0
	}
	for k,v in pairs(kv)do
		rope:SetKeyValue(k,tostring(v))
	end
	rope:Spawn()
	rope:Activate()
	Ent1:DeleteOnRemove(rope)
	Ent2:DeleteOnRemove(rope)
	return rope
end
function SWEP:OnRemove()
	if(IsValid(self.Owner) && CLIENT && self.Owner:IsPlayer())then
		local vm=self.Owner:GetViewModel()
		if(IsValid(vm)) then vm:SetMaterial("");vm:SetColor(Color(255,255,255,255)) end
	end
	if((self.Rope)and(self.Rope.Remove)and(IsValid(self.Rope))and(SERVER))then self.Rope:Remove() end
	if((self.Owner)and(IsValid(self.Owner))and(self.Owner.SelectWeapon))then
		self.Owner:SelectWeapon("wep_jack_hmcd_hands")
	end
end
function SWEP:Holster()
	if((self:GetCurrentState()=="Idling")or(self:GetCurrentState()=="Hidden"))then
		if(IsValid(self.Owner) && CLIENT && self.Owner:IsPlayer())then
			local vm=self.Owner:GetViewModel()
			if(IsValid(vm)) then vm:SetMaterial("");vm:SetColor(Color(255,255,255,255)) end
		end
		return true
	else
		return false
	end
end
function SWEP:Deploy()
	self:HideThenDraw(self.DrawTime)
	self:SetNextPrimaryFire(CurTime()+self.DrawTime+self.Owner:GetViewModel():SequenceDuration())
	self:SetNextSecondaryFire(CurTime()+self.DrawTime+self.Owner:GetViewModel():SequenceDuration())
	self:SetShouldHideWorldModel(false)
end
function SWEP:HideThenDraw(num)
	self:SetHidden(100)
	self:SetCurrentState("Hidden")
	-- self.Weapon:EmitSound("snds_jack_equipmentfumble/"..math.random(1,10)..".wav",70,math.random(80,120))
	timer.Simple(num,function()
		if(IsValid(self))then
			-- self.Weapon:EmitSound("snds_jack_clothmove/"..math.random(1,9)..".wav",70,math.random(90,110))
			self:SetCurrentState("Drawing")
			self:CustomFinishedDrawing()
		end
	end)
end
function SWEP:CustomFinishedDrawing()
	-- wat
end
function SWEP:Fail()
	sound.Play("weapons/slam/throw.wav",self:GetPos(),75,110)
	sound.Play("weapons/slam/throw.wav",self:GetPos(),70,110)
	sound.Play("weapons/slam/throw.wav",self:GetPos(),65,110)
	self.Owner:ViewPunch(VectorRand():Angle())
	self:Reload()
end
function SWEP:CustomThink(State,Sprintin,HiddenAmt,BackAmt)
	if(CLIENT)then return end
	if(IsValid(self.GrapplinHook))then
		local Vec,Vel=self.GrapplinHook:GetPos()-(self.Owner:GetPos()+Vector(0,0,-50)),self.Owner:GetVelocity()
		local Dir=Vec:GetNormalized()
		local Dist=Vec:Length()
		local EffDist=Dist-self.DesiredDist
		local RelVel=self.GrapplinHook:GetPhysicsObject():GetVelocity()-Vel
		if(EffDist>0)then
			local LinearVelocity,Ground=(Dir:Dot(Vel))*Dir,self.Owner:IsOnGround()
			self.Owner:SetGroundEntity(nil)
			self.Owner:SetVelocity(Dir*math.Clamp(EffDist*10,0,150)-LinearVelocity/2)
			self.GrapplinHook:GetPhysicsObject():ApplyForceCenter(-Dir*EffDist*100-self.GrapplinHook:GetPhysicsObject():GetVelocity()/40)
			if((EffDist>20)and not(Ground)and(RelVel:Length()>1200))then
				self:Fail()
				return
			end
		end
		if(self.Rope)then
			self.Rope:Fire("SetLength",self.DesiredDist+10)
		end
	elseif(State=="Nothing")then
		self:Reload()
	elseif(State=="Winding")then
		if(self.NextSpinWhooshTime<CurTime())then
			local Pow=self:GetThrowPower()
			self.NextSpinWhooshTime=CurTime()+math.Clamp((10/Pow),.3,1.25)
			sound.Play("weapons/slam/throw.wav",self:GetPos(),65,math.Clamp(Pow,60,130))
			self.Owner:ViewPunch(Angle(-1,0,0))
		end
		if(SERVER)then
			local Spun=self:GetSpin()+25
			if(Spun>360)then Spun=0 end
			self:SetSpin(Spun)
		end
	end
end
function SWEP:CustomWindup()
	-- no
end
if(CLIENT)then
	function SWEP:PreDrawViewModel(vm,ply,wep)
		vm:SetMaterial("models/shiny")
		vm:SetColor(Color(10,10,10,255))
	end
	local DownAmt=10
	function SWEP:GetViewModelPosition(pos,ang)
		if(self.Owner:KeyDown(IN_SPEED))then
			DownAmt=math.Clamp(DownAmt+.6,0,50)
		else
			DownAmt=math.Clamp(DownAmt-.6,0,50)
		end
		if((self:GetCurrentState()=="Nothing")or(self:GetCurrentState()=="Winding"))then DownAmt=DownAmt+10 end
		pos=pos+ang:Forward()*30+ang:Right()*15-ang:Up()*(15+DownAmt)
		return pos,ang
	end
	local TheMat=Material("cable/rope")
	function SWEP:DrawWorldModel()
		if not(self:GetCurrentState()=="Nothing")then
			local Pos,Ang=self.Owner:GetBonePosition(self.Owner:LookupBone("ValveBiped.Bip01_R_Hand"))
			if(self.DatWorldModel)then
				if((Pos)and(Ang)and(GAMEMODE:ShouldDrawWeaponWorldModel(self)))then
					local ThePos=Pos+Ang:Forward()*4+Ang:Right()-Ang:Up()*0
					Ang:RotateAroundAxis(Ang:Forward(),90)
					if(self:GetCurrentState()=="Winding")then
						Ang:RotateAroundAxis(Ang:Forward(),self:GetSpin())
						ThePos=ThePos+Ang:Up()*30
						render.SetMaterial(TheMat)
						local Col=render.GetAmbientLightColor(ThePos)
						render.DrawBeam(Pos,ThePos,2,1,0,Color(Col.r*255,Col.g*255,Col.b*255,255))
					else
						Ang:RotateAroundAxis(Ang:Forward(),90)
					end
					self.DatWorldModel:SetRenderOrigin(ThePos)
					self.DatWorldModel:SetRenderAngles(Ang)
					--local Mat=Matrix()
					--Mat:Scale(Vector(.9,.4,.9))
					--self.DatWorldModel:EnableMatrix("RenderMultiply",Mat)
					local R,G,B=render.GetColorModulation()
					render.SetColorModulation(.1,.1,.1)
					self.DatWorldModel:DrawModel()
					render.SetColorModulation(R,G,B)
				end
			else
				self.DatWorldModel=ClientsideModel("models/weapons/c_models/c_grappling_hook/c_grappling_hook.mdl")
				self.DatWorldModel:SetMaterial("models/shiny")
				self.DatWorldModel:SetColor(Color(10,10,10,255))
				self.DatWorldModel:SetModelScale(.8,0)
				self.DatWorldModel:SetPos(self:GetPos())
				self.DatWorldModel:SetParent(self)
				self.DatWorldModel:SetNoDraw(true)
			end
		end
	end
end