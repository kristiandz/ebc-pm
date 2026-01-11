#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;
#include scripts\utility\_utility;

init()
{	
	level.missionCallbacks = [];
	registerMissionCallback("playerKilled", ::challenge_kills);
}

AngleClamp180(angle)
{
	angleFrac = angle / 360.0;
	angle = (angleFrac - floor(angleFrac)) * 360.0;
	if(angle > 180.0)
		return angle - 360.0;
	return angle;
}

registerMissionCallback(callback, func)
{
	if(!isDefined(level.missionCallbacks[callback]))
		level.missionCallbacks[callback] = [];
	level.missionCallbacks[callback][level.missionCallbacks[callback].size] = func;
}

challenge_kills(data)
{
	if(!isDefined(data.attacker) || !isPlayer(data.attacker))
		return;
	player = data.attacker;
	time = data.time;
	weaponClass = getWeaponClass(data.sWeapon);

	// Melee category
	if(data.sMeansOfDeath == "MOD_MELEE")
		ch_meleeCategory(data, player);
	// Bullet category
	if(data.sMeansOfDeath == "MOD_RIFLE_BULLET" || data.sMeansOfDeath == "MOD_PISTOL_BULLET")
		ch_bulletCategory(data, player, weaponClass);
	// Explosives category
	if(data.sMeansOfDeath == "MOD_GRENADE_SPLASH" || data.sMeansOfDeath == "MOD_EXPLOSIVE" || data.sMeansOfDeath == "MOD_PROJECTILE")
		ch_explosiveCategory(data, player);

	// Other categories
	if(!isDefined(player.tBagCheckStarted))
		player thread tBagCheck(data.victim.origin);
	// Took a wepaon
	if(isDefined(player.tookWeaponFrom[data.sWeapon]))
	{
		player increaseStats(3128, 8);
		player processChallenge("Tactician", "Steal enemy weapons");
	}
	// Headshot
	if(data.sMeansOfDeath == "MOD_HEAD_SHOT")
	{
		player increaseStats(3123, 3);
		player processChallenge("Hitman","Make a clean headshot kill");
	}
	// Air
	if(!data.attackerOnGround)
	{
		player increaseStats(3129, 9);
		player processChallenge("Trickster", "Get an air kill after jumping");
	}
	if(maps\mp\gametypes\_globallogic::getTimeRemaining() > 150000 && (level.gametype == "sd" || level.gametype == "sr" ))
	{
		player increaseStats(3125, 5);
		player processChallenge("Daredevil", "Kill in the first 15 seconds");
	}
}

tBagCheck(origin)
{
	self endon("death");
	self endon("disconnect");
	
	while(distance2D(self.origin, origin) > 50)
	{
		wait 0.1;
		if(!isDefined(self)) // Why is the self endon not enough ??
			return;
	}
	for(i = 0; i < 2; i++)
	{
		while(self getStance() != "crouch")
			wait 0.05;
		while(self getStance() != "stand")
			wait 0.05;
	}
	self increaseStats(3126, 6);
	self processChallenge("Weirdo", "Teabag an enemy");
}

ch_meleeCategory(data, player)
{
	vAngles = data.victim.anglesOnDeath[1];
	pAngles = player.anglesOnKill[1];
	angleDiff = AngleClamp180(vAngles - pAngles);
	// Ninja challenge requirements
	if (abs(angleDiff) < 30)
	{
		player increaseStats(3121, 1);
		player processChallenge("Ninja", "Melee an enemy from behind");
	}
	else
	{
		player increaseStats(3121, 1);
		player processChallenge("Ninja", "Melee an enemy");
	}
}

ch_explosiveCategory(data, player)
{
	player increaseStats(3122, 2);
	player processChallenge("Demolition", "Get kills with explosives");
}

