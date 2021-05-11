player(response)
{
	self endon ( "disconnect" );
	if( int(response) <= 35 )
	{
		spray = int(response)-1;
		if( self maps\mp\gametypes\_rank::isSprayUnlocked( spray ) )
		{
			self setStat( 979, spray );
			self setClientDvar( "drui_spray", spray );
		}
	}	
	if( int(response) > 35 )
	{
		character = int(response)-41;
		if( self maps\mp\gametypes\_rank::isCharacterUnlocked( character ) )
		{
			self setStat( 980, character );
			self setClientDvar( "drui_character", character );
			self iprintln("You have selected skin: ^1"+character);
		}
	}
}