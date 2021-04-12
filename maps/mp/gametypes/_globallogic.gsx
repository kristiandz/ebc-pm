#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_globallogic_utils;
#include scripts\utility\common;

init()
{
	//precacheModel("projectile_cbu97_clusterbomb");
	//level.pointEffext = loadfx( "misc/ui_pickup_unavailable" );
	
	level.gametype=toLower(getDvar("g_gametype"));
	if(!isDefined(level.tweakablesInitialized))maps\mp\gametypes\_tweakables::init();
	level.splitscreen=0;
	level.xenon=0;
	level.ps3=0;
	level.console=0;
	level.oldschool=0;
	level.onlineGame = true;
	level.rankedMatch = true;
	level.tempEntity = spawn( "script_model", (0,0,0) );
	level.script=toLower(getDvar("mapname"));
	checkRestartMap();
	level.otherTeam["allies"]="axis";
	level.otherTeam["axis"]="allies";
	level.teamBased=false;
	level.overrideTeamScore=false;
	level.overridePlayerScore=false;
	level.displayHalftimeText=false;
	level.displayRoundEndText=true;
	level.endGameOnScoreLimit=true;
	level.endGameOnTimeLimit=true;
	precacheString(&"MP_HALFTIME");
	precacheString(&"MP_OVERTIME");
	precacheString(&"MP_ROUNDEND");
	precacheString(&"MP_INTERMISSION");
	precacheString(&"MP_SWITCHING_SIDES");
	precacheString(&"MP_CONNECTED");
	level.halftimeType="halftime";
	level.halftimeSubCaption=&"MP_SWITCHING_SIDES";
	level.lastStatusTime=0;
	level.wasWinning="none";
	level.lastSlowProcessFrame=0;
	level.placement["allies"]=[];
	level.placement["axis"]=[];
	level.placement["all"]=[];
	level.postRoundTime=5;
	level.inOvertime=false;
	level.players=[];
	level.shoutbars=[];
	
	level.instrattime = false;
	level.firstblood = false;
	level.inFinalKillcam = false;
	level.numKills = 0;
	
	level.randomcolour = (RandomFloat(1), RandomFloat(1), RandomFloat(1));
	registerDvars();
	precacheModel("tag_origin");
	precacheShader("faction_128_usmc");
	precacheShader("faction_128_arab");
	precacheShader("faction_128_ussr");
	precacheShader("faction_128_sas");
	PrecacheShader("line_vertical");
	PrecacheShader("line_horizontal");
	
	precacheItem("briefcase_bomb_mp");
	precacheItem("briefcase_bomb_defuse_mp");
	precacheModel("prop_suitcase_bomb");
	
	precacheItem( "knife_mp" );
	precacheItem( "change_mp" );
	precacheShader("white");
	precacheShader("black");
	precacheShader( "bloodsplat3" );
	
	precacheStatusIcon("hud_status_dead");
	precacheStatusIcon("alkohol_menu");
	precacheStatusIcon("hud_status_connecting");
	precacheStatusIcon("compassping_friendlyfiring_mp");
	precacheStatusIcon("compassping_enemy");
	precacheRumble("damage_heavy");
	
	level.fx["smallfire"] = loadfx("fire/tank_fire_engine");
	level.fx_bloodpool = LoadFX( "impacts/bloodpool" );
	level.fx["revtrail_red_flare"] = loadFX("deathrun/revtrail_red_flare");
	
	if(!isDefined(game["tiebreaker"]))game["tiebreaker"]=false;
	if(!isDefined(game["gamestarted"]))promod\modes::main();
	level.hardcoreMode=getDvarInt("scr_hardcore");
	level.roundswitch=getDvarInt("scr_"+level.gametype+"_roundswitch");
	level.roundLimit=getDvarInt("scr_"+level.gametype+"_roundlimit");
	level.timelimit=getDvarFloat("scr_"+level.gametype+"_timelimit");
	level.scoreLimit=getDvarInt("scr_"+level.gametype+"_scorelimit");
	level.numLives=getDvarInt("scr_"+level.gametype+"_numlives");
	setDvar("ui_scorelimit",level.scoreLimit);
	setDvar("ui_timelimit",level.timelimit);
	
	if(level.hardcoreMode)setDvar("scr_player_maxhealth",30);
	else setDvar("scr_player_maxhealth",100);
	
	thread admin_list(); // Test performance first
	thread list_cleaner();
	
	thread buildSprayInfo();
	thread buildCharacterInfo();
	
	thread scripts\general::init();
}

registerDvars()
{
	setDvar("ui_bomb_timer",0);
	makeDvarServerInfo("ui_bomb_timer");
}

SetupCallbacks()
{
	level.spawnPlayer=::spawnPlayer;
	level.spawnClient=::spawnClient;
	level.spawnSpectator=::spawnSpectator;
	level.spawnIntermission=::spawnIntermission;
	level.onPlayerScore=::default_onPlayerScore;
	level.onTeamScore=::default_onTeamScore;
	level.onXPEvent=::onXPEvent;
	level.waveSpawnTimer=::waveSpawnTimer;
	level.onSpawnPlayer=::blank;
	level.onSpawnSpectator=::default_onSpawnSpectator;
	level.onSpawnIntermission=::default_onSpawnIntermission;
	level.onRespawnDelay=::blank;
	level.onTimeLimit=::default_onTimeLimit;
	level.onScoreLimit=::default_onScoreLimit;
	level.onDeadEvent=::default_onDeadEvent;
	level.onOneLeftEvent=::default_onOneLeftEvent;
	level.giveTeamScore=::giveTeamScore;
	level.givePlayerScore=::givePlayerScore;
	level._setTeamScore=::_setTeamScore;
	level._setPlayerScore=::_setPlayerScore;
	level._getTeamScore=::_getTeamScore;
	level._getPlayerScore=::_getPlayerScore;
	level.onPrecacheGametype=::blank;
	level.onStartGameType=::blank;
	level.onPlayerConnect=::blank;
	level.onPlayerDisconnect=::blank;
	level.onPlayerDamage=::blank;
	level.onPlayerKilled=::blank;
	level.onEndGame=::blank;
	level.autoassign=::menuAutoAssign;
	level.spectator=::menuSpectator;
	level.killspec=::menuKillspec;
	level.allies=::menuAllies;
	level.axis=::menuAxis;
}

WaitTillSlowProcessAllowed()
{
	while(level.lastSlowProcessFrame==gettime())
		wait 0.05;
	level.lastSlowProcessFrame=gettime();
}

blank(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10)
{
}

default_onDeadEvent(team)
{
	if(team=="allies")
	{
		iPrintLn(game["strings"]["allies_eliminated"]);
		makeDvarServerInfo("ui_text_endreason",game["strings"]["allies_eliminated"]);
		setDvar("ui_text_endreason",game["strings"]["allies_eliminated"]);
		thread endGame("axis",game["strings"]["allies_eliminated"]);
	}
	else if(team=="axis")
	{
		iPrintLn(game["strings"]["axis_eliminated"]);
		makeDvarServerInfo("ui_text_endreason",game["strings"]["axis_eliminated"]);
		setDvar("ui_text_endreason",game["strings"]["axis_eliminated"]);
		thread endGame("allies",game["strings"]["axis_eliminated"]);
	}
	else
	{
		makeDvarServerInfo("ui_text_endreason",game["strings"]["tie"]);
		setDvar("ui_text_endreason",game["strings"]["tie"]);
		if(level.teamBased)thread endGame("tie",game["strings"]["tie"]);
		else thread endGame(undefined,game["strings"]["tie"]);
	}
}

default_onOneLeftEvent(team)
{
	if(!level.teamBased)
	{
		winner=getHighestScoringPlayer();
		thread endGame(winner,&"MP_ENEMIES_ELIMINATED");
	}
}

default_onTimeLimit()
{
	winner=undefined;
	if(level.teamBased)
	{
		if(game["teamScores"]["allies"]==game["teamScores"]["axis"])winner="tie";
		else if(game["teamScores"]["axis"]>game["teamScores"]["allies"])winner="axis";
		else winner="allies";
	}
	else winner=getHighestScoringPlayer();
	makeDvarServerInfo("ui_text_endreason",game["strings"]["time_limit_reached"]);
	setDvar("ui_text_endreason",game["strings"]["time_limit_reached"]);
	thread endGame(winner,game["strings"]["time_limit_reached"]);
}

default_onScoreLimit()
{
	if(!level.endGameOnScoreLimit)return;
	winner=undefined;
	if(level.teamBased)
	{
		if(game["teamScores"]["allies"]==game["teamScores"]["axis"])winner="tie";
		else if(game["teamScores"]["axis"]>game["teamScores"]["allies"])winner="axis";
		else winner="allies";
	}
	else winner=getHighestScoringPlayer();
	makeDvarServerInfo("ui_text_endreason",game["strings"]["score_limit_reached"]);
	setDvar("ui_text_endreason",game["strings"]["score_limit_reached"]);
	level.forcedEnd=true;thread endGame(winner,game["strings"]["score_limit_reached"]);
}

updateGameEvents()
{
	if((!level.numLives&&!level.inOverTime)||level.inGracePeriod)return;
	if(level.teamBased)
	{
		if(level.everExisted["allies"]&&!level.aliveCount["allies"]&&level.everExisted["axis"]&&!level.aliveCount["axis"]&&!level.playerLives["allies"]&&!level.playerLives["axis"])
		{
			[[level.onDeadEvent]]("all");
			return;
		}
		if(level.everExisted["allies"]&&!level.aliveCount["allies"]&&!level.playerLives["allies"])
		{
			[[level.onDeadEvent]]("allies");
			return;
		}
		if(level.everExisted["axis"]&&!level.aliveCount["axis"]&&!level.playerLives["axis"])
		{
			[[level.onDeadEvent]]("axis");
			return;
		}
		if(level.lastAliveCount["allies"]>1&&level.aliveCount["allies"]==1&&level.playerLives["allies"]==1)
		{
			[[level.onOneLeftEvent]]("allies");
			return;
		}
		if(level.lastAliveCount["axis"]>1&&level.aliveCount["axis"]==1&&level.playerLives["axis"]==1)
		{
			[[level.onOneLeftEvent]]("axis");
			return;
		}
	}
	else
	{
		if((!level.aliveCount["allies"]&&!level.aliveCount["axis"])&&(!level.playerLives["allies"]&&!level.playerLives["axis"])&&level.maxPlayerCount>1)
		{
			[[level.onDeadEvent]]("all");
			return;
		}
		if((level.aliveCount["allies"]+level.aliveCount["axis"]==1)&&(level.playerLives["allies"]+level.playerLives["axis"]==1)&&level.maxPlayerCount>1)
		{
			[[level.onOneLeftEvent]]("all");
			return;
		}
	}
}

matchStartTimer()
{
	level.instrattime = true;
	visionSetNaked("mpIntro", 0);
	matchStartText = createServerFontString("objective", 1.5);
	matchStartText setPoint("CENTER", "CENTER", 0, -20);
	matchStartText.sort = 1001;
	matchStartText setText(game["strings"]["match_starting_in"]);
	matchStartText.foreground = false;
	matchStartText.hidewheninmenu = true;
	matchStartTimer = createServerTimer("objective", 1.4);
	matchStartTimer setPoint("CENTER", "CENTER", 0, 0);
	matchStartTimer promod\strattime::setStarttime(level.prematchPeriod);
	matchStartTimer.sort = 1001;
	matchStartTimer.foreground = false;
	matchStartTimer.hideWhenInMenu = true;
	wait level.prematchPeriod;
	visionSetNaked(getDvar("mapname"), 1);
	level notify("clock_over");
	level.instrattime = false;
	if(isDefined(matchStartText))
	matchStartText destroyElem();
}

matchStartTimerSkip()
{
	visionSetNaked(getDvar("mapname"),0);
}

roofspawn()
{
	level endon("game_ended");
	self endon("disconnect");
	self endon("joined_spectators");
	self endon("joined_team");
	self notify("spawned");
	self notify("end_respawn");
	self setSpawnVariables();
	self.sessionteam=self.team;
	hadSpawned=self.hasSpawned;
	self.sessionstate="playing";
	self.spectatorclient=-1;
	self.killcamentity=-0;
	self.archivetime=0;
	self.psoffsettime=0;
	self.maxhealth=maps\mp\gametypes\_tweakables::getTweakableValue("player","maxhealth");
	self.health=self.maxhealth;
	self.hasSpawned=true;
	self allowsprint(true);
	self allowjump(true);
	self notify( "spawned_player" );
	[[level.onSpawnPlayer]]();
	prof_end("spawnPlayer_preUTS");
	level thread updateTeamStatus();
	prof_begin("spawnPlayer_postUTS");
	self enableWeapons();
	self maps\mp\gametypes\_class::giveLoadout(self.team,self.class);
	prof_end("spawnPlayer_postUTS");
	self freezeControls( false );
	self setperk( "specialty_quieter" );
	self setperk( "specialty_gpsjammer" );
	self setperk( "specialty_longersprint" );
	self removeWeapons_knife();
	self notify("isKnifing");
}

spawnPlayer()
{
	prof_begin("spawnPlayer_preUTS");
	self endon("disconnect");
	self endon("joined_spectators");
	self endon("joined_team");
	self notify("spawned");
	self notify("end_respawn");
	self setSpawnVariables();
	if(isDefined(self.proxBar))self.proxBar destroyElem();
	if(isDefined(self.proxBarText))self.proxBarText destroyElem();
	if(isDefined(self.xpBar))self.xpBar destroyElem();
	if(level.teamBased)self.sessionteam=self.team;
	else self.sessionteam="none";
	hadSpawned=self.hasSpawned;
	self.sessionstate="playing";
	self.spectatorclient=-1;
	self.killcamentity=-1;
	self.archivetime=0;
	self.psoffsettime=0;
	self.maxhealth=maps\mp\gametypes\_tweakables::getTweakableValue("player","maxhealth");
	self.health=self.maxhealth;
	self.hasSpawned=true;
	self.spawnTime=getTime();
	if(self.pers["lives"])self.pers["lives"]--;
	if(!self.wasAliveAtMatchStart)
	{
		acceptablePassedTime=20;
		if(level.timeLimit>0&&acceptablePassedTime<level.timeLimit*15)acceptablePassedTime=level.timeLimit*15;
		if(level.inGracePeriod||getTimePassed()<acceptablePassedTime*1000)self.wasAliveAtMatchStart=true;
	}
	[[level.onSpawnPlayer]]();
	prof_end("spawnPlayer_preUTS");
	level thread updateTeamStatus();
	prof_begin("spawnPlayer_postUTS");
	
	if(isDefined(game["PROMOD_KNIFEROUND"])&&game["PROMOD_KNIFEROUND"]&&isDefined(level.strat_over)&&level.strat_over)
		self thread removeWeapons();
	if(isDefined(self.class)) 
		self maps\mp\gametypes\_class::giveLoadout(self.team,self.class); // Check if self.class
	if(!hadSpawned&&isDefined(game["state"])&&game["state"]=="playing")
	{
		team=self.team;
		thread maps\mp\gametypes\_hud_message::oldNotifyMessage(game["strings"][team+"_name"],undefined,game["icons"][team],game["colors"][team]);
	}
	if(isDefined(level.strat_over)&&!level.strat_over)
	{
		self allowsprint(false);
		self allowjump(false);
		self setMoveSpeedScale(0);
	}
	prof_end("spawnPlayer_postUTS");
	wait 0.1;
	self notify("spawned_player");
	if(isDefined(game["state"])&&game["state"]=="postgame")self freezePlayerForRoundEnd();
	if(!isDefined(level.rdyup)||!level.rdyup)self.statusicon="";
	if(isDev())	self.statusicon="alkohol_menu";
	if(self GetStat(1333) == 1) self thread trailFX();
    self thread sprayLogo();
	waittillframeend;
	id = self getStat( 980 );
	if( id != 0 && isDefined(level.characterInfo[id]["handsModel"]) ) self setViewModel( level.characterInfo[id]["handsModel"] );
	//self thread scripts\ending::editor();
}

