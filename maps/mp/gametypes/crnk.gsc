#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

main()
{
	level.fx_flash = loadFX("impacts/cranked");
	if(getDvar("mapname") == "mp_background")
		return;
	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();
	level.teamBased = getDvarInt("scr_crnk_teambased");
	level.onStartGameType = ::onStartGameType;
	level.onSpawnPlayer = ::onSpawnPlayer;
	
	if(!level.teamBased)
		level.scoreLimit = getDvarInt("scr_crnk_ffa_scorelimit");
	
	if(level.teamBased)
		level.onRoundSwitch = ::onRoundSwitch;
}
onStartGameType()
{
	setClientNameMode("manual_change");
	maps\mp\gametypes\_globallogic::setObjectiveText("allies", &"PL_OBJECTIVES_CRNK");
	maps\mp\gametypes\_globallogic::setObjectiveText("axis", &"PL_OBJECTIVES_CRNK");
	maps\mp\gametypes\_globallogic::setObjectiveScoreText("allies", &"PL_OBJECTIVES_CRNK_SCORE");
	maps\mp\gametypes\_globallogic::setObjectiveScoreText("axis", &"PL_OBJECTIVES_CRNK_SCORE");
	maps\mp\gametypes\_globallogic::setObjectiveHintText("allies", &"PL_OBJECTIVES_CRNK_HINT");
	maps\mp\gametypes\_globallogic::setObjectiveHintText("axis", &"PL_OBJECTIVES_CRNK_HINT");
	level.spawnMins = (0, 0, 0);
	level.spawnMaxs = (0, 0, 0);
	if(level.teamBased)
	{
		maps\mp\gametypes\_spawnlogic::placeSpawnPoints("mp_tdm_spawn_allies_start");
		maps\mp\gametypes\_spawnlogic::placeSpawnPoints("mp_tdm_spawn_axis_start");
		maps\mp\gametypes\_spawnlogic::addSpawnPoints("allies", "mp_tdm_spawn");
		maps\mp\gametypes\_spawnlogic::addSpawnPoints("axis", "mp_tdm_spawn");
	}
	else
	{
		maps\mp\gametypes\_spawnlogic::addSpawnPoints("allies", "mp_dm_spawn");
		maps\mp\gametypes\_spawnlogic::addSpawnPoints("axis", "mp_dm_spawn");
	}
	level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter(level.spawnMins, level.spawnMaxs);
	setMapCenter(level.mapCenter);
	allowed[0] = level.gametype;
	allowed[1] = "tdm";
	level.displayRoundEndText = false;
	maps\mp\gametypes\_gameobjects::main(allowed);
	if(level.roundLimit != 1 && level.numLives)
	{
		level.overrideTeamScore = true;
		level.displayRoundEndText = true;
		level.onEndGame = ::onEndGame;
	}
	level.onPlayerKilled = ::onPlayerKilled;
}

onRoundSwitch()
{
	level.halftimeType = "halftime";
}

onSpawnPlayer()
{
	if(level.teamBased)
	{
		self.usingObj = undefined;
		if(level.inGracePeriod)
		{
			spawnPoints = getentarray("mp_tdm_spawn_" + self.pers["team"] + "_start", "classname");
			if(!spawnPoints.size)
				spawnPoints = getentarray("mp_sab_spawn_" + self.pers["team"] + "_start", "classname");
			if(!spawnPoints.size)
			{
				spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints(self.pers["team"]);
				spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam(spawnPoints);
			}
			else spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnPoints);
		}
		else
		{
			spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints(self.pers["team"]);
			spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam(spawnPoints);
		}
	}
	else
	{
		spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints(self.pers["team"]);
		spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_DM(spawnPoints);
	}
	self spawn(spawnPoint.origin, spawnPoint.angles);
}

onEndGame(winner)
{
	if(level.teamBased)
	{
		if(isDefined(winner) && (winner == "allies" || winner == "axis"))
			[[level._setTeamScore]](winner, [[level._getTeamScore]](winner) + 1);
	}
	else
	{
		if(isDefined(winner))
		[[level._setPlayerScore]](winner, winner[[level._getPlayerScore]]() + 1);
	}
}

onPlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	self endon("disconnect");
	
	if(isDefined(self.cranked_timer)) 
		self.cranked_timer destroy();
		
	if(isDefined(self.cranked)) 
		self.cranked destroy();
		
	if(isDefined(self.screenflash))
		self.screenflash destroy();
		
	if(isDefined(self.line1)) 
		self.line1 destroy();
		
	if(isDefined(self.line2)) 
		self.line2 destroy();

	self.isCranked = false;

	if(sMeansofDeath != "MOD_SUICIDE" && sMeansofDeath != "MOD_FALLING" && attacker != self)
	{
		if(isAlive(attacker)) 
		{         
			attacker playLocalSound("cranked");
			if(isDefined(attacker.isCranked) && attacker.isCranked == true)
			{
				attacker notify("cranked_over");
				if(isDefined(attacker.cranked_timer)) 
					attacker.cranked_timer destroy();
						   
				attacker thread timerCranked();
				attacker thread waitToExplode();
				
				attacker setMoveSpeedScale(1.3);
			} 
			else if(isDefined(attacker) && isAlive(attacker)) 
			{
				attacker.isCranked = true; 
				attacker thread timerCranked();
				attacker thread waitToExplode();
			}             
		}    
	}    
}

timerCranked()
{
	if(!isDefined(self.cranked_timer))
	{
		self.cranked_timer = newClientHudElem(self);
		self.cranked_timer.x = 315;
		self.cranked_timer.y = 80;
		self.cranked_timer.alignX = "center";
		self.cranked_timer.alignY = "middle";
		self.cranked_timer.horzAlign = "fullscreen";
		self.cranked_timer.vertAlign = "fullscreen";
		self.cranked_timer.fontScale = 2.7;
		self.cranked_timer.sort = 20000;
		self.cranked_timer.hidewheninmenu = true;
		self.cranked_timer.foreground = true;
		self.cranked_timer.color = game["colors"]["white"];
		self.cranked_timer.alpha = 0;
		self.cranked_timer setTenthsTimer(30);
	}
	
	if(!isDefined(self.screenflash))
	{
		self.screenflash = newClientHudElem(self);
		self.screenflash.x = 0;
		self.screenflash.y = 0;
		self.screenflash.horzAlign = "fullscreen";
		self.screenflash.vertAlign = "fullscreen";
		self.screenflash.alignX = "center";
		self.screenflash.alignY = "middle";
		self.screenflash.color = (1, 1, 1);
		self.screenflash.hidewheninmenu = true;
		self.screenflash.foreground = true;
		self.screenflash setShader("line_horizontal", 1000, 1000);
		self.screenflash.alpha = 0;
	}
	
	if(!isDefined(self.line1))
	{
		self.line1 = newClientHudElem(self);
		self.line1.x = 250;
		self.line1.y = 93;
		self.line1.horzAlign = "fullscreen";
		self.line1.vertAlign = "fullscreen";
		self.line1.alignX = "center";
		self.line1.alignY = "middle";
		self.line1.color = (1, 0.9, 0.9);
		self.line1.hidewheninmenu = true;
		self.line1.foreground = true;
		self.line1 setShader("line_horizontal", 100, 3);
		self.line1.alpha = 0;
	}
	
	if(!isDefined(self.line2))
	{
		self.line2 = newClientHudElem(self);
		self.line2.x = 370;
		self.line2.y = 93;
		self.line2.horzAlign = "fullscreen";
		self.line2.vertAlign = "fullscreen";
		self.line2.alignX = "center";
		self.line2.alignY = "middle";
		self.line2.color = (1, 0.9, 0.9);
		self.line2.hidewheninmenu = true;
		self.line2.foreground = true;
		self.line2 setShader("line_horizontal", 100, 3);
		self.line2.alpha = 0;
	}

	if(!isDefined(self.cranked))
	{
		self.cranked = newClientHudElem(self);
		self.cranked.x = 315; 
		self.cranked.y = 103;
		self.cranked.alignX = "center";
		self.cranked.alignY = "middle";
		self.cranked.horzAlign = "fullscreen";
		self.cranked.vertAlign = "fullscreen";
		self.cranked.fontScale = 1.7;
		self.cranked.sort = 20000;
		self.cranked.foreground = true;
		self.cranked.hidewheninmenu = true;
		self.cranked.color = game["colors"]["white"];
		self.cranked maps\mp\gametypes\_hud::fontPulseInit();
		self.cranked.alpha = 0;
		self.cranked setText("CRANKED");
	}
	self thread timerColor();
	self thread screenflash();
}

