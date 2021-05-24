#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

#include scripts\utility\_utility;
#include scripts\utility\splash_utility;

init()
{
	level.splashNum = int( tableLookup( "mp/splashTable.csv", 0, "splashnum", 1 ) );

	for ( ID = 1; ID <= level.SplashNum; ID++ )
	{
		precacheString( tableLookupIString( "mp/splashTable.csv", 0, ID, 2 ) );
		precacheString( tableLookupIString( "mp/splashTable.csv", 0, ID, 3 ) );
	}
	
	precacheShader("gradient_top");
	precacheShader("gradient_bottom");
	precacheShader("flare");
	
	level.numKills = 0;
	
	level thread onPlayerConnect();	
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );
		
		player thread onPlayerSpawned();
		player.lastKilledBy = undefined;
		player.pers["cur_kill_streak"] = 0;
		player.pers["cur_death_streak"] = 0;
		player.recentKillCount = 0;
		player.lastKillTime = 0;
	}
}

onPlayerSpawned()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("spawned");
		self.firstTimeDamaged = [];
		self.damaged = undefined;
	}
}

killedPlayer( victim, weapon, meansOfDeath )
{
	level endon("_game_ended");

	self endon("disconnect");
	victim endon("disconnect");

	if(!isDefined(level.numKills))
		level.numKills = 0;
		
	level.numKills++;

	if(!isDefined(self) || !isDefined(victim) || (victim.team == self.team && level.teambased) || weapon == "none")
		return;
		
	curTime = getTime();
	
	self thread updateRecentKills();
	self.lastKillTime = getTime();
	self.lastKilledPlayer = victim;

	if ( isDefined(victim.damaged) && victim.damaged == getTime() )
	{
		weaponClass = getWeaponClass( weapon );

		if ( meansOfDeath != "MOD_MELEE" && ( weaponClass == "weapon_sniper" ) )
			self thread splashNotifyDelayed( "one_shot_kill" );
	}
	
	if ( level.numKills == 1 )
		self firstBlood();

	if ( self.pers["cur_death_streak"] > 3 )
		self comeBack();

	if ( meansOfDeath == "MOD_HEAD_SHOT" )
		self headShot();

	if ( !isAlive( self ) && self.deathtime + 800 < getTime() )
		self postDeathKill();

	if ( level.teamBased && curTime - victim.lastKillTime < 500 )
	{
		if ( victim.lastkilledplayer != self )
			self avengedPlayer();
	}

	if ( isDefined( victim.attackerPosition ) )
		attackerPosition = victim.attackerPosition;
	else
		attackerPosition = self.origin;

	if ( isAlive( self ) && (meansOfDeath == "MOD_RIFLE_BULLET" || meansOfDeath == "MOD_PISTOL_BULLET" || meansOfDeath == "MOD_HEAD_SHOT") && distance( 	attackerPosition, victim.origin ) > 1536 && !isDefined( self.assistedSuicide ) )
		self longshot();

	if ( isDefined( victim.pers["cur_kill_streak"] ) && victim.pers["cur_kill_streak"] >= max(3,int( level.aliveCount[level.otherTeam[victim.team]] / 2 )) )
		self buzzKill();

	if ( isDefined( self.lastKilledBy ) && self.lastKilledBy == victim )
	{
		self.lastKilledBy = undefined;
		self revenge();
	}

	victim.lastKilledBy = self;	
}

wallbang()
{
	self thread splashNotifyDelayed( "wallbang" );
	self thread maps\mp\gametypes\_rank::giveRankXP( "wallbang" );
}

longshot()
{
	self thread splashNotifyDelayed( "longshot" );
	self thread maps\mp\gametypes\_rank::giveRankXP( "longshot" );
}

execution()
{
	self thread splashNotifyDelayed( "execution" );
	self thread maps\mp\gametypes\_rank::giveRankXP( "execution" );
}

headShot()
{
	self thread splashNotifyDelayed( "headshot_splash" );
	self thread maps\mp\gametypes\_rank::giveRankXP( "headshot_splash" );
}

avengedPlayer()
{
	self thread splashNotifyDelayed( "avenger" );
	self thread maps\mp\gametypes\_rank::giveRankXP( "avenger" );
}

assistedSuicide()
{
	self thread splashNotifyDelayed( "assistedsuicide" );
	self thread maps\mp\gametypes\_rank::giveRankXP( "assistedsuicide" );
}

defendedPlayer()
{
	self thread splashNotifyDelayed( "defender" );
	self thread maps\mp\gametypes\_rank::giveRankXP( "defender" );
}


postDeathKill()
{
	self thread splashNotifyDelayed( "posthumous" );
	self thread maps\mp\gametypes\_rank::giveRankXP( "posthumous" );
}

revenge()
{
	self thread splashNotifyDelayed( "revenge" );
	self thread maps\mp\gametypes\_rank::giveRankXP( "revenge" );
}

multiKill( killCount )
{
	assert( killCount > 1 );
	
	if ( killCount == 2 )
		self thread splashNotifyDelayed( "doublekill" );

	else if ( killCount == 3 )
	{
		self thread splashNotifyDelayed( "triplekill" );
		thread teamPlayerCardSplash( "callout_3xkill", self );
	}
	else
	{
		self thread splashNotifyDelayed( "multikill" );
		thread teamPlayerCardSplash( "callout_3xpluskill", self );
	}	
}

firstBlood()
{
	self thread splashNotifyDelayed( "firstblood" );
	self thread maps\mp\gametypes\_rank::giveRankXP( "firstblood" );
	thread teamPlayerCardSplash( "callout_firstblood", self );
}

buzzKill()
{
	self thread splashNotifyDelayed( "buzzkill" );
	self thread maps\mp\gametypes\_rank::giveRankXP( "buzzkill" );
}

comeBack()
{
	self thread splashNotifyDelayed( "comeback" );
	self thread maps\mp\gametypes\_rank::giveRankXP( "comeback" );
}

updateRecentKills()
{
	self endon ( "disconnect" );
	level endon ( "game_ended" );
	
	self notify ( "updateRecentKills" );
	self endon ( "updateRecentKills" );
	
	self.recentKillCount++;
	
	wait 1.7;
	
	if ( self.recentKillCount > 1 )
		self multiKill( self.recentKillCount );
	
	self.recentKillCount = 0;
}

isWallBang( attacker, victim )
{
	return bulletTracePassed( attacker getEye(), victim getEye(), false, attacker );
}