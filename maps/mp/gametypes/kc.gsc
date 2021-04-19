#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include scripts\utility\_utility;

main()
{
	if(getdvar("mapname") == "mp_background")
		return;
		
	if ( !isdefined( game["switchedsides"] ) )
		game["switchedsides"] = false;		
		
	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();

	level.teamBased = true;
	level.overrideTeamScore = true;

	level.onPrecacheGameType = ::onPrecacheGameType;
	level.onStartGameType = ::onStartGameType;
	level.onSpawnPlayer = ::onSpawnPlayer;
    level.onPlayerKilled = ::onPlayerKilled;
	level.onRoundSwitch = ::onRoundSwitch;


	game["dialog"]["gametype"] = "kill_confirmed";

	game["dialog"]["offense_obj"] = "kc_boost";
	game["dialog"]["defense_obj"] = "kc_boost";

}

onPrecacheGameType()
{
	precacheModel( "skull_dogtag" );
	precacheModel( "cross_dogtag" );
	precacheString( &"PL_KILL_CONFIRMED_P" );
	precacheString( &"PL_KILL_DENIED" );
	precacheString( &"PL_GOTTAGS" );   
}

onStartGameType()
{
	setClientNameMode("auto_change");

	maps\mp\gametypes\_globallogic::setObjectiveText( "allies", &"PL_OBJECTIVES_KC" );
	maps\mp\gametypes\_globallogic::setObjectiveText( "axis", &"PL_OBJECTIVES_KC" );
	
	maps\mp\gametypes\_globallogic::setObjectiveScoreText( "allies", &"PL_OBJECTIVES_KC_SCORE" );
	maps\mp\gametypes\_globallogic::setObjectiveScoreText( "axis", &"PL_OBJECTIVES_KC_SCORE" );
	
	maps\mp\gametypes\_globallogic::setObjectiveHintText( "allies", &"PL_OBJECTIVES_KC_HINT" );
	maps\mp\gametypes\_globallogic::setObjectiveHintText( "axis", &"PL_OBJECTIVES_KC_HINT" );
			
	level.spawnMins = ( 0, 0, 0 );
	level.spawnMaxs = ( 0, 0, 0 );
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_tdm_spawn_allies_start" );
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_tdm_spawn_axis_start" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_tdm_spawn" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_tdm_spawn" );
	
	level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
	setMapCenter( level.mapCenter );
	
	allowed[0] = level.gametype;
	allowed[1] = "war";
	
	level.displayRoundEndText = false;
	maps\mp\gametypes\_gameobjects::main(allowed);
	
	// elimination style
	if ( level.roundLimit != 1 && level.numLives )
	{
		level.overrideTeamScore = true;
		level.displayRoundEndText = true;
		level.onDeadEvent = ::onDeadEvent;
	}
}

onSpawnPlayer()
{
	// Check which spawn points should be used
	if ( game["switchedsides"] ) {
		spawnTeam = level.otherTeam[ self.pers["team"] ];
	} else {
		spawnTeam =  self.pers["team"];
	}

	self.usingObj = undefined;

	if ( level.inGracePeriod )
	{
		spawnPoints = getentarray("mp_tdm_spawn_" + spawnTeam + "_start", "classname");
		
		if ( !spawnPoints.size )
			spawnPoints = getentarray("mp_sab_spawn_" + spawnTeam + "_start", "classname");
			
		if ( !spawnPoints.size )
		{
			spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( spawnTeam );
			spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( spawnPoints );
		}
		else
		{
			spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( spawnPoints );
		}		
	}
	else
	{
		spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( spawnTeam );
		spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( spawnPoints );
	}
	
	self spawn( spawnpoint.origin, spawnpoint.angles );
	self thread intoSpawn(spawnpoint.origin, spawnpoint.angles);
}

onDeadEvent( team )
{
	// Make sure players on both teams were not eliminated
	if ( team != "all" ) 
	{
		[[level._setTeamScore]]( getOtherTeam(team), [[level._getTeamScore]]( getOtherTeam(team) ) + 1 );
		thread maps\mp\gametypes\_globallogic::endGame( getOtherTeam(team), game["strings"][team + "_eliminated"] );
	} else 
	{
		// We can't determine a winner if everyone died like in S&D so we declare a tie
		thread maps\mp\gametypes\_globallogic::endGame( "tie", game["strings"]["round_draw"] );
	}
}

onRoundSwitch()
{
	// Just change the value for the variable controlling which map assets will be assigned to each team
	level.halftimeType = "halftime";
	game["switchedsides"] = !game["switchedsides"];
}

onPlayerKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	if(isDefined(self) && isDefined(attacker))
		self thread spawnDogTags( attacker );
}    
    
spawnDogTags( attacker )
{
	if(isDefined(attacker) && self.pers["team"] != "spectator" && attacker != self) 
	{
		if(attacker.pers["team"] != self.pers["team"])
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
	if ( taker.pers["team"] != self.team )
	{		
		tagowner = enemyTag.owner;
		event = "kill_confirmed";
		splash = "Picked up tags";
		taker thread onPickupDogTag( event, splash );
		taker.pers["gottags"]++;
	}
	else if ( taker.pers["team"] == self.team ) 
	{
		tagowner = friendlyTag.owner;
		event = "tags_retrieved";
		splash = "Picked up tags";
		taker thread onPickupDogTag( event, splash );	
		taker.pers["gottags"]++;
	}
	trigger playSound( "dogtag_kc_pickup" );
	trigger notify( "picked_up" );
	friendlyTag notify( "picked_up" );
	enemyTag notify( "picked_up" );
	trigger delete();
	friendlyTag delete();
	enemyTag delete ();
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

	if( isDefined( trigger ) )
		trigger delete();

	if( isDefined( friendlyTag ) ) 
		friendlyTag delete();

	if( isDefined( enemyTag ) )
		enemyTag delete ();
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

intoSpawn(originA, anglesA)
{
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
	self thread ispawnang(ent);
	ent.angles = anglesA;
	ent setmodel( "tag_origin" );
	self linkto( ent );
	ent.angles = ( ent.angles[ 0 ] + 89, ent.angles[ 1 ], ent.angles[ 2 ] );
	ent moveto ( originA + (0,0,0), 2, 0, 2 );
	wait ( 1.00 );
	wait( 0.6 );
	ent rotateto( ( ent.angles[ 0 ] - 89, ent.angles[ 1 ], ent.angles[ 2 ]  ), 0.5, 0.3, 0.2 );
	wait ( 0.5 );
	wait( 0.1 );
	self unlink();
	ent delete();
	self freezeControls( false );
}

ispawnang(ent)
{
	while(isDefined(ent) && isDefined(self))
	{
		self SetPlayerAngles( ent.angles );
		wait 0.05;
	}
}