ch_bulletCategory(data, player, weaponClass)
{
	vAngles = data.victim.anglesOnDeath[1];
	pAngles = player.anglesOnKill[1];
	angleDiff = AngleClamp180(vAngles - pAngles);
	
	// Ninja

	// Demolition

	// Trickster challenge requirements

	// Hitman challenge requirements
	if(weaponClass == "weapon_pistol" && data.sMeansOfDeath == "MOD_HEAD_SHOT")
	{
		player increaseStats(3123, 3);
		player processChallenge("Hitman", "Get a pistol headshot");
	}
	if(data.attackerStance == "prone" && weaponClass == "weapon_sniper" && distance2D(player.origin, data.victim.origin) > 200)
	{
		player increaseStats(3123, 3);
		player processChallenge("Hitman", "Long range sniper shot while prone");
	}
	if (abs(angleDiff) < 30)
	{
		player increaseStats(3123, 3);
		player processChallenge("Hitman", "Kill an enemy from behind");
	}

	// Juggernaut challenge requirements
	if(data.health < 40)
	{
		player increaseStats(3124, 4);
		player processChallenge("Juggernaut", "Kill an enemy while hurt");
	}
	// Daredevil challenge requirements
	

	// Assault challenge requirements
	if(weaponClass == "weapon_rifle")
	{
		player increaseStats(3127, 7);
		player processChallenge("Assault", "Get a rifle kill");
	}

	// Tactician challenge requirements
	if(data.victimHealth < 40 && (data.attacker.pers["damage_done_last"] > data.victimHealth))
	{
		player increaseStats(3128, 8);
		player processChallenge("Tactician", "Execute an enemy with low health");
	}

	// Precision challenge requirements
	if(data.attackerStance == "crouch" && weaponClass == "weapon_pistol" && distance2D(player.origin, data.victim.origin) > 100)
	{
		player increaseStats(3125, 5);
		player processChallenge("Precision", "Distant pistol kill from a crouch");
	}
}

playerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, sHitLoc)
{	
	self.anglesOnDeath = self getPlayerAngles();
	if(isDefined(attacker))
		attacker.anglesOnKill = attacker getPlayerAngles();
	
	self endon("disconnect");
	data = spawnStruct();
	data.victim = self;
	data.eInflictor = eInflictor;
	data.attacker = attacker;
	data.iDamage = iDamage;
	data.sMeansOfDeath = sMeansOfDeath;
	data.sWeapon = sWeapon;
	data.sHitLoc = sHitLoc;
	data.health = attacker.health;
	data.victimHealth = self.pers["health_current"];
	data.time = getTime();
	data.victimOnGround = data.victim isOnGround();
	
	if(isPlayer(attacker))
	{
		data.attackerOnGround = data.attacker isOnGround();
		data.attackerStance = data.attacker getStance();
	}
	else
	{
		data.attackerOnGround = false;
		data.attackerStance = "stand";
	}
	waitAndProcessPlayerKilledCallback(data);
}

waitAndProcessPlayerKilledCallback(data)
{
	if(isDefined(data.attacker))
		data.attacker endon("disconnect");
	wait .05;
	maps\mp\gametypes\_globallogic::WaitTillSlowProcessAllowed();
	doMissionCallback("playerKilled", data);
}

doMissionCallback(callback, data)
{	
	if(!isDefined(level.missionCallbacks[callback]))
		return;
	if(isDefined(data)) 
		for(i = 0; i < level.missionCallbacks[callback].size; i++)
			thread [[level.missionCallbacks[callback][i]]](data);
	else 
		for(i = 0; i < level.missionCallbacks[callback].size; i++)
			thread [[level.missionCallbacks[callback][i]]]();
}

processChallenge(category, challenge)
{
	self thread splashQueue(category, challenge);
	self givePlayerScore("Challenge completed", 1);
	self underScorePopup(category + " updated");
}

givePlayerScore(event, score)
{
	self maps\mp\gametypes\_rank::giveRankXP(event, score);
	self.pers["score"] += score;
	self maps\mp\gametypes\_persistence::statAdd("score", (self.pers["score"] - score));
	self.score = self.pers["score"];
	self notify ("update_playerscore_hud");
}

splashQueue(category, challenge)
{
	// Workaround for now, a full queue should be implemented
	self challengeSplashNotify(category, challenge);
}

