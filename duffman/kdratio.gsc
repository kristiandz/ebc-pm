#include scripts\utility\common;

init()
{

	addConnectThread(::initStats,"once");
	addConnectThread(::ShowKDRatio);
	wait .05;
	for(;;wait 1)
	{
		if( game["state"] == "playing" ) continue;
		players = getAllPlayers();
		for(i=0;i<players.size;i++)
		{
			if(isDefined(players[i]))
			{
				if(isDefined(players[i].mc_kdratio))
					players[i].mc_kdratio thread FadeOut(1);
				if(isDefined(players[i].mc_streak))
					players[i].mc_streak thread FadeOut(0.6);
				if(isDefined(players[i].mc_kc))
					players[i].mc_kc thread FadeOut(0.4);
				if(isDefined(players[i].mc_rsc))
					players[i].mc_rsc thread FadeOut(0.2);
			}
		}				
	}
}

initStats() 
{
	self.pers["shoots"] = 1;
	self.pers["hits"] = 1;
	if(!isDefined(self.pers["gottags"]))
		self.pers["gottags"] = 0;
	if(!isDefined(self.pers["rescues"]))
		self.pers["rescues"] = 0;
}

ShowKDRatio()
{
	self notify( "new_KDRRatio" );
	self endon( "new_KDRRatio" );
	self endon( "disconnect" );
	
	wait 1;
	if( IsDefined( self.mc_kdratio ) )	self.mc_kdratio Destroy();
	if( IsDefined( self.mc_streak ) )	self.mc_streak Destroy();
	if( IsDefined( self.mc_kc ) )	self.mc_kc Destroy();
	if( IsDefined( self.mc_rsc ) )	self.mc_rsc Destroy();
	
	self.mc_streak = NewClientHudElem(self);
	self.mc_streak.x = 110;
	self.mc_streak.y = -472;
	self.mc_streak.horzAlign = "left";
	self.mc_streak.vertAlign = "bottom";
	self.mc_streak.alignX = "left";
	self.mc_streak.alignY = "middle";
	self.mc_streak.alpha = 0;
	self.mc_streak.fontScale = 1.4;
	self.mc_streak.hidewheninmenu = true;
	self.mc_streak.label = &"^7Killstreak:^8 &&1";
	self.mc_streak FadeOverTime(0.2);
	self.mc_streak.alpha = 1;
	self.mc_streak.archived = true; // Make a workaround to hide the stats in fkc, but to retain sepctating stats for all players
	
	self.mc_kdratio = NewClientHudElem(self);
	self.mc_kdratio.x = 110;
	self.mc_kdratio.y = -460;
	self.mc_kdratio.horzAlign = "left";
	self.mc_kdratio.vertAlign = "bottom";
	self.mc_kdratio.alignX = "left";
	self.mc_kdratio.alignY = "middle";
	self.mc_kdratio.alpha = 0;
	self.mc_kdratio.fontScale = 1.4;
	self.mc_kdratio.hidewheninmenu = true;
	self.mc_kdratio.label = &"K/D Ratio:^8 &&1";
	self.mc_kdratio FadeOverTime(0.4);
	self.mc_kdratio.alpha = 1;
	self.mc_kdratio.archived = true;
	
	if(level.gametype == "kc" || level.gametype == "sr" )
	{
		self.mc_kc = NewClientHudElem(self);
		self.mc_kc.x = 110;
		self.mc_kc.y = -448;
		self.mc_kc.horzAlign = "left";
		self.mc_kc.vertAlign = "bottom";
		self.mc_kc.alignX = "left";
		self.mc_kc.alignY = "middle";
		self.mc_kc.alpha = 0;
		self.mc_kc.fontScale = 1.4;
		self.mc_kc.hidewheninmenu = true;
		self.mc_kc.label = &"Eliminated tags:^8 &&1";
		self.mc_kc FadeOverTime(0.8);
		self.mc_kc.alpha = 1;
		self.mc_kc.glowcolor = (0.7, 0.2, 0.2);
		self.mc_kc.glowalpha = 0.8;
		self.mc_kc.archived = true;
		
		if(level.gametype == "sr")
		{
			self.mc_rsc = NewClientHudElem(self);
			self.mc_rsc.x = 110;
			self.mc_rsc.y = -436;
			self.mc_rsc.horzAlign = "left";
			self.mc_rsc.vertAlign = "bottom";
			self.mc_rsc.alignX = "left";
			self.mc_rsc.alignY = "middle";
			self.mc_rsc.alpha = 0;
			self.mc_rsc.fontScale = 1.4;
			self.mc_rsc.hidewheninmenu = true;
			self.mc_rsc.label = &"Rescued tags:^8 &&1";
			self.mc_rsc FadeOverTime(1);
			self.mc_rsc.alpha = 1;
			self.mc_rsc.glowcolor = (0.7, 0.2, 0.2);
			self.mc_rsc.glowalpha = 0.8;
			self.mc_rsc.archived = true;
		}
	}
	color = (0,0,0);
	first = true;
	for(;;)
	{
		if(first)
			first = 0;
		else 
			wait .5;
		if(!isDefined(self) || !isDefined(self.pers) || !isDefined(self.pers[ "hits" ]) || !isDefined(self.pers[ "kills" ]) || !isDefined(self.pers[ "deaths" ]) || !isDefined(self.pers[ "shoots" ]) || !isDefined(self.mc_kdratio) || !isDefined(self.mc_streak))
			return;	
		if( IsDefined( self.pers[ "kills" ] ) && IsDefined( self.pers[ "deaths" ] ) )
		{
			if( self.pers[ "deaths" ] < 1 ) ratio = self.pers[ "kills" ];
			else ratio = int( self.pers[ "kills" ] / self.pers[ "deaths" ] * 100 ) / 100;				
			self.mc_kdratio FadeOverTime(.5);
			self.mc_kdratio setValue(ratio);
		}	
		self.mc_streak setValue(self GetStat(2304));
		if( level.gametype == "sr" )
		{
			if( IsDefined( self.mc_kc ) )self.mc_kc setValue( self.pers["gottags"] );
			if( IsDefined( self.mc_rsc ) )self.mc_rsc setValue( self.pers["rescues"] );
		}
		if( level.gametype == "kc" )
		{
			self.mc_kc setValue( self.pers["gottags"] );
		}
		self common_scripts\utility::waittill_any("disconnect","death","weapon_fired","weapon_change","player_killed");
	}
}