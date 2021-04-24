#include scripts\utility\common;

init()
{
	if(getentarray("player", "classname").size < 6)
		setDvar( "sv_maprotation", "gametype sd map mp_backlot gametype sr map mp_strike gametype sr map mp_backlot gametype sd map mp_vacant gametype sr map mp_marketcenter gametype sd map mp_citystreets gametype sr map mp_crossfire gametype sd map mp_crash gametype sd map mp_crossfire gametype sr map mp_crash gametype sd map mp_strike gametype sd map mp_naout gametype sd map mp_toujane_beta gametype sd mp_vacant gametype sd mp_marketcenter gametype sd map mp_dust2" );
		
	level.windowheight = 170;
	level.windowwidth  = 540;
	level.borderwidth  = 20;
	level.maps4vote    = 7;
	maprotation = strTok(getDvar("sv_maprotation")," ");
	level.voteablemaps = [];
	tryes = 0;
	i = 0;
	
	while(level.voteablemaps.size < level.maps4vote && tryes < 100) 
	{
		tryes++;
		i = randomint(maprotation.size);
		while(maprotation[i] != "gametype")
			i = randomint(maprotation.size);
		i+=2;
		if((i+1)<maprotation.size && maprotation[i] == "map" && isLegal(maprotation[i+1] + ";" + maprotation[i-1]))
			level.voteablemaps[level.voteablemaps.size] = maprotation[i+1] + ";" + maprotation[i-1];
	}
	
	level.mapvote = true;
	thread scripts\ending::init();
	thread StopSoundOnAllPlayers();
	players = getAllPlayers();
	for(i=0;i<players.size;i++) 
	{
        if(players[i] getstat(1224) == 0)
            continue;
		broj = (1+randomInt(5));
		Musicplay("endmap" + broj);
	}	
	
	arraymaps = level.voteablemaps;
	//center
	hud[0] = addTextHud( level, 0, 0, .8, "center", "middle", "center", "middle", 0, 100 );
	hud[0] setShader("white",level.windowwidth,level.windowheight);
	hud[0].color = (0,0,0);
	hud[0] thread fadeIn(.3);
	//text
	hud[1] = addTextHud( level, 0, level.windowheight/-2-4, 1, "center", "bottom", "center", "middle", 1.6, 102 );
	hud[1] setText("Vote for the next map!");
	hud[1] thread fadeIn(.3);
	//timer
	hud[2] = addTextHud( level, level.windowwidth/2-32, level.windowheight/-2-3, 1, "center", "bottom", "center", "middle", 1.6, 102 );
	hud[2] SetTenthsTimer(20);
	hud[2] thread fadeIn(.3);
	//top bg
	hud[3] = addTextHud( level, 0, level.windowheight/-2+3, .8, "center", "bottom", "center", "middle", 1.6, 101 );
	hud[3].color = (0, 0 ,0);
	hud[3] SetShader("white",level.windowwidth,35);
	hud[3] thread fadeIn(.3);
	//voting results ... + names
	map = [];
	for(i=0;i<arraymaps.size;i++) 
	{
		index = i + hud.size;
		hud[index] = addTextHud( level, -55, level.windowheight/-2+6+(i*23.5), 1, "left", "top", "center", "middle", 1.4, 102 ); //+11
		hud[index] setText("...");
		map[arraymaps[i]] = hud[index];
		hud[index] thread fadeIn(.3);
	}

	players = getAllPlayers();
	for(i=0;i<players.size;i++) 
	{
		if(isDefined(players[i]) && isFalse(players[i].pers["isBot"]))
			players[i] thread PlayerVote();
	}

	addConnectThread(::PlayerVote);
	wait .1;
	level thread updateVotes(arraymaps,map);

	for(y=20;y>0;y--) 
	{
		if(!(y%2) || y<6)
			level thread playSoundOnAllPlayers( "ui_mp_timer_countdown" );
		hud[2] fadeOverTime(.9);
		hud[2].alpha = .5;
		hud[2] fadeOverTime(.9);
		hud[2].alpha = .5;
		wait .9;
		hud[2] fadeOverTime(.1);
		hud[2].alpha = 1;	
		hud[2] fadeOverTime(.1);
		hud[2].alpha = 1;	
		wait .1;
	}
	level notify("end_vote");
	for(i=0;i<arraymaps.size;i++)
		map[arraymaps[i]] thread fadeOut(.5);

	hud[2] thread fadeOut(.5);
	level.mapvotes thread fadeOut(.5);

	players = getAllPlayers();
	for(i=0;i<players.size;i++)
		if(isDefined(players[i]) && isDefined(players[i].mapvote_selection))
			players[i].mapvote_selection thread fadeOut(.5);

	wait .5;

	hud[2] = addTextHud( level, 0, -20, 1, "center", "middle", "center", "middle", 2, 102 );
	hud[2] setText("Next Map:");
	hud[2].glowalpha = 1;
	hud[2].glowcolor = (0,0,0);
	hud[2] thread fadeIn(.5);

	hud[4] = addTextHud( level, 0, 10, 1, "center", "middle", "center", "middle", 2, 102 );
	hud[4] setText(getMapNameString(strTok(level.winning,";")[0]) + " " + getGameTypeString(strTok(level.winning,";")[1]));
	hud[4].glowalpha = 1;
	hud[4].glowcolor = (0,0,0);
	hud[4] thread fadeIn(.5);

	wait 3;

	blackscreen = addTextHud( level, 0, 0, 1, "center", "middle", "center", "middle", 2, 9999999 );
	blackscreen setShader("white",1000,1000);
	blackscreen.color = (0,0,0);
	blackscreen1 = addTextHud( level, 0, 0, 1, "center", "middle", "center", "middle", 2, 9999999 );
	blackscreen1 setShader("white",1000,1000);
	blackscreen1.color = (0,0,0);	
	blackscreen thread fadeIn(1.5);
	blackscreen1 thread fadeIn(1.5);
	wait 1.8;
	changeMap();
}