waitToExplode()
{
	self endon("death");
	self endon("disconnect");
	self endon("cranked_over");
	level endon("game_ended");

	wait(30);

	if(isDefined(self.cranked_timer)) 
		self.cranked_timer destroy();

	if(isAlive(self))
		self thread explodeCranked();
}

explodeCranked()
{
    if(isDefined(self.isCranked) && self.isCranked == true && isAlive(self)) 
	{
		phyExpMagnitude = 2.5;
		blastRadius = 230;

		physicsExplosionSphere(self.origin + (0, 0, 30), blastRadius, blastRadius / 2, phyExpMagnitude);
		self maps\mp\gametypes\_shellshock::barrel_earthQuake();
		playFx(level.fx_flash, self.origin);
		self playSound("grenade_explode_default");
		self notify("cranked_over");
		self suicide();
	}    
}

screenflash()
{
	if(isDefined(self.screenflash))
	{
 		self.screenflash.alpha = 1;
		wait 0.05;
		self.screenflash.alpha = 0;
	}
}

timerColor()
{
	self endon("death");
	self endon("disconnect");
	self endon("cranked_over");
		
	self.cranked_timer.alpha = 1;
	self.cranked.alpha = 1;
	self.line1.alpha = 1;
	self.line2.alpha = 1;
	self.cranked thread fontPulse(level);
	
	PlayFX(level.fx_flash , self.origin);
	Earthquake(0.3, 2, self.origin, 100);
	
	self.line1.x = 250;
	self.line2.x = 370;
	self.line1.color = (1, 0.8, 0.8);
	self.line2.color = (1, 0.8, 0.8);
	
	self.line2 MoveOverTime(27);
	self.line2.x = 310;
	self.line2 FadeOverTime(25); 
	self.line2.color = (1,0,0);
	
	self.line1 MoveOverTime(27);
	self.line1.x = 310;
	self.line1 FadeOverTime(25); 
	self.line1.color = (1,0,0);

	timeLeft = 30;
	while(true)
	{
		if(level.gameEnded) 
		{
			if(isDefined(self.cranked_timer)) 
				self.cranked_timer.alpha = 0;
			
			if(isDefined(self.line1)) 
				self.line1.alpha = 0;
			
			if(isDefined(self.line2)) 				
				self.line2.alpha = 0;				
				
			if(isDefined(self.cranked)) 
				self.cranked.alpha = 0;
				
			wait(0.05);
			return;
		}
		if(timeLeft <= 5)
		{ 
			self.cranked_timer.color = game["colors"]["red"];

			if(timeLeft == 0) 
				break;
			self playLocalSound("ui_mp_suitcasebomb_timer");
		}
		else if(timeLeft <= 10)
			self.cranked_timer.color = game["colors"]["orange"];
		wait(1.0);
		timeLeft--;      
	}
}

fontPulse(player)
{
	self notify ("fontPulse");
	self endon ("fontPulse");
	self endon("death");
	self endon("cranked_over");
	player endon("disconnect");
	player endon("joined_team");
	player endon("joined_spectators");

	scaleRange = self.maxFontScale - self.baseFontScale;

	while(self.fontScale < self.maxFontScale)
	{
		self.fontScale = min(self.maxFontScale, self.fontScale + (scaleRange / self.inFrames));
		wait 0.05;
	}
	while(self.fontScale > self.baseFontScale)
	{
		self.fontScale = max(self.baseFontScale, self.fontScale - (scaleRange / self.outFrames));
		wait 0.05;
	}
}