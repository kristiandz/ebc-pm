#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

finalKillcamWaiter()
{
	if(!level.inFinalKillcam)
		return;
	while(level.inFinalKillcam)
		wait(0.05);
}

postRoundFinalKillcam()
{
	level notify("play_final_killcam");
	thread playsound();
	maps\mp\gametypes\_globallogic_utils::resetOutcomeForAllPlayers();
	finalKillcamWaiter();	
}

playsound()
{
    genre[0] = (1 + randomInt(10));   //hardbass
    genre[1] = (11 + randomInt(10));  //edm
    genre[2] = (21 + randomInt(5));   //rock
    genre[3] = (26 + randomInt(10));  //pop
    genre[4] = (36 + randomInt(5));   //troll
    genre[5] = (41 + randomInt(10));  //balkan
    genre[6] = (51 + randomInt(10));  //trap
    genre[7] = (61 + randomInt(10));  //rave    
        
    players = getAllPlayers();
    for(i = 0; i < players.size; i++)
    {
        if(players[i] getstat(1224) == 0)
            continue;
		stat = [];
        for(k = 0; k < 8; k++)
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
		if(isDefined(number) && number.size != 0)
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
    return getEntArray("player", "classname");
}

startFinalKillcam(attackerNum, targetNum, killcamentityindex, sWeapon, deathTime, deathTimeOffset, offsetTime, attacker, victim, villain_name, victim_name)
{
	if(attackerNum < 0)
		return;
	recordKillcamSettings(attackerNum, targetNum, sWeapon, deathTime, deathTimeOffset, offsetTime, attacker, killcamentityindex, victim, villain_name, victim_name);
	startLastKillcam();
}

startLastKillcam()
{
	if(level.inFinalKillcam)
		return;
	if(!isDefined(level.lastKillCam))
		return;
	
	level.inFinalKillcam = true;
	level waittill("play_final_killcam");

	players = level.players;
	for(index = 0; index < players.size; index++)
	{
		player = players[index];
		player closeMenu(); 
		player closeInGameMenu();
		player thread finalKillcam();
	}
	wait(0.1);
	while(areAnyPlayersWatchingTheKillcam())
		wait(0.05);

	level.inFinalKillcam = false;
}

areAnyPlayersWatchingTheKillcam()
{
	players = level.players;
	for(index = 0; index < players.size; index++)
	{
		player = players[index];
		if(isDefined(player.killcam))
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

waitFinalKillcamSlowdown(startTime)
{
	self endon("disconnect");
	self endon("end_finalkillcam");
	secondsUntilDeath = ((level.lastKillCam.deathTime - startTime) / 1000);
	deathTime = getTime() + secondsUntilDeath * 1000;
	waitBeforeDeath = 2;
	wait(max(0, (secondsUntilDeath - waitBeforeDeath)));
	setTimeScale(1, int( deathTime - 500));
	wait(waitBeforeDeath);
	setTimeScale(1,getTime());
}

setTimeScale(to, time)
{
	difference = (abs(getTime() - time)/1000);
	timescale = getDvarFloat("timescale");
	if(difference != 0) 
	{
		for(i = timescale * 20; i >= to * 20; i -= 1 )
		{
			wait((int(difference) / int(getDvarFloat("timescale") * 20)) / 20);
			setDvar("timescale", i / 20);
		} 
	}
	else
		setDvar("timescale", to);
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
		if(self.archivetime <= 0)
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
		if(!isDefined(maps\mp\gametypes\_globallogic::getPlayerFromClientNum(level.lastKillCam.spectatorclient)))
			break;
		wait 0.05;
	}
	self notify("end_finalkillcam");
}

recordKillcamSettings(spectatorclient, targetentityindex, sWeapon, deathTime, deathTimeOffset, offsettime, attacker, entityindex, victim, villain_name, victim_name)
{
	if(!isDefined(level.lastKillCam))
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
	level.lastKillCam.villain_name = villain_name; //
	level.lastKillCam.victim_name = victim_name; //
}

finalKillcam()
{
	self endon("disconnect");
	level endon("game_ended");
	self notify("end_killcam");
	self setClientDvar("cg_airstrikeKillCamDist", 20);
	
	postDeathDelay = (getTime() - level.lastKillCam.deathTime) / 1000;
	predelay = postDeathDelay + level.lastKillCam.deathTimeOffset;
	camtime = calcKillcamTime(level.lastKillCam.weapon, predelay, false, undefined);
	postdelay = calcPostDelay();
	killcamoffset = camtime + predelay;
	killcamlength = camtime + postdelay - 0.05;
	killcamstarttime = (gettime() - killcamoffset * 1000);

	self notify("begin_killcam", getTime());

	self.sessionstate = "spectator";
	self.spectatorclient = level.lastKillCam.spectatorclient;
	self.killcamentity = -1;
	if(level.lastKillCam.entityindex >= 0)
		self thread setKillCamEntity(level.lastKillCam.entityindex, 0 - killcamstarttime - 100);
	self.killcamtargetentity = level.lastKillCam.targetentityindex;
	self.archivetime = killcamoffset;
	self.killcamlength = killcamlength;
	self.psoffsettime = level.lastKillCam.offsettime;

	self allowSpectateTeam("allies", true);
	self allowSpectateTeam("axis", true);
	self allowSpectateTeam("freelook", false);
	self allowSpectateTeam("none", false);

	wait 0.05;
	if(self.archivetime <= predelay)
	{
		self.sessionstate = "dead";
		self.spectatorclient = -1;
		self.killcamentity = -1;
		self.archivetime = 0;
		self.psoffsettime = 0;
		self notify("end_finalkillcam");
		return;
	}
	
	self thread checkForAbruptKillcamEnd();
	self thread checkPlayers();
	self.killcam = true;
	self addKillcamTimer(camtime);
	self addKillcamKiller(level.lastKillCam.attacker, level.lastKillCam.victim, level.lastKillCam.villain_name, level.lastKillCam.victim_name);
	self thread waitKillcamTime();
	self thread waitFinalKillcamSlowdown(killcamstarttime);
	self waittill("end_finalkillcam");
	
	if(isDefined(self.sname)) 
		self.sname destroy();
	
	self.villain destroy();
	self.versus destroy();
	self.victim destroy();
	self endKillcam();
}

isKillcamGrenadeWeapon(sWeapon)
{
	if(sWeapon == "frag_grenade_mp")
		return true;
	else if(sWeapon == "frag_grenade_short_mp")
		return true;
	return false;
}

calcKillcamTime(sWeapon, predelay, respawn, maxtime)
{
	camtime = 0.0;
	if(isKillcamGrenadeWeapon(sWeapon))
		camtime = 4.25; 
	else
		camtime = 5;
	if(isdefined(maxtime)) 
	{
		if(camtime > maxtime)
			camtime = maxtime;
		if(camtime < .05)
			camtime = .05;
	}
	return camtime;
}

calcPostDelay()
{
	postdelay = 1;
	// Time after player death that killcam continues for
	if(getDvar( "scr_killcam_posttime") == "")
		postdelay = 2;
	else 
	{
		postdelay = getDvarFloat( "scr_killcam_posttime");
		if(postdelay < 0.05)
			postdelay = 0.05;
	}
	return postdelay;
}

addKillcamKiller(attacker, victim, attacker_name, victim_name)
{
	self.villain = createFontString("objective", 1.5);
	self.villain setPoint("CENTER", "BOTTOM", -510, -59); 
	self.villain.alignX = "right";
	self.villain.archived = false;
	if(isDefined(attacker))	
		self.villain setPlayerNameString(attacker);
	else
		self.villain setText(attacker_name);
	self.villain.foreground = true;  
	self.villain.alpha = 1;
	self.villain.glowalpha = 1;
	self.villain.glowColor = level.randomcolour;
	self.villain moveOverTime(4);
	self.villain.x = -30;  

	self.versus = createFontString("objective", 1.4);
	self.versus.alpha = 0;
	self.versus setPoint("CENTER", "BOTTOM", 0, -59);  
	self.versus.archived = false;
	self.versus setText("vs");
	self.versus.foreground = true;    
	self.versus.glowColor = level.randomcolour;
	self.versus fadeOverTime(4);
	self.versus.alpha = 1;
  
	self.victim = createFontString("objective", 1.5);
	self.victim setPoint("CENTER", "BOTTOM", 510, -59);
	self.victim.alignX = "left";  
	self.victim.archived = false;
	if(isDefined(victim)) 
		self.victim setPlayerNameString(victim);
	else 
		self.victim setText(victim_name);
	self.victim.foreground = true;
	self.victim.glowalpha = 1; 
	self.victim.glowColor = level.randomcolour;
	self.victim moveOverTime(4);
	self.victim.x = 30; 
	
	if(isDefined(self.carryIcon))
		self.carryIcon destroy();
}

text()
{
	self endon("disconnect");
    names = level.name;
	if(isDefined(names) && level.gametype != "dm")
	{
		self.sname = createFontString("default", 1.4);
		self.sname setPoint("LEFT", "BOTTOM", -410, 8);  
		self.sname.archived = false;
		self.sname setText(names);
		self.sname.foreground = true; 
		self.sname.alpha = 1;
		self.sname moveOverTime(1);
		self.sname.y = -10;
	}
}

getsongname(songnum)
{
	if(!isDefined(songnum))
		return;
	switch(songnum)
	{
		case 1:	level.name = "Hu Biss - Slow";
		break;
		case 2:	level.name = "Alan Aztec - BASS ASSASSIN";
		break;
		case 3:	level.name = "Alan Aztec - Deutschland";
		break;
		case 4:	level.name = "Alan Aztec - Street Racer";
		break;
		case 5:	level.name = "uamee - BACK TO 2006";
		break;
		case 6:	level.name = "Classified Donk";
		break;
		case 7:	level.name = "Classified Donk";
		break;
		case 8:	level.name = "Classified Donk";
		break;
		case 9:	level.name = "Classified Donk";
		break;
		case 10: level.name = "Classified Donk";
		break;
		case 11: level.name = "D.O.D - So Much In Love";
		break;
		case 12: level.name = "Riva - Run Away (HU Biss Re-Work)";
		break;
		case 13: level.name = "NERUS & DJ KAKA - Blow";
		break;
		case 14: level.name = "Justice - Stress";
		break;
		case 15: level.name = "Cartoon - Why We Lose";
		break;
		case 16: level.name = "Feint - Snake Eyes";
		break;
		case 17: level.name = "HU Biss - Loto";
		break;
		case 18: level.name = "Hava Naguila Techno";
		break;
		case 19: level.name = "KSLV - Psycho";
		break;
		case 20: level.name = "Henrikz - I Dont Want";
		break;
		case 21: level.name = "Disturbed - Another Way To Die";
		break;
		case 22: level.name = "Avenged Sevenfold - Welcome to the family";
		break;
		case 23: level.name = "Finger eleven - Paralyzer ";	
        break;	
	    case 24: level.name = "Pain - Party in my head";	
        break;	
	    case 25: level.name = "Avenged Sevenfold - Shepherd Of Fire ";	
        break;	
	    case 26: level.name = "Regular Everyday Normal Motherfuck";	
        break;	
	    case 27: level.name = "Katy Perry - Firework";	
        break;	
	    case 28: level.name = "Zedd - Clarity ft Foxes";	
        break;	
	    case 29: level.name = "AWOLNATION - Sail";
        break;	
		case 30: level.name = "Live Learn";	
        break;	
	    case 31: level.name = "Sons of Zion - Crazy";	
        break;	
	    case 32: level.name = "Alok & Mathieu Koss - Big Jet Plane";	
        break;	
	    case 33: level.name = "Stevie Nicks - I cant wait";	
        break;	
	    case 34: level.name = "Giorgos Mazonakis x Arash - Tora Tora";	
        break;	
		case 35: level.name = "You are The Best";	
        break;	
		case 36: level.name = "Sickbrain - Parabole Tanczooo";
        break;
		case 37: level.name = "Peggy Gouy - It Goes Like Nanana";
        break;
		case 38: level.name = "Maco Mamuko - Whiskey, Cola & Tequila";
        break;
		case 39: level.name = "Taki sam ti ja";
        break;
		case 40: level.name = "Napoelon - Dobro dosli";
        break;
		case 41: level.name = "Sandu Ciorba - Dalibomba";
        break;
		case 42: level.name = "Tobi King - Loli Mou";
        break;
		case 43: level.name = "Kendi  Arapske Pare ";
        break;
		case 44: level.name = "Budka Suflera - Twoje Radio";
        break;
		case 45: level.name = "Beki Bekic - Carlama";
        break;
		case 46: level.name = "Sanja Ilic Balkanika Balkan";
        break;
		case 47: level.name = "Stoja - Moje Srce Ostariti Ne Sme";
        break;
		case 48: level.name = "Gistro Bancho - BALKAN BASS";
        break;
		case 49: level.name = "RADO SHISHARKATA - TIGRE";
        break;
		case 50: level.name = "Ceca - Volim te";
        break;
		case 51: level.name = "Eljay  No Pressure";
        break;
		case 52: level.name = "DMX  Ruff Ryders";
        break;
		case 53: level.name = "Big Pun x Fat Joe - Twinz";
        break;
		case 54: level.name = "8ErS - Indestructable";
        break;
		case 55: level.name = "Griby - Kopy";
        break;
		case 56: level.name = "8ErS X HPNTK Hunned Off Top";
        break;
		case 57: level.name = "LDRU Keeping Score PACES";
        break;
		case 58: level.name = "Tiber - Warrior";
        break;
		case 59: level.name = "The Prototypes - Pop It Off";
        break;
		case 60: level.name = "ARMNHMR - Rise";
        break;
		case 61: level.name = "Phara - Great Attractor";
        break;
		case 62: level.name = "RMB - Redemption";
        break;
		case 63: level.name = "Robert_Hoff - Multicellularity";
        break;
		case 64: level.name = "Viper Diva - Love  Riot";
        break;
		case 65: level.name = "XAlox - Noche En La Habana";
        break;
		case 66: level.name = "Analect - The Time Is Now";
        break;
		case 67: level.name = "Chlär - Forgot To Dream";
        break;
		case 68: level.name = "Sept - Emerging Depravation ";
        break;
		case 69: level.name = "Little Sis Nora - MDMA";
        break;		
		case 70: level.name = "Chontane  Ecosphere";
        break;		
	}	
}

addKillcamTimer(camtime)
{
	if(!isDefined(self.fkc_timer))
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
		self.fkc_timer.color = (1, 1, 1);
		self.fkc_timer.hideWhenInMenu = true;
	}
	self.fkc_timer.y = 40;
	self.fkc_timer.alpha = 1;
	self.fkc_timer setTenthsTimer(camtime);
}

setKillCamEntity(killcamentityindex, delayms)
{
	self endon("disconnect");
	self endon("end_killcam");
	self endon("spawned");
	if(delayms > 0)
		wait delayms / 1000;
	self.killcamentity = killcamentityindex;
}