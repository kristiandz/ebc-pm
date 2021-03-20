player(response)
{
	self endon ( "disconnect" );
	
	if( int(response) < 6)
	{
		spray = int(response);
		if( self maps\mp\gametypes\_rank::isASprayUnlocked( spray ) )
		{
			spray = (spray+29);
			self setStat( 979, spray );
			self setClientDvar( "drui_spray", spray );
		}
	}
	else if( int(response) > 5 && int(response) < 9 )
	{
		spray = int(response)-5;
		if( self maps\mp\gametypes\_rank::isDSprayUnlocked( spray ) )
		{
			spray = (spray+34);
			self setStat( 979, spray );
			self setClientDvar( "drui_spray", spray );
		}
	}		
	else if( int(response) > 9 && int(response) < 13 )
	{
		character = int(response)-9;
		if( self maps\mp\gametypes\_rank::isDCharacterUnlocked( character ) )
		{
			self setStat( 980, (character+19) );
			self setClientDvar( "drui_character", character );
		}
	}
	else if( int(response) > 12 )
	{
		character = int(response)-10;
		if( self maps\mp\gametypes\_rank::isACharacterUnlocked( character ) )
		{
			self setStat( 980, (character+20) );
			self setClientDvar( "drui_character", character );
		}
	}
}