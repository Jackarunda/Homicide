if ( SERVER ) then
	AddCSLuaFile()
else
	killicon.AddFont( "wep_jack_hmcd_pistol", "HL2MPTypeDeath", "1", Color( 255, 0, 0 ) )
end
SWEP.Base = "wep_jack_hmcd_smallpistol"
SWEP.PrintName		= translate.weaponpistol
SWEP.Instructions	= translate.weaponpistolDesc
SWEP.Primary.ClipSize			= 13
SWEP.ENT="ent_jack_hmcd_pistol"
SWEP.CustomColor=Color(50,50,50,255)
SWEP.HolsterSlot=2
SWEP.DeathDroppable=true
SWEP.CloseFireSound="snd_jack_hmcd_smp_close.wav"
SWEP.FarFireSound="snd_jack_hmcd_smp_far.wav"
SWEP.CarryWeight=1200