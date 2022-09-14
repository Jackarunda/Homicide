//
// Localized ParticleEmitter as it's tied to the player position or input pos. - Josh 'Acecool' Moser
//
--[[ -- none of this works, at all
local META_PLAYER = FindMetaTable( "Player" );
__PARTICLE_EMITTER = __PARTICLE_EMITTER || ParticleEmitter;
function ParticleEmitter( _pos, _use3D )
	print("WHY GARRY WHY")
	// Initialize table
	if ( !__GLOBAL_PARTICLE_EMITTER ) then __GLOBAL_PARTICLE_EMITTER = { }; end

	// Ensure arguments are set or set default
	_pos = ( !_pos ) && self:GetPos( ) || _pos;
	_key = ( !_use3D ) && "use2D" || "use3D";

	// Create or use existing emitter and update the position
	__GLOBAL_PARTICLE_EMITTER[ _key ] = ( !__GLOBAL_PARTICLE_EMITTER[ _key ] || type( __GLOBAL_PARTICLE_EMITTER[ _key ] ) != "CLuaEmitter" ) && __PARTICLE_EMITTER( _pos, _use3D ) || __GLOBAL_PARTICLE_EMITTER[ _key ];
	__GLOBAL_PARTICLE_EMITTER[ _key ]:SetPos( _pos );

	// Return the emitter
	return __GLOBAL_PARTICLE_EMITTER[ _key ];
end

//
// Finish will keep the reference but not destroy the emitter properly.
//
local META_EMITTER = FindMetaTable( "CLuaEmitter" );
if ( !META_EMITTER.__Finish ) then META_EMITTER.__Finish = META_EMITTER.Finish; end
function META_EMITTER:Finish( )
	print("FUCK YOU GARRY")
	// Garbage Collect and nullify vars, and table on Finish.
	if ( __GLOBAL_PARTICLE_EMITTER ) then
		if ( __GLOBAL_PARTICLE_EMITTER.use2D ) then __GLOBAL_PARTICLE_EMITTER.use2D = nil; end
		if ( __GLOBAL_PARTICLE_EMITTER.use3D ) then __GLOBAL_PARTICLE_EMITTER.use3D = nil; end
		__GLOBAL_PARTICLE_EMITTER = nil;
	end

	// Call Original Finish function...
	self:__Finish( );
end
--]]