removeWeapons_knife()
{
	self endon("disconnect");
	self maps\mp\gametypes\_class::giveLoadout(self.team,self.class);
	wait 0.05;
	attachment="";
	if(self.pers[self.pers["class"]]["loadout_secondary_attachment"]=="silencer")attachment="_silencer";
	sidearmWeapon=self.pers[self.pers["class"]]["loadout_secondary"]+attachment+"_mp";
	self takeAllWeapons();
	self giveWeapon(sidearmWeapon,0);
	self setweaponammoclip(sidearmWeapon,0);
	self setweaponammostock(sidearmWeapon,0);
	self GiveWeapon("knife_mp");
	self switchtoWeapon(sidearmWeapon);
}

removeWeapons()
{
	self endon("disconnect");
	self maps\mp\gametypes\_class::giveLoadout(self.team,self.class);
	wait 0.05;
	attachment="";
	if(self.pers[self.pers["class"]]["loadout_secondary_attachment"]=="silencer")attachment="_silencer";
	sidearmWeapon=self.pers[self.pers["class"]]["loadout_secondary"]+attachment+"_mp";
	self takeAllWeapons();
	self giveWeapon(sidearmWeapon,0);
	self setweaponammoclip(sidearmWeapon,0);
	self setweaponammostock(sidearmWeapon,0);
	self GiveWeapon("knife_mp");
	self switchtoWeapon(sidearmWeapon);
	self setclientdvar("g_compassShowEnemies",1);
}

spawnSpectator(origin,angles)
{
	self notify("spawned");
	self notify("end_respawn");
	in_spawnSpectator(origin,angles);
}

respawn_asSpectator(origin,angles)
{
	in_spawnSpectator(origin,angles);
}

in_spawnSpectator(origin,angles)
{
	self setSpawnVariables();
	if(self.pers["team"]=="spectator")self clearLowerMessage();
	self.sessionstate="spectator";
	self.spectatorclient=-1;
	self.killcamentity=-1;
	self.archivetime=0;
	self.psoffsettime=0;
	if(self.pers["team"]=="spectator")
	{
		if(!isDefined(level.rdyup)||!level.rdyup)self.statusicon="";
		if(!isDefined(self.freelook))self thread monitorFreeLook();
	}
	maps\mp\gametypes\_spectating::setSpectatePermissions();
	[[level.onSpawnSpectator]](origin,angles);
	level thread updateTeamStatus();
}

getPlayerFromClientNum(clientNum)
{
	if(clientNum<0)return undefined;
	for(i=0;i<level.players.size;i++)
	{
		if(level.players[i]getEntityNumber()==clientNum)return level.players[i];
	}
	return undefined;
}

waveSpawnTimer()
{
	level endon("game_ended");
	while(isDefined(game["state"])&&game["state"]=="playing")
	{
		time=getTime();
		if(time-level.lastWave["allies"]>(level.waveDelay["allies"]*1000))
		{
			level notify("wave_respawn_allies");
			level.lastWave["allies"]=time;
			level.wavePlayerSpawnIndex["allies"]=0;
		}
		if(time-level.lastWave["axis"]>(level.waveDelay["axis"]*1000))
		{
			level notify("wave_respawn_axis");
			level.lastWave["axis"]=time;
			level.wavePlayerSpawnIndex["axis"]=0;
		}
		wait 0.05;
	}
}

freeLook(condition)
{
	if(getDvarInt("scr_game_spectatetype")==1)
	{
		if(condition)wait 0.1;
		for(i=0;i<level.players.size;i++)
		{
			player=level.players[i];
			if(player.pers["team"]=="spectator")
				if(!isDefined(player.freelook)||!player.freelook)
					player allowSpectateTeam("freelook",condition);
		}
	}
}

monitorFreeLook()
{
	self.freelook=true;
	self thread checkADS();
	self thread checkAttack();
	self thread checkMelee();
}

checkMelee()
{
	self endon("disconnect");
	self endon("joined_team");
	waittillframeend;
	for(;;)
	{
		if(self meleeButtonPressed())
		{
			self notify("stop_follow");
			self.freelook=true;
			self.spectatorlast=undefined;
		}
		while(self meleeButtonPressed())
		{
			wait 0.07;
			continue;
		}
		wait 0.07;
	}
}

checkAttack()
{
	self endon("disconnect");
	self endon("joined_team");
	waittillframeend;
	for(;;)
	{
		if(self attackButtonPressed())
		{
			for(i=0;i<level.players.size;i++)
			{
				players=level.players[i];
				if(isAlive(players)&&((players.pers["team"]=="allies"||players.pers["team"]=="axis")))
				{
					self notify("stop_follow");
					self.freelook=false;break;
				}
			}
		}
		while(self attackButtonPressed())
		{
			wait 0.07;continue;
		}
		wait 0.07;
	}
}

checkADS()
{
	self endon("disconnect");
	self endon("joined_team");
	waittillframeend;
	for(;;)
	{
		while(!self adsButtonPressed())wait 0.07;
		for(i=0;i<level.players.size;i++)
		{
			players=level.players[i];
			if(isAlive(players)&&((players.pers["team"]=="allies"||players.pers["team"]=="axis")))
			{
				self notify("stop_follow");
				self.freelook=false;
				break;
			}
		}
		while(self adsButtonPressed())wait 0.07;
	}
}

default_onSpawnSpectator(origin,angles)
{
	thread freeLook(false);
	if(isDefined(origin)&&isDefined(angles))
	{
		self spawn(origin,angles);
		thread freeLook(true);
		return;
	}
	spawnpointname="mp_global_intermission";
	spawnpoints=getentarray(spawnpointname,"classname");
	spawnpoint=maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);
	self spawn(spawnpoint.origin,spawnpoint.angles);
	thread freeLook(true);
}

spawnIntermission()
{
	self notify("spawned");
	self notify("end_respawn");
	self setSpawnVariables();
	self clearLowerMessage();
	self freezeControls(false);
	self.sessionstate="intermission";
	self.spectatorclient=-1;
	self.killcamentity=-1;
	self.archivetime=0;
	self.psoffsettime=0;
	[[level.onSpawnIntermission]]();
	self setDepthOfField(0,128,512,4000,6,1.8);
}

default_onSpawnIntermission()
{
	spawnpointname="mp_global_intermission";
	spawnpoints=getentarray(spawnpointname,"classname");
	spawnpoint=spawnPoints[0];
	if(isDefined(spawnpoint))self spawn(spawnpoint.origin,spawnpoint.angles);
}

timeUntilRoundEnd()
{
	if(level.gameEnded)
	{
		timePassed=(getTime()-level.gameEndTime)/1000;
		timeRemaining=level.postRoundTime-timePassed;
		if(timeRemaining<0)return 0;
		return timeRemaining;
	}
	if(level.inOvertime||level.timeLimit<=0||!isDefined(level.startTime))return undefined;
	timePassed=(getTime()-level.startTime)/1000;
	timeRemaining=(level.timeLimit*60)-timePassed;
	return timeRemaining+level.postRoundTime;
}

freezePlayerForRoundEnd()
{
	self clearLowerMessage();
}

freeGameplayHudElems()
{
	if(isDefined(self.lowerMessage))self.lowerMessage destroyElem();
	if(isDefined(self.lowerTimer))self.lowerTimer destroyElem();
	if(isDefined(self.proxBar))self.proxBar destroyElem();
	if(isDefined(self.proxBarText))self.proxBarText destroyElem();
}

endGame(winner,endReasonText)
{
	if(isDefined(game["state"])&&game["state"]=="postgame")return;
	if(isDefined(level.onEndGame))[[level.onEndGame]](winner);
	if(isDefined(game["PROMOD_MATCH_MODE"])&&game["PROMOD_MATCH_MODE"]=="match")setDvar("g_deadChat",1);
	game["state"]="postgame";
	if(isDefined(level.ended))
        return;
	level.gameEndTime=getTime();
	level.gameEnded=true;
	level.inGracePeriod=false;
	level notify("game_ended");
	setGameEndTime(0);
	updatePlacement();
	
	for(i=0;i<level.players.size;i++)
	{
		player=level.players[i];
		player freezePlayerForRoundEnd();
		player thread roundEndDoF(4);
		player freeGameplayHudElems();
	}
	
	if((level.roundLimit>1||(!level.roundLimit&&level.scoreLimit!=1))&&!level.forcedEnd)
	{
		if(level.displayRoundEndText)
		{
			for(i=0;
			i<level.players.size;
			i++)
			{
				player=level.players[i];
				if(level.teamBased)player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify(winner,true,endReasonText,0.75);
				else player thread maps\mp\gametypes\_hud_message::outcomeNotify(winner,endReasonText,0.75);
				if(isDefined(player.pers["team"])&&player.pers["team"]=="spectator")continue;player setClientDvars("ui_hud_hardcore",1,"cg_drawSpectatorMessages",0,"g_compassShowEnemies",0);
			}
			if(hitRoundLimit()||hitScoreLimit())roundEndWait(level.roundEndDelay/2);
			else roundEndWait(level.roundEndDelay);
		}
		game["roundsplayed"]++;
		roundSwitching=false;
		if(!hitRoundLimit()&&!hitScoreLimit())roundSwitching=checkRoundSwitch();
		if(roundSwitching&&level.teamBased)
		{
			for(i=0;i<level.players.size;i++)
			{
				player=level.players[i];
				if(player.pers["team"]=="spectator")player setClientDvars("shout_scores_attack",game["teamScores"][game["defenders"]],"shout_scores_defence",game["teamScores"][game["attackers"]]);
				if(!isDefined(player.pers["team"])||player.pers["team"]=="spectator")
				{
					player[[level.spawnIntermission]]();
					player closeMenu();
					player closeInGameMenu();
					continue;
				}
				switchType=level.halftimeType;
				if(switchType=="halftime")
				{
					if(level.roundLimit)
					{
						if((game["roundsplayed"]*2)==level.roundLimit)switchType="halftime";
						else switchType="intermission";
					}
					else if(level.scoreLimit)
					{
						if(game["roundsplayed"]==(level.scoreLimit-1))switchType="halftime";
						else switchType="intermission";
					}
					else switchType="intermission";
				}
				player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify(switchType,true,level.halftimeSubCaption);
				player setClientDvar("ui_hud_hardcore",1);
				if(player.pers["team"]=="axis")
				{
					player.switching=true;
					player menuAllies();
				}
				else if(player.pers["team"]=="allies")
				{
					player.switching=true;
					player menuAxis();
				}
			}
			old_score=game["teamScores"]["allies"];
			game["teamScores"]["allies"]=game["teamScores"]["axis"];
			game["teamScores"]["axis"]=old_score;
			thread maps\mp\gametypes\_promod::updateClassAvailability("allies");
			thread maps\mp\gametypes\_promod::updateClassAvailability("axis");
			roundEndWait(level.halftimeRoundEndDelay);
		}
		else if(!hitRoundLimit()&&!hitScoreLimit()&&!level.displayRoundEndText&&level.teamBased)
		{
			for(i=0;
			i<level.players.size;
			i++)
			{
				player=level.players[i];
				if(!isDefined(player.pers["team"])||player.pers["team"]=="spectator")
				{
					player[[level.spawnIntermission]]();
					player closeMenu();
					player closeInGameMenu();
					continue;
				}
				switchType=level.halftimeType;
				if(switchType=="halftime")
				{
					if(level.roundLimit)
					{
						if((game["roundsplayed"]*2)==level.roundLimit)switchType="halftime";
						else switchType="roundend";
					}
					else if(level.scoreLimit)
					{
						if(game["roundsplayed"]==(level.scoreLimit-1))switchType="halftime";
						else switchTime="roundend";
					}
				}
				player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify(switchType,true,endReasonText);
				player setClientDvar("ui_hud_hardcore",1);
			}
			roundEndWait(level.halftimeRoundEndDelay);
		}
		if(isDefined(game["PROMOD_KNIFEROUND"])&&game["PROMOD_KNIFEROUND"])
		{
			if(isDefined(game["PROMOD_MATCH_MODE"])&&game["PROMOD_MATCH_MODE"]=="match") /////////////////////
			{
				game["promod_do_readyup"]=1;
				game["promod_first_readyup_done"]=0;
				for(i=0;i<level.players.size;i++)
				{
					level.players[i].pers["kills"]=0;
					level.players[i].pers["deaths"]=0;
					level.players[i].pers["assists"]=0;
					level.players[i].pers["score"]=0;
					waittillframeend;
				}  ////////////////////////////////////////////////////////////////////////////////////////////
				game["roundsplayed"]--;
				[[level._setTeamScore]]("allies",0);
				[[level._setTeamScore]]("axis",0);
				for(i=0;i<level.players.size;i++)
				if(level.players[i].pers["team"]=="spectator")level.players[i]setClientDvars("shout_scores_attack",game["teamScores"][game["attackers"]],"shout_scores_defence",game["teamScores"][game["defenders"]]);
			}
			game["PROMOD_KNIFEROUND"]=0;
			for(i=0;i<level.players.size;i++)
			{
				if(level.players[i].pers["team"]=="axis"||level.players[i].pers["team"]=="allies")level.players[i]setclientdvar("g_compassShowEnemies",0);
				waittillframeend;
			}
		}
		executePostRoundEvents();
		if(!hitRoundLimit()&&!hitScoreLimit())
		{
			game["state"]="playing";
			if ( isDefined(level.teamBalance) && level.teambalance )
			level notify ( "roundSwitching" );
			map_restart(true);
			return;
		}
		if(hitRoundLimit())endReasonText=game["strings"]["round_limit_reached"];
		else if(hitScoreLimit())endReasonText=game["strings"]["score_limit_reached"];
		else endReasonText=game["strings"]["time_limit_reached"];
	}
	for(i=0;i<level.players.size;i++)
	{
		player=level.players[i];
		if(!isDefined(player.pers["team"])||player.pers["team"]=="spectator")
		{
			player[[level.spawnIntermission]]();
			player closeMenu();
			player closeInGameMenu();
			continue;
		}
		if(level.teamBased)
		{
			winner=getWinningTeam();
			player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify(winner,false,endReasonText);
		}
		else player thread maps\mp\gametypes\_hud_message::outcomeNotify(winner,endReasonText);
		player setClientDvars("ui_hud_hardcore",1,"cg_drawSpectatorMessages",0,"g_compassShowEnemies",0);
		player maps\mp\gametypes\_weapons::printStats();
	}
	roundEndWait(level.postRoundTime);
	level.intermission=true;
	if ( isOneRound() )
	{
		setDvar( "scr_gameended", 1 );
		maps\mp\gametypes\_globallogic_utils::executePostRoundEvents();
	}
	//regain players array since some might've disconnected during the wait above
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];
		
		player closeMenu();
		player closeInGameMenu();
		player notify ( "reset_outcome" );
		player setClientDvar( "ui_hud_hardcore", 1 );
		player setclientdvar( "g_scriptMainMenu", "" );
	}

	duffman\mapvote::init();
	
	for(i=0;i<level.players.size;i++)
	{
		player=level.players[i];
		player closeMenu();
		player closeInGameMenu();
		player notify("reset_outcome");
		player thread spawnIntermission();
		player setClientDvar("ui_hud_hardcore",0);
	}
	wait 4;
	if(isDefined(game["PROMOD_MATCH_MODE"])&&game["PROMOD_MATCH_MODE"]=="match")
	{
		map_restart(false);
		return;
	}
	exitLevel(false);
}

