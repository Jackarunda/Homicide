if ( SERVER ) then
	AddCSLuaFile()
else
	killicon.AddFont( "wep_jack_hmcd_revolver", "HL2MPTypeDeath", "1", Color( 255, 0, 0 ) )
	SWEP.WepSelectIcon=surface.GetTextureID("vgui/wep_jack_hmcd_revolver")
end
SWEP.Base = "wep_jack_hmcd_firearm_base"
SWEP.PrintName		= translate.weaponrevolver
SWEP.Instructions	= translate.weaponrevolverDesc
SWEP.Primary.ClipSize			= 6
SWEP.ViewModel		= "models/weapons/v_pist_jeagle.mdl"
SWEP.WorldModel		= "models/weapons/w_357.mdl"
SWEP.ViewModelFlip=false
SWEP.Damage=40
SWEP.SprintPos=Vector(3,0,-12)
SWEP.SprintAng=Angle(70,0,0)
SWEP.AimPos=Vector(-1.75,0,.4)
SWEP.ReloadTime=5
SWEP.ReloadRate=.5
SWEP.ReloadSound="snd_jack_hmcd_rvreload.wav"
SWEP.AmmoType="357"
SWEP.TriggerDelay=.175
SWEP.CycleTime=.175
SWEP.Recoil=1
SWEP.Supersonic=false
SWEP.Accuracy=.99
SWEP.ShotPitch=90
SWEP.ENT="ent_jack_hmcd_revolver"
SWEP.CommandDroppable=true
SWEP.CycleType="revolving"
SWEP.ReloadType="clip"
SWEP.CustomColor=Color(50,50,50,255)
SWEP.HolsterSlot=2
SWEP.DeathDroppable=true
SWEP.CarryWeight=1500