challengeSplashNotify(category, description)
{	
	self endon("disconnect");
	self destroyChallengeSplash();
	wait 0.05;

	if(description.size > 26)
		width = 210;
	else
		width = 160;

	self.ui_challenge[0] = newClientHudElem(self);
	self.ui_challenge[0].x = -150;
	self.ui_challenge[0].y = -95;
	self.ui_challenge[0].alignX = "left";
	self.ui_challenge[0].horzAlign = "left";
	self.ui_challenge[0].vertAlign = "middle";
	self.ui_challenge[0].alignY = "bottom";
	self.ui_challenge[0] setShader("gradient_top", width, 15);
	self.ui_challenge[0].alpha = 0.3;
	self.ui_challenge[0].sort = 900;
	self.ui_challenge[0].hideWhenInMenu = true;
	self.ui_challenge[0].archived = false;

	self.ui_challenge[1] = newClientHudElem(self);
	self.ui_challenge[1].x = -150;
	self.ui_challenge[1].y = -70;
	self.ui_challenge[1].alignX = "left";
	self.ui_challenge[1].horzAlign = "left";
	self.ui_challenge[1].vertAlign = "middle";
	self.ui_challenge[1].alignY = "bottom";
	self.ui_challenge[1] setShader("gradient_bottom", width, 15);
	self.ui_challenge[1].alpha = 0.2;
	self.ui_challenge[1].sort = 901;
	self.ui_challenge[1].hideWhenInMenu = true;
	self.ui_challenge[1].archived = false;

	self.ui_challenge[2] = addTextHud(self, -100, -97, 1, "left", "middle", 1.4); 
	self.ui_challenge[2].horzAlign = "left";
	self.ui_challenge[2].vertAlign = "middle";
	self.ui_challenge[2] setText(category);
	self.ui_challenge[2].sort = 903;
	self.ui_challenge[2].hideWhenInMenu = true;
	self.ui_challenge[2].archived = false;

	self.ui_challenge[3] = addTextHud(self, -100, -82, 1, "left", "middle", 1.4);
	self.ui_challenge[3].horzAlign = "left";
	self.ui_challenge[3].vertAlign = "middle";
	self.ui_challenge[3] setText(description);
	self.ui_challenge[3].font = "big";
	self.ui_challenge[3].sort = 904;
	self.ui_challenge[3].hideWhenInMenu = true;
	self.ui_challenge[3].archived = false;

	self.ui_challenge[4] = newClientHudElem(self);
	self.ui_challenge[4].x = -150;
	self.ui_challenge[4].y = -110;
	self.ui_challenge[4].alignX = "left";
	self.ui_challenge[4].horzAlign = "left";
	self.ui_challenge[4].vertAlign = "middle";
	self.ui_challenge[4].alignY = "bottom";
	self.ui_challenge[4] setShader("line_horizontal", width, 1);
	self.ui_challenge[4].alpha = 0.3;
	self.ui_challenge[4].sort = 905;
	self.ui_challenge[4].hideWhenInMenu = true;
	self.ui_challenge[4].archived = false;

	self.ui_challenge[5] = newClientHudElem(self);
	self.ui_challenge[5].x = -150;
	self.ui_challenge[5].y = -69;
	self.ui_challenge[5].alignX = "left";
	self.ui_challenge[5].horzAlign = "left";
	self.ui_challenge[5].vertAlign = "middle";
	self.ui_challenge[5].alignY = "bottom";
	self.ui_challenge[5] setShader("line_horizontal", width, 1);
	self.ui_challenge[5].alpha = 0.3;
	self.ui_challenge[5].sort = 906;
	self.ui_challenge[5].hideWhenInMenu = true;
	self.ui_challenge[5].archived = false;
		
	for(i = 0 ; i < self.ui_challenge.size && isDefined(self.ui_challenge[i]); i++)
		self.ui_challenge[i] moveOverTime(0.15);
	self.ui_challenge[0].x = 5;
	self.ui_challenge[1].x = 5;
	self.ui_challenge[2].x = 10;
	self.ui_challenge[3].x = 10;
	self.ui_challenge[4].x = 5;
	self.ui_challenge[5].x = 5;

	wait 3;
	for(i = 0; i < self.ui_challenge.size && isDefined(self.ui_challenge[i]); i++)
		self.ui_challenge[i] moveOverTime(0.15);

	if(isDefined(self.ui_challenge[0]))
	{
		self.ui_challenge[0].x = -150;
		self.ui_challenge[1].x = -150;
		self.ui_challenge[2].x = -100;
		self.ui_challenge[3].x = -100;
		self.ui_challenge[4].x = -150;
		self.ui_challenge[5].x = -150;
	}

	wait 0.05;
	self destroyChallengeSplash();
}

destroyChallengeSplash()
{
	if(!isDefined( self.ui_challenge ) || !self.ui_challenge.size)
		return;
	for(i = 0; i < self.ui_challenge.size; i++)
		self.ui_challenge[i] destroy();
	self.ui_challenge = [];
}

addTextHud(who, x, y, alpha, alignX, alignY, fontScale)
{
	if(isPlayer(who))
		hud = newClientHudElem(who);
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

increaseStats(stat, category)
{
	// Total counter is +10 for all
	// Example 3123 = active, 3133 = total for the same category
	active_stat = self GetStat(stat);
	total_stat = self GetStat(stat+10);
	self SetStat(stat, active_stat + 1);
	self SetStat(stat+10, total_stat + 1);

	self refreshUI(category);
}

refreshUI(category)
{
	challenge = scripts\utility\challenge_utility::getChallengeData(category);

	if(challenge[1] == self GetStat(3117))
		x = 1;
	else if(challenge[1] == self GetStat(3118))
		x = 3;
	else
		return;

	self setClientDvar("ui_challenge_stats_" + x, challenge[3]);
	// Just the primary for now, untill we define the activation round logic
}