getWinningTeam()
{
	if(getGameScore("allies")==getGameScore("axis"))winner="tie";
	else if(getGameScore("allies")>getGameScore("axis"))winner="allies";
	else winner="axis";
	return winner;
}

roundEndWait(defaultDelay)
{
	notifiesDone=false;
	while(!notifiesDone)
	{
		notifiesDone=true;
		for(i=0;i<level.players.size;i++)
		{
			players=level.players[i];
			if(!isDefined(players.doingNotify)||!players.doingNotify)continue;
			notifiesDone=false;
		}
		wait 0.5;
	}
	wait defaultDelay;
}

roundEndDOF(time)
{
	self setDepthOfField(0,128,512,4000,6,1.8);
}

getHighestScoringPlayer()
{
	winner=undefined;
	tie=false;
	for(i=0;i<level.players.size;i++)
	{
		players=level.players[i];
		if(!isDefined(players.score)||players.score<1)continue;
		if(!isDefined(winner)||players.score>winner.score)
		{
			winner=players;
			tie=false;
		}
		else if(players.score==winner.score)tie=true;
	}
	if(tie||!isDefined(winner))return undefined;
	else return winner;
}

checkTimeLimit()
{
	if(isDefined(level.timeLimitOverride)&&level.timeLimitOverride)return;
	if(!isDefined(game["state"])||game["state"]!="playing")
	{
		setGameEndTime(0);
		return;
	}
	if(level.timeLimit<=0)
	{
		setGameEndTime(0);
		return;
	}
	if(level.inPrematchPeriod)
	{
		setGameEndTime(0);
		return;
	}
	if(!isdefined(level.startTime))return;
	timeLeft=getTimeRemaining();
	setGameEndTime(getTime()+int(timeLeft));
	if(timeLeft>0)return;
	[[level.onTimeLimit]]();
}

getTimeRemaining()
{
	return level.timeLimit*60000-getTimePassed();
}

checkScoreLimit()
{
	if((!isDefined(game["state"])||game["state"]!="playing")||level.scoreLimit<=0||(level.teamBased&&game["teamScores"]["allies"]<level.scoreLimit&&game["teamScores"]["axis"]<level.scoreLimit)||(!level.teamBased&&(!isPlayer(self)||self.score<level.scoreLimit)))return;
	[[level.onScoreLimit]]();
}

hitRoundLimit()
{
	if(level.roundLimit<=0)return false;
	return(game["roundsplayed"]>=level.roundLimit);
}

hitScoreLimit()
{
	if(level.scoreLimit<=0)return false;
	if(level.teamBased)
		if(game["teamScores"]["allies"]>=level.scoreLimit||game["teamScores"]["axis"]>=level.scoreLimit)
			return true;
	else
	{
		for(i=0;i<level.players.size;i++)
		{
			player=level.players[i];
			if(isDefined(player.score)&&player.score>=level.scorelimit)return true;
		}
	}
	return false;
}

updateGameTypeDvars()
{
	level endon("game_ended");
	while(isDefined(game["state"])&&game["state"]=="playing")
	{
		thread checkTimeLimit();
		thread checkScoreLimit();
		if(isdefined(level.startTime)&&getTimeRemaining()<3000)
		{
			wait 0.1;
			continue;
		}
		wait 1;
	}
}

menuAutoAssign()
{
	teams[0]="allies";
	teams[1]="axis";
	assignment=teams[randomInt(2)];
	self closeMenus();
	if(level.teamBased)
	{
		playerCounts=self maps\mp\gametypes\_teams::CountPlayers();
		if(playerCounts["allies"]==playerCounts["axis"])
		{
			if(getTeamScore("allies")==getTeamScore("axis"))assignment=teams[randomInt(2)];
			else if(getTeamScore("allies")<getTeamScore("axis"))assignment="allies";
			else assignment="axis";
		}
		else if(playerCounts["allies"]<playerCounts["axis"])assignment="allies";
		else assignment="axis";
		if(assignment==self.pers["team"]&&(self.sessionstate=="playing"||self.sessionstate=="dead"))
		{
			self beginClassChoice();
			return;
		}
	}
	if(assignment!=self.pers["team"]&&self.sessionstate=="playing")
	{
		self.switching_teams=true;
		self.joining_team=assignment;
		self.leaving_team=self.pers["team"];
		self suicide();
	}
	oldTeam=self.pers["team"];
	self.pers["class"]=undefined;
	self.class=undefined;
	self.pers["team"]=assignment;
	self.team=assignment;
	self setClientDvar("loadout_curclass","");
	self updateObjectiveText();
	if(level.teamBased)self.sessionteam=assignment;
	else self.sessionteam="none";
	if(!isDefined(level.rdyup)||!level.rdyup)
	{
		if(!isAlive(self))self.statusicon="hud_status_dead";
		else self.statusicon="";
	}
	self notify("joined_team");
	self notify("end_respawn");
	self.freelook=undefined;
	if(self.pers["team"]=="allies"&&oldTeam!=self.pers["team"])
	{
		if(game["attackers"]=="allies"&&game["defenders"]=="axis")iPrintLN(self.name+"^7 Joined Attack");
		else iPrintLN(self.name+" Joined Defence");
	}
	else if(self.pers["team"]=="axis"&&oldTeam!=self.pers["team"])
	{
		if(game["attackers"]=="allies"&&game["defenders"]=="axis")iPrintLN(self.name+"^7 Joined Defence");
		else iPrintLN(self.name+" Joined Attack");
	}
	if(oldTeam!=self.pers["team"]&&(oldTeam=="allies"||oldTeam=="axis"))thread maps\mp\gametypes\_promod::updateClassAvailability(oldTeam);
	self setClientDvars("g_compassShowEnemies",0,"cg_scoreboardheight",435);
	self beginClassChoice();
	self setclientdvar("g_scriptMainMenu",game["menu_class_"+self.pers["team"]]);
}

updateObjectiveText()
{
	if(self.pers["team"]=="spectator")
	{
		self setClientDvar("cg_objectiveText","");
		return;
	}
	if(level.scorelimit>0)self setclientdvar("cg_objectiveText",getObjectiveScoreText(self.pers["team"]),level.scorelimit);
	else self setclientdvar("cg_objectiveText",getObjectiveText(self.pers["team"]));
}

closeMenus()
{
	self closeMenu();
	self closeInGameMenu();
}

beginClassChoice()
{
	if(self.pers["team"]=="axis"||self.pers["team"]=="allies")self openMenu(game["menu_changeclass_"+self.pers["team"]]);
}

menuAllies()
{
	if(self.pers["team"]=="allies")return;
	self closeMenus();
	if(!isDefined(self.switching))self.switching=false;
	if(self.pers["team"]!="allies")
	{
		if(isDefined(game["PROMOD_MATCH_MODE"])&&game["PROMOD_MATCH_MODE"]!="match"&&level.teamBased&&!self.switching&&!maps\mp\gametypes\_teams::getJoinTeamPermissions("allies"))
		{
			self openMenu(game["menu_team"]);
			return;
		}
		if(level.inGracePeriod&&(!isdefined(self.hasDoneCombat)||!self.hasDoneCombat))self.hasSpawned=false;
		if(self.sessionstate=="playing"&&!self.switching)
		{
			self.switching_teams=true;
			self.joining_team="allies";
			self.leaving_team=self.pers["team"];
			self suicide();
		}
		oldTeam=self.pers["team"];
		if(self.switching)
		{
			self.pers["team"]="allies";self.team="allies";
		}
		else
		{
			self.pers["class"]=undefined;
			self.class=undefined;
			self.pers["team"]="allies";
			self.team="allies";
			self setClientDvar("loadout_curclass","");
		}
		self updateObjectiveText();
		if(level.teamBased)self.sessionteam="allies";
		else self.sessionteam="none";
		if(!isDefined(level.rdyup)||!level.rdyup)
		{
			if(!isAlive(self))self.statusicon="hud_status_dead";
			else self.statusicon="";
		}
		self setclientdvar("g_scriptMainMenu",game["menu_class_allies"]);
		self notify("joined_team");
		self notify("end_respawn");
		self.freelook=undefined;
		if(game["attackers"]=="allies"&&game["defenders"]=="axis"&&!self.switching)iprintln(self.name+"^7 Joined Attack");
		else if(!self.switching)iprintln(self.name+"^7 Joined Defence");
		if(oldTeam=="axis")thread maps\mp\gametypes\_promod::updateClassAvailability(oldTeam);
		self setClientDvars("g_compassShowEnemies",0,"cg_scoreboardheight",435);
	}
	if(!self.switching)self beginClassChoice();
	self.switching=false;
}

menuAxis()
{
	if(self.pers["team"]=="axis")return;
	self closeMenus();
	if(!isDefined(self.switching))self.switching=false;
	if(self.pers["team"]!="axis")
	{
		if(isDefined(game["PROMOD_MATCH_MODE"])&&game["PROMOD_MATCH_MODE"]!="match"&&level.teamBased&&!self.switching&&!maps\mp\gametypes\_teams::getJoinTeamPermissions("allies"))
		{
			self openMenu(game["menu_team"]);
			return;
		}
		if(level.inGracePeriod&&(!isdefined(self.hasDoneCombat)||!self.hasDoneCombat))self.hasSpawned=false;
		if(self.sessionstate=="playing"&&!self.switching)
		{
			self.switching_teams=true;
			self.joining_team="axis";
			self.leaving_team=self.pers["team"];
			self suicide();
		}
		oldTeam=self.pers["team"];
		if(self.switching)
		{
			self.pers["team"]="axis";
			self.team="axis";
		}
		else
		{
			self.pers["class"]=undefined;
			self.class=undefined;
			self.pers["team"]="axis";
			self.team="axis";
			self setClientDvar("loadout_curclass","");
		}
		self updateObjectiveText();
		if(level.teamBased)self.sessionteam="axis";
		else self.sessionteam="none";
		if(!isDefined(level.rdyup)||!level.rdyup)
		{
			if(!isAlive(self))self.statusicon="hud_status_dead";
			else self.statusicon="";
		}
		self setclientdvar("g_scriptMainMenu",game["menu_class_axis"]);
		self notify("joined_team");
		self notify("end_respawn");
		self.freelook=undefined;
		if(game["attackers"]=="allies"&&game["defenders"]=="axis"&&!self.switching)iprintln(self.name+"^7 Joined Defence");
		else if(!self.switching)iprintln(self.name+"^7 Joined Attack");
		if(oldTeam=="allies")thread maps\mp\gametypes\_promod::updateClassAvailability(oldTeam);
		self setClientDvars("g_compassShowEnemies",0,"cg_scoreboardheight",435);
	}
	if(!self.switching)self beginClassChoice();
	self.switching=false;
}

menuKillspec()
{
	if(self.pers["team"]!="axis"&&self.pers["team"]!="allies")return;
	self closeMenus();
	if(self.sessionstate=="playing")self suicide();
	self.pers["class"]=undefined;
	self.class=undefined;
	self iprintln("Choose a class to respawn");
	self setClientDvar("loadout_curclass","");
	self thread[[level.spawnSpectator]](self.origin,self.angles);
	thread maps\mp\gametypes\_promod::updateClassAvailability(self.pers["team"]);
}

menuSpectator()
{
	if(self.pers["team"]=="spectator")return;
	self closeMenus();
	if(self.pers["team"]!="spectator")
	{
		if(self.sessionstate=="playing")
		{
			self.switching_teams=true;
			self.joining_team="spectator";
			self.leaving_team=self.pers["team"];
			self suicide();
		}
		oldTeam=self.pers["team"];
		self.pers["class"]=undefined;
		self.class=undefined;
		self.pers["team"]="spectator";
		self.team="spectator";
		self setClientDvar("loadout_curclass","");
		self updateObjectiveText();
		self.sessionteam="spectator";
		self thread[[level.spawnSpectator]](self.origin,self.angles);
		if(game["attackers"]=="allies"&&game["defenders"]=="axis")self setClientDvars("shout_attack_name","Attack","shout_defence_name","Defence");
		else self setClientDvars("shout_attack_name","Defence","shout_defence_name","Attack");
		self setClientDvars("shout_scores_attack",game["teamScores"][game["attackers"]],"shout_scores_defence",game["teamScores"][game["defenders"]]);
		self notify("joined_spectators");
		iprintln(self.name + " Joined Spectators");
		logPrint("JT;"+self getGuid()+";"+self getEntityNumber()+";spectator;"+self.name+";\n");
		if(oldTeam=="allies"||oldTeam=="axis")thread maps\mp\gametypes\_promod::updateClassAvailability(oldTeam);
		self setClientDvars("g_compassShowEnemies",1,"cg_scoreboardheight",500);
	}
}

