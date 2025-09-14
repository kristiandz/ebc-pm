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
		case 1:	level.name = "Classified Donk";
		break;
		case 2:	level.name = "Classified Donk";
		break;
		case 3:	level.name = "Classified Donk";
		break;
		case 4:	level.name = "Classified Donk";
		break;
		case 5:	level.name = "Classified Donk";
		break;
		case 6:	level.name = "XS Project - Brosay Dolbit";
		break;
		case 7:	level.name = "XS Project - Tashus Ot Kolotushek";
		break;
		case 8:	level.name = "DJ BLYATMAN - BETON";
		break;
		case 9:	level.name = "Classified Donk";
		break;
		case 10: level.name = "Classified Donk";
		break;
		case 11: level.name = "HU Biss - Closer";
		break;
		case 12: level.name = "Mr. Cheez - So Sexy";
		break;
		case 13: level.name = "Excision - Live Wire";
		break;
		case 14: level.name = "Toby Green - Check this";
		break;
		case 15: level.name = "Tony Junior - Cobra";
		break;
		case 16: level.name = "SKisM - Experts";
		break;
		case 17: level.name = "Yellow Claw x EURO TRASH - BENZ";
		break;
		case 18: level.name = "Deorro - Five Hours";
		break;
		case 19: level.name = "EXPOSED - Show Me";
		break;
		case 20: level.name = "Drenchill - Freed from desire";
		break;
		case 21: level.name = "Disturbed -Unstoppable";
		break;
		case 22: level.name = "IOU - FFDP";
		break;
		case 23: level.name = "Simple Plan - Take My Hand ";	
        break;	
	    case 24: level.name = "Tom Petty - Free Fallin";	
        break;	
	    case 25: level.name = "Creedence Clearwater Revival - Fortunate Son";	
        break;	
	    case 26: level.name = "Tritonal - Colors";	
        break;	
	    case 27: level.name = "99 Luftballons";	
        break;	
	    case 28: level.name = "DMP - Wine Up";	
        break;	
	    case 29: level.name = "Jimmy Cliff- Roots Woman";
        break;	
		case 30: level.name = "Sade - Smooth Operator";	
        break;	
	    case 31: level.name = "JC REYES - FARDOS";	
        break;	
	    case 32: level.name = "Cameo - Candy";	
        break;	
	    case 33: level.name = "La Factoría - Perdoname";	
        break;	
	    case 34: level.name = "Cuddly Toy";	
        break;	
		case 35: level.name = "Gipsy Kings - Hotel California";	
        break;	
		case 36: level.name = "HXI HXELLPLAYA -HELLDRIFT 2";
        break;
		case 37: level.name = "Beki Bekic -Carlama";
        break;
		case 38: level.name = "Yolanda Be Cool - We No Speak Americano";
        break;
		case 39: level.name = "Dođi na morski greben - Nikad izvini";
        break;
		case 40: level.name = "Surprise";
        break;
		case 41: level.name = "Misko Dilin - Provincijalac";
        break;
		case 42: level.name = "Sateliti - Gradksa moda";
        break;
		case 43: level.name = "Hoptek";
        break;
		case 44: level.name = "Ceca x Maya Berović - Ne računaj na mene";
        break;
		case 45: level.name = "MM - NAŠIKAM SE I PRAVIM HAOS";
        break;
		case 46: level.name = "Nikos Kourkoulis - Mera Me Ti Mera";
        break;
		case 47: level.name = "Akcent feat. Nicole Cherry - Si Me Quieres";
        break;
		case 48: level.name = "Kristali - Rakia";
        break;
		case 49: level.name = "DIONA - NEPOKORNA";
        break;
		case 50: level.name = "Koktel ljubavi";
        break;
		case 51: level.name = "Tomsize - All That Ass";
        break;
		case 52: level.name = "Tony Junior - Police (Savagez Remix)";
        break;
		case 53: level.name = "mute - HEAVY";
        break;
		case 54: level.name = "Mr. Carmack - Pay For What";
        break;
		case 55: level.name = "DMX - X Gon Give It To Ya";
        break;
		case 56: level.name = "Dread Pitt - Arena";
        break;
		case 57: level.name = "Dieom - VIOLENT";
        break;
		case 58: level.name = "Tropkillaz & Buku  Follow the Beat";
        break;
		case 59: level.name = "Major Lazer - Jah No Partial (CRNKN Remix)";
        break;
		case 60: level.name = "Linkin Park - In The End (NOES Remix)";
        break;
		case 61: level.name = "Sub Focus, Cherish, ACRAZE - Do It To It";
        break;
		case 62: level.name = "ENDRIU & MAESTRO - W KLAPKACH (KNASSIX)";
        break;
		case 63: level.name = "Jengi - Bel Mercy (DJ KAKA Bootleg)";
        break;
		case 64: level.name = "Sak Noel - Loca (TAIMEN & KUBIX BOOTLEG)";
        break;
		case 65: level.name = "Trese Mi Se Lada";
        break;
		case 66: level.name = "Sickbrain - Doing This";
        break;
		case 67: level.name = "Marshall Jefferson x Solardo - Move Your Body";
        break;
		case 68: level.name = "Dr.Peacock - Trip to Greece";
        break;
		case 69: level.name = "D-Sturb & Act Of Rage & Nolz - Magnetism";
        break;		
		case 70: level.name = "Act of Rage & D-Sturb - Let The Games Begin";
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