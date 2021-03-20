#include scripts\utility\_utility;

splashNotifyDelayed( splash )
{		
	self thread underScorePopup(getSplashTitle(splash));
}

teamPlayerCardSplash( splash, owner, blank )
{			
	for( i = 0; i < level.players.size; i++  )			
		level.players[i] thread playerCardSplashNotify( splash, owner );
}

playerCardSplashNotify(splash, owner)
{
	self endon("disconnect");

	if ( tableLookup( "mp/splashTable.csv", 1, splash, 0 ) != "" )
	{
		while(isDefined(self.leftnotifyinprogress) && self.leftnotifyinprogress )
			wait 0.05;
				
		if(!isDefined(owner))
			return;

		self.leftnotifyinprogress = true;
		
		self destroyPlayerCard();
				
		self.leftnotify = [];
		self.leftnotify[0] = newClientHudElem( self );
		self.leftnotify[0].x = -150;
		self.leftnotify[0].y = 125;
		self.leftnotify[0].alignX = "left";
		self.leftnotify[0].horzAlign = "left";
		self.leftnotify[0].alignY = "top";
		self.leftnotify[0] setShader( "gradient_top", 150, 20 );
		self.leftnotify[0].alpha = 0.5;
		self.leftnotify[0].sort = 900;
		self.leftnotify[0].hideWhenInMenu = true;
		self.leftnotify[0].archived = false;
		
		self.leftnotify[1] = newClientHudElem( self );
		self.leftnotify[1].x = -150;
		self.leftnotify[1].y = 155;
		self.leftnotify[1].alignX = "left";
		self.leftnotify[1].horzAlign = "left";
		self.leftnotify[1].alignY = "top";
		self.leftnotify[1] setShader( "gradient_bottom", 150, 20 );
		self.leftnotify[1].alpha = 0.2;
		self.leftnotify[1].sort = 901;
		self.leftnotify[1].hideWhenInMenu = true;
		self.leftnotify[1].archived = false;
			
		self.leftnotify[2] = newClientHudElem( self );
		self.leftnotify[2].x = -150;
		self.leftnotify[2].y = 130;
		self.leftnotify[2].alignX = "left";
		self.leftnotify[2].horzAlign = "left";
		self.leftnotify[2].alignY = "top";
		self.leftnotify[2].alpha = 1;
		self.leftnotify[2] setShader( maps\mp\gametypes\_rank::getRankInfoIcon(owner.pers["rank"],owner.pers["prestige"]), 40, 40 );
		self.leftnotify[2].sort = 902;
		self.leftnotify[2].hideWhenInMenu = true;
		self.leftnotify[2].archived = false;

		self.leftnotify[3] = addTextHud( self, -100, 130, 1, "left", "top", 1.4 ); 
		self.leftnotify[3].horzAlign = "left";
		self.leftnotify[3] setText( owner.name );
		self.leftnotify[3].sort = 903;
		self.leftnotify[3].color = self getColorByTeam();
		self.leftnotify[3].hideWhenInMenu = true;
		self.leftnotify[3].archived = false;
		
		self.leftnotify[4] = addTextHud( self, -100, 145, 1, "left", "top", 1.4 );
		self.leftnotify[4].horzAlign = "left";
		self.leftnotify[4] setText( getSplashTitle(splash) );
		self.leftnotify[4].sort = 904;
		self.leftnotify[4].hideWhenInMenu = true;
		self.leftnotify[4].archived = false;
	
		self.leftnotify[5] = newClientHudElem( self );
		self.leftnotify[5].x = -150;
		self.leftnotify[5].y = 125;
		self.leftnotify[5].alignX = "left";
		self.leftnotify[5].horzAlign = "left";
		self.leftnotify[5].alignY = "top";
		self.leftnotify[5] setShader( "line_horizontal", 150, 1 );
		self.leftnotify[5].alpha = 0.3;
		self.leftnotify[5].sort = 905;
		self.leftnotify[5].hideWhenInMenu = true;
		self.leftnotify[5].archived = false;
		
		self.leftnotify[6] = newClientHudElem( self );
		self.leftnotify[6].x = -150;
		self.leftnotify[6].y = 174;
		self.leftnotify[6].alignX = "left";
		self.leftnotify[6].horzAlign = "left";
		self.leftnotify[6].alignY = "top";
		self.leftnotify[6] setShader( "line_horizontal", 150, 1 );
		self.leftnotify[6].alpha = 0.3;
		self.leftnotify[6].sort = 906;
		self.leftnotify[6].hideWhenInMenu = true;
		self.leftnotify[6].archived = false;
		
		for(i = 0 ; i < self.leftnotify.size && isDefined(self.leftnotify[i]); i++)
			self.leftnotify[i] moveOverTime(0.15);
				
		self.leftnotify[0].x = 5;
		self.leftnotify[1].x = 5;
		self.leftnotify[2].x = 5;
		self.leftnotify[3].x = 55;
		self.leftnotify[4].x = 55;
		self.leftnotify[5].x = 5;
		self.leftnotify[6].x = 5;
		
		wait 0.15;
		time = getSplashDuration(splash)-0.05;
		
		waittill_notify_ent_or_timeout(level,"_game_ended", time);

		for(i = 0 ; i < self.leftnotify.size && isDefined(self.leftnotify[i]); i++)
			self.leftnotify[i] moveOverTime(0.15);
			
		self.leftnotify[0].x = -150;
		self.leftnotify[1].x = -150;
		self.leftnotify[2].x = -150;
		self.leftnotify[3].x = -100;
		self.leftnotify[4].x = -100;	
		self.leftnotify[5].x = -150;
		self.leftnotify[6].x = -150;		

		wait 0.15;
		self destroyPlayerCard();
		wait 0.05;
		self.leftnotifyinprogress = false;
	}
}
destroyPlayerCard()
{
	if( !isDefined( self.leftnotify ) )
		return;

	for( i = 0; i < self.leftnotify.size; i++ )
		self.leftnotify[i] destroy();
	self.leftnotify = [];
}

getSplashTitle(splash)
{
return tableLookupIString( "mp/splashTable.csv" , 1 , splash , 2 );
}

getSplashDuration(splash)
{
return stringToFloat(tableLookup( "mp/splashTable.csv" , 1 , splash , 5 ));
}

addTextHud( who, x, y, alpha, alignX, alignY, fontScale )
{
	if( isPlayer( who ) )
		hud = newClientHudElem( who );
	else
		hud = newHudElem();

	hud.x = x;
	hud.y = y;
	hud.alpha = alpha;
	hud.alignX = alignX;
	hud.alignY = alignY;
	hud.fontScale = fontScale;
	return hud;
}