removeDisconnectedPlayerFromPlacement()
{
	offset=0;
	numPlayers=level.placement["all"].size;
	found=false;
	for(i=0;i<numPlayers;i++)
	{
		if(level.placement["all"][i]==self)found=true;
		if(found)level.placement["all"][i]=level.placement["all"][i+1];
	}
	if(!found)return;
	level.placement["all"][numPlayers-1]=undefined;
	updateTeamPlacement();
	if(level.teamBased)return;
	numPlayers=level.placement["all"].size;
	for(i=0;i<numPlayers;i++)
	{
		player=level.placement["all"][i];
		player notify("update_outcome");
	}
}

updatePlacement()
{
	prof_begin("updatePlacement");
	if(!level.players.size)return;
	level.placement["all"]=[];
	for(i=0;i<level.players.size;i++)
	{
		if(level.players[i].team=="allies"||level.players[i].team=="axis")level.placement["all"][level.placement["all"].size]=level.players[i];
	}
	placementAll=level.placement["all"];
	for(i=1;i<placementAll.size;i++)
	{
		player=placementAll[i];
		playerScore=player.score;
		for(j=i-1;j>=0&&(playerScore>placementAll[j].score||(playerScore==placementAll[j].score&&player.deaths<placementAll[j].deaths));j--)
			placementAll[j+1]=placementAll[j];
		placementAll[j+1]=player;
	}
	level.placement["all"]=placementAll;
	updateTeamPlacement();
	prof_end("updatePlacement");
}

updateTeamPlacement()
{
	placement["allies"]=[];
	placement["axis"]=[];
	placement["spectator"]=[];
	if(!level.teamBased)return;
	placementAll=level.placement["all"];
	placementAllSize=placementAll.size;
	for(i=0;i<placementAllSize;i++)
	{
		player=placementAll[i];
		team=player.pers["team"];
		placement[team][placement[team].size]=player;
	}
	level.placement["allies"]=placement["allies"];
	level.placement["axis"]=placement["axis"];
}

onXPEvent(event)
{
	self maps\mp\gametypes\_rank::giveRankXP(event);
}

givePlayerScore(event,player,victim)
{
	if(level.overridePlayerScore)return;
	score=player.pers["score"];
	[[level.onPlayerScore]](event,player,victim);
	if(score==player.pers["score"])return;
	player.score=player.pers["score"];
	if(!level.teambased)thread sendUpdatedDMScores();
	player notify("update_playerscore_hud");
	player thread checkScoreLimit();
}

default_onPlayerScore(event,player,victim)
{
	score=maps\mp\gametypes\_rank::getScoreInfoValue(event);
	player.pers["score"]+=score;
}

_setPlayerScore(player,score)
{
	if(score==player.pers["score"])return;
	player.pers["score"]=score;
	player.score=player.pers["score"];
	player notify("update_playerscore_hud");
	player thread checkScoreLimit();
}

_getPlayerScore(player)
{
	return player.pers["score"];
}

giveTeamScore(event,team,player,victim)
{
	if(level.overrideTeamScore)return;
	teamScore=game["teamScores"][team];
	[[level.onTeamScore]](event,team,player,victim);
	if(teamScore==game["teamScores"][team])return;updateTeamScores(team);
	thread checkScoreLimit();
}

_setTeamScore(team,teamScore)
{
	if(teamScore==game["teamScores"][team])return;
	game["teamScores"][team]=teamScore;
	updateTeamScores(team);
	thread checkScoreLimit();
}

updateTeamScores(team1,team2)
{
	setTeamScore(team1,getGameScore(team1));
	if(isdefined(team2))setTeamScore(team2,getGameScore(team2));
	if(level.teambased)thread sendUpdatedTeamScores();
}

_getTeamScore(team)
{
	return game["teamScores"][team];
}

default_onTeamScore(event,team,player,victim)
{
	score=maps\mp\gametypes\_rank::getScoreInfoValue(event);
	otherTeam=level.otherTeam[team];
	if(game["teamScores"][team]>game["teamScores"][otherTeam])level.wasWinning=team;
	else if(game["teamScores"][otherTeam]>game["teamScores"][team])level.wasWinning=otherTeam;
	game["teamScores"][team]+=score;
	isWinning="none";
	if(game["teamScores"][team]>game["teamScores"][otherTeam])isWinning=team;
	else if(game["teamScores"][otherTeam]>game["teamScores"][team])isWinning=otherTeam;
	if(isWinning!="none"&&isWinning!=level.wasWinning&&getTime()-level.lastStatusTime>5000)level.lastStatusTime=getTime();
	if(isWinning!="none")level.wasWinning=isWinning;
}

sendUpdatedTeamScores()
{
	level notify("updating_scores");
	level endon("updating_scores");
	wait 0.05;
	WaitTillSlowProcessAllowed();
	for(i=0;i<level.players.size;i++)level.players[i]updateScores();
	for(i=0;i<level.players.size;i++)
	{
		player=level.players[i];
		if(player.pers["team"]=="spectator")
		{
			if(game["attackers"]=="allies"&&game["defenders"]=="axis")player setClientDvars("shout_scores_attack",game["teamScores"]["allies"],"shout_scores_defence",game["teamScores"]["axis"]);
			else player setClientDvars("shout_scores_attack",game["teamScores"]["axis"],"shout_scores_defence",game["teamScores"]["allies"]);
		}
	}
}

sendUpdatedDMScores()
{
	level notify("updating_dm_scores");
	level endon("updating_dm_scores");
	wait 0.05;
	WaitTillSlowProcessAllowed();
	for(i=0;i<level.players.size;i++)
	{
		level.players[i]updateDMScores();
		level.players[i].updatedDMScores=true;
	}
}

initPersStat(dataName)
{
	if(!isDefined(self.pers[dataName]))self.pers[dataName]=0;
}

getPersStat(dataName)
{
	return self.pers[dataName];
}

incPersStat(dataName,increment)
{
	self.pers[dataName]+=increment;
}

updateTeamStatus()
{
	level notify("updating_team_status");
	level endon("updating_team_status");
	level endon("game_ended");
	if(isDefined(game["state"])&&game["state"]=="postgame")return;
	prof_begin("updateTeamStatus");
	level.playerCount["allies"]=0;
	level.playerCount["axis"]=0;
	level.lastAliveCount["allies"]=level.aliveCount["allies"];
	level.lastAliveCount["axis"]=level.aliveCount["axis"];
	level.aliveCount["allies"]=0;level.aliveCount["axis"]=0;
	level.playerLives["allies"]=0;
	level.playerLives["axis"]=0;
	level.alivePlayers["allies"]=[];
	level.alivePlayers["axis"]=[];
	level.activePlayers=[];
	for(i=0;i<level.players.size;i++)
	{
		player=level.players[i];
		team=player.team;
		class=player.class;
		if(team!="spectator"&&(isDefined(class)&&class!="") && !isDefined(player.isKnifing))
		{
			level.playerCount[team]++;
			if(player.sessionstate=="playing")
			{
				level.aliveCount[team]++;
				level.playerLives[team]++;
				if(isAlive(player))
				{
					level.alivePlayers[team][level.alivePlayers.size]=player;
					level.activeplayers[level.activeplayers.size]=player;
				}
			}
			else if(player maySpawn()) level.playerLives[team]++;
		}
	}
	if(level.aliveCount["allies"]+level.aliveCount["axis"]>level.maxPlayerCount)level.maxPlayerCount=level.aliveCount["allies"]+level.aliveCount["axis"];
	if(level.aliveCount["allies"])level.everExisted["allies"]=true;if(level.aliveCount["axis"])level.everExisted["axis"]=true;
	for(i=0;i<level.players.size;i++)
		if(level.players[i].pers["team"]=="allies"||level.players[i].pers["team"]=="axis")level.players[i]setClientDvars("self_alive",level.aliveCount[level.players[i].pers["team"]],"opposing_alive",level.aliveCount[maps\mp\gametypes\_gameobjects::getEnemyTeam(level.players[i].pers["team"])]);
	prof_end("updateTeamStatus");
	level updateGameEvents();
}

isValidClass(class)
{
	return isdefined(class)&&class!="";
}

playTickingSound()
{
	self endon("death");
	self endon("stop_ticking");
	level endon("game_ended");
	for(;;)
	{
		self playSound("ui_mp_suitcasebomb_timer");
		wait 1;
	}
}

stopTickingSound()
{
	self notify("stop_ticking");
}

timeLimitClock()
{
	level endon("game_ended");
	wait 0.05;
	clockObject=spawn("script_origin",(0,0,0));
	while(isDefined(game["state"])&&game["state"]=="playing")
	{
		if(!level.timerStopped&&level.timeLimit)
		{
			timeLeft=getTimeRemaining()/1000;
			timeLeftInt=int(timeLeft+0.5);
			if(timeLeftInt<=10||(timeLeftInt<=30&&timeLeftInt%2==0))
			{
				if(!timeLeftInt)break;
					clockObject playSound("ui_mp_timer_countdown");
			}
			if(timeLeft-floor(timeLeft)>=0.05)wait timeLeft-floor(timeLeft);
		}
		wait 1;
	}
}

gameTimer()
{
	level endon("game_ended");
	level waittill("prematch_over");
	level.startTime=getTime();
	level.discardTime=0;
	if(isDefined(game["roundMillisecondsAlreadyPassed"]))
	{
		level.startTime-=game["roundMillisecondsAlreadyPassed"];
		game["roundMillisecondsAlreadyPassed"]=undefined;
	}
	prevtime=gettime();
	while(isDefined(game["state"])&&game["state"]=="playing")
	{
		if(!level.timerStopped)game["timepassed"]+=gettime()-prevtime;
		prevtime=gettime();
		wait 1;
	}
}

getTimePassed()
{
	if(!isDefined(level.startTime))return 0;
	if(level.timerStopped)return(level.timerPauseTime-level.startTime)-level.discardTime;
	else return(gettime()-level.startTime)-level.discardTime;
}

pauseTimer()
{
	if(level.timerStopped)return;
	level.timerStopped=true;
	level.timerPauseTime=gettime();
}

resumeTimer()
{
	if(!level.timerStopped)return;
	level.timerStopped=false;
	level.discardTime+=gettime()-level.timerPauseTime;
}

openMainMenu()
{
	maxwait=0;while(!level.players.size&&maxwait<=1)
	{
		wait 0.05;
		maxwait+=0.05;
	}
	for(i=0;i<level.players.size;i++)
	{
		player=level.players[i];
		if(!isDefined(player.pers["team"])||player.pers["team"]=="none")
		{
			player setclientdvar("g_scriptMainMenu",game["menu_team"]);
			player openMenu(game["menu_team"]);
		}
	}
}

checkRestartMap()
{
	if(getDvar("o_gametype")=="")setDvar("o_gametype",level.gametype);
	else if(getDvar("o_gametype")!=level.gametype)
	{
		level.restarting=true;
		setDvar("o_gametype",level.gametype);
		maprot=getDvar("sv_maprotationcurrent");
		new_maprot="map "+level.script+" "+maprot;
		setDvar("sv_maprotationcurrent",new_maprot);
		exitLevel(false);
	}
}

startGame()
{
	thread gameTimer();
	level.timerStopped=true;
	thread maps\mp\gametypes\_spawnlogic::spawnPerFrameUpdate();
	prematchPeriod();
	thread openMainMenu();
	if ((isDefined(game["PROMOD_MATCH_MODE"]) && game["PROMOD_MATCH_MODE"] == "match" || getDvarInt("promod_allow_strattime") && isDefined(game["CUSTOM_MODE"]) && game["CUSTOM_MODE"]) && (level.gametype == "sd" || level.gametype == "sr")) promod\strattime::main();
	if(isDefined(game["PROMOD_MATCH_MODE"])&&game["PROMOD_MATCH_MODE"]=="strat")
	{
		thread disableBombsites();
		thread promod\stratmode::main();
		setDvar("g_deadChat",1);
		SetClientNameMode("auto_change");
		setGameEndTime(0);
		return;
	}
	if(isDefined(game["PROMOD_KNIFEROUND"])&&game["PROMOD_KNIFEROUND"])
	{
		thread disableBombsites();
		if(game["PROMOD_MATCH_MODE"]!="pub")
		{
			level.timeLimitOverride=true;
			setGameEndTime(0);
		}
	}
	level notify("prematch_over");
	level.timerStopped=false;
	if(!isDefined(game["PROMOD_KNIFEROUND"])||!game["PROMOD_KNIFEROUND"]||game["PROMOD_MATCH_MODE"]=="pub")thread timeLimitClock();
	thread gracePeriod();
}

disableBombsites()
{
	if(level.gametype=="sd"||level.gametype=="sr"&&isDefined(level.bombZones))
		for(j=0;j<level.bombZones.size;j++)
			level.bombZones[j]maps\mp\gametypes\_gameobjects::disableObject();
}

prematchPeriod()
{
	level endon("game_ended");
	if(level.prematchPeriod>0&&isDefined(game["PROMOD_MATCH_MODE"])&&game["PROMOD_MATCH_MODE"]!="match"&&game["PROMOD_MATCH_MODE"]!="strat")
	{
		if(getDvarInt("promod_allow_strattime")&&isDefined(game["CUSTOM_MODE"])&&game["CUSTOM_MODE"]&&(level.gametype=="sd"||level.gametype=="sr"))matchStartTimerSkip();
		else matchStartTimer();
	}
	else matchStartTimerSkip();
	level.inPrematchPeriod=false;
	for(i=0;i<level.players.size;i++)
	{
		level.players[i]freezeControls(false);
		level.players[i]enableWeapons();
	}
}

gracePeriod()
{
	level endon("game_ended");
	wait level.gracePeriod;
	level notify("grace_period_ending");
	wait 0.05;
	level.inGracePeriod=false;
	if(!isDefined(game["state"])||game["state"]!="playing")return;
	if(level.numLives)
	{
		for(i=0;i<level.players.size;i++)
		{
			player=level.players[i];
			if(!player.hasSpawned&&player.sessionteam!="spectator"&&!isAlive(player))player.statusicon="hud_status_dead";
		}
	}
	level thread updateTeamStatus();
}

TimeUntilWaveSpawn(minimumWait)
{
	earliestSpawnTime=gettime()+minimumWait*1000;
	lastWaveTime=level.lastWave[self.pers["team"]];
	waveDelay=level.waveDelay[self.pers["team"]]*1000;
	numWavesPassedEarliestSpawnTime=(earliestSpawnTime-lastWaveTime)/waveDelay;
	numWaves=ceil(numWavesPassedEarliestSpawnTime);
	timeOfSpawn=lastWaveTime+numWaves*waveDelay;
	if(isdefined(self.waveSpawnIndex))timeOfSpawn+=50*self.waveSpawnIndex;
	return(timeOfSpawn-gettime())/1000;
}

