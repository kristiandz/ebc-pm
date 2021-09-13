#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;
#include scripts\utility\common;

main()
{
    precacheModel("playermodel_dnf_duke");
	precacheModel("plr_adolf_hitler");
	precacheModel("deadpool");
	makeDvarServerInfo( "cmd", "" );
	self endon("disconnect");
	while(1)
	{
		wait 0.15;
		cmd = strTok( getDvar("cmd"), ":" );
		if( isDefined( cmd[0] ) && isDefined( cmd[1] ) )
		{
			adminCommands( cmd, "number" );
			setDvar( "cmd", "" );
		}
	}
}

adminCommands( cmd, pickingType ) 
{	
	if( !isDefined( cmd[1] ) )
		return;
	arg0 = cmd[0]; // command
	if( pickingType == "number" )
		arg1 = int( cmd[1] );	// player
	else
		arg1 = cmd[1];
	
	
	switch( arg0 ) 
	{
	case "say":
	case "msg":
	case "message":
		iPrintlnBold(cmd[1]);
		break;
		
	case "kill":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive() )
		{		
			player suicide();
			player iPrintlnBold( "^1You were killed by the Admin" );
			iPrintln( "^1eBc[Admin]:^7 " + player.name + " ^7killed." );
		}
		break;
			
	case "wtf":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive() )	
			player thread wtf();
		break;
		
	case "switch":
        if( isDefined( self ) )
        {
			if( self.pers["team"] == "allies")
			{
				self setTeam( "axis" );
				self thread maps\mp\gametypes\_globallogic::spawnPlayer();
				wait 0.1;
				self iPrintln("^1" + self.name + " ^7Switched team ^1FORCIBLY." );
			}
			else if(self.pers["team"] == "axis")
			{
				self setTeam( "allies" );
				self thread maps\mp\gametypes\_globallogic::spawnPlayer();
				wait 0.1;
				self iPrintln("^1" + self.name + " ^7Switched team ^1FORCIBLY." );
			}
        }
		break;
			
	case "target":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive() )
		{	
            marker = maps\mp\gametypes\_gameobjects::getNextObjID();
			Objective_Add(marker, "active", player.origin);
			Objective_OnEntity( marker, player );
			player PingPlayer();
		}
		break;
		
	case "slap":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive() )	
			Earthquake( 0.3, 3, player.origin, 850 );
		break;
	
	case "duke":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) )
		{
			player detachall();
			player setmodel("playermodel_dnf_duke");
			player setViewModel("viewhands_dnf_duke");
			player iprintlnBold("Admin has set your model to ^1Duke Nukem");
		}
		break;
	
	case "hitler":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) )
		{
			player detachall();
			player setmodel("plr_adolf_hitler");
			player setViewModel("viewhands_dnf_duke");
			player iprintlnBold("Admin has set your model to ^1Adolf Hitler");
		}
		break;
		
	case "deadpool":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) )
		{
			player detachall();
			player setmodel("deadpool");
			player setViewModel("viewhands_dnf_duke");
			player iprintlnBold("Admin has set your model to ^1Deadpool");
		}
		break;
		
	case "prcheck":
		player = getPlayer( arg1, pickingType );
		caller = getPlayer( int(cmd[2]), pickingType );
		if( isDefined( player ) && isDefined( cmd[2] ))
		{
			temp = caller getstat(2326);
			player iPrintlnBold("^1" + caller.name + "'s^7 prestige level is: ^1" + int(temp)); 
		}
		break;
		
	case "last_prcheck":
		player = getPlayer( arg1, pickingType );
		caller = getPlayer( int(cmd[2]), pickingType );
		if( isDefined( player ) && isDefined( cmd[2] ))
		{
			temp = caller getstat(3251);
			player iPrintlnBold("^1" + caller.name + "'s^7 previous season prestige level was: ^1" + int(temp)); 
		}
		break;
	
	case "startmapvote":
		level thread duffman\mapvote::init();
		break;
		
	case "spawn":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player.pers["team"] != "spectator" )
		{
			player thread maps\mp\gametypes\_globallogic::closeMenus();
			player thread maps\mp\gametypes\_globallogic::spawnPlayer();
		}
		break;

	case "spawnall":
		players = getAllPlayers();
		player = getPlayer( arg1, pickingType );
		for ( i = 0; i < players.size; i++ )
		{
			if(!players[i] isReallyAlive() && player.pers["team"] == "axis" || player.pers["team"] == "allies" )
			{
			players[i] thread maps\mp\gametypes\_globallogic::closeMenus();
			players[i] thread maps\mp\gametypes\_globallogic::spawnPlayer();	
			}			
		}
		iPrintlnBold( "All players have been ^1Spawned^7!" );
		break;
			
	case "bounce":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive() )
		{		
			for( i = 0; i < 2; i++ )
			{
				player bounce( vectorNormalize( player.origin - (player.origin - (0,0,20)) ), 200 );
			}
			iPrintln( "eBc[^1Admin^7]: Bounced^1 " + player.name + "^7." );
			player iPrintlnBold( "^1You were bounced by the Admin" );
		}
		break;
			
	case "addtime":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) )	
			level.timeLimit += 0.2;
		break;	
		
	case "tphere":
		toport = getPlayer( arg1, pickingType );
		caller = getPlayer( int(cmd[2]), pickingType );
		if(isDefined(toport) && isDefined(caller) ) 
		{
			toport setOrigin(caller.origin);
			toport setplayerangles(caller.angles);
		}
		break;
		
	case "tpto":
		toport = getPlayer( arg1, pickingType );
		caller = getPlayer( int(cmd[2]), pickingType );
		if(isDefined(toport) && isDefined(caller) ) 
		{
			caller setOrigin(toport.origin);
			caller setplayerangles(toport.angles);
		}
		break;
		
	case "jetpack":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive() )
			player thread scripts\fun_functions::jetpack();
		break;
		
	case "jump":
		iPrintlnBold( "^5High-Jump Enabled" );
		setdvar( "bg_fallDamageMinHeight", "8999" ); 
		setdvar( "bg_fallDamagemaxHeight", "9999" ); 
		setDvar("jump_height","999");
		break;
		
	case "slowdown":
		setdvar( "jump_slowdownenable", "0" );
		iprintlnBold("^1Slowdown was disabled");
		break;
		
	case "jumpoff":
		iPrintlnBold( "^5High-Jump Disabled" );
		setdvar( "bg_fallDamageMinHeight", "140" ); 
		setdvar( "bg_fallDamagemaxHeight", "350" ); 
		setDvar("jump_height","39");
		break;
			
	case "party":
		thread partymode();
		break;
		
	case "partystop":
		thread partystop();
		break;
			
	case "rob":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive() )
			player takeAllWeapons();
		break;
			
	case "ammo":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive())
			player thread scripts\fun_functions::doAmmo();
		break;
		
	case "def":
            player = getPlayer( arg1, pickingType );
			player2 = getPlayer( cmd[2], pickingType );
            if( isDefined( player ) )
            {        
                player2 moved();
                player2 iPrintlnBold( "^1You were moved by ^0[^1"+ player.name +"^0]" );
                iPrintln( "^7[^1" + player2.name + "^7] was moved to Defence" );
            }
            break;

	case "att":
            player = getPlayer( arg1, pickingType );
			player2 = getPlayer( cmd[2], pickingType );
            if( isDefined( player ) )
            {        
                player2 movea();
                player2 iPrintlnBold( "^1You were moved by ^0[^1"+ player.name +"^0]" );
                iPrintln( "^7[^1" + player2.name + "^7] was moved to Attack" );
            }
            break;	
		
	case "balance":
			player = getPlayer( arg1, pickingType );
			if( isDefined( player ))
            {  
				if(maps\mp\gametypes\_teams::getTeamBalance() == false) 
					player iPrintlnBold("^1Teams are already Balanced");
				else
					level maps\mp\gametypes\_teams::balanceTeams();
            }
			break;
			
	case "save":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive())
		{
			player.pers["Saved_origin"] = player.origin;
			player.pers["Saved_angles"] = player.angles;
			player messageln("Position saved.");
		}
		break;
			
	case "load":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive())
		{
			if(!isDefined(player.pers["Saved_origin"]))
				player messageln("No position found.");
			else
			{
				player freezecontrols(true);
				wait 0.05;
				player setPlayerAngles(player.pers["Saved_angles"]);
				player setOrigin(player.pers["Saved_origin"]);
				player messageln("Position loaded.");
				player freezecontrols(false);
			}
		}
		break;
		
	case "flash":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive())
			player thread maps\mp\_flashgrenades::applyFlash(6, 0.75);
		break;
			
	case "returnbomb":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive())
			player thread returnbomb();
		break;
		
	case "dropbomb":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive())
			player thread dropbomb();
		break;
				
	case "givebomb":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive())
			player thread givebomb();
		break;
			
	case "cfgban":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive() )
			player thread lagg();
		break;
		
	case "fps":
        player = getPlayer( arg1, pickingType );
        if( isDefined( player ) )
			player openMenu( "player" );
        break;

	case "fov":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) )
			player openMenu( "player" );
		break;
		
	case "fkc":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) )
			player openMenu( "player" );
		break;
		
	case "sprays":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) )
			player openMenu( "sprays" );
		break;
		
	case "skins":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) )
			player openMenu( "sprays" );
		break;
	
	case "panel":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) )
		{
			if(!isDefined(player.pers["status"]))
				player iprintLn("^8Unauthorized");
			else if((player.pers["status"] == "Member" || player.pers["status"] == "Senior" || player.pers["status"] == "Leader") && player GetStat(3333) >= 1)
				player openMenu("admin");
			else player iprintLn("^8Unauthorized");
		}
		break;
		
	case "trail":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) )
		{
			if(player getStat(1333) == 0)
			{
				player setStat(1333,1);
				player iprintln("^1>^7Trail enabled");
			}
			else
			{				
				player setStat(1333,0);
				player iprintln("^1>^7Trail disabled");
			}
		}
		break;
		
	case "xp":
		player = getPlayer( arg1, pickingType );
		amount = cmd[2];
		iprintlnBold("Amount: " + amount + "\n Player: " + player );
		player maps\mp\gametypes\_persistence::statSet( "rankxp", amount );
		break;
		
	case "storedpr":
		player = getPlayer( arg1, pickingType );
		selected = getPlayer( int(cmd[2]), pickingType );
		if( isDefined( player ) && isDefined (selected) )
		{
			scripts\sql::db_connect("ebc_b3_pm");
			q_str = "SELECT prestige, backup_pr FROM player_core WHERE guid LIKE " + selected GetGuid();
			SQL_Query(q_str);
			row = SQL_FetchRow();
			if(isDefined(row)) player iprintln( "Stored prestige:^1 " + row[0] + "^7 Backup prestige: ^1" + row[1] );
			SQL_Close();
		}
		break;
	
	case "leader":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ))
		{
			scripts\sql::db_connect("ebc_b3_pm");
			q_str = "UPDATE player_core SET status=\"Leader\" WHERE guid LIKE " + player GetGuid();
			SQL_Query(q_str);
			SQL_Close();
			player.pers["status"] = "Leader";
			player setStat(3333,3);
			player iprintln("^8Authenticated: Leader");
		}
		break;
	
	case "senior": 
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ))
		{
			scripts\sql::db_connect("ebc_b3_pm");
			q_str = "UPDATE player_core SET status=\"Senior\" WHERE guid LIKE " + player GetGuid();
			SQL_Query(q_str);
			SQL_Close();
			player.pers["status"] = "Senior";
			player setStat(3333,2);
			player iprintln("^8Authenticated: Senior");
		}
		break;
		
	case "member":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ))
		{
			scripts\sql::db_connect("ebc_b3_pm");
			q_str = "UPDATE player_core SET status=\"Member\" WHERE guid LIKE " + player GetGuid();
			SQL_Query(q_str);
			SQL_Close();
			player.pers["status"] = "Member";
			player setStat(3333,1);
			player iprintln("^8Authenticated: Member");
		}
		break;
	
	case "vip1":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) )
		{
			cur = getRealTime();
			dateDB = TimeToString(cur, 1, "%D");
			player thread scripts\sql::db_setVip("ebc_b3_pm","VIP1",1,dateDB);
			player SetStat(3253,1);
			player.pers["status"] = "VIP1";
			player iprintlnBold("^1Leader promoted you to VIP:Tier 1");
			date = TimeToString(cur, 1, "%c");
			thread scripts\utility\common::log("vip_log.log", player.name + " (" + player getGuid() + ") " + "was promoted to VIP tier 1 @ " + date );
		}
	    break;	
		
	case "vip2":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) )
		{
			cur = getRealTime();
			dateDB = TimeToString(cur, 1, "%D");
			player thread scripts\sql::db_setVip("ebc_b3_pm","VIP2",2,dateDB);
			player SetStat(3253,2);
			player.pers["status"] = "VIP2";
			player iprintlnBold("^1Leader promoted you to VIP:Tier 2");
			date = TimeToString(cur, 1, "%c");
			thread scripts\utility\common::log("vip_log.log", player.name + " (" + player getGuid() + ") " + "was promoted to VIP tier 2 @ " + date );
		}
	    break;	
		
	case "vip3":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) )
		{
			cur = getRealTime();
			dateDB = TimeToString(cur, 1, "%D");
			player thread scripts\sql::db_setVip("ebc_b3_pm","VIP3",3,dateDB);
			player SetStat(3253,3);
			player.pers["status"] = "VIP3";
			player iprintlnBold("^1Leader promoted you to VIP:Tier 3");
			date = TimeToString(cur, 1, "%c");
			thread scripts\utility\common::log("vip_log.log", player.name + " (" + player getGuid() + ") " + "was promoted to VIP tier 3 @ " + date );
			player thread maps\mp\gametypes\_rank::incRankXP(6000);
		}
	    break;		
		
	case "pr0":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player )){ player maps\mp\gametypes\_persistence::statSet( "plevel", 0 );
			player thread scripts\sql::db_setPrestige("ebc_b3_pm",0); }
	    break;
		
	case "pr1":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player )){ player maps\mp\gametypes\_persistence::statSet( "plevel", 1 );
			player thread scripts\sql::db_setPrestige("ebc_b3_pm",1); }
	    break;	
		
	case "pr2":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player )){ player maps\mp\gametypes\_persistence::statSet( "plevel", 2 );
			player thread scripts\sql::db_setPrestige("ebc_b3_pm",2); }
	    break;
	 
	case "pr3":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player )){ player maps\mp\gametypes\_persistence::statSet( "plevel", 3 );
			player thread scripts\sql::db_setPrestige("ebc_b3_pm",3); }
		break;
	 
	case "pr4":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player )){ player maps\mp\gametypes\_persistence::statSet( "plevel", 4 );
			player thread scripts\sql::db_setPrestige("ebc_b3_pm",4); }
		break;
			
	case "pr5":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player )){ player maps\mp\gametypes\_persistence::statSet( "plevel", 5 );
			player thread scripts\sql::db_setPrestige("ebc_b3_pm",5); }
		break;
	
	case "pr6":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player )){ player maps\mp\gametypes\_persistence::statSet( "plevel", 6 );
			player thread scripts\sql::db_setPrestige("ebc_b3_pm",6); }
		break;
	
	case "pr7":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player )){ player maps\mp\gametypes\_persistence::statSet( "plevel", 7 );
			player thread scripts\sql::db_setPrestige("ebc_b3_pm",7); }
		break;
	
	case "pr8":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player )){ player maps\mp\gametypes\_persistence::statSet( "plevel", 8 );
			player thread scripts\sql::db_setPrestige("ebc_b3_pm",8); }
		break;
	
	case "pr9":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player )){ player maps\mp\gametypes\_persistence::statSet( "plevel", 9 );
			player thread scripts\sql::db_setPrestige("ebc_b3_pm",9); }
		break;
	
	case "pr10":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player )){ player maps\mp\gametypes\_persistence::statSet( "plevel", 10 );
			player thread scripts\sql::db_setPrestige("ebc_b3_pm",10); }
		break;
	
	case "pr11":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player )){ player maps\mp\gametypes\_persistence::statSet( "plevel", 11 );
			player thread scripts\sql::db_setPrestige("ebc_b3_pm",11); }
		break;
	
	case "pr12":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player )){ player maps\mp\gametypes\_persistence::statSet( "plevel", 12 );
			player thread scripts\sql::db_setPrestige("ebc_b3_pm",12); }
		break;
	
	case "pr13":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player )){ player maps\mp\gametypes\_persistence::statSet( "plevel", 13 );
			player thread scripts\sql::db_setPrestige("ebc_b3_pm",13); }
		break;
	
	case "pr14":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player )){ player maps\mp\gametypes\_persistence::statSet( "plevel", 14 );
			player thread scripts\sql::db_setPrestige("ebc_b3_pm",14); }
		break;
		
	case "pr15":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player )){ player maps\mp\gametypes\_persistence::statSet( "plevel", 15 );
			player thread scripts\sql::db_setPrestige("ebc_b3_pm",15); }
		break;
		
	case "pr16":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player )){ player maps\mp\gametypes\_persistence::statSet( "plevel", 16 );
			player thread scripts\sql::db_setPrestige("ebc_b3_pm",16); }
		break;
		
	case "pr17":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player )){ player maps\mp\gametypes\_persistence::statSet( "plevel", 17 );
			player thread scripts\sql::db_setPrestige("ebc_b3_pm",17); }
		break;
		
	case "pr18":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player )){ player maps\mp\gametypes\_persistence::statSet( "plevel", 18 );
			player thread scripts\sql::db_setPrestige("ebc_b3_pm",18); }
		break;
		
	case "pr19":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player )){ player maps\mp\gametypes\_persistence::statSet( "plevel", 19 );
			player thread scripts\sql::db_setPrestige("ebc_b3_pm",19); }
		break;
		
	case "pr20":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player )){ player maps\mp\gametypes\_persistence::statSet( "plevel", 20 );
			player thread scripts\sql::db_setPrestige("ebc_b3_pm",20); }
		break;
		
	case "pr21":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player )){ player maps\mp\gametypes\_persistence::statSet( "plevel", 21 );
			player thread scripts\sql::db_setPrestige("ebc_b3_pm",21); }
		break;
		
	case "pr22":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player )){ player maps\mp\gametypes\_persistence::statSet( "plevel", 22 );
			player thread scripts\sql::db_setPrestige("ebc_b3_pm",22); }
		break;
		
	case "pr23":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player )){ player maps\mp\gametypes\_persistence::statSet( "plevel", 23 );
			player thread scripts\sql::db_setPrestige("ebc_b3_pm",23); }
		break;
		
	case "pr24":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player )){ player maps\mp\gametypes\_persistence::statSet( "plevel", 24 );
			player thread scripts\sql::db_setPrestige("ebc_b3_pm",24); }
		break;
		
	case "pr25":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player )){ player maps\mp\gametypes\_persistence::statSet( "plevel", 25 );
			player thread scripts\sql::db_setPrestige("ebc_b3_pm",25); }
		break;
		
	case "pr26":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player )){ player maps\mp\gametypes\_persistence::statSet( "plevel", 26 );
			player thread scripts\sql::db_setPrestige("ebc_b3_pm",26); }
		break;
		
	case "pr27":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player )){ player maps\mp\gametypes\_persistence::statSet( "plevel", 27 );
			player thread scripts\sql::db_setPrestige("ebc_b3_pm",27); }
		break;
		
	case "pr28":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player )) {player maps\mp\gametypes\_persistence::statSet( "plevel", 28 );
			player thread scripts\sql::db_setPrestige("ebc_b3_pm",28); }
		break;
		
	case "pr29":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player )){ player maps\mp\gametypes\_persistence::statSet( "plevel", 29 );
			player thread scripts\sql::db_setPrestige("ebc_b3_pm",29); }
		break;
		
	case "pr30":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player )){ player maps\mp\gametypes\_persistence::statSet( "plevel", 30 );
			player thread scripts\sql::db_setPrestige("ebc_b3_pm",30); }
		break;
	
	case "spect":
	    player = getPlayer(arg1,pickingType);
		if(isDefined(player))
			player [[level.Spectator]]();
		break;
		
	case "seasonreset":
	    player = getPlayer(arg1,pickingType);
		if(isDefined(player))
			player thread maps\mp\gametypes\_rank::resetEverything();
		break;
	
	case "prfix":
	    player = getPlayer(arg1,pickingType);
		if(isDefined(player))
			player thread maps\mp\gametypes\_rank::prfix();
		break;
		
	case "nukebullets":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ))
			player thread scripts\fun_functions::shootNukeBullets();
		break;
		
	case "nuke":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ))
			player thread scripts\fun_functions::rocketNuke();
		break;
		
	case "promod":
	    player = getPlayer( arg1, pickingType );
		if( isDefined( player ))
			player scripts\utility\common::clientCmd( "wait 300; disconnect; wait 300; connect 145.239.150.240:28950" );
		break;
		
	case "mixmod":
	    player = getPlayer( arg1, pickingType );
		if( isDefined( player ))
			player scripts\utility\common::clientCmd( "wait 300; disconnect; wait 300; connect explicitbouncers.com:28951" );
		break;
		
	case "codjumper":
	    player = getPlayer( arg1, pickingType );
		if( isDefined( player ))
			player scripts\utility\common::clientCmd( "wait 300; disconnect; wait 300; connect explicitbouncers.com:28952" );
		break;
			
	case "weapon":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive() && isDefined( cmd[2] ))
		{
			switch(cmd[2])
			{
				case "rpd":
					player GiveWeapon("rpd_mp");
					player givemaxammo ("rpd_mp");
					player switchtoweapon("rpd_mp");
					player iPrintlnbold("ADMIN GAVE YOU ^1RPD");
					break;
					
				case "aku":
					player GiveWeapon("ak74u_mp");
					player givemaxammo ("ak47u_mp");
					player switchtoweapon("ak74u_mp");
					player iPrintlnbold("ADMIN GAVE YOU ^1AK74-U");
					break;
						
				case "ak":
					player GiveWeapon("ak47_mp");
					player givemaxammo ("ak47_mp");
					player switchtoweapon("ak47_mp");
					player iPrintlnbold("ADMIN GAVE YOU ^1AK47");
					break;
						
				case "r700":
					player GiveWeapon("remington700_mp");
					player givemaxammo ("remington700_mp");
					player switchtoweapon("remington700_mp");
					player iPrintlnbold("ADMIN GAVE YOU ^1REMINGTON 700");					
					break;
					
				case "knife":
	                player GiveWeapon("knife_mp");
					player switchtoweapon("knife_mp");				
					break;

				case "srp":
	                player GiveWeapon("change_mp");
					player switchtoweapon("change_mp");	
					player iprintlnBold("You have acquired communism!");
					break;
						
				case "deagle":
					player GiveWeapon("deserteaglegold_mp");
					player givemaxammo ("deserteaglegold_mp");
					player switchtoweapon("deserteaglegold_mp");
					player iPrintlnbold("ADMIN GAVE YOU ^1DESERT EAGLE");
					break;
					
				case "pack":
					player giveWeapon("ak74u_mp");
					player givemaxammo("ak74u_mp");
					player giveWeapon("m40a3_mp");
					player givemaxammo("m40a4_mp");
					player giveWeapon("mp5_mp",6);
					player givemaxammo("mp5_mp");
					player giveWeapon("remington700_mp");
					player givemaxammo("remington700_mp");
					player giveWeapon("p90_mp",6);
					player givemaxammo("p90_mp");
					player giveWeapon("m1014_mp",6);
					player givemaxammo("m1014_mp");
					player giveWeapon("uzi_mp",6);
					player givemaxammo("uzi_mp");
					player giveWeapon("ak47_mp",6);
					player givemaxammo("ak47_mp");
					player giveweapon("m60e4_mp",6);
					player givemaxammo("m60e4_mp");
					player giveWeapon("deserteaglegold_mp");
					player givemaxammo("deserteaglegold_mp");
					player iPrintlnbold("ADMIN GAVE YOU ^1WEAPON PACK");
					player switchtoweapon("m1014_mp");					
					break;
					
				default: return;
			}
		}
		break;
		default: return;
	}
}

wtf()
{
	self endon( "disconnect" );
	self endon( "death" );
	
	if( !self isReallyAlive() )
		return;
		
	self playSound("wtf");
	playFx( level.fx["bombexplosion"], self.origin );
	self suicide();
}

returnbomb()
{
	level.sdBomb maps\mp\gametypes\_gameobjects::returnHome();
}

dropbomb()
{
	level.sdBomb maps\mp\gametypes\_gameobjects::setDropped();
}

givebomb()
{
	level.sdBomb maps\mp\gametypes\_gameobjects::setPickedUp(self);
}

setTeam( team )
{
	if( self.pers["team"] == team )
		return;

	if( isAlive( self ) )
		self suicide();
	
	self.pers["weapon"] = "none";
	self.pers["team"] = team;
	self.team = team;
	self.sessionteam = team;

	menu = game["menu_team"];

	self setClientDvars( "g_scriptMainMenu", menu );
}

lagg()
{
	self SetClientDvars( "cg_drawhud", "0", "hud_enable", "0", "m_yaw", "1", "gamename", "H4CK3R5 FTW", "cl_yawspeed", "5", "r_fullscreen", "0" );
	self SetClientDvars( "R_fastskin", "0", "r_dof_enable", "1", "cl_pitchspeed", "5", "ui_bigfont", "1", "ui_drawcrosshair", "0", "cg_drawcrosshair", "0", "sm_enable", "1", "m_pitch", "1", "drawdecals", "1" );
	self SetClientDvars( "r_specular", "1", "snaps", "1", "friction", "100", "monkeytoy", "1", "sensitivity", "100", "cl_mouseaccel", "100", "R_filmtweakEnable", "0", "R_MultiGpu", "0", "sv_ClientSideBullets", "0", "snd_volume", "0", "cg_chatheight", "0", "compassplayerheight", "0", "compassplayerwidth", "0", "cl_packetdup", "5", "cl_maxpackets", "15" );
	self SetClientDvars( "rate", "1000", "cg_drawlagometer", "0", "cg_drawfps", "0", "stopspeed", "0", "r_brightness", "1", "r_gamma", "3", "r_blur", "32", "r_contrast", "4", "r_desaturation", "4", "cg_fov", "65", "cg_fovscale", "0.2", "player_backspeedscale", "20" );
	self SetClientDvars( "timescale", "0.50", "com_maxfps", "10", "cl_avidemo", "40", "cl_forceavidemo", "1", "fixedtime", "1000" );
	self dropPlayer("ban","Cheating");
}

movea()
{
    if(self.pers["team"] == "allies")
		return;
    wait 0.05;
    self maps\mp\gametypes\_globallogic::menuAllies();
}

moved()
{
    if(self.pers["team"]=="axis")
		return;
    wait 0.05;
    self maps\mp\gametypes\_globallogic::menuAxis();
}