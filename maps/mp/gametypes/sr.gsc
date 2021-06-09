#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\utility\_utility;
#include maps\mp\gametypes\_hud_util;

main()
{
	if (getdvar("mapname") == "mp_background") return;
	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();
	level.teamBased = true;
	level.overrideTeamScore = true;
	level.onPrecacheGameType = ::onPrecacheGameType;
	level.onStartGameType = ::onStartGameType;
	level.onSpawnPlayer = ::onSpawnPlayer;
	level.onDeadEvent = ::onDeadEvent;
	level.onTimeLimit = ::onTimeLimit;
	level.onRoundSwitch = ::onRoundSwitch;
	level.onPlayerKilled = ::onPlayerKilled;
	level.endGameOnScoreLimit = false;
}

onPrecacheGameType()
{
	game["bomb_dropped_sound"] = "mp_war_objective_lost";
	game["bomb_recovered_sound"] = "mp_war_objective_taken";
	precacheShader("waypoint_bomb");
	precacheShader("hud_suitcase_bomb");
	precacheShader("waypoint_target");
	precacheShader("waypoint_target_a");
	precacheShader("waypoint_target_b");
	precacheShader("waypoint_defend");
	precacheShader("waypoint_defend_a");
	precacheShader("waypoint_defend_b");
	precacheShader("waypoint_defuse");
	precacheShader("waypoint_defuse_a");
	precacheShader("waypoint_defuse_b");
	precacheShader("compass_waypoint_target");
	precacheShader("compass_waypoint_target_a");
	precacheShader("compass_waypoint_target_b");
	precacheShader("compass_waypoint_defend");
	precacheShader("compass_waypoint_defend_a");
	precacheShader("compass_waypoint_defend_b");
	precacheShader("compass_waypoint_defuse");
	precacheShader("compass_waypoint_defuse_a");
	precacheShader("compass_waypoint_defuse_b");
	precacheString( &"MP_EXPLOSIVES_RECOVERED_BY");
	precacheString( &"MP_EXPLOSIVES_DROPPED_BY");
	precacheString( &"MP_EXPLOSIVES_PLANTED_BY");
	precacheString( &"MP_EXPLOSIVES_DEFUSED_BY");
	precacheString( &"PLATFORM_HOLD_TO_PLANT_EXPLOSIVES");
	precacheString( &"PLATFORM_HOLD_TO_DEFUSE_EXPLOSIVES");
	precacheString( &"MP_CANT_PLANT_WITHOUT_BOMB");
	precacheString( &"MP_PLANTING_EXPLOSIVE");
	precacheString( &"MP_DEFUSING_EXPLOSIVE");
	
	precacheModel( "skull_dogtag" );
	precacheModel( "cross_dogtag" );
}

onRoundSwitch()
{
	level.halftimeType = "halftime";
}

getBetterTeam()
{
	kills["allies"] = 0;
	kills["axis"] = 0;
	deaths["allies"] = 0;
	deaths["axis"] = 0;
	for( i=0; i<level.players.size; i++ )
	{
		player = level.players[i];
		team = player.pers["team"];
		if( isDefined(team) && (team == "allies" || team == "axis" ))
		{
			kills[team] += player.kills;
			deaths[team] += player.deaths;
		}
	}
	if(kills["allies"] > kills["axis"]) return "allies";
	else if(kills["axis"] > kills["allies"]) return "axis";
	if(deaths["allies"] < deaths["axis"]) return "allies";
	else if(deaths["axis"] < deaths["allies"]) return "axis";
	if(randomint(2) == 0) return "allies";
	return "axis";
}