TimeUntilSpawn()
{
	if((level.inGracePeriod&&!self.hasSpawned)||(isDefined(level.rdyup)&&level.rdyup)||(isDefined(game["PROMOD_MATCH_MODE"])&&game["PROMOD_MATCH_MODE"]=="strat"))return 0;
	respawnDelay=0;
	if(self.hasSpawned)
	{
		result=self[[level.onRespawnDelay]]();
		if(isDefined(result))respawnDelay=result;
		else respawnDelay=getDvarInt("scr_"+level.gameType+"_playerrespawndelay");
	}
	waveBased=(getDvarInt("scr_"+level.gameType+"_waverespawndelay")>0);
	if(waveBased)return self TimeUntilWaveSpawn(respawnDelay);
	return respawnDelay;
}

maySpawn()
{
	if((isDefined(level.rdyup)&&level.rdyup)||(isDefined(game["PROMOD_MATCH_MODE"])&&game["PROMOD_MATCH_MODE"]=="strat"))return true;
	if(level.inOvertime)return false;
	if(level.numLives)
	{
		if(level.teamBased)gameHasStarted=(level.everExisted["axis"]&&level.everExisted["allies"]);
		else gameHasStarted=(level.maxPlayerCount>1);
		if(gameHasStarted&&(!self.pers["lives"]||(!level.inGracePeriod&&!self.hasSpawned)))return false;
	}
	return true;
}

spawnClient(timeAlreadyPassed)
{
	if(!self maySpawn())
	{
		shouldShowRespawnMessage=true;
		if((level.roundLimit>1&&game["roundsplayed"]>=(level.roundLimit-1))||(level.scoreLimit>1&&level.teambased&&game["teamScores"]["allies"]>=level.scoreLimit-1&&game["teamScores"]["axis"]>=level.scoreLimit-1))shouldShowRespawnMessage=false;
		if(shouldShowRespawnMessage)
		{
			setLowerMessage(game["strings"]["spawn_next_round"]);
			self thread removeSpawnMessageShortly();
		}
		self thread[[level.spawnSpectator]](self.origin,self.angles);
		return;
	}
	if(self.waitingToSpawn)return;
	self.waitingToSpawn=true;
	self waitAndSpawnClient(timeAlreadyPassed);
	if(isdefined(self))self.waitingToSpawn=false;
}

waitAndSpawnClient(timeAlreadyPassed)
{
	self endon("disconnect");
	self endon("end_respawn");
	self endon("game_ended");
	if(!isdefined(timeAlreadyPassed))timeAlreadyPassed=0;
	spawnedAsSpectator=false;
	if(!isdefined(self.waveSpawnIndex)&&isdefined(level.wavePlayerSpawnIndex[self.team]))
	{
		self.waveSpawnIndex=level.wavePlayerSpawnIndex[self.team];
		level.wavePlayerSpawnIndex[self.team]++;
	}
	timeUntilSpawn=TimeUntilSpawn();
	if(timeUntilSpawn>timeAlreadyPassed)
	{
		timeUntilSpawn-=timeAlreadyPassed;
		timeAlreadyPassed=0;
	}
	else
	{
		timeAlreadyPassed-=timeUntilSpawn;
		timeUntilSpawn=0;
	}
	if(timeUntilSpawn>0)
	{
		setLowerMessage(game["strings"]["waiting_to_spawn"],timeUntilSpawn);
		if(!spawnedAsSpectator)self thread respawn_asSpectator(self.origin+(0,0,60),self.angles);
		spawnedAsSpectator=true;
		self waitForTimeOrNotify(timeUntilSpawn,"force_spawn");
	}
	waveBased=(getDvarInt("scr_"+level.gameType+"_waverespawndelay")>0);
	if(!maps\mp\gametypes\_tweakables::getTweakableValue("player","forcerespawn")&&self.hasSpawned&&!waveBased)
	{
		setLowerMessage(game["strings"]["press_to_spawn"]);
		if(!spawnedAsSpectator)self thread respawn_asSpectator(self.origin+(0,0,60),self.angles);
		spawnedAsSpectator=true;
		self waitRespawnButton();
	}
	self.waitingToSpawn=false;
	self clearLowerMessage();
	self.waveSpawnIndex=undefined;
	self thread[[level.spawnPlayer]]();
}

waitForTimeOrNotify(time,notifyname)
{
	self endon("disconnect");
	self endon(notifyname);
	wait time;
}

removeSpawnMessageShortly()
{
	self endon("disconnect");
	waittillframeend;
	self endon("end_respawn");
	wait 2;
	self clearLowerMessage(2);
}

Callback_StartGameType()
{
	level.prematchPeriod=0;
	level.intermission=false;
	game["state"]="playing";
	if(!isDefined(game["gamestarted"]))
	{
		if(!isDefined(game["allies"]))game["allies"]="marines";
		if(!isDefined(game["axis"]))game["axis"]="opfor";
		if(!isDefined(game["attackers"]))game["attackers"]="allies";
		if(!isDefined(game["defenders"]))game["defenders"]="axis";
		if(!isDefined(game["state"]))game["state"]="playing";
		makeDvarServerInfo("scr_allies","usmc");
		makeDvarServerInfo("scr_axis","arab");
		game["strings"]["press_to_spawn"]=&"PLATFORM_PRESS_TO_SPAWN";
		if(level.teamBased)
		{
			game["strings"]["waiting_for_teams"]=&"MP_WAITING_FOR_TEAMS";
			game["strings"]["opponent_forfeiting_in"]=&"MP_OPPONENT_FORFEITING_IN";
		}
		else
		{
			game["strings"]["waiting_for_teams"]=&"MP_WAITING_FOR_PLAYERS";
			game["strings"]["opponent_forfeiting_in"]=&"MP_OPPONENT_FORFEITING_IN";
		}
		game["strings"]["match_starting_in"]=&"MP_MATCH_STARTING_IN";
		game["strings"]["spawn_next_round"]=&"MP_SPAWN_NEXT_ROUND";
		game["strings"]["waiting_to_spawn"]=&"MP_WAITING_TO_SPAWN";
		game["strings"]["match_starting"]=&"MP_MATCH_STARTING";
		game["strings"]["change_class"]=&"MP_CHANGE_CLASS_NEXT_SPAWN";
		game["strings"]["tie"]=&"MP_MATCH_TIE";
		game["strings"]["round_draw"]=&"MP_ROUND_DRAW";
		game["strings"]["enemies_eliminated"]=&"MP_ENEMIES_ELIMINATED";
		game["strings"]["score_limit_reached"]=&"MP_SCORE_LIMIT_REACHED";
		game["strings"]["round_limit_reached"]=&"MP_ROUND_LIMIT_REACHED";
		game["strings"]["time_limit_reached"]=&"MP_TIME_LIMIT_REACHED";
		game["strings"]["players_forfeited"]=&"MP_PLAYERS_FORFEITED";
		
		game["colors"]["blue"] = (0.4, 0.65, 0.8);
		game["colors"]["orange"] = (1, 0.44, 0.13);
		game["colors"]["red"] = (0.9,0.1,0.1);
		game["colors"]["white"] = (1.0,1.0,1.0);
		game["colors"]["black"] = (0.0,0.0,0.0);
		game["colors"]["green"] = (0.25,0.75,0.25);
		game["colors"]["yellow"] = (0.65,0.65,0.0);
		
		if(game["attackers"]=="allies"&&game["defenders"]=="axis")
		{
			game["strings"]["allies_name"]="Attack";
			game["strings"]["axis_name"]="Defence";
			game["strings"]["allies_eliminated"]="Attack eliminated";
			game["strings"]["axis_eliminated"]="Defence eliminated";
			game["strings"]["allies_forfeited"]="Attack forfeited";
			game["strings"]["axis_forfeited"]="Defence forfeited";
		}
		else
		{
			game["strings"]["allies_name"]="Defence";
			game["strings"]["axis_name"]="Attack";
			game["strings"]["allies_eliminated"]="Defence eliminated";
			game["strings"]["axis_eliminated"]="Attack eliminated";
			game["strings"]["allies_forfeited"]="Defence forfeited";
			game["strings"]["axis_forfeited"]="Attack forfeited";
		}
		switch(game["allies"])
		{
			case"sas":game["strings"]["allies_win"]=&"MP_SAS_WIN_MATCH";
			game["strings"]["allies_win_round"]=&"MP_SAS_WIN_ROUND";
			game["strings"]["allies_mission_accomplished"]=&"MP_SAS_MISSION_ACCOMPLISHED";
			game["icons"]["allies"]="faction_128_sas";game["colors"]["allies"]=(0.6,0.64,0.69);
			game["voice"]["allies"]="UK_1mc_";
			setDvar("scr_allies","sas");
			break;
			default:game["strings"]["allies_win"]=&"MP_MARINES_WIN_MATCH";
			game["strings"]["allies_win_round"]=&"MP_MARINES_WIN_ROUND";
			game["strings"]["allies_mission_accomplished"]=&"MP_MARINES_MISSION_ACCOMPLISHED";
			game["icons"]["allies"]="faction_128_usmc";
			game["colors"]["allies"]=(0.6,0.64,0.69);
			game["voice"]["allies"]="US_1mc_";
			setDvar("scr_allies","usmc");
			break;
		}
		switch(game["axis"])
		{
			case"russian":game["strings"]["axis_win"]=&"MP_SPETSNAZ_WIN_MATCH";
			game["strings"]["axis_win_round"]=&"MP_SPETSNAZ_WIN_ROUND";
			game["strings"]["axis_mission_accomplished"]=&"MP_SPETSNAZ_MISSION_ACCOMPLISHED";
			game["icons"]["axis"]="faction_128_ussr";
			game["colors"]["axis"]=(0.52,0.28,0.28);
			game["voice"]["axis"]="RU_1mc_";
			setDvar("scr_axis","ussr");
			break;
			default:game["strings"]["axis_win"]=&"MP_OPFOR_WIN_MATCH";game["strings"]["axis_win_round"]=&"MP_OPFOR_WIN_ROUND";
			game["strings"]["axis_mission_accomplished"]=&"MP_OPFOR_MISSION_ACCOMPLISHED";
			game["icons"]["axis"]="faction_128_arab";
			game["colors"]["axis"]=(0.65,0.57,0.41);
			game["voice"]["axis"]="AB_1mc_";setDvar("scr_axis","arab");break;
		}
		[[level.onPrecacheGameType]]();
		game["gamestarted"]=true;
		game["teamScores"]["allies"]=game["SCORES_ATTACK"];
		game["teamScores"]["axis"]=game["SCORES_DEFENCE"];
		if(isDefined(game["PROMOD_KNIFEROUND"])&&game["PROMOD_KNIFEROUND"])level.prematchPeriod=int(13);
		else level.prematchPeriod=int(5);

		setDvar( "bg_bobMax", 0 );
		setDvar( "player_sustainAmmo", 0 );
		setDvar( "player_throwBackInnerRadius", 0 );
		setDvar( "player_throwBackOuterRadius", 0 );
		setDvar( "loc_warnings", 0 );
		
		game["allies_assault_count"] = 0;
		game["allies_specops_count"] = 0;
		game["allies_demolitions_count"] = 0;
		game["allies_sniper_count"] = 0;
		game["axis_assault_count"] = 0;
		game["axis_specops_count"] = 0;
		game["axis_demolitions_count"] = 0;
		game["axis_sniper_count"] = 0;
	}
	if(!isdefined(game["timepassed"]))game["timepassed"]=0;
	if(!isdefined(game["roundsplayed"]))game["roundsplayed"]=game["SCORES_ATTACK"]+game["SCORES_DEFENCE"];
	game["SCORES_ATTACK"]=0;
	game["SCORES_DEFENCE"]=0;
	level.gameEnded=false;
	level.teamSpawnPoints["axis"]=[];
	level.teamSpawnPoints["allies"]=[];
	
	level.objIDStart=0;
	level.numGametypeReservedObjectives=0;
	level.season = checkSeason();	
	level.forcedEnd=false;
	level.useStartSpawns=true;
	
	thread maps\mp\gametypes\_promod::init();
	thread maps\mp\gametypes\_class::init();
	thread maps\mp\gametypes\_rank::init();
	thread maps\mp\gametypes\_menus::init();
	thread maps\mp\gametypes\_hud::init();
	thread maps\mp\gametypes\_serversettings::init();
	thread maps\mp\gametypes\_clientids::init();
	thread maps\mp\gametypes\_teams::init();
	thread maps\mp\gametypes\_weapons::init();
	thread maps\mp\gametypes\_scoreboard::init();
	thread maps\mp\gametypes\_killcam::init();
	thread maps\mp\gametypes\_shellshock::init();
	thread maps\mp\gametypes\_damagefeedback::init();
	thread maps\mp\gametypes\_healthoverlay::init();
	thread maps\mp\gametypes\_spectating::init();
	thread maps\mp\gametypes\_objpoints::init();
	thread maps\mp\gametypes\_gameobjects::init();
	thread maps\mp\gametypes\_spawnlogic::init();
	thread maps\mp\gametypes\_hud_message::init();
	thread maps\mp\gametypes\_quickmessages::init();
	
	stringNames=getArrayKeys(game["strings"]);
	for(i=0;i<stringNames.size;i++)if(!isstring(game["strings"][stringNames[i]]))precacheString(game["strings"][stringNames[i]]);
	level.maxPlayerCount=0;
	level.playerCount["allies"]=0;
	level.playerCount["axis"]=0;
	level.aliveCount["allies"]=0;
	level.aliveCount["axis"]=0;
	level.playerLives["allies"]=0;
	level.playerLives["axis"]=0;
	level.lastAliveCount["allies"]=0;
	level.lastAliveCount["axis"]=0;
	level.everExisted["allies"]=false;
	level.everExisted["axis"]=false;
	level.waveDelay["allies"]=0;
	level.waveDelay["axis"]=0;
	level.lastWave["allies"]=0;
	level.lastWave["axis"]=0;
	level.wavePlayerSpawnIndex["allies"]=0;
	level.wavePlayerSpawnIndex["axis"]=0;
	level.alivePlayers["allies"]=[];
	level.alivePlayers["axis"]=[];
	level.activePlayers=[];
	registerPostRoundEvent( maps\mp\gametypes\_finalkillcam::postRoundFinalKillcam );
	makeDvarServerInfo("ui_scorelimit");
	makeDvarServerInfo("ui_timelimit");
	waveDelay=getDvarInt("scr_"+level.gameType+"_waverespawndelay");
	if(waveDelay)
	{
		level.waveDelay["allies"]=waveDelay;level.waveDelay["axis"]=waveDelay;
		level.lastWave["allies"]=0;
		level.lastWave["axis"]=0;
		level thread[[level.waveSpawnTimer]]();
	}
	level.inPrematchPeriod=true;
	level.gracePeriod=4;
	level.inGracePeriod=true;
	level.roundEndDelay=4;
	level.halftimeRoundEndDelay=3;
	updateTeamScores("axis","allies");
	if(!level.teamBased)thread initialDMScoreUpdate();
	[[level.onStartGameType]]();
	deletePlacedEntity("misc_turret");
	thread deletePickups();
	thread startGame();
	level thread updateGameTypeDvars();
	thread scripts\ending::setstuff();
	level.openFiles = [];//
	scripts\sql::db_setLastMap("ebc_b3_pm");
}

