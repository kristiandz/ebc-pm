#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

init(modVersion) 
{
    precacheItem("saw_grip_mp");
	thread onPlayerConnected();
}

onPlayerConnected() 
{
	for(;;) 
	{
		level waittill("connected",player);
		player thread onPlayerSpawn();
	}
}

Only(wep) 
{
	game["only_weapon"] = strTok(wep,"$")[0];
	players = scripts\utility\common::getAllPlayers();
	for(i=0;i<players.size;i++) 
		players[i] notify("new_only_weapon");
	
	if(strTok(wep,"$")[0] != "*") 
	{
		game["only_welcomemsg"] = strTok(wep,"$")[1];
		iprintlnbold("Only mode got changed to ^1" + game["only_welcomemsg"]);
		game["only_weapons"] = strTok(wep,"$")[0];
	}
	else 
	{
		iprintlnbold("Only mode got ^1reset");
		game["only_welcomemsg"] = undefined;
		game["only_weapons"] = undefined;
		game["only_weapon"] = undefined; // Double check this on live
	}
}

InfinityWeaponAmmo(weapon)
{
	self endon("disconnect");
	self endon("spawned");
	self endon("new_only_weapon");
	weapon = strTok(weapon,";");
	while(1) 
	{
		for(i=0;i<weapon.size;i++) 
		{
			self GiveMaxAmmo( weapon[i] );
		}
		wait 1;
	}
}

onPlayerSpawn() 
{
	self endon("disconnect");
	while(1) 
	{
		self common_scripts\utility::waittill_any("disconnect","spawned","new_only_weapon");
		if(!isDefined(self.pers["welcomed_only"])) 
		{
			self.pers["welcomed_only"] = 1;
			if(isDefined(game["only_welcomemsg"]))
				self iprintlnbold("We are currently playing only ^1" + game["only_welcomemsg"]);
		}
		wait .05;
		level.allowpickup = true;
		if(!isDefined(game["only_weapon"]) || game["only_weapon"] == "*")
			continue;
		self thread InfinityWeaponAmmo(game["only_weapons"]);
		level.allowpickup = false;		
		weapon = strTok(game["only_weapon"],";");
		self TakeAllWeapons();
		if(weapon[0] == "knife_mp") 
		{
			self giveWeapon( "deserteaglegold_mp" );
			self setWeaponAmmoStock( "deserteaglegold_mp", 0 );
			self setWeaponAmmoClip( "deserteaglegold_mp", 0 );
			wait .05;
			self switchToWeapon( "deserteaglegold_mp" );
		}	
		else 
		{
			for(i=0;i<weapon.size;i++) 
			{
				self giveWeapon( weapon[i] );
				self GiveMaxAmmo( weapon[i] );			
			}
			wait .05;
			self switchToWeapon( weapon[randomint(weapon.size)] );				
		}
	}
}