onStartGameType()
{
	setClientNameMode("manual_change");
	game["strings"]["target_destroyed"] = &"MP_TARGET_DESTROYED";
	game["strings"]["bomb_defused"] = &"MP_BOMB_DEFUSED";
	precacheString(game["strings"]["target_destroyed"]);
	precacheString(game["strings"]["bomb_defused"]);
	maps\mp\gametypes\_globallogic::setObjectiveText(game["attackers"], &"OBJECTIVES_SD_ATTACKER");
	maps\mp\gametypes\_globallogic::setObjectiveText(game["defenders"], &"OBJECTIVES_SD_DEFENDER");
	maps\mp\gametypes\_globallogic::setObjectiveScoreText(game["attackers"], &"OBJECTIVES_SD_ATTACKER_SCORE");
	maps\mp\gametypes\_globallogic::setObjectiveScoreText(game["defenders"], &"OBJECTIVES_SD_DEFENDER_SCORE");
	maps\mp\gametypes\_globallogic::setObjectiveHintText(game["attackers"], &"OBJECTIVES_SD_ATTACKER_HINT");
	maps\mp\gametypes\_globallogic::setObjectiveHintText(game["defenders"], &"OBJECTIVES_SD_DEFENDER_HINT");
	level.spawnMins = (0, 0, 0);
	level.spawnMaxs = (0, 0, 0);
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints("mp_sd_spawn_attacker");
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints("mp_sd_spawn_defender");
	level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter(level.spawnMins, level.spawnMaxs);
	setMapCenter(level.mapCenter);
	allowed[0] = level.gametype;
	allowed[1] = "bombzone";
	allowed[2] = "blocker";
	allowed[3] = "sd";
	level.dogtags = [];
	maps\mp\gametypes\_gameobjects::main(allowed);
	thread updateGametypeDvars();
	thread bombs();
	thread rescuereset();
}

onSpawnPlayer()
{
	self.isPlanting = false;
	self.isDefusing = false;
	if( self.pers["team"] == game["attackers"]) spawnPointName = "mp_sd_spawn_attacker";
	else spawnPointName = "mp_sd_spawn_defender";
	self setclientdvar("ui_drawbombicon", 0);
	if( level.multiBomb && !isDefined(self.carryIcon) && self.pers["team"] == game["attackers"] && !level.bombPlanted)
	{
		self.carryIcon = createIcon("hud_suitcase_bomb", 50, 50);
		self.carryIcon setPoint("CENTER", "CENTER", 223, 167);
		self.carryIcon.alpha = 0.75;
		self setclientdvar("ui_drawbombicon", 1);
	}
	spawnPoints = getEntArray(spawnPointName, "classname");
	spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnPoints);
	self spawn(spawnpoint.origin, spawnpoint.angles);
	self thread intoSpawn(spawnpoint.origin, spawnpoint.angles);
	level notify("spawned_player");
}

protection()
{
	self endon("disconnect");
	
	self.isSpawnProtected = true;
	self iPrintln(">Spawnprotection ^2enabled");
	timer = 0;
	while(timer <= 3)
	{
		timer += 0.25;
		if(self UseButtonPressed() || self ADSButtonPressed() || self FragButtonPressed() || self MeleeButtonPressed() || self AttackButtonPressed() || self SecondaryOffhandButtonPressed())
			break;
		wait 0.25;
	}
	self.isSpawnProtected = false;
	self SetStat(2583,0);
	self iPrintln(">Spawnprotection ^1disabled");
}

rescuereset()
{
	wait 0.5;
    players = getAllPlayers();
    for( i = 0; i < players.size; i++ )
		players[i] SetStat(2801, 0 );
}

sd_endGame(winningTeam,endReasonText)
{	
	if(isdefined(winningTeam))[[level._setTeamScore]](winningTeam,[[level._getTeamScore]](winningTeam)+1);
	thread maps\mp\gametypes\_globallogic::endGame(winningTeam, endReasonText);
}

onDeadEvent(team)
{
	if(maps\mp\gametypes\_teams::getTeamBalance() == true)
	 level maps\mp\gametypes\_teams::balanceTeams();
	
	if(level.bombExploded || level.bombDefused) return;
	if(team == "all")
	{
		if(level.bombPlanted) sd_endGame(game["attackers"], game["strings"][game["defenders"] + "_eliminated"]);
		else sd_endGame(game["defenders"],game["strings"][game["attackers"] + "_eliminated"]);
	}
	else if(team == game["attackers"])
	{
		if(level.bombPlanted) return;
		sd_endGame(game["defenders"], game["strings"][game["attackers"] + "_eliminated"]);
	}
	else if(team == game["defenders"]) sd_endGame(game["attackers"], game["strings"][game["defenders"] + "_eliminated"]);
}