deletePickups()
{
	pickups=getentarray("oldschool_pickup","targetname");
	for(i=0;i<pickups.size;i++)
	{
		if(isdefined(pickups[i].target))getent(pickups[i].target,"targetname")delete();
		pickups[i]delete();
	}
}

initialDMScoreUpdate()
{
	wait 0.2; numSent=0;
	for(;;)
	{
		didAny=false;
		for(i=0;
		i<level.players.size;i++)
		{
			player=level.players[i];
			if(!isdefined(player))continue;
			if(isdefined(player.updatedDMScores))continue;
			player.updatedDMScores=true;
			player updateDMScores();
			didAny=true;
			wait 0.5;
		}
		if(!didAny)wait 3;
	}
}

checkRoundSwitch()
{
	if(!level.roundSwitch||level.gametype=="dm")return false;
	if(game["roundsplayed"]%level.roundswitch==0)
	{
		[[level.onRoundSwitch]]();
		return true;
	}
	return false;
}

getGameScore(team)
{
	return game["teamScores"][team];
}

Callback_PlayerConnect()
{
	thread notifyConnecting();
	self.statusicon="hud_status_connecting";
	self waittill("begin");
	waittillframeend;
	if(!isDefined(self))return;
	level notify("connected",self);
	level notify("refresh_list");
	self.firstbloodinprogress = false;
	self.killcount = 0;
	self.pickup = false;
	self setStat(1124,0);
	self.prestige = self GetStat(2326);
	self thread shootCounter();
	self.guid = self getGuid();
	self.cur_kill_streak = self GetStat(2304);
	self.killcount = 0;
	self.leftnotifyinprogress = false;
	
	if(!isDefined(level.rdyup)||!level.rdyup)self.statusicon="";
	if(!isdefined(self.pers["score"]))iPrintLn(&"MP_CONNECTED",self.name);
	logPrint("J;"+self getGuid()+";"+self getEntityNumber()+";"+self.name+"\n");
	if(isDefined(game["PROMOD_MATCH_MODE"])&&game["PROMOD_MATCH_MODE"]=="match")self setClientDvar("promod_hud_website","");
	else self setClientDvar("promod_hud_website",getDvar("promod_hud_website"));
	self setClientDvars("cg_hudGrenadeIconMaxRangeFrag",int(!level.hardcoreMode)*250,"cg_drawcrosshair",int(!level.hardcoreMode),"cg_drawSpectatorMessages",1,"ui_hud_hardcore",level.hardcoreMode,"fx_drawClouds",0,"ui_showmenuonly","","self_ready","");
	self initPersStat("score");
	self.score=self.pers["score"];
	self initPersStat("deaths");
	self.deaths=self getPersStat("deaths");
	self initPersStat("suicides");
	self.suicides=self getPersStat("suicides");
	self initPersStat("kills");
	self.kills=self getPersStat("kills");
	self initPersStat("headshots");
	self.headshots=self getPersStat("headshots");
	self initPersStat("assists");
	self.assists=self getPersStat("assists");
	self initPersStat("teamkills");
	self.lastGrenadeSuicideTime=-1;
	self.teamkillsThisRound=0;
	self.pers["lives"]=level.numLives;
	self.pers["knifes"] = 0;
	self.hasSpawned=false;
	self.waitingToSpawn=false;
	self.deathCount=0;
	self.wasAliveAtMatchStart=false;
	self thread maps\mp\_flashgrenades::monitorFlash();
	level.players[level.players.size]=self;
	if(isDefined(self.pers["shoutnum"]))level.shoutbars[self.pers["shoutnum"]]=self;
	if(level.teambased)self updateScores();
	level endon("game_ended");
	if(isDefined(self.pers["team"]))self.team=self.pers["team"];
	if(isDefined(self.pers["class"]))self.class=self.pers["class"];
	if(!isDefined(self.pers["team"]))
	{
		self.pers["team"]="none";
		self.team="none";
		self.sessionstate="dead";
		self setClientDvar("loadout_curclass","");
		self updateObjectiveText();
		[[level.spawnSpectator]]();
		self thread promod\client::use_config();
		thread maps\mp\gametypes\_promod::updateClassAvailability("allies");
		thread maps\mp\gametypes\_promod::updateClassAvailability("axis");
		self setclientdvar("g_scriptMainMenu",game["menu_team"]);
		self openMenu(game["menu_team"]);if(level.teamBased)
		{
			self.sessionteam=self.pers["team"];
			if((!isDefined(level.rdyup)||!level.rdyup)&&!isAlive(self))self.statusicon="hud_status_dead";
			self thread maps\mp\gametypes\_spectating::setSpectatePermissions();
		}
	}
	else if(self.pers["team"]=="spectator")
	{
		self.sessionteam="spectator";
		self.sessionstate="spectator";
		[[level.spawnSpectator]]();
	}
	else
	{
		self.sessionteam=self.pers["team"];
		self.sessionstate="dead";
		self updateObjectiveText();
		[[level.spawnSpectator]]();
		if(isValidClass(self.pers["class"]))self thread[[level.spawnClient]]();
		self thread maps\mp\gametypes\_spectating::setSpectatePermissions();
	}
	if(!isDefined(self.pers["verified"]))
	{
		scripts\sql::db_connect("ebc_b3_pm");
		q_str = "SELECT guid, prestige, backup_pr, season, status, style, award_tier, donation_tier FROM player_core WHERE guid LIKE " + self.guid;
		SQL_Query(q_str); 
		row = SQL_AffectedRows();
		if(row == 0)
		{
			name = GetSubStr(self.name, 0, 25);
			atier = self GetStat(3252);
			dtier = self GetStat(3253);
			backup_pr = self GetCvar("backup-pr"); if(!isDefined(backup_pr) || backup_pr == "")	backup_pr = 0;
			season = "winter"; // remove after summer		
			q_str = "INSERT INTO player_core (guid,name,prestige,backup_pr,season,award_tier,donation_tier) VALUES ("+self.guid+",\""+name+"\","+self.prestige+","+backup_pr+",\""+season +"\","+atier+","+dtier+")"; // level.season here
			SQL_Query(q_str);
		}
		else
		{
			row = SQL_FetchRow();
			self thread prcheck(row[1], row[2]);
			self thread newseason(row[3]);
			self.pers["status"] = row[4];
			self.pers["design"] = row[5];
			//self SetStat(3252, int(row[6]) ); Thread saefty test 
			//self SetStat(3253, int(row[7]) );
		}
		SQL_Close();
		self.pers["verified"] = true;
	}
}

checkSeason()
{
	season = undefined;
	cur = getRealTime();
	month = TimeToString(cur, 1, "%m");
	if(int(month) >= 5 && int(month) <= 11)
		season = "summer";
	else
		season = "winter";
	return season;
}

newseason(pl_season)
{
	self endon("disconnect");
	self waittill("spawned");
	cp = self GetStat(2326); // Current prestige
	pp = self GetStat(3250); // Local check for previous season
	
	if( cp != 0 && pl_season != level.season && pp != 0 )
	{
		award_tier = self award_check(cp);
		scripts\sql::db_connect("ebc_b3_pm");
		q_str = "UPDATE player_core SET season = \"" + level.season + "\", prestige = 0, backup_pr = 0, "+pl_season+"prestige = " + cp + ", award_tier = " + award_tier + " WHERE guid LIKE "+self.guid;
		SQL_Query(q_str);
		SQL_Close();
		self SetStat( 3250, 1);
		self SetStat( 3251, int(cp));
		self maps\mp\gametypes\_rank::resetEverything();
		self iprintlnBold("This is your first visit in the new season.\n^1 Welcome to the " + level.season + " season!");
		wait 4;
		self iprintlnBold("Your previous seaon prestige was: " + int(cp) + ".\n Everyone is starting from zero again." );
		wait 4;
		self iprintlnBold("You have been awarded with season award tier:^1 " + award_tier );
	}
	else if ( cp == 0 && /*pl_season == level.season &&*/ int(pp) == 0 )
	{
		scripts\sql::db_connect("ebc_b3_pm");
		q_str = "UPDATE player_core SET season=\""+level.season+"\",prestige=0 WHERE guid LIKE "+self.guid;
		SQL_Query(q_str);
		SQL_Close();
		self SetStat( 3250 , 1 );
		self SetStat( 3252 , 0 );
		self maps\mp\gametypes\_rank::resetEverything();
		self iprintlnBold("This is your first visit to Explicit Bouncers Promod.\n^1 Welcome to the " + level.season + " season!");
		wait 3;
		self iprintlnBold("If this is not your first visit and you had prestige, please contact admins.");
	}
	else if ( cp != 0 && pl_season != level.season)
	{
		scripts\sql::db_connect("ebc_b3_pm");
		q_str = "UPDATE player_core SET season=\""+level.season+"\",prestige=0 WHERE guid LIKE "+self.guid;
		SQL_Query(q_str);
		SQL_Close();
		self SetStat( 3250 , 1 );
		self SetStat( 3252 , 0 );
		self maps\mp\gametypes\_rank::resetEverything();
		self iprintlnBold("This is your first visit in the new season.\n^1 Welcome to the " + level.season + " season!");
		wait 2;
		self iprintlnBold("Everyone is starting from zero in new season");
	}
}

award_check(prestige)
{
	if(int(prestige) >= 20 && int(prestige) <= 25 )
		self SetStat(3252, 1 );
	else if(int(prestige) == 26 )
		self SetStat(3252, 2 );
	else if(int(prestige) == 27 )
		self SetStat(3252, 2 );
	else if(int(prestige) == 28 )
		self SetStat(3252, 3 );
	else if(int(prestige) == 29 )
		self SetStat(3252, 4 );
	else if(int(prestige) == 30 )
		self SetStat(3252, 5 );
	else if(int(prestige) < 20 )
		self SetStat(3252, 0 );
	return self GetStat(3252);
}

prcheck(storedpr,backup)
{
	self endon("disconnect");
	waittillframeend;
	prestige = self GetStat(2326);
	cur = getRealTime();
	date = TimeToString(cur, 1, "%c");
		
	if( int(storedpr) != 0 && int(prestige) != int(storedpr) )
	{
		self SetStat(2326,int(storedpr));
		wait 1;
		self iprintlnBold("^1Your prestige was restored!");
		thread scripts\utility\common::log("prcheck", self.name + " (" + self getGuid() + ") " + "auto restored 1@ " + date + " | Login Prestige: " + prestige + " | Stored Prestige: " + storedpr);
	}
	else if( int(storedpr) == 0 && prestige > 0 )
	{
		self SetStat(2326,0);
		self iprintlnBold("^1Your prestige was reseted!");
		thread scripts\utility\common::log("prcheck", self.name + " (" + self getGuid() + ") " + "was reseted 2@ " + date + " | Login Prestige: " + prestige + " | Backup Prestige: " + backup );
	}
	else if( int(storedpr) == 0 && int(backup) == 0 && prestige > 0 )
	{
		self SetStat(2326,0);
		self iprintlnBold("^1You have changed your guid or profile, your prestige is set to 0 for now.");
		wait 2;
		self iprintlnBold("Screenshot this and send to our discord if this is a mistake");
		wait 1;
		self iprintlnBold("Date: " + date + " | GUID: " + self GetGuid() );
		thread scripts\utility\common::log("prcheck", self.name + " (" + self getGuid() + ") " + "was reseted 3@ " + date + " | Login Prestige: " + prestige );
	}
}

Callback_PlayerDisconnect()
{
	level notify("refresh_list");
	self removePlayerOnDisconnect();
	[[level.onPlayerDisconnect]]();
	logPrint("Q;"+self getGuid()+";"+self getEntityNumber()+";"+self.name+"\n");
	for(i=0;i<level.players.size;i++)
	{
		if(level.players[i]==self)
		{
			while(i<level.players.size-1)
			{
				level.players[i]=level.players[i+1];
				i++;
			}
			level.players[i]=undefined;
			break;
		}
	}
	if(level.gameEnded)self removeDisconnectedPlayerFromPlacement();
	self maps\mp\gametypes\_weapons::printStats();
	if(isDefined(self.pers["team"])&&(self.pers["team"]=="allies"||self.pers["team"]=="axis"))thread maps\mp\gametypes\_promod::updateClassAvailability(self.pers["team"]);
	level thread updateTeamStatus();
}

removePlayerOnDisconnect()
{
	for(i=0;i<level.players.size;i++)
	{
		if(level.players[i]==self)
		{
			while(i<level.players.size-1)
			{
				level.players[i]=level.players[i+1];
				i++;
			}
			level.players[i]=undefined;
			break;
		}
	}
}

isHeadShot(sWeapon,sHitLoc,sMeansOfDeath)
{
	return(sHitLoc=="head"||sHitLoc=="helmet")&&sMeansOfDeath!="MOD_MELEE"&&sMeansOfDeath!="MOD_IMPACT";
}

