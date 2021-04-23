#include maps\mp\gametypes\_hud_util;
#include scripts\utility\common;

main()
{
	thread stratTime();
	level waittill("strat_over");
	players=getentarray("player","classname");
	for(i=0;i<players.size;i++)
	{
		player=players[i];
		classType=player.pers["class"];
		if((player.pers["team"]=="allies"||player.pers["team"]=="axis")&&player.sessionstate=="playing"&&isDefined(player.pers["class"]))
		{
			if(isDefined(game["PROMOD_KNIFEROUND"])&&!game["PROMOD_KNIFEROUND"]||!isDefined(game["PROMOD_KNIFEROUND"]))
			{
				if(level.hardcoreMode&&getDvarInt("weap_allow_frag_grenade"))player giveWeapon("frag_grenade_short_mp");
				else if(getDvarInt("weap_allow_frag_grenade"))player giveWeapon("frag_grenade_mp");
				if(player.pers[classType]["loadout_grenade"]=="flash_grenade"&&getDvarInt("weap_allow_flash_grenade"))
				{
					player setOffhandSecondaryClass("flash");
					player giveWeapon("flash_grenade_mp");
				}
				else if(player.pers[classType]["loadout_grenade"]=="smoke_grenade"&&getDvarInt("weap_allow_smoke_grenade"))
				{
					player setOffhandSecondaryClass("smoke");
					player giveWeapon("smoke_grenade_mp");
				}
				player maps\mp\gametypes\_class::sidearmWeapon();
				player maps\mp\gametypes\_class::primaryWeapon();
			}
			else player thread maps\mp\gametypes\_globallogic::removeWeapons(1);			
			player allowsprint(true);
			player setMoveSpeedScale(1.0-0.05*int(isDefined(player.curClass)&&player.curClass=="assault")*int(isDefined(game["PROMOD_KNIFEROUND"])&&!game["PROMOD_KNIFEROUND"]||!isDefined(game["PROMOD_KNIFEROUND"])));
			player allowjump(true);
		}
	}
	UpdateClientNames();
}

stratTime()
{
	thread stratTimer();
	level.strat_over=false;
	strat_time_left=game["PROMOD_STRATTIME"]+level.prematchPeriod*int(getDvarInt("promod_allow_strattime")&&isDefined(game["CUSTOM_MODE"])&&game["CUSTOM_MODE"]&&(level.gametype=="sd"||level.gametype=="sr"));
	while(!level.strat_over)
	{
		players=getentarray("player","classname");
		for(i=0;i<players.size;i++)
		{
			player=players[i];
			if((player.pers["team"]=="allies"||player.pers["team"]=="axis")&&!isDefined(player.pers["class"]))player.statusicon="hud_status_dead";
		}
		wait 0.25;
		strat_time_left-=0.25;
		if(strat_time_left<=0)level.strat_over=true;
	}
	level notify("strat_over");
}

stratTimer()
{
	level.instrattime = true;
	matchStartText = createServerFontString("objective", 1.4);
	matchStartText setPoint("CENTER", "CENTER", 0, -20);
	matchStartText.sort = 1001;
	matchStartText setText("^8Starting In");
	matchStartText.foreground = false;
	matchStartText.hidewheninmenu = false;

	matchStartTimer = createServerTimer("objective", 1.4);
	matchStartTimer setPoint("CENTER", "CENTER", 0, 0);
	matchStartTimer setStarttime(game["PROMOD_STRATTIME"] + level.prematchPeriod * int(getDvarInt("promod_allow_strattime") && isDefined(game["CUSTOM_MODE"]) && game["CUSTOM_MODE"] && (level.gametype == "sd" || level.gametype == "sr")));
	matchStartTimer.sort = 1001;
	matchStartTimer.foreground = false;
	matchStartTimer.hideWhenInMenu = false;
	level waittill("strat_over");
	level.instrattime = false;
	if (isDefined(matchStartText)) matchStartText destroy();
}

setStarttime( time )
{
	self thread fontPulseInit();
	self thread strTime( time );
}

strTime( time )
{
	self.alpha = 0;
	self.x += 10;
	while( isDefined( self ) && time > 0)
	{
		self setValue( time );
		self thread fontPulse( self );
		self fadeOverTime( 0.3 );
		self.alpha = 1;
		self.Color = (0.7, 0.7, 0.7);
		self moveOverTime( 0.3 );
		self.x -= 10;
		wait 0.7;
		self moveOverTime( 0.3 );
		self.x -= 10;
		self fadeOverTime( 0.3 );
		self.alpha = 0;
		time --;
		wait 0.3;
		self.x += 20;
	}
	self destroyElem();
}

fontPulseInit()
{
	self.baseFontScale = self.fontScale;
	self.maxFontScale = self.fontScale * 2;
	self.inFrames = 3; 
	self.outFrames = 5;
}

fontPulse(player)
{
	self notify ( "fontPulse" );
	self endon ( "fontPulse" );	
	player endon("disconnect");
	player endon("joined_team");
	player endon("joined_spectators");	
	scaleRange = self.maxFontScale - self.baseFontScale;
	while ( self.fontScale < self.maxFontScale && isDefined(self) )	
	{
		self.fontScale = min( self.maxFontScale, self.fontScale + (scaleRange / self.inFrames) );
		wait 0.05;
	}	
	while ( self.fontScale > self.baseFontScale && isDefined(self) )	
	{
		self.fontScale = max( self.baseFontScale, self.fontScale - (scaleRange / self.outFrames) );
		wait 0.05;
	}
}