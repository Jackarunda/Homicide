if ( SERVER ) then
	AddCSLuaFile()
else
	killicon.AddFont( "wep_jack_hmcd_shotgun", "HL2MPTypeDeath", "1", Color( 255, 0, 0 ) )
	SWEP.WepSelectIcon=surface.GetTextureID("vgui/wep_jack_hmcd_shotgun")
end
SWEP.Base="wep_jack_hmcd_firearm_base"
SWEP.PrintName		= "Remington 870"
SWEP.Instructions	= "This is a typical civilian pump-action hunting shotgun. It has a 6-round magazine and fires 12-guage 2-3/4 inch cartridges.\n\nLMB to fire.\nRMB to aim.\nRELOAD to reload.\nShot placement counts."
SWEP.Primary.ClipSize			= 6
SWEP.SlotPos=2
SWEP.ViewModel		= "models/weapons/v_shot_m3juper90.mdl"
SWEP.WorldModel		= "models/weapons/w_shot_m3juper90.mdl"
SWEP.ViewModelFlip=false
SWEP.Damage=15
SWEP.NumProjectiles=8
SWEP.Spread=.0285
SWEP.SprintPos=Vector(5,-1,-1)
SWEP.SprintAng=Angle(-20,70,-40)
SWEP.AimPos=Vector(-1.95,-1.5,1.1)
SWEP.ReloadRate=.5
SWEP.AmmoType="Buckshot"
SWEP.AimTime=5
SWEP.BearTime=7
SWEP.TriggerDelay=.1
SWEP.CycleTime=.9
SWEP.Recoil=2
SWEP.Supersonic=false
SWEP.Accuracy=.99
SWEP.HipFireInaccuracy=.15
SWEP.CloseFireSound="snd_jack_hmcd_sht_close.wav"
SWEP.FarFireSound="snd_jack_hmcd_sht_far.wav"
SWEP.CycleSound="snd_jack_hmcd_shotpump.wav"
SWEP.ENT="ent_jack_hmcd_shotgun"
SWEP.MuzzleEffect="pcf_jack_mf_mshotgun"
SWEP.CommandDroppable=true
SWEP.DeathDroppable=true
SWEP.ShellType="ShotgunShellEject"
SWEP.HipHoldType="shotgun"
SWEP.AimHoldType="ar2"
SWEP.DownHoldType="passive"
SWEP.FuckedWorldModel=true
SWEP.ReloadSound="snd_jack_shotguninsert.wav"
SWEP.ReloadType="individual"
SWEP.CycleType="manual"
SWEP.BarrelLength=10
SWEP.HolsterSlot=1
SWEP.HolsterPos=Vector(3.5,0,-4)
SWEP.HolsterAng=Angle(160,5,180)
SWEP.CarryWeight=5000