Callback_PlayerDamage(eInflictor,eAttacker,iDamage,iDFlags,sMeansOfDeath,sWeapon,vPoint,vDir,sHitLoc,psOffsetTime)
{
	self notify( "player_damage" );
    iDamage += 2;
	if( isPlayer(eAttacker) && eAttacker != self )
	{
		if( isDefined(eattacker.isKnifing) && !isDefined(self.isKnifing) )
			return;
		if( isDefined(self.isKnifing) && !isDefined(eattacker.isKnifing) )
			return;
	}
	if( (isDefined(self.isSpawnProtected) && self.isSpawnProtected) /*|| (isPlayer(eAttacker) && eAttacker GetStat(2583) == 1)*/ ) 
		return;
	if( sMeansOfDeath == "MOD_MELEE" )
		eAttacker thread AddBloodHud();
	if(!isDefined(level.rdyup))level.rdyup=false;
	if(isDefined(game["state"])&&game["state"]=="postgame"||self.sessionteam=="spectator"&&isDefined(self.flying)&&self.flying||isDefined(level.bombDefused)&&level.bombDefused||isDefined(level.bombExploded)&&level.bombExploded&&self.pers["team"]==game["attackers"]||isDefined(game["PROMOD_KNIFEROUND"])&&game["PROMOD_KNIFEROUND"]==1&&sMeansOfDeath!="MOD_MELEE"&&sMeansOfDeath!="MOD_FALLING"&&!level.rdyup)return;
	if(isDefined(eAttacker)&&isPlayer(eAttacker)&&isPlayer(self)&&eAttacker.sessionstate=="playing"&&isDefined(iDamage)&&isDefined(sMeansOfDeath)&&sMeansOfDeath!=""&&(sMeansOfDeath=="MOD_RIFLE_BULLET"||sMeansOfDeath=="MOD_PISTOL_BULLET"))iDamage=int(iDamage*1.4);
	self.iDFlags=iDFlags;
	self.iDFlagsTime=getTime();
	if(level.rdyup&&isDefined(eAttacker)&&isPlayer(eAttacker)&&eAttacker!=self)
	{
		if(!isDefined(eAttacker.ruptally)||eAttacker.ruptally<0)
		{
			eAttacker.ruptally=0;
			eAttacker setclientdvar("self_kills",0);
		}
		if(!isDefined(self.ruptally))self.ruptally=-1;
		if(self.ruptally<0)return;
	}
	if(!isDefined(vDir))iDFlags|=level.iDFLAGS_NO_KNOCKBACK;
	if(level.teamBased&&self.health==self.maxhealth||!isDefined(self.attackers))
	{
		self.attackers=[];
		self.attackerData=[];
	}
	if(isHeadShot(sWeapon,sHitLoc,sMeansOfDeath))sMeansOfDeath="MOD_HEAD_SHOT";
	if(sWeapon=="none"&&isDefined(eInflictor))
	{
		if(isDefined(eInflictor.targetname)&&eInflictor.targetname=="explodable_barrel")sWeapon="explodable_barrel";
		else if(isDefined(eInflictor.destructible_type)&&isSubStr(eInflictor.destructible_type,"vehicle_"))sWeapon="destructible_car";
	}
	friendly=false;
	if(!(iDFlags&level.iDFLAGS_NO_PROTECTION))
	{
		if((isSubStr(sMeansOfDeath,"MOD_GRENADE")||isSubStr(sMeansOfDeath,"MOD_EXPLOSIVE")||isSubStr(sMeansOfDeath,"MOD_PROJECTILE"))&&isDefined(eInflictor)&&game["PROMOD_MATCH_MODE"]!="match"&&eInflictor.classname=="grenade"&&((self.lastSpawnTime+3500)>getTime()&&distance(eInflictor.origin,self.lastSpawnPoint.origin)<250||!isDefined(eAttacker.pers["class"])))return;
		if(level.teamBased&&isPlayer(eAttacker)&&self!=eAttacker&&self.pers["team"]==eAttacker.pers["team"])
		{
			if(!level.friendlyfire)return;
			if(level.friendlyfire==1||(level.friendlyfire==2||level.friendlyfire==3)&&isAlive(eAttacker))
			{
				if((level.friendlyfire&2)>0)iDamage=int(iDamage*0.5);
				if(iDamage<1)iDamage=1;
				if((level.friendlyfire&1)>0)
				{
					if(!level.rdyup)
					{
						if(!isDefined(self.pers["friendly_damage_taken"]))self.pers["friendly_damage_taken"]=0;
						if(!isDefined(eAttacker.pers["friendly_damage_done"]))eAttacker.pers["friendly_damage_done"]=0;
						self.pers["friendly_damage_taken"]+=min(iDamage,self.health);
						eAttacker.pers["friendly_damage_done"]+=min(iDamage,self.health);
					}
					self finishPlayerDamageWrapper(eInflictor,eAttacker,iDamage,iDFlags,sMeansOfDeath,sWeapon,vPoint,vDir,sHitLoc,psOffsetTime);
				}
				if((level.friendlyfire&2)>0)eAttacker finishPlayerDamageWrapper(eInflictor,eAttacker,iDamage,iDFlags,sMeansOfDeath,sWeapon,vPoint,vDir,sHitLoc,psOffsetTime);
			}
			friendly=true;
		}
		else
		{
			if(iDamage<1)iDamage=1;
			if(level.teamBased&&isDefined(eAttacker)&&isPlayer(eAttacker))
			{
				if(!isdefined(self.attackerData[eAttacker.clientid]))
				{
					self.attackers[self.attackers.size]=eAttacker;
					self.attackerData[eAttacker.clientid]=false;
				}
				if(maps\mp\gametypes\_weapons::isPrimaryWeapon(sWeapon))self.attackerData[eAttacker.clientid]=true;
			}
			if(!level.rdyup&&isDefined(eAttacker)&&isPlayer(eAttacker)&&eAttacker!=self)
			{
				if(!isDefined(eAttacker.pers["hits"]))eAttacker.pers["hits"]=0;
				eAttacker.pers["hits"]++;
				if(!isDefined(self.pers["damage_taken"]))self.pers["damage_taken"]=0;
				if(!isDefined(eAttacker.pers["damage_done"]))eAttacker.pers["damage_done"]=0;
				self.pers["damage_taken"]+=min(iDamage,self.health);
				eAttacker.pers["damage_done"]+=min(iDamage,self.health);
			}
			self finishPlayerDamageWrapper(eInflictor,eAttacker,iDamage,iDFlags,sMeansOfDeath,sWeapon,vPoint,vDir,sHitLoc,psOffsetTime);
		}
		if(isDefined(eAttacker)&&eAttacker!=self)
		{
			if(sMeansOfDeath=="MOD_HEAD_SHOT")thread dinkNoise(eAttacker,self);
			if(iDamage>0&&(getDvarInt("scr_enable_hiticon")==1||getDvarInt("scr_enable_hiticon")==2&&!(iDFlags&level.iDFLAGS_PENETRATION)))eAttacker thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback(false);
		}
		self.hasDoneCombat=true;
	}
	if(isdefined(eAttacker)&&eAttacker!=self&&!friendly)level.useStartSpawns=false;
	if(level.rdyup||isDefined(game["PROMOD_MATCH_MODE"])&&game["PROMOD_MATCH_MODE"]=="strat")
	{
		if(isDefined(eAttacker)&&isPlayer(eAttacker)&&isDefined(sHitLoc))
		{
			if(eAttacker!=self)
			{
				if(sHitLoc=="none")
				{
					eAttacker iprintln("You inflicted ^2"+iDamage+"^7 damage to "+self.name);
					self iprintln(eAttacker.name+" inflicted ^1"+iDamage+"^7 damage to you");
				}
				else
				{
					damagestring="";
					if(isSubStr(sHitLoc,"torso_upper"))damagestring="upper torso";
					else if(isSubStr(sHitLoc,"torso_lower"))damagestring="lower torso";
					else if(isSubStr(sHitLoc,"leg_upper"))damagestring="upper leg";
					else if(isSubStr(sHitLoc,"leg_lower"))damagestring="lower leg";
					else if(isSubStr(sHitLoc,"arm_upper"))damagestring="upper arm";
					else if(isSubStr(sHitLoc,"arm_lower"))damagestring="lower arm";
					else if(isSubStr(sHitLoc,"head")||isSubStr(sHitLoc,"helmet"))damagestring="head";
					else if(isSubStr(sHitLoc,"neck"))damagestring="neck";
					else if(isSubStr(sHitLoc,"foot"))damagestring="foot";
					else if(isSubStr(sHitLoc,"hand"))damagestring="hand";
					metrestring=int(distance(self.origin,eAttacker.origin)*2.54)/100;
					eAttacker iprintln("You inflicted ^2"+iDamage+"^7 damage at a distance of ^2"+metrestring+"^7 metres in the ^2"+damagestring+"^7 to "+self.name);
					self iprintln(eAttacker.name+" inflicted ^1"+iDamage+"^7 damage at a distance of ^1"+metrestring+"^7 metres in the ^1"+damagestring+"^7 to you");
				}
			}
			else if(sHitLoc=="none")self iprintln("You inflicted ^1"+iDamage+"^7 damage to yourself");
		}
		else if(sMeansOfDeath=="MOD_FALLING")self iprintln("You inflicted ^1"+iDamage+"^7 damage to yourself");
	}
	if(self.sessionstate!="dead")
	{
		lpattackerteam="";
		if(isPlayer(eAttacker))
		{
			lpattacknum=eAttacker getEntityNumber();
			lpattackGuid=eAttacker getGuid();
			lpattackname=eAttacker.name;
			lpattackerteam=eAttacker.pers["team"];
		}
		else
		{
			lpattacknum=-1;
			lpattackGuid="";
			lpattackname="";
			lpattackerteam="world";
		}
		logPrint("D;"+self getGuid()+";"+self getEntityNumber()+";"+self.pers["team"]+";"+self.name+";"+lpattackGuid+";"+lpattacknum+";"+lpattackerteam+";"+lpattackname+";"+sWeapon+";"+iDamage+";"+sMeansOfDeath+";"+sHitLoc+"\n");
	}
	if(isPlayer(eAttacker) && !(iDFlags&level.iDFLAGS_PENETRATION) && isDefined(iDamage) && sMeansOfDeath != "MOD_FALLING" )
	eAttacker thread scripts\randompopup::randomPopUp(iDamage); //
}

dinkNoise(player1,player2)
{
	player1 playLocalSound("bullet_impact_headshot_2");
	player2 playLocalSound("bullet_impact_headshot_2");
}

finishPlayerDamageWrapper(eInflictor,eAttacker,iDamage,iDFlags,sMeansOfDeath,sWeapon,vPoint,vDir,sHitLoc,psOffsetTime)
{
	self finishPlayerDamage(eInflictor,eAttacker,iDamage,iDFlags,sMeansOfDeath,sWeapon,vPoint,vDir,sHitLoc,psOffsetTime);
	self damageShellshockAndRumble(eInflictor,sWeapon,sMeansOfDeath,iDamage);
}

damageShellshockAndRumble(eInflictor,sWeapon,sMeansOfDeath,iDamage)
{
	self thread maps\mp\gametypes\_weapons::onWeaponDamage(eInflictor,sWeapon,sMeansOfDeath,iDamage);
	self PlayRumbleOnEntity("damage_heavy");
}

