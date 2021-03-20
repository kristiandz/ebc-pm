#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

main()
{
	precacheShader( "line_horizontal" );
	level.fx_flash = loadFX( "impacts/cranked" );
	if (getDvar("mapname") == "mp_background") return;
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
	maps\mp\gametypes\_globallogic::setObjectiveText( "allies", &"PL_OBJECTIVES_CRNK" );
	maps\mp\gametypes\_globallogic::setObjectiveText( "axis", &"PL_OBJECTIVES_CRNK" );
	maps\mp\gametypes\_globallogic::setObjectiveScoreText( "allies", &"PL_OBJECTIVES_CRNK_SCORE" );
	maps\mp\gametypes\_globallogic::setObjectiveScoreText( "axis", &"PL_OBJECTIVES_CRNK_SCORE" );
	maps\mp\gametypes\_globallogic::setObjectiveHintText( "allies", &"PL_OBJECTIVES_CRNK_HINT" );
	maps\mp\gametypes\_globallogic::setObjectiveHintText( "axis", &"PL_OBJECTIVES_CRNK_HINT" );
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
	if (level.roundLimit != 1 && level.numLives)
	{
		level.overrideTeamScore = true;
		level.displayRoundEndText = true;
		level.onEndGame = ::onEndGame;
	}
	level.onPlayerKilled = maps\mp\gametypes\_cranked::onPlayerKilled;
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
		if (level.inGracePeriod)
		{
			spawnPoints = getentarray("mp_tdm_spawn_" + self.pers["team"] + "_start", "classname");
			if (!spawnPoints.size) spawnPoints = getentarray("mp_sab_spawn_" + self.pers["team"] + "_start", "classname");
			if (!spawnPoints.size)
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
		if (isDefined(winner) && (winner == "allies" || winner == "axis"))
			[[level._setTeamScore]](winner, [[level._getTeamScore]](winner) + 1);
	}
	else
	{
		if (isDefined(winner))
		[[level._setPlayerScore]](winner, winner[[level._getPlayerScore]]() + 1);
	}
}