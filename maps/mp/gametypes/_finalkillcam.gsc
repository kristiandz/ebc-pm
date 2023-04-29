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
	self.villain = createFontString("default", 1.7);
	self.villain setPoint("CENTER", "BOTTOM", -510, -55); 
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

	self.versus = createFontString("default", 1.7);
	self.versus.alpha = 0;
	self.versus setPoint("CENTER", "BOTTOM", 0, -55);  
	self.versus.archived = false;
	self.versus setText("vs");
	self.versus.foreground = true;    
	self.versus.glowColor = level.randomcolour;
	self.versus fadeOverTime(4);
	self.versus.alpha = 1;
  
	self.victim = createFontString("default", 1.7);
	self.victim setPoint("CENTER", "BOTTOM", 510, -55);
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
		self.sname = createFontString("default", 1);
		self.sname setPoint("LEFT", "BOTTOM", 0, 10);  
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
		case 1:	level.name = "Iron Project - Mind Games";
		break;
		case 2:	level.name = "Nochnoj Desant";
		break;
		case 3:	level.name = "IRON PROJECT - Mind Games";
		break;
		case 4:	level.name = "Nochnoj desant(vol.1)";
		break;
		case 5:	level.name = "Nochnoj desant(vol.1)";
		break;
		case 6:	level.name = "Nochnoj desant(vol.1)";
		break;
		case 7:	level.name = "Iron Project - Let’s Bass";
		break;
		case 8:	level.name = "XS Project - Zhelezno";
		break;
		case 9:	level.name = "Hi-Tech - Let There Be Light";
		break;
		case 10: level.name = "2 In A Room - Wiggle It (Dead Factory Remix)";
		break;
		case 11: level.name = "Beave Good 4 U";
		break;
		case 12: level.name = "Sam Feldt - Crying On The Dancefloor";
		break;
		case 13: level.name = "Forever";
		break;
		case 14: level.name = "Never be the same again";
		break;
		case 15: level.name = "John North x Ana Es - This Feeling";
		break;
		case 16: level.name = "Defqwop Heart Afire";
		break;
		case 17: level.name = "Boombox Cartel -Moody (Ace Aura Mix)";
		break;
		case 18: level.name = "Borgore - Cant squad with us";
		break;
		case 19: level.name = "Vinai - Legend";
		break;
		case 20: level.name = "Vide - Top Of The World";
		break;
		case 21: level.name = "Pretend Were Dead";
		break;
		case 22: level.name = "Sum 41 - Pain For Pleasure";
		break;
		case 23: level.name = "The Pretty Reckless - Going To Hell";	
        break;	
	    case 24: level.name = "Stone Sour - Absolute Zero";	
        break;	
	    case 25: level.name = "Hardcore - Beast in Black";	
        break;	
	    case 26: level.name = "Flo Rida - I Dont Like It I Love It";	
        break;	
	    case 27: level.name = "Kygo Imagine Dragons - Born To Be Yours ";	
        break;	
	    case 28: level.name = "Post Malone - Go Flex";	
        break;	
	    case 29: level.name = "Bon Jovi - Have A Nice Day";	
        break;	
		case 30: level.name = "Willie Williams - Armagideon Time";	
        break;	
	    case 31: level.name = "Call me Maybe";	
        break;	
	    case 32: level.name = "Travis Scott  goosebumps ft Kendrick Lamar";	
        break;	
	    case 33: level.name = "Run This Town(Riton Remix)";	
        break;	
	    case 34: level.name = "Nate Dogg - Keep It Coming";	
        break;	
		case 35: level.name = "Calvin Harris  This Is What You Came For";	
        break;	
		case 36: level.name = "Vatrogasci - Samo zbog litre";	
        break;
		case 37: level.name = "Motokultivator";	
        break;
		case 38: level.name = "Dragan Savic - Muska kurva";	
        break;
		case 39: level.name = "Hm";	
        break;
		case 40: level.name = "CUVAJ GLAVU";	
        break;
		case 41: level.name = "MC Stojan - Lete Pare";	
        break;
		case 42: level.name = "Hako - Ko na cilimu";	
        break;
		case 43: level.name = "Inas  Da da da";	
        break;
		case 44: level.name = "Pare pare";	
        break;
		case 45: level.name = "Indy - Bato Bre";	
        break;
		case 46: level.name = "Mile Kitic - Svi su tu";	
        break;
		case 47: level.name = "Jana - Ostavi mi drugove";	
        break;
		case 48: level.name = "MC YANKOO - FRANKFURT BEC";	
        break;
		case 49: level.name = "Maya Berović Neka Stvar";	
        break;
		case 50: level.name = "Dzek i Dzoni (Rastoni Mix)";	
        break;
		case 51: level.name = "Big Pun Noriega - You Came Up";	
        break;
		case 52: level.name = "DROELOE  In Time feat Belle Doron";	
        break;
		case 53: level.name = "KLOUD  Dark Down Below";	
        break;
		case 54: level.name = "Peacemakers - Gonna Party Like";	
        break;
		case 55: level.name = "TOMYGONE - Yoshimitsu";	
        break;
		case 56: level.name = "Egzod - Reserve";	
        break;
		case 57: level.name = "YZKN  Bounce";	
        break;
		case 58: level.name = "50 Cent - In Da Club";	
        break;
		case 59: level.name = "Zella Day - Compass Vanic Remix";	
        break;
		case 60: level.name = "XXTRAKT & Charlie Traplin - Run";	
        break;
		case 61: level.name = "Henning Baer - Burning Chrome";	
        break;
		case 62: level.name = "Marco Bailey Swag";	
        break;
		case 63: level.name = "Paul Elstak New Kids - Turbo";	
        break;
		case 64: level.name = "Regal - Still Raving";	
        break;
		case 65: level.name = "Asquith - Set The Trap ";	
        break;
		case 66: level.name = "Waveshock - Shake Me Down";	
        break;
		case 67: level.name = "KASST - Hell On Earth";	
        break;
		case 68: level.name = "MJ Cole - Pictures In My Head (High Contrast Remix)";	
        break;
		case 69: level.name = "Wait A Minute";	
        break;		
		case 70: level.name = "Jeroen Search - Twin Paradox";	
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