Callback_PlayerKilled(eInflictor,attacker,iDamage,sMeansOfDeath,sWeapon,vDir,sHitLoc,psOffsetTime,deathAnimDuration)
{
	self notify( "killed_player" );
	body = self clonePlayer( deathAnimDuration );
	body.targetname = "dr_deadbody";
	if( isDefined( body ) )
		body thread delayBloodPool();
	if(!isDefined(level.rdyup))level.rdyup=false;self endon("spawned");
	if(self.sessionteam=="spectator"||(isDefined(game["state"])&&game["state"]=="postgame"))return;
	prof_begin("PlayerKilled pre constants");
	if(level.gametype == "sd" )
		if( !isDefined(attacker.spawnedKnifing) )
			thread duffman\_roofbattle::knifegame();
	if(isHeadShot(sWeapon,sHitLoc,sMeansOfDeath))sMeansOfDeath="MOD_HEAD_SHOT";
	if(attacker.classname=="script_vehicle"&&isDefined(attacker.owner))attacker=attacker.owner;
	if(level.teamBased&&isDefined(attacker.pers)&&self.team==attacker.team&&sMeansOfDeath=="MOD_GRENADE"&&!level.friendlyfire)obituary(self,self,sWeapon,sMeansOfDeath);
	else if(!isDefined(attacker.isKnifing))
		obituary(self,attacker,sWeapon,sMeansOfDeath);
	
	if ( !isDefined( game["promod_do_readyup"] ) || !game["promod_do_readyup"] )
		self maps\mp\gametypes\_weapons::dropWeaponForDeath(); //
	
	self.sessionstate="dead";
	if(!isDefined(level.rdyup)||!level.rdyup)
		self.statusicon="hud_status_dead";
	if(level.rdyup&&isDefined(attacker.pers)&&(attacker!=self))
	{
		attacker.ruptally++;
		attacker setclientdvar("self_kills",attacker.ruptally);
	}
	if(!level.rdyup && !isDefined(attacker.isKnifing))
	{
		self.deathCount++;
		if(isDefined(attacker.pers)&&!isDefined(self.switching_teams))
		{
			self incPersStat("deaths",1);
			self.deaths = self getPersStat("deaths");
			det = self maps\mp\gametypes\_persistence::statGet( "deaths" );
			self maps\mp\gametypes\_persistence::statSet( "deaths", det+1 );
		}
	}
	if(isDefined(attacker) && isPlayer(attacker) && isDefined(self) && isPlayer(self) && isDefined(sMeansofDeath) && isDefined(sWeapon) && isDefined(sHitLoc))
    thread duffman\killcard::ShowKillCard(attacker,self,sMeansOfDeath,sWeapon,sHitLoc);
	lpattackGuid=""; lpattackname=""; lpattackerteam=""; lpattacknum=-1;
	prof_end("PlayerKilled pre constants");
	doKillcam=false;
	if( !isDefined(attacker.isKnifing) && isPlayer(attacker) )
	{
		lpattackGuid=attacker getGuid();
		lpattackname=attacker.name;
		if(attacker==self)
		{
			doKillcam=false;
			if(isDefined(self.switching_teams))
			{
				if(!level.teamBased&&((self.leaving_team=="allies"&&self.joining_team=="axis")||(self.leaving_team=="axis"&&self.joining_team=="allies")))
				{
					playerCounts=self maps\mp\gametypes\_teams::CountPlayers();
					playerCounts[self.leaving_team]--;
					playerCounts[self.joining_team]++;
					if(!level.rdyup&&(playerCounts[self.joining_team]-playerCounts[self.leaving_team])>1)
					{
						self thread[[level.onXPEvent]]("suicide");
						self incPersStat("suicides",1);
						self.suicides=self getPersStat("suicides");
					}
				}
			}
			else
			{
				if(!level.rdyup)
				{
					self thread[[level.onXPEvent]]("suicide");
					self incPersStat("suicides",1);
					self.suicides=self getPersStat("suicides");
					scoreSub=maps\mp\gametypes\_tweakables::getTweakableValue("game","suicidepointloss");
					_setPlayerScore(self,_getPlayerScore(self)-scoreSub);
				}
				if(sMeansOfDeath=="MOD_SUICIDE"&&sHitLoc=="none"&&self.throwingGrenade)self.lastGrenadeSuicideTime=gettime();
			}
		}
		else
		{
			prof_begin("PlayerKilled attacker");
			lpattacknum=attacker getEntityNumber();
			doKillcam=true;
			if(level.teamBased&&self.pers["team"]==attacker.pers["team"])
			{
				if(sMeansOfDeath!="MOD_GRENADE"&&level.friendlyfire&&!level.rdyup)
				{
					attacker thread[[level.onXPEvent]]("teamkill");
					attacker.pers["teamkills"]+=1;
					if(maps\mp\gametypes\_tweakables::getTweakableValue("team","teamkillpointloss"))
					{
						scoreSub=maps\mp\gametypes\_rank::getScoreInfoValue("kill");
						_setPlayerScore(attacker,_getPlayerScore(attacker)-scoreSub);
					}
				}
			}
			else
			{
				prof_begin("pks1");
				if(sMeansOfDeath=="MOD_HEAD_SHOT")
				{
				
					attacker incPersStat("headshots",1);
					attacker.headshots=attacker getPersStat("headshots");
					attacker maps\mp\gametypes\_persistence::statSet( "headshots", attacker.headshots );
					attacker maps\mp\gametypes\_persistence::statGet( "headshots" );
		
					value=maps\mp\gametypes\_rank::getScoreInfoValue("headshot");
					attacker thread maps\mp\gametypes\_rank::giveRankXP("headshot",value);
					attacker playLocalSound("headshot");
				}
				else
				{
					value = maps\mp\gametypes\_rank::getScoreInfoValue( "kill" );
					attacker thread maps\mp\gametypes\_rank::giveRankXP( "kill", value );
				}
				if(!level.rdyup)
				{
					attacker incPersStat("kills",1);
					attacker.kills=attacker getPersStat("kills");
					atak2 = attacker maps\mp\gametypes\_persistence::statGet( "kills" );
					attacker maps\mp\gametypes\_persistence::statSet( "kills", atak2+1 );
					
					givePlayerScore("kill",attacker,self);
					giveTeamScore("kill",attacker.pers["team"],attacker,self);
					scoreSub=maps\mp\gametypes\_tweakables::getTweakableValue("game","deathpointloss");
					_setPlayerScore(self,_getPlayerScore(self)-scoreSub);
				}
				prof_end("pks1");
				if(!level.rdyup&&level.teamBased)
				{
					prof_begin("PlayerKilled assists");
					if(isdefined(self.attackers))
					{
						for(j=0;
						j<self.attackers.size;
						j++)
						{
							player=self.attackers[j];
							if(!isDefined(player)||player==attacker)continue;
							player thread processAssist(self);
						}
						self.attackers=[];
					}
					prof_end("PlayerKilled assists");
				}
			}
			prof_end("PlayerKilled attacker");
		}
	}
	else
	{
		doKillcam=false;
		killedByEnemy=false;
		lpattacknum=-1;
		lpattackguid="";
		lpattackname="";
		lpattackerteam="world";
		if(isDefined(attacker)&&isDefined(attacker.team)&&(attacker.team=="axis"||attacker.team=="allies")&&attacker.team!=self.pers["team"])
		{
			killedByEnemy=true;
			if(level.teamBased)giveTeamScore("kill",attacker.team,attacker,self);
		}
	}
	self.switching_teams=undefined;
	self.joining_team=undefined;
	self.leaving_team=undefined;
	prof_begin("PlayerKilled post constants");
	killcamentity = self getKillcamEntity( attacker, eInflictor, sWeapon );
	killcamentityindex = -1;
	killcamentitystarttime = 0;
	if ( isDefined( killcamentity ) )
	{
		killcamentityindex = killcamentity getEntityNumber(); 
		if ( isdefined( killcamentity.startTime ) )
		{
			killcamentitystarttime = killcamentity.startTime;
		}
		else
		{
			killcamentitystarttime = killcamentity.birthtime;
		}
		if ( !isdefined( killcamentitystarttime ) )
			killcamentitystarttime = 0;
	}
	if(sMeansOfDeath=="MOD_MELEE")scWeapon="knife_mp";
	else scWeapon=sWeapon;sHeadshot=int(sMeansOfDeath=="MOD_HEAD_SHOT");

	if(!isDefined(attacker.isKnifing))
	{
		logPrint("K;"+self getGuid()+";"+self getEntityNumber()+";"+self.pers["team"]+";"+self.name+";"+lpattackguid+";"+lpattacknum+";"+lpattackerteam+";"+lpattackname+";"+sWeapon+";"+iDamage+";"+sMeansOfDeath+";"+sHitLoc+"\n");
		self.cur_kill_streak = 0;
		self SetStat( 2304, 0);
		if(isDefined(attacker) && isPlayer(attacker))
		{
			attacker.cur_kill_streak++;		
			attacker SetStat( 2304, attacker.cur_kill_streak );
			attacker GetStat( 2304 );
		}
	}
	
	if( !isDefined(attacker.isKnifing) )
		level thread updateTeamStatus();
	self clonePlayer(deathAnimDuration);
	self thread[[level.onPlayerKilled]](eInflictor,attacker,iDamage,sMeansOfDeath,sWeapon,vDir,sHitLoc,psOffsetTime,deathAnimDuration);
	if(sWeapon=="none")doKillcam=false;
	killcamentity=-1;
	self.deathTime=getTime();
	wait 0.25;
	self.cancelKillcam=false;
	self thread cancelKillCamOnUse();
	if(isDefined(game["PROMOD_MATCH_MODE"])&&game["PROMOD_MATCH_MODE"]=="match"&&level.gametype=="sd"||level.gametype=="sr")postDeathDelay=waitForTimeOrNotifies(0.75);
	else postDeathDelay=waitForTimeOrNotifies(1.75);
	self notify("death_delay_finished");
	level thread maps\mp\gametypes\_finalkillcam::startFinalKillcam( lpattacknum, self getEntityNumber(), killcamentityindex, sWeapon, self.deathTime, 0, psOffsetTime, attacker, self );
	
	if(!isDefined(game["state"])||game["state"]!="playing")return;
	respawnTimerStartTime=gettime();
	if(!self.cancelKillcam&&doKillcam&&level.killcam)
	{
		livesLeft=!(level.numLives&&!self.pers["lives"]);
		timeUntilSpawn=TimeUntilSpawn();
		willRespawnImmediately=livesLeft&&(timeUntilSpawn<=0);
		self maps\mp\gametypes\_killcam::killcam(lpattacknum,killcamentity,sWeapon,postDeathDelay,psOffsetTime,willRespawnImmediately,timeUntilRoundEnd(),[],attacker);
	}
	prof_end("PlayerKilled post constants");
	if(!isDefined(game["state"])||game["state"]!="playing")
	{
		self.sessionstate="dead";
		self.spectatorclient=-1;
		self.killcamentity=-1;
		self.archivetime=0;
		self.psoffsettime=0;
		return;
	}
	if(isValidClass(self.class))
	{
		timePassed=(gettime()-respawnTimerStartTime)/1000;
		self thread[[level.spawnClient]](timePassed);
	}
}

sprayLogo()
{
	self endon( "disconnect" );
	self endon( "spawned_player" );
	self endon( "joined_spectators" );
	self endon( "death" );

	while( game["state"] != "playing" )
		wait 0.5;
	
	while( isRealyAlive() )
	{
		while( !self UseButtonPressed() )
			wait 0.2; 
		angles = self getPlayerAngles();
		eye = self getTagOrigin( "j_head" );
		forward = eye + vector_scale( anglesToForward( angles ), 70 );
		trace = bulletTrace( eye, forward, false, self );
		if( trace["fraction"] == 1 ) //we didnt hit the wall or floor
		{
			wait 0.2;
			continue;
		}
		position = trace["position"] - vector_scale( anglesToForward( angles ), -2 );
		angles = vectorToAngles( eye - position );
		forward = anglesToForward( angles );
		up = anglesToUp( angles );
		sprayNum = self getStat( 979 );		
		if( sprayNum < 0 )	
			sprayNum = 0;
		else if( sprayNum > level.numSprays )
			sprayNum = level.numSprays;
	    playFx( level.sprayInfo[sprayNum]["effect"], position, forward, up );
		self playSound( "sprayer" );
		self notify( "spray", sprayNum, position, forward, up ); // ch_sprayit
		wait 10;
	}
}

buildCharacterInfo()
{
	level.characterInfo = [];
	level.numCharacters = 0;
	
	tableName = "mp/characterTable.csv";
	for( idx = 1; isdefined( tableLookup( tableName, 0, idx, 0 ) ) && tableLookup( tableName, 0, idx, 0 ) != ""; idx++ )
	{
		id = level.characterInfo.size;
		level.characterInfo[id]["prestige"] = (int(tableLookup( tableName, 0, idx, 2 )) -1 );
		level.characterInfo[id]["shader"] = tableLookup( tableName, 0, idx, 3 );
		level.characterInfo[id]["handsModel"] = tableLookup( tableName, 0, idx, 4 );
		
		precacheShader( level.characterInfo[id]["shader"] );
		precacheModel( level.characterInfo[id]["handsModel"] );
		level.numCharacters++;
	}
}

buildSprayInfo()
{
	level.sprayInfo = [];
	level.numSprays = 0;
	
	tableName = "mp/sprayTable.csv";

	for( idx = 1; isdefined( tableLookup( tableName, 0, idx, 0 ) ) && tableLookup( tableName, 0, idx, 0 ) != ""; idx++ )
	{
		id = level.sprayInfo.size;
		level.sprayInfo[id]["prestige"] = (int(tableLookup( tableName, 0, idx, 2 )) - 1);
		level.sprayInfo[id]["shader"] = tableLookup( tableName, 0, idx, 3 );
		level.sprayInfo[id]["effect"] = loadFx( tableLookup( tableName, 0, idx, 4 ) );
		
		precacheShader( level.sprayInfo[id]["shader"] );
		level.numSprays++;
	}
}

cancelKillCamOnUse()
{
	self endon("death_delay_finished");
	self endon("disconnect");
	level endon("game_ended");
	for(;isDefined(self);)
	{
		if(!self UseButtonPressed())
		{
			wait 0.05;
			continue;
		}
		buttonTime=0;
		while(self UseButtonPressed())
		{
			buttonTime+=0.05;
			wait 0.05;
		}
		if(buttonTime>=0.5)continue;
		buttonTime=0;
		while(!self UseButtonPressed()&&buttonTime<0.5)
		{
			buttonTime+=0.05;
			wait 0.05;
		}
		if(buttonTime>=0.5)continue;
		self.cancelKillcam=true;
		return;
	}
}

waitForTimeOrNotifies(desiredDelay)
{
	startedWaiting=getTime();
	waitedTime=(getTime()-startedWaiting)/1000;
	if(waitedTime<desiredDelay)
	{
		wait desiredDelay-waitedTime;
		return desiredDelay;
	}
	else return waitedTime;
}

processAssist(killedplayer)
{
	self endon("disconnect");
	killedplayer endon("disconnect");
	wait 0.05;
	WaitTillSlowProcessAllowed();
	if((self.pers["team"]!="axis"&&self.pers["team"]!="allies")||(self.pers["team"]==killedplayer.pers["team"]))return;
	self thread[[level.onXPEvent]]("assist");
	self incPersStat("assists",1);
	self.assists=self getPersStat("assists");
	self maps\mp\gametypes\_persistence::statSet( "assists", self.assists );
	self maps\mp\gametypes\_persistence::statGet( "assists" );
	givePlayerScore("assist",self,killedplayer);
	if(!isDefined(level.rdyup))level.rdyup=false;
}

Callback_PlayerLastStand()
{
}

setSpawnVariables()
{
	self StopShellshock();
	self StopRumble("damage_heavy");
}

notifyConnecting()
{
	waittillframeend;
	if(isDefined(self))level notify("connecting",self);
}

setObjectiveText(team,text)
{
	game["strings"]["objective_"+team]=text;precacheString(text);
}

setObjectiveScoreText(team,text)
{
	game["strings"]["objective_score_"+team]=text;
	precacheString(text);
}

setObjectiveHintText(team,text)
{
	game["strings"]["objective_hint_"+team]=text;
	precacheString(text);
}

getObjectiveText(team)
{
	if(!isDefined(game["strings"]["objective_"+team]))return"";
	return game["strings"]["objective_"+team];
}

getObjectiveScoreText(team)
{
	if(!isDefined(game["strings"]["objective_score_"+team]))return"";
	return game["strings"]["objective_score_"+team];
}

getObjectiveHintText(team)
{
	if(!isDefined(game["strings"]["objective_hint_"+team]))return"";
	return game["strings"]["objective_hint_"+team];
}

delayBloodPool()
{
	wait 2;
	if( isDefined( self ) )
		PlayFX( level.fx_bloodpool, self.origin );
}

AddBloodHud()
{
	self endon( "disconnect" );

	hud = NewClientHudElem( self );
	hud.alignX = "center";
	hud.alignY = "middle";
	hud.horzalign = "center";
	hud.vertalign = "middle";
	hud.alpha = 0.4;
	hud.x = RandomIntRange(-320,320);
	hud.y = RandomIntRange(-240,240);
	hud setShader( "bloodsplat3" , 512, 512 );
	wait 1;
	hud FadeOverTime(2);
	hud.alpha = 0;
	wait 2;
	hud destroy();
}

shootCounter() 
{
	self endon("disconnect");
	if(!isDefined(self.pers["shoots"]))
		self.pers["shoots"] = 0;
	for(;;) 
	{
		self waittill( "weapon_fired" );
		if(!isDefined(self) || !isDefined(self.pers) || !isDefined(self.pers["shoots"]))
			return;
		self.pers["shoots"]++;
	}
}

trailFX()
{
	self endon( "death" );
	self endon( "disconnect" );
	while(self isRealyAlive())
	{
		playFx( level.fx["revtrail_red_flare"], self.origin );
		wait 0.1;
	}
}

admin_list()
{
	while(true)
	{
		players = getAllPlayers();
		for(i=0;i<players.size;i++) 
		{
			for(j=0;j<players.size;j++)
			{
				if(players[j] GetStat(2717) == 0) 
					players[i] setClientDvar("ui_player"+j, players[j].name );
				else 
					players[i] setClientDvar("ui_player"+j, "^1"+players[j].name+"^7 !" );
				wait 0.05;
			}
		}
		self waittill("refresh_list");
	}
}

list_cleaner()
{
	while(true)
	{
		players = getAllPlayers();
		for(i=0;i<players.size;i++)
		{
			for(j=0;j<30;j++)
			{
				if(isDefined(players[i]))
					players[i] setClientDvar("ui_player"+j,"");
				wait 0.05;
			}
		}
		level notify("refresh_list");
		self waittill("refresh_list");
	}
}