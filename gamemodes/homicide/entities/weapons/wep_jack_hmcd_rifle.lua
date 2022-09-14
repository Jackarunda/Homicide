if ( SERVER ) then
	AddCSLuaFile()
else
	killicon.AddFont( "wep_jack_hmcd_rifle", "HL2MPTypeDeath", "1", Color( 255, 0, 0 ) )
	SWEP.WepSelectIcon=surface.GetTextureID("vgui/wep_jack_hmcd_rifle")
end
SWEP.Base = "wep_jack_hmcd_firearm_base"
SWEP.PrintName		= translate.weaponrifle
SWEP.Instructions	= translate.weaponrifleDesc
SWEP.Primary.ClipSize			= 5
SWEP.ViewModel		= "models/weapons/v_snip_jwp.mdl"
SWEP.WorldModel		= "models/weapons/w_snip_jwp.mdl"
SWEP.ViewModelFlip=true
SWEP.Damage=115
SWEP.SprintPos=Vector(-9,0,-2)
SWEP.SprintAng=Angle(-20,-60,40)
SWEP.AimPos=Vector(1.95,-3,.5)
SWEP.ReloadTime=6
SWEP.ReloadRate=.75
SWEP.ReloadSound="snd_jack_hmcd_boltreload.wav"
SWEP.CycleSound="snd_jack_hmcd_boltcycle.wav"
SWEP.AmmoType="AR2"
SWEP.TriggerDelay=.2
SWEP.CycleTime=1.2
SWEP.Recoil=1
SWEP.Supersonic=true
SWEP.Accuracy=.9999
SWEP.ShotPitch=100
SWEP.ENT="ent_jack_hmcd_rifle"
SWEP.DeathDroppable=true
SWEP.CommandDroppable=true
SWEP.CycleType="manual"
SWEP.ReloadType="magazine"
SWEP.DrawAnim="awm_draw"
SWEP.FireAnim="awm_fire"
SWEP.ReloadAnim="awm_reload"
SWEP.CloseFireSound="snd_jack_hmcd_snp_close.wav"
SWEP.FarFireSound="snd_jack_hmcd_snp_far.wav"
SWEP.ShellType="RifleShellEject"
SWEP.Scoped=true
SWEP.ScopeFoV=25
SWEP.ScopedSensitivity=.1
SWEP.BarrelLength=18
SWEP.AimTime=9
SWEP.BearTime=9
SWEP.FuckedWorldModel=true
SWEP.HipHoldType="shotgun"
SWEP.AimHoldType="ar2"
SWEP.DownHoldType="passive"
SWEP.MuzzleEffect="pcf_jack_mf_mrifle1"
SWEP.HolsterSlot=1
SWEP.HolsterPos=Vector(3.5,2,-4)
SWEP.HolsterAng=Angle(160,5,180)
SWEP.CarryWeight=5000