onTimeLimit()
{
	if(maps\mp\gametypes\_teams::getTeamBalance() == true)
	 level maps\mp\gametypes\_teams::balanceTeams();
	if(level.teamBased) sd_endGame(game["defenders"],game["strings"]["time_limit_reached"]);
	else sd_endGame(undefined,game["strings"]["time_limit_reached"]);
}

updateGametypeDvars()
{
	level.plantTime = dvarFloatValue("planttime", 5, 0, 20);
	level.defuseTime = dvarFloatValue("defusetime", 7, 0, 20);
	level.bombTimer = dvarFloatValue("bombtimer", 45, 1, 300);
	level.multiBomb = dvarIntValue("multibomb", 0, 0, 1);
}

bombs()
{
	level.bombPlanted = false;
	level.bombDefused = false;
	level.bombExploded = false;
	trigger = getEnt("sd_bomb_pickup_trig", "targetname");
	if(!isDefined(trigger)) return;
	visuals[0] = getEnt("sd_bomb", "targetname");
	if(!isDefined(visuals[0])) return;
	precacheModel("prop_suitcase_bomb");
	visuals[0] setModel("prop_suitcase_bomb");
	if(!level.multiBomb&&!game["PROMOD_KNIFEROUND"]&&isDefined(game["PROMOD_MATCH_MODE"])&&game["PROMOD_MATCH_MODE"]!="strat")
	{
		level.sdBomb = maps\mp\gametypes\_gameobjects::createCarryObject(game["attackers"],trigger, visuals, (0, 0, 32));
		level.sdBomb maps\mp\gametypes\_gameobjects::allowCarry("friendly");
		level.sdBomb maps\mp\gametypes\_gameobjects::set2DIcon("friendly", "compass_waypoint_bomb");
		level.sdBomb maps\mp\gametypes\_gameobjects::set3DIcon("friendly", "waypoint_bomb");
		level.sdBomb maps\mp\gametypes\_gameobjects::setVisibleTeam("friendly");
		level.sdBomb maps\mp\gametypes\_gameobjects::setCarryIcon("hud_suitcase_bomb");
		level.sdBomb.onPickup = ::onPickup;
		level.sdBomb.onDrop = ::onDrop;
	}
	else
	{
		trigger delete();
		visuals[0] delete();
	}
	level.bombZones = [];
	bombZones = getEntArray("bombzone", "targetname");
	for( i=0; i < bombZones.size; i++ )
	{
		trigger = bombZones[i];
		visuals = getEntArray(bombZones[i].target, "targetname");
		bombZone = maps\mp\gametypes\_gameobjects::createUseObject(game["defenders"], trigger, visuals, (0, 0, 64));
		bombZone maps\mp\gametypes\_gameobjects::allowUse("enemy");
		bombZone maps\mp\gametypes\_gameobjects::setUseTime(level.plantTime);
		bombZone maps\mp\gametypes\_gameobjects::setUseText( &"MP_PLANTING_EXPLOSIVE");
		bombZone maps\mp\gametypes\_gameobjects::setUseHintText( &"PLATFORM_HOLD_TO_PLANT_EXPLOSIVES");
		if(!level.multiBomb) bombZone maps\mp\gametypes\_gameobjects::setKeyObject(level.sdBomb);
		label = bombZone maps\mp\gametypes\_gameobjects::getLabel();
		bombZone.label = label;
		bombZone maps\mp\gametypes\_gameobjects::set2DIcon("friendly", "compass_waypoint_defend" + label);
		bombZone maps\mp\gametypes\_gameobjects::set2DIcon("enemy", "compass_waypoint_target" + label);
		bombZone maps\mp\gametypes\_gameobjects::setVisibleTeam("any");
		bombZone.onBeginUse = ::onBeginUse;
		bombZone.onEndUse = ::onEndUse;
		bombZone.onUse = ::onUsePlantObject;
		bombZone.onCantUse = ::onCantUse;
		for( j=0; j < visuals.size; j++ )
		{
			if(isDefined(visuals[j].script_exploder))
			{
				bombZone.exploderIndex = visuals[j].script_exploder;
				break;
			}
		}
		level.bombZones[level.bombZones.size] = bombZone;
		bombZone.bombDefuseTrig = getent(visuals[0].target, "targetname");
		bombZone.bombDefuseTrig.origin += (0, 0, -10000);
		bombZone.bombDefuseTrig.label = label;
	}
	for( i=0; i < level.bombZones.size; i++)
	{
		array = [];
		for( j=0; j < level.bombZones.size; j++)
		{
			if(j!=i) array[array.size] = level.bombZones[j];
		}
		level.bombZones[i].otherBombZones = array;
	}
}