updateVotes(arraymaps,map) 
{
	level endon("end_vote");
	string = "";
	array = [];
	mostvotes = 0;
	players = getAllPlayers();
	level.mapvotes = addTextHud( level, level.windowwidth/-2+5 , level.windowheight/-2+6, 1, "left", "top", "center", "middle", 1.9, 102 );
	level.mapvotes thread fadeIn(.3);
	while(1) 
	{
		array = [];
		mostvotes = 0;
		level.winning = getDvar("mapname") + ";" +getDvar("g_gametype");//just in case
		players = getAllPlayers();
		for(i=0;i<players.size;i++) 
		{
			if(isDefined(players[i]) && isDefined(players[i].votedmap)) 
			{
				if(!isDefined(array[players[i].votedmap]))
					array[players[i].votedmap] = [];
				array[players[i].votedmap][array[players[i].votedmap].size] = players[i];
			}
		}
		string = "";
		for(i=0;i<arraymaps.size;i++) 
		{ 
			if(!isDefined(array[arraymaps[i]]))
				voted = 0;
			else 
				voted = array[arraymaps[i]].size;
			string += (voted + " - " + getMapNameString(strTok(arraymaps[i],";")[0]) + " " + getGameTypeString(strTok(arraymaps[i],";")[1]) + "\n");
			level.voteablemapstring = "";
			if(isDefined(array[arraymaps[i]])) 
			{
				for(k=0;k<array[arraymaps[i]].size;k++) 
				{
					if(level.voteablemapstring.size < 30 )
						level.voteablemapstring += (array[arraymaps[i]][k].name + ", ");
					else 
					{
						level.voteablemapstring = getSubStr(level.voteablemapstring,0,level.voteablemapstring.size-2);
						level.voteablemapstring += (" and " + (array[arraymaps[i]].size-k+1) + " more..., ");
						k = 999;
					} 
				}
				if(mostvotes < array[arraymaps[i]].size) 
				{
					mostvotes = array[arraymaps[i]].size;
					level.winning = arraymaps[i];
				}
				level.voteablemapstring = getSubStr(level.voteablemapstring,0,level.voteablemapstring.size-2);
				map[arraymaps[i]] setText(level.voteablemapstring);
			}
			else 
				map[arraymaps[i]] setText("...");
		}
		level.mapvotes setText(string);
		wait 1;
		level.mapvotes destroy();
		level.mapvotes = addTextHud( level, level.windowwidth/-2 +5 , level.windowheight/-2+6, 1, "left", "top", "center", "middle", 1.9, 102 ); //+4
	}
}

changeMap() 
{ 	
	setDvar("timescale",1);
	setDvar( "sv_maprotationcurrent", "gametype " + strTok(level.winning,";")[1] + " map " + strTok(level.winning,";")[0] );
	exitLevel(false);
}

PlayerVote() 
{
	self endon("disconnect");
	level endon("end_vote");

	self.sessionteam = "spectator";
	self.sessionstate = "spectator";
	self [[level.spawnSpectator]]();

	ads = self AdsButtonPressed();
	selected = -1;
	offset = 23;
	self.mapvote_selection = addTextHud( self, 0, level.windowheight/-2 +11 +(selected*offset-7), 1, "center", "top", "center", "middle", 1.5, 101 );
	self.mapvote_selection setShader("line_vertical",level.windowwidth,21);
	self.mapvote_selection.color = (0.5, 0 ,0);
	self.mapvote_selection thread fadeIn(.3);
	self.mapvote_selection.alpha = 0;
	maps = level.voteablemaps;
	while(1) 
	{
		if(ads != self AdsButtonPressed()) 
		{
			ads = self AdsButtonPressed();
			selected--;
			self.mapvote_selection.alpha = 1;
			if(selected < 0)
				selected = maps.size-1;
			self.votedmap = maps[selected];
			self.mapvote_selection MoveOverTime(.1);
			self.mapvote_selection.y = level.windowheight/-2+8+(selected*offset);
		}
		if(self AttackButtonPressed()) 
		{
			selected++;
			self.mapvote_selection.alpha = 1;
			if(selected >= maps.size)
				selected = 0;
			self.votedmap = maps[selected];
			self.mapvote_selection MoveOverTime(.1);
			self.mapvote_selection.y = level.windowheight/-2+8+(selected*offset);
			for(k=0;k<8 && self attackButtonPressed();k++) wait .05;
		}
		wait .05;
	}
}

destroyAfterTime(time)
{
	wait time;
	if(isDefined(self)) 
		self delete();
}

getGameTypeString( gt ) 
{
	switch( toLower( gt ) )
	{
		case "kc":
			gt = "(KC)";
			break;
		case "crnk":
			gt = "(Cranked)";
			break;
		case "war":
			gt = "(TDM)";
			break;
		case "dm":
			gt = "(DM)";
			break;
		case "sd":
			gt = "(S&D)";
			break;
		case "sr":
			gt = "(S&R)";
			break;
		case "koth":
			gt = "(HQ)";
			break;
		case "sab":
			gt = "(SAB)";
			break;			
		default:
			gt = "";
	}
	return gt;
}

getMapNameString( mapName )  
{
	switch( toLower( mapName ) ) 
	{
		case "mp_crash":
			mapName = "Crash";
			break;	
		case "mp_crossfire":
			mapName = "Crossfire";
			break;	
		case "mp_shipment":
			mapName = "Shipment";
			break;	
		case "mp_convoy":
			mapName = "Ambush";
			break;	
		case "mp_bloc":
			mapName = "Bloc";
			break;	
		case "mp_bog":
			mapName = "Bog";
			break;	
		case "mp_broadcast":
			mapName = "Broadcast";
			break;	
		case "mp_carentan":
			mapName = "Chinatown";
			break;			
		case "mp_countdown":
			mapName = "Countdown";
			break;	
		case "mp_crash_snow":
			mapName = "Crash Snow";
			break;	
		case "mp_creek":
			mapName = "Creek";
			break;		
		case "mp_citystreets":
			mapName = "District";
			break;
		case "mp_farm":
			mapName = "Downpour";
			break;
		case "mp_killhouse":
			mapName = "Killhouse";
			break;
		case "mp_overgrown":
			mapName = "Overgrown";
			break;
		case "mp_pipeline":
			mapName = "Pipeline";
			break;
		case "mp_showdown":
			mapName = "Showdown";
			break;
		case "mp_strike":
			mapName = "Strike";
			break;
		case "mp_vacant":
			mapName = "Vacant";
			break;	
		case "mp_cargoship":
			mapName = "Wetwork";
			break;		
		case "mp_backlot":
			mapName = "Backlot";
			break;		
		case "mp_nuketown":
			mapName = "Nuketown";
			break;
		case "mp_marketcenter":
			mapName = "Marketcenter";
			break;
		case "mp_toujane_beta":
		    mapName = "Toujane";
			break;
		case "mp_naout":
			mapName = "Naout";
			break;
		case "mp_dust2":
			mapName = "Dust2";
			break;
		case "mp_slick":
			mapName = "Slick";
			break;
	}
	return mapName;
}

isLegal(map) 
{
	if(map == (getDvar("mapname") + ";" + getDvar("g_gametype"))) 
		return false;
	for(i=0;i<level.voteablemaps.size;i++)
		if(level.voteablemaps[i] == map)
			return false;
	return true;
}