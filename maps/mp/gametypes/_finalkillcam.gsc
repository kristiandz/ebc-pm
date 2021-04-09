#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

finalKillcamWaiter()
{
	if ( !level.inFinalKillcam )
		return;
		
	while (level.inFinalKillcam)
		wait(0.05);
}

postRoundFinalKillcam()
{
	level notify( "play_final_killcam" );
	thread playsound();
	maps\mp\gametypes\_globallogic_utils::resetOutcomeForAllPlayers();
	finalKillcamWaiter();	
}

playsound()
{
    genre[0] = (1+randomInt(10));     //hardbass
    genre[1] = (11+randomInt(10));    //edm
    genre[2] = (21+randomInt(5));     //rock
    genre[3] = (26+randomInt(10));    //pop
    genre[4] = (36+randomInt(5));     //troll
    genre[5] = (41+randomInt(10));    //balkan
    genre[6] = (51+randomInt(10));    //trap
    genre[7] = (61+randomInt(10));    //rave    
        
    players = getAllPlayers();
    for( i = 0; i < players.size; i++ )
    {
        if(players[i] getstat(1224) == 0)
            continue;
		
		stat = [];
        for(k=0;k<8;k++)
          stat[k] = players[i] getstat(2901 + k);
        
        number = [];
        for(j = 0; j < stat.size; j++)
        {
            if(stat[j] == 0)
                continue;
           
            number[number.size] = j;   
        }
		if(!players[i] getstat(1224) == 1)
			return;
		if( isDefined(number) && number.size != 0)
		{			
		randomNumber = (number[randomInt(number.size)]);
		grnmb = genre[randomNumber];
        getsongname(int(grnmb));        
        players[i] setStat((2909), int(grnmb) );            
        players[i] text();
        players[i] playLocalSound("endround" + int(grnmb));
		}
    }
}

getAllPlayers() 
{
    return getEntArray( "player", "classname" );
}

startFinalKillcam(attackerNum,targetNum,killcamentityindex,sWeapon,deathTime,deathTimeOffset,offsetTime,attacker,victim)
{
	if(attackerNum < 0)
		return;
	recordKillcamSettings( attackerNum, targetNum, sWeapon, deathTime, deathTimeOffset, offsetTime, attacker, killcamentityindex, victim );
	startLastKillcam();
}

startLastKillcam()
{
	if ( level.inFinalKillcam )
		return;

	if ( !isDefined(level.lastKillCam) )
		return;
	
	level.inFinalKillcam = true;
	level waittill ( "play_final_killcam" );

	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];
		player closeMenu(); 
		player closeInGameMenu();
		player thread finalKillcam();
	}
	
	wait( 0.1 );

	while ( areAnyPlayersWatchingTheKillcam() )
		wait( 0.05 );

	level.inFinalKillcam = false;
}

areAnyPlayersWatchingTheKillcam()
{
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];
		if ( isDefined( player.killcam ) )
			return true;
	}
	
	return false;
}

waitKillcamTime()
{
	self endon("disconnect");
	self endon("end_finalkillcam");
	wait(self.killcamlength - 0.05);
	self notify("end_finalkillcam");
}

waitFinalKillcamSlowdown( startTime )
{
	self endon("disconnect");
	self endon("end_finalkillcam");
	secondsUntilDeath = ( ( level.lastKillCam.deathTime - startTime ) / 1000 );
	deathTime = getTime() + secondsUntilDeath * 1000;
	waitBeforeDeath = 2;
	wait( max(0, (secondsUntilDeath - waitBeforeDeath) ) );
	setTimeScale( 1, int( deathTime - 500 ));
	wait( waitBeforeDeath );
	setTimeScale(1,getTime());
}

setTimeScale(to,time)
{
	difference = (abs(getTime() - time)/1000);
	timescale = getDvarFloat("timescale");
	if(difference != 0) 
	{
		for(i = timescale*20; i >= to*20; i -= 1 )
		{
			wait ((int(difference)/int(getDvarFloat("timescale")*20))/20);
			setDvar("timescale",i/20);
		} 
	}
	else
	setDvar("timescale",to);
}

endKillcam()
{
	if(isDefined(self.fkc_timer))
		self.fkc_timer.alpha = 0;
	if(isDefined(self.killertext))
		self.killertext.alpha = 0;	
	self.killcam = undefined;
}

checkForAbruptKillcamEnd()
{
	self endon("disconnect");
	self endon("end_finalkillcam");
	while(1)
	{
		if ( self.archivetime <= 0 )
			break;
		wait .05;
	}
	self notify("end_finalkillcam");
}

checkPlayers()
{
	self endon("disconnect");
	self endon("end_finalkillcam");
	while(1)
	{
		if(! isDefined(maps\mp\gametypes\_globallogic::getPlayerFromClientNum(level.lastKillCam.spectatorclient)) )
			break;
		wait 0.05;
	}
	self notify("end_finalkillcam");
}

recordKillcamSettings( spectatorclient, targetentityindex, sWeapon, deathTime, deathTimeOffset, offsettime, attacker, entityindex, victim )
{
	if ( ! isDefined(level.lastKillCam) )
		level.lastKillCam = spawnStruct();
	
	level.lastKillCam.spectatorclient = spectatorclient;
	level.lastKillCam.weapon = sWeapon;
	level.lastKillCam.deathTime = deathTime;
	level.lastKillCam.deathTimeOffset = deathTimeOffset;
	level.lastKillCam.offsettime = offsettime;
	level.lastKillCam.targetentityindex = targetentityindex;
	level.lastKillCam.attacker = attacker;
	level.lastKillCam.entityindex = entityindex;
	level.lastKillCam.victim = victim;
}

finalKillcam()
{
	self endon("disconnect");
	level endon("game_ended");
	
	self notify( "end_killcam" );
	self setClientDvar("cg_airstrikeKillCamDist", 20);
	
	postDeathDelay = (getTime() - level.lastKillCam.deathTime) / 1000;
	predelay = postDeathDelay + level.lastKillCam.deathTimeOffset;
	camtime = calcKillcamTime( level.lastKillCam.weapon, predelay, false, undefined );
	postdelay = calcPostDelay();
	killcamoffset = camtime + predelay;
	killcamlength = camtime + postdelay - 0.05;
	killcamstarttime = (gettime() - killcamoffset * 1000);

	self notify ( "begin_killcam", getTime() );

	self.sessionstate = "spectator";
	self.spectatorclient = level.lastKillCam.spectatorclient;
	self.killcamentity = -1;
	if ( level.lastKillCam.entityindex >= 0 )
		self thread setKillCamEntity( level.lastKillCam.entityindex, 0 - killcamstarttime - 100 );
	self.killcamtargetentity = level.lastKillCam.targetentityindex;
	self.archivetime = killcamoffset;
	self.killcamlength = killcamlength;
	self.psoffsettime = level.lastKillCam.offsettime;

	self allowSpectateTeam("allies", true);
	self allowSpectateTeam("axis", true);
	self allowSpectateTeam("freelook", false);
	self allowSpectateTeam("none", false);

	wait 0.05;

	if ( self.archivetime <= predelay )
	{
		self.sessionstate = "dead";
		self.spectatorclient = -1;
		self.killcamentity = -1;
		self.archivetime = 0;
		self.psoffsettime = 0;
		self notify ( "end_finalkillcam" );
		return;
	}
	
	self thread checkForAbruptKillcamEnd();
	self thread checkPlayers();

	self.killcam = true;

	self addKillcamTimer(camtime);
	self addKillcamKiller(level.lastKillCam.attacker,level.lastKillCam.victim);
	
	self thread waitKillcamTime();
	self thread waitFinalKillcamSlowdown( killcamstarttime );

	self waittill("end_finalkillcam");
	
	if( isDefined( self.sname ) ) 
		self.sname destroy();
	
	self.villain destroy();
	self.versus destroy();
	self.victim destroy();

	self endKillcam();
}

isKillcamGrenadeWeapon( sWeapon )
{
	if (sWeapon == "frag_grenade_mp")
		return true;
		
	else if (sWeapon == "frag_grenade_short_mp"  )
		return true;
	
	return false;
}
calcKillcamTime( sWeapon, predelay, respawn, maxtime )
{
	camtime = 0.0;
	
	if ( isKillcamGrenadeWeapon( sWeapon ) )
		camtime = 4.25; 
	else
		camtime = 5;
	
	if (isdefined(maxtime)) 
	{
		if (camtime > maxtime)
			camtime = maxtime;
		if (camtime < .05)
			camtime = .05;
	}
	return camtime;
}

calcPostDelay()
{
	postdelay = 1;
	// time after player death that killcam continues for
	if (getDvar( "scr_killcam_posttime") == "")
		postdelay = 2;
	else 
	{
		postdelay = getDvarFloat( "scr_killcam_posttime");
		if (postdelay < 0.05)
			postdelay = 0.05;
	}
	return postdelay;
}

addKillcamKiller(attacker,victim)
{
	self.villain = createFontString( "default", 1.7 );
	self.villain setPoint( "CENTER", "BOTTOM", -510, -70 ); 
	self.villain.alignX = "right";
	self.villain.archived = false;
	if(isDefined(attacker))	self.villain setPlayerNameString( attacker );
	self.villain.foreground = true;  
	self.villain.alpha = 1;
	self.villain.glowalpha = 1;
	self.villain.glowColor = level.randomcolour;
	self.villain moveOverTime( 4 );
	self.villain.x = -30;  

	self.versus = createFontString( "default", 1.7 );
	self.versus.alpha = 0;
	self.versus setPoint( "CENTER", "BOTTOM", 0, -70 );  
	self.versus.archived = false;
	self.versus setText( "vs" );
	self.versus.foreground = true;    
	self.versus.glowColor = level.randomcolour;
	self.versus fadeOverTime( 4 );
	self.versus.alpha = 1;
  
	self.victim = createFontString( "default", 1.7 );
	self.victim setPoint( "CENTER", "BOTTOM", 510, -70 );
	self.victim.alignX = "left";  
	self.victim.archived = false;
	if(isDefined(victim)) self.victim setPlayerNameString( victim );
	self.victim.foreground = true;
	self.victim.glowalpha = 1; 
	self.victim.glowColor = level.randomcolour;
	self.victim moveOverTime( 4 );
	self.victim.x = 30; 
	
	if ( isDefined( self.carryIcon ) )
		self.carryIcon destroy();
}

text()
{
	self endon("disconnect");
    names = level.name;
	if(isDefined(names))
	{
		self.sname = createFontString( "default", 1.4 );
		self.sname setPoint( "CENTER", "BOTTOM", 0, 10 );  
		self.sname.archived = false;
		self.sname setText(names);
		self.sname.foreground = true; 
		self.sname.alpha = 1;
		self.sname moveOverTime( 1 );
		self.sname.y = -10;
	}
}

getsongname(songnum)
{
	if(!isDefined(songnum))return;
	switch(songnum)
	{
		case 1:	level.name = "DJ BLYATMAN - MOLOTOV";
		break;
		case 2:	level.name = "DJ BLYATMAN - SUPERFLY";
		break;
		case 3:	level.name = "DJ BLYATMAN & HBKN - EASTERN BLOC";
		break;
		case 4:	level.name = "XS Project Zhelezno";
		break;
		case 5:	level.name = "XS Project - Molot";
		break;
		case 6:	level.name = "XS Project - Na Kolbasu";
		break;
		case 7:	level.name = "Steel Deluxe - Gormonalno";
		break;
		case 8:	level.name = "XS Project - DJ";
		break;
		case 9:	level.name = "XS Project - Marafon";
		break;
		case 10: level.name = "XS Project - Novogodnyaya";
		break;
		case 11: level.name = "Henrikz  Keyb - Give It To Me Video";
		break;
		case 12: level.name = "Reece Low - Break Kronics (DatAss Remix)";
		break;
		case 13: level.name = "Tchami - Toxic Love";
		break;
		case 14: level.name = "Bob Marley - Jamming (Tropkillaz Remix)";
		break;
		case 15: level.name = "DJ Snake - Propaganda (Jauz Remix)";
		break;
		case 16: level.name = "Major Lazer feat. Alessia Cara - Hell and High Water";
		break;
		case 17: level.name = "Dubvision - Turn It Around (Gioni Edit)";
		break;
		case 18: level.name = "Teriyaki Boyz - Tokyo Drift (Callmearco Remix)";
		break;
		case 19: level.name = "Avicii - Without You Audio ft. Sandro Cavazza";
		break;
		case 20: level.name = "LOW";
		break;
		case 21: level.name = "The Doors - LA Woman";
		break;
		case 22: level.name = "Nightwish - The Kinslayer";
		break;
		case 23: level.name = "WASP - I wanna be somebody";	
        break;	
	    case 24: level.name = "Two Lane Blacktop";	
        break;	
	    case 25: level.name = "Boston - Rock & Roll Band";	
        break;	
	    case 26: level.name = "Live It Up - Nicky Jam feat. Will Smith";	
        break;	
	    case 27: level.name = "Gente de Zona - La Gozadera";	
        break;	
	    case 28: level.name = "Onetox - Ramukanji";	
        break;	
	    case 29: level.name = "Pit Bull - Oye";	
        break;	
		case 30: level.name = "Coast Modern - Dive";	
        break;	
	    case 31: level.name = "Daddy Yankee + Katy Perry - Con Calma Remix";	
        break;	
	    case 32: level.name = "Onetox - Leabana";	
        break;	
	    case 33: level.name = "Don't You Want Me Baby	";	
        break;	
	    case 34: level.name = "Pointer sisters - Automatic";	
        break;	
		case 35: level.name = "Thalia, Gente de Zona - Lento";	
        break;	
		case 36: level.name = "Hermes House Band - Country Roads Remix";	
        break;
		case 37: level.name = "The Beach Boys - Kokomo";	
        break;
		case 38: level.name = "Yello - Oh yeah";	
        break;
		case 39: level.name = "Mambo number 5 - Lou Bega";	
        break;
		case 40: level.name = "Mexa mexa";	
        break;
		case 41: level.name = "Mile Kitic i Juzni Vetar - Znas li sta o njoj";	
        break;
		case 42: level.name = "Mc Yankoo x DJ Bobby B. x Jacky Jack - GAS";	
        break;
		case 43: level.name = "CONNECT FEAT. COBY - LOKACIJA";	
        break;
		case 44: level.name = "CONNECT - PIJANA";	
        break;
		case 45: level.name = "Vuco - Volim Piti";	
        break;
		case 46: level.name = "VUK MOB - KLUB ILI KAFANA";	
        break;
		case 47: level.name = "Mc Yankoo feat Milica Todorovic - Moje Zlato";	
        break;
		case 48: level.name = "CORONA - IZVINI MAMA";	
        break;
		case 49: level.name = "Dragana Mirkovic - Tebi ljubav meni bol";	
        break;
		case 50: level.name = "DJ SNS feat Semko - Djevojka sa Balkana";	
        break;
		case 51: level.name = "Lookas - Loko";	
        break;
		case 52: level.name = "Party Favor - Booty Loose";	
        break;
		case 53: level.name = "The Great Escape - I Cant Resist Nebbra Remix";	
        break;
		case 54: level.name = "Grebz - Afterparty";	
        break;
		case 55: level.name = "Die Strase lebt";	
        break;
		case 56: level.name = "Flechette - Bones";	
        break;
		case 57: level.name = "8Ers - Indestructable";	
        break;
		case 58: level.name = "Onderkoffer x MIME - OMG";	
        break;
		case 59: level.name = "A$AP Mob - Yamborghini High";	
        break;
		case 60: level.name = "50 Cent - PIMP";	
        break;
		case 61: level.name = "Mr Puta - Green Stuff (Malua Remix)";	
        break;
		case 62: level.name = "Timmy Trumpet & Sub Zero Project - Project X";	
        break;
		case 63: level.name = "World Renowned";	
        break;
		case 64: level.name = "Alignment - Dark Space";	
        break;
		case 65: level.name = "WOW";	
        break;
		case 66: level.name = "Maximum Force (Defqon.1 Anthem 2018)";	
        break;
		case 67: level.name = "Bansuri";	
        break;
		case 68: level.name = "FISHER - You Little Beauty";	
        break;
		case 69: level.name = "DJ Isaac & Crystal Lake - Stick Em";	
        break;		
		case 70: level.name = "J A G E R M E I S T E R";	
        break;		
	}	
}

addKillcamTimer(camtime)
{
	if (! isDefined(self.fkc_timer))
	{
		self.fkc_timer = createFontString("big", 1.72);
		self.fkc_timer.archived = false;
		self.fkc_timer.x = 0;
		self.fkc_timer.alignX = "center";
		self.fkc_timer.alignY = "middle";
		self.fkc_timer.horzAlign = "center_safearea";
		self.fkc_timer.vertAlign = "top";
		self.fkc_timer.y = 40;
		self.fkc_timer.sort = 1;
		self.fkc_timer.font = "big";
		self.fkc_timer.foreground = true;
		self.fkc_timer.color = (1,1,1);
		self.fkc_timer.hideWhenInMenu = true;
	}
	self.fkc_timer.y = 40;
	self.fkc_timer.alpha = 1;
	self.fkc_timer setTenthsTimer(camtime);
}
setKillCamEntity( killcamentityindex, delayms )
{
	self endon("disconnect");
	self endon("end_killcam");
	self endon("spawned");
	
	if ( delayms > 0 )
		wait delayms / 1000;
	
	self.killcamentity = killcamentityindex;
}