onBeginUse(player)
{
	if(self maps\mp\gametypes\_gameobjects::isFriendlyTeam(player.pers["team"]))
	{
		player playSound("mp_bomb_defuse");
		player.isDefusing = true;
		if(isDefined(level.sdBombModel)) level.sdBombModel hide();
	}
	else
	{
		player playSound("mp_bomb_plant");
		player.isPlanting = true;
		if(level.multibomb)
		{
			for( i=0; i < self.otherBombZones.size; i++) self.otherBombZones[i] maps\mp\gametypes\_gameobjects::disableObject();
		}
	}
}

onEndUse(team, player, result)
{
	if(isAlive(player))
	{
		player.isDefusing = false;
		player.isPlanting = false;
	}
	if(self maps\mp\gametypes\_gameobjects::isFriendlyTeam(player.pers["team"]))
	{
		if(isDefined(level.sdBombModel) && !result) level.sdBombModel show();
	}
	else
	{
		if(level.multibomb && !result)
		{
			for( i=0; i < self.otherBombZones.size; i++) 
				self.otherBombZones[i] maps\mp\gametypes\_gameobjects::enableObject();
		}
	}
}

onCantUse(player)
{
	player iPrintLnBold( &"MP_CANT_PLANT_WITHOUT_BOMB");
}

onUsePlantObject(player)
{
	if(level.gameEnded) return;
	if(!self maps\mp\gametypes\_gameobjects::isFriendlyTeam(player.pers["team"]))
	{
		if(!level.hardcoreMode) iPrintLn( &"MP_EXPLOSIVES_PLANTED_BY", player.name);
		maps\mp\gametypes\_globallogic::givePlayerScore("plant", player);
		for( i=0; i < level.bombZones.size; i++)
		{
			if(level.bombZones[i] == self) continue;
			level.bombZones[i] maps\mp\gametypes\_gameobjects::disableObject();
		}
		for( i=0; i < level.players.size; i++) level.players[i] playLocalSound("promod_planted");
		player thread[[level.onXPEvent]]("plant");
		level thread bombPlanted(self, player);
		logPrint("P_P;"+player getGuid()+";"+player getEntityNumber()+";"+player.name+"\n");
	}
}

onUseDefuseObject(player)
{
	if(level.gameEnded || level.bombExploded) return;
	level thread bombDefused();
	self maps\mp\gametypes\_gameobjects::disableObject();
	playSoundOnPlayers("promod_defused");
	if(!level.hardcoreMode) iPrintLn( &"MP_EXPLOSIVES_DEFUSED_BY", player.name);
	maps\mp\gametypes\_globallogic::givePlayerScore("defuse", player);
	player thread[[level.onXPEvent]]("defuse");
	logPrint("P_D;"+player getGuid()+";"+player getEntityNumber()+";"+player.name+"\n");
}

onDrop(player)
{
	if(!level.bombPlanted)
	{
		if(isDefined(player) && isDefined(player.name))
			printOnTeamArg( &"MP_EXPLOSIVES_DROPPED_BY", game["attackers"], player);
	}
	self maps\mp\gametypes\_gameobjects::set3DIcon("friendly", "waypoint_bomb");
	if (!level.bombPlanted) playSoundOnPlayers(game["bomb_dropped_sound"], game["attackers"]);
}

onPickup(player)
{
	self maps\mp\gametypes\_gameobjects::set3DIcon("friendly", "waypoint_defend");
	if(!level.bombDefused)
	{
		if(isDefined(player) && isDefined(player.name)) 
			printOnTeamArg( &"MP_EXPLOSIVES_RECOVERED_BY", game["attackers"], player);
	}
	playSoundOnPlayers(game["bomb_recovered_sound"], game["attackers"]);
}

bombPlanted(destroyedObj, player)
{
	maps\mp\gametypes\_globallogic::pauseTimer();
	level.bombPlanted = true;
	destroyedObj.visuals[0] thread maps\mp\gametypes\_globallogic::playTickingSound();
	level.tickingObject = destroyedObj.visuals[0];
	level.timeLimitOverride = true;
	setGameEndTime(int(gettime() + (level.bombTimer * 1000)));
	setDvar("ui_bomb_timer", 1);
	if(!level.multiBomb)
	{
		level.sdBomb maps\mp\gametypes\_gameobjects::allowCarry("none");
		level.sdBomb maps\mp\gametypes\_gameobjects::setVisibleTeam("none");
		level.sdBomb maps\mp\gametypes\_gameobjects::setDropped();
		level.sdBombModel = level.sdBomb.visuals[0];
	}
	else
	{
		for( i=0; i < level.players.size; i++)
		{
			if(isDefined(level.players[i].carryIcon)) level.players[i].carryIcon destroyElem();
		}
		trace = bulletTrace(player.origin + (0, 0, 20), player.origin - (0, 0, 2000), false, player);
		tempAngle = randomfloat(360);
		forward = (cos(tempAngle), sin(tempAngle), 0);
		forward = vectornormalize(forward - vector_scale(trace["normal"], vectordot(forward, trace["normal"])));
		dropAngles = vectortoangles(forward);
		level.sdBombModel = spawn("script_model", trace["position"]);
		level.sdBombModel.angles = dropAngles;
		level.sdBombModel setModel("prop_suitcase_bomb");
	}
	destroyedObj maps\mp\gametypes\_gameobjects::allowUse("none");
	destroyedObj maps\mp\gametypes\_gameobjects::setVisibleTeam("none");
	label = destroyedObj maps\mp\gametypes\_gameobjects::getLabel();
	trigger = destroyedObj.bombDefuseTrig;
	trigger.origin = level.sdBombModel.origin;
	visuals = [];
	defuseObject = maps\mp\gametypes\_gameobjects::createUseObject(game["defenders"], trigger, visuals, (0, 0, 32));
	defuseObject maps\mp\gametypes\_gameobjects::allowUse("friendly");
	defuseObject maps\mp\gametypes\_gameobjects::setUseTime(level.defuseTime);
	defuseObject maps\mp\gametypes\_gameobjects::setUseText( &"MP_DEFUSING_EXPLOSIVE");
	defuseObject maps\mp\gametypes\_gameobjects::setUseHintText( &"PLATFORM_HOLD_TO_DEFUSE_EXPLOSIVES");
	defuseObject maps\mp\gametypes\_gameobjects::setVisibleTeam("any");
	defuseObject maps\mp\gametypes\_gameobjects::set2DIcon("friendly", "compass_waypoint_defuse" + label);
	defuseObject maps\mp\gametypes\_gameobjects::set2DIcon("enemy", "compass_waypoint_defend" + label);
	defuseObject.label = label;
	defuseObject.onBeginUse = ::onBeginUse;
	defuseObject.onEndUse = ::onEndUse;
	defuseObject.onUse = ::onUseDefuseObject;
	BombTimerWait();
	setDvar("ui_bomb_timer", 0);
	destroyedObj.visuals[0] maps\mp\gametypes\_globallogic::stopTickingSound();
	if(level.gameEnded || level.bombDefused) return;
	level.bombExploded = true;
	explosionOrigin = level.sdBombModel.origin;
	level.sdBombModel hide();
	if(isdefined(player))destroyedObj.visuals[0] radiusDamage(explosionOrigin, 512, 200, 20, player);
	else destroyedObj.visuals[0] radiusDamage(explosionOrigin, 512, 200, 20);
	rot = randomfloat(360);
	explosionEffect = spawnFx(level.fx["bombexplosion"], explosionOrigin + (0, 0, 50), (0, 0, 1), (cos(rot), sin(rot), 0));
	triggerFx(explosionEffect);
	thread playSoundinSpace("exp_suitcase_bomb_main", explosionOrigin);
	for(i=0; i < level.bombZones.size; i++) level.bombZones[i] maps\mp\gametypes\_gameobjects::disableObject();
	defuseObject maps\mp\gametypes\_gameobjects::disableObject();
	setGameEndTime(0);
	playSoundOnPlayers("promod_destroyed");
	wait 0.05;
	sd_endGame(game["attackers"], game["strings"]["target_destroyed"]);
}

BombTimerWait()
{
	level endon("game_ended");
	level endon("bomb_defused");
	wait level.bombTimer;
}

playSoundinSpace(alias, origin)
{
	org = spawn("script_origin", origin);
	org.origin = origin;
	org playSound(alias);
	wait 10;
	org delete();
}

bombDefused()
{
	level.tickingObject maps\mp\gametypes\_globallogic::stopTickingSound();
	level.bombDefused = true;
	level notify("bomb_defused");
	setGameEndTime(0);
	setDvar("ui_bomb_timer", 0);
	wait 0.05;
	sd_endGame(game["defenders"], game["strings"]["bomb_defused"]);
}

intoSpawn(originA, anglesA)
{
	self endon("disconnect");
	if(isDefined(self.pers["gotani"]))
		return;
	self.pers["gotani"] = true;
	self playLocalSound( "ui_camera_whoosh_in" );
	wait 0.1;
	self freezeControls( true );
	zoomHeight = 6500;
	slamzoom = true;
	self.origin = originA + ( 0, 0, zoomHeight );
	ent = spawn( "script_model", self.origin );
	if(isDefined(self)) self thread ispawnang(ent);
	ent.angles = anglesA;
	ent setmodel( "tag_origin" );
	self linkto( ent );
	ent.angles = ( ent.angles[ 0 ] + 89, ent.angles[ 1 ], ent.angles[ 2 ] );
	ent moveto ( originA + (0,0,0), 2, 0, 2 );
	wait 1.6;
	ent rotateto( ( ent.angles[ 0 ] - 89, ent.angles[ 1 ], ent.angles[ 2 ]  ), 0.5, 0.3, 0.2 );
	wait 0.6;
	if(isDefined(self))
	{
		self unlink();
		self freezeControls( false );
	}
	if(isDefined(ent))ent delete();
}

ispawnang(ent)
{
	while(isDefined(ent) && isDefined(self))
	{
		self SetPlayerAngles( ent.angles );
		wait 0.05;
	}
}

onPlayerKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	if( isPlayer( attacker ) && attacker != self && (self GetStat(2801) < 1))
		self thread spawnDogTags( attacker );
} 

spawnDogTags( attacker )
{
	if(isDefined(attacker) && self.pers["team"] != "spectator" && attacker != self) 
	{
		basePosition = playerPhysicsTrace( self.origin + ( 0, 0, 10 ), self.origin + ( 0, 0, -99999 ) );
		
		trigger = spawn( "trigger_radius", basePosition, 0, 20, 50 );
		trigger endon( "picked_up" );
		trigger endon( "timed_out" );
		trigger.owner = attacker;
		trigger.team = attacker.pers["team"];
		
		friendlyTag = spawn( "script_model", basePosition + ( 0, 0, 20 ) );
		friendlyTag endon( "picked_up" );
		friendlyTag endon( "timed_out" );
		friendlyTag setModel( "cross_dogtag" );
		friendlyTag.team = self.pers["team"];
		friendlyTag.owner = self;
		
		enemyTag = spawn( "script_model", basePosition + ( 0, 0, 20 ) );
		enemyTag endon( "picked_up" );
		enemyTag endon( "timed_out" );
		enemyTag setModel( "skull_dogtag" );
		enemyTag.team = attacker.pers["team"];
		enemyTag.owner = self;
		
		self thread onJoinedDisconnect( enemyTag, friendlyTag, trigger );
		friendlyTag thread bounce();
		enemyTag thread bounce();
		friendlyTag thread showTagToTeam();
		enemyTag thread showTagToTeam();
		trigger thread onUseTag( friendlyTag, enemyTag, trigger );
	}
}

onUseTag( friendlyTag, enemyTag, trigger )
{ 
	//self endon("disconnect"); Test the proper entity
	trigger endon( "timed_out" );
	friendlyTag endon( "timed_out" );
	enemyTag endon( "timed_out" );
	trigger waittill( "trigger", taker );
	for(;;)
	{
		trigger waittill( "trigger", taker );
		if( !isdefined(taker) || !isAlive(taker) || !isDefined(taker.pers["team"]) )
			continue;
		else break;
	}

	if( taker.pers["team"] == friendlyTag.team ) 
	{
		tagowner = friendlyTag.owner;
		event = "tags_retrieved";
		splash = "Rescued";
		taker thread onPickupDogTag( event, splash );	
		taker.pers["rescues"]++;
		temp = taker GetStat(3001);
		taker SetStat(3001, temp+1);
		if ( isDefined( tagowner ) )
		{
			taker clearLowerMessage();
			tagowner thread maps\mp\gametypes\_globallogic::spawnPlayer();
			tagowner setweaponammoclip("frag_grenade_mp",0);
			tagowner setweaponammostock("frag_grenade_mp",0);
			tagowner setweaponammoclip("flash_grenade_mp",0);
			tagowner setweaponammostock("flash_grenade_mp",0);			
			tagowner setweaponammoclip("smoke_grenade_mp",0);
			tagowner setweaponammostock("smoke_grenade_mp",0);			
			tagowner iprintLnBold("^1You were rescued!");
			temp = tagowner GetStat(2801);
			tagowner SetStat( 2801, int(temp) + 1 ); // Rescue limit
			tagowner thread protection();
		}
	}
	if ( taker.pers["team"] == enemyTag.team ) 
	{
		tagowner = enemyTag.owner;
		event = "kill_confirmed";
		splash = "Enemy eliminated";
		taker.pers["gottags"]++;
		temp = taker GetStat(3002);
		taker SetStat(3002, temp+1);
		taker thread onPickupDogTag( event, splash );
		if ( isDefined( tagowner ) )
			tagowner thread underScorePopup( "Eliminated" );
	}
	trigger playSound( "dogtag_kc_pickup" );
	trigger notify( "picked_up" );
	friendlyTag notify( "picked_up" );
	enemyTag notify( "picked_up" );
	if(isDefined(trigger)) trigger delete();
	if(isDefined(friendlyTag)) friendlyTag delete();
	if(isDefined(enemyTag)) enemyTag delete();
}

waittill_any_or_time(x,y,z,time,r)
{
	level endon("game_ended");
	
	if(isDefined(x))
		self endon(x);

	if(isDefined(y))
		self endon(y);

	if(isDefined(z))
		self endon(z);
	
	if(isDefined(r))
		self endon(r);

	if(isDefined(time))
		wait time;
}

onJoinedDisconnect( enemyTag, friendlyTag, trigger )
{
	self endon( "spawned_player" );
	self endon( "game_ended" );

	self waittill_any_or_time( "disconnect", "joined_team", "joined_spectators", 22, "pickup");

	trigger notify( "picked_up" );
	friendlyTag notify( "picked_up" );
	enemyTag notify( "picked_up" );

	trigger notify( "timed_out" );
	friendlyTag notify( "timed_out" );
	enemyTag notify( "timed_out" );

	if(isDefined(trigger))trigger delete();
	if(isDefined(friendlyTag))friendlyTag delete();
	if(isDefined(enemyTag))enemyTag delete();
}

onPickupDogTag( event, splash )
{
	if(isPlayer(self))
	{
		self thread underScorePopup(splash);
		self thread maps\mp\gametypes\_rank::giveRankXP( event );
		self.pers["score"] += 2;
		self maps\mp\gametypes\_persistence::statAdd( "score", self.pers["score"] );
		self.score = self.pers["score"];
	}
}

bounce()
{
	self endon( "picked_up" );
	self endon( "timed_out" );
	while( isDefined(self) )
	{
		self rotateYaw( 360, 3, 0.3, 0.3 );
		self moveZ( 20, 1.5, 0.3, 0.3 );
		wait 1.5;
		self moveZ( -20, 1.5, 0.3, 0.3 );
		wait 1.5;	
	}
}

showTagToTeam()
{
	while( isDefined( self ) ) // use while() in case player changes team
	{
		self hide();
		for( i = 0 ; i < level.players.size ; i ++ )
		{
			player = level.players[i];
			if ( player.pers["team"] == self.team )
				self showToPlayer( player );
		}
		wait 0.05;
	}
}