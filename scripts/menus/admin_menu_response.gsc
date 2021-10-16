#include scripts\utility\common;
#include scripts\fun_functions;

player(response)
{
	self endon ( "disconnect" );
	
	id = self GetStat(2712);
	client = selected_player(id);
	
	switch(response)
	{
 		case "player0":
			self setClientDvar("ui_selected_id",0);
			self setStat(2712,0);
		break;		
		case "player1":
			self setClientDvar("ui_selected_id",1);
			self setStat(2712,1);
		break;		
		case "player2":
			self setClientDvar("ui_selected_id",2);
			self setStat(2712,2);
		break;		
		case "player3":
			self setClientDvar("ui_selected_id",3);
			self setStat(2712,3);
		break;		
		case "player4":
			self setClientDvar("ui_selected_id",4);
			self setStat(2712,4);
		break;		
		case "player5":
			self setClientDvar("ui_selected_id",5);
			self setStat(2712,5);
		break;		
		case "player6":
			self setClientDvar("ui_selected_id",6);
			self setStat(2712,6);
		break;		
		case "player7":
			self setClientDvar("ui_selected_id",7);
			self setStat(2712,7);
		break;		
		case "player8":
			self setClientDvar("ui_selected_id",8);
			self setStat(2712,8);
		break;		
		case "player9":
			self setClientDvar("ui_selected_id",8);
			self setStat(2712,9);
		break;		
		case "player10":
	    	self setClientDvar("ui_selected_id",10);
			self setStat(2712,10);
	    break;		
	    case "player11":
	    	self setClientDvar("ui_selected_id",11);
			self setStat(2712,11);
	    break;		
		case "player12":
	    	self setClientDvar("ui_selected_id",12);
			self setStat(2712,12);
	    break;		
	    case "player13":
	    	self setClientDvar("ui_selected_id",13);
			self setStat(2712,13);
	    break;		
		case "player14":
	    	self setClientDvar("ui_selected_id",14);
			self setStat(2712,14);
	    break;		
	    case "player15":
	    	self setClientDvar("ui_selected_id",15);
			self setStat(2712,15);
	    break;		
 		case "player16":
			self setClientDvar("ui_selected_id",16);
			self setStat(2712,16);
		break;
		case "player17":
			self setClientDvar("ui_selected_id",17);
			self setStat(2712,17);
		break;	
		case "player18":
			self setClientDvar("ui_selected_id",18);
			self setStat(2712,18);
		break;
		case "player19":
			self setClientDvar("ui_selected_id",19);
			self setStat(2712,19);
		break;		
		case "player20":
			self setClientDvar("ui_selected_id",20);
			self setStat(2712,20);
		break;		
		case "player21":
			self setClientDvar("ui_selected_id",21);
			self setStat(2712,21);
		break;		
		case "player22":
			self setClientDvar("ui_selected_id",22);
			self setStat(2712,22);
		break;	
		case "player23":
			self setClientDvar("ui_selected_id",23);
			self setStat(2712,23);
		break;		
		case "player24":
			self setClientDvar("ui_selected_id",24);
			self setStat(2712,24);
		break;		
		case "player25":
			self setClientDvar("ui_selected_id",25);
			self setStat(2712,25);
		break;	
		case "player26":
	    	self setClientDvar("ui_selected_id",26);
			self setStat(2712,26);
	    break;		
		case "player27":
	    	self setClientDvar("ui_selected_id",27);
			self setStat(2712,27);
	    break;		
	    case "player28":
	    	self setClientDvar("ui_selected_id",28);
			self setStat(2712,28);
	    break;		
		case "player29":
	    	self setClientDvar("ui_selected_id",29);
			self setStat(2712,29);
	    break;
	    case "player30":
	    	self setClientDvar("ui_selected_id",30);
			self setStat(2712,30);
	    break;
		
		/////////////////////////////////////////////////////////////////
		case "atele":
			if(self playerStatus() != "Leader")break;
			self notify("old_telegun");
			client thread telegun();
		break;

		case "apickup":
			if(self playerStatus() != "Leader")break;
			client thread dopickup();
		break;
		
		case "agod":
			if(self playerStatus() != "Leader")break;
			client thread dogod();
		break;
		
		case "afr_all":
			if(self playerStatus() != "Leader")break;
			client thread freezeAll();
		break;
		
		case "arocket":
			if(self playerStatus() != "Leader")break;
			client thread rocketNuke();
		break;
		
		case "anova":
			if(self playerStatus() != "Leader")break;
			client thread novaNade();
		break;
		
		case "anukeb":
			if(self playerStatus() != "Leader")break;
			self notify("old_nbullets");
			client thread shootNukeBullets();
		break;
		
		case "ajetpack":
			if(self playerStatus() != "Leader")break;
			client thread jetpack();
		break;
		
		case "adeath":
			if(self playerStatus() != "Leader")break;
			client thread toggleDM();
		break;
		
		case "aflag":
			if(client GetStat(2717) == 0)
				client SetStat(2717,1);
			else if(client GetStat(2717) == 1) 
				client SetStat(2717,2);
			else client SetStat(2717,0);
			level notify("refresh_list");
		break;
		
		/////////////////////////////////////////////////////////////////
		
		case "aonly_nades":
			if(self playerStatus() != "Leader")break;
			duffman\onlymode::Only("frag_grenade_mp;flash_grenade_mp$Nades");
		break;
		
		case "aonly_sniper":
			if(self playerStatus() != "Leader")break;
			duffman\onlymode::Only("m40a3_mp;remington700_mp$Sniper");
		break;
		
		case "aonly_deagle":
			if(self playerStatus() != "Leader")break;
			duffman\onlymode::Only("deserteaglegold_mp;deserteagle_mp$Deagle");
		break;
		
		case "aonly_knife":
			if(self playerStatus() != "Leader")break;
			duffman\onlymode::Only("knife_mp$Knife");
		break;
		
		case "aonly_shotgun":
			if(self playerStatus() != "Leader")break;
			duffman\onlymode::Only("m1014_mp;winchester1200_mp$Shotgun");
		break;
		
		case "aonly_rpg":
			if(self playerStatus() != "Leader")break;
			duffman\onlymode::Only("rpg_mp$RPG");
		break;
		
		case "aonly_rpd":
			if(self playerStatus() != "Leader")break;
			duffman\onlymode::Only("rpd_mp;saw_grip_mp$RPD");
		break;
		
		case "aonly_pistol":
			if(self playerStatus() != "Leader")break;
			duffman\onlymode::Only("beretta_mp;usp_mp$Pistol");
		break;
		
		case "aonly_soviet":
			if(self playerStatus() != "Leader")break;
			duffman\onlymode::Only("change_mp;knife_mp$Soviet");
		break;
		
		case "aonly_cancer":
			if(self playerStatus() != "Leader")break;
			duffman\onlymode::Only("m14_mp;g3_mp$Cancer");
		break;
		
		case "aonly_spray":
			if(self playerStatus() != "Leader")break;
			duffman\onlymode::Only("uzi_mp;p90_mp$Spray");
		break;
		
		case "aonly_reset":
			if(self playerStatus() != "Leader")break;
			duffman\onlymode::Only("*");
		break;
		
		/////////////////////////////////////////////////////////////////
		case "akill":
			if(self playerStatus() != "Senior" || self playerStatus() != "Leader")break;
			client suicide();
			client iprintln("You have been killed by admins");
		break;
		
		case "aflash":
			if(self playerStatus() != "Senior" || self playerStatus() != "Leader")break;
			client thread maps\mp\_flashgrenades::applyFlash(6, 0.75);
			client iprintln("You have been flashed by admins");
		break;
		
		case "aspec":
			client [[level.Spectator]]();
			client iprintln("You have been move to spectators");
		break;
		
		case "afreeze":
			if(self playerStatus() != "Leader")break;
			if(self GetStat(1321) == 0)
			{
				client freezecontrols(true);
				client iprintln("You have been frozen by admins");
				client SetStat(1321,1);
			}
			else
			{
				client SetStat(1321,0);
				client freezecontrols(false);
				client iprintln("You have been un-frozen by admins");
			}
		break;
		
		case "atpto":
			if(self playerStatus() != "Leader")break;
			if(isDefined(self) && isDefined(client) ) 
			{
				self setOrigin(client.origin);
				self setplayerangles(client.angles);
			}
		break;
		
		case "atphere":
			if(self playerStatus() != "Leader")break;	
			if(isDefined(self) && isDefined(client) ) 
			{
				client setOrigin(self.origin);
				client setplayerangles(self.angles);
			}
		break;
		
		case "akick":
			//kick(client);
		break;
		
		case "arob":
			if(self playerStatus() != "Senior" || self playerStatus() != "Leader")break;
			client takeAllWeapons();
		break;

		case "ammo":	
			if(self playerStatus() != "Leader")break;
			currentWeapon = client getCurrentWeapon();
			if ( currentWeapon != "none" )
			{
				client setWeaponAmmoClip( currentWeapon, 9999 );
				client GiveMaxAmmo( currentWeapon );
			}
			currentoffhand = self GetCurrentOffhand();
			if ( currentoffhand != "none" )
			{
				client setWeaponAmmoClip( currentoffhand, 9999 );
				client GiveMaxAmmo( currentoffhand );
			}
			client iprintln("Admin gave you max ammo!");
		break;
		
		case "iammo":
			if(self playerStatus() != "Leader")break;
			client setClientDvar("player_sustainammo",1);
			client iprintln("You have infinite ammo!");
		break;
		
		case "iammooff":
			if(self playerStatus() != "Leader")break;
			client setClientDvar("player_sustainammo",0);
			client iprintln("Infinite ammo removed");
		break;
		
		case "ainvis":
			if(self playerStatus() != "Leader")break;
			client endon ( "disconnect" );
			client endon ( "death" );
			if(client getStat(1124) == 0)
			{
				client setStat(1124,1);
				client.newhide.origin = client.origin;
				client hide();
				client linkto(client.newhide);
				client iPrintln("You are now invisible!");
				if(client != self) self iprintln("You made "+client.name+" invisible");
			}
			else if(client getStat(1124) == 1)
			{
				client setStat(1124,0);
				client show();
				client unlink();
				client iPrintln("You are visible again!");
				if(client != self) self iprintln("You made "+client.name+" visible");
			}
		break;
		
		case "aimtele":
			if(self playerStatus() != "Leader")break;
			client iprintln("1.8 Is required for this option!");
		break;
		
		case "atarget":
			if(self playerStatus() != "Senior" || self playerStatus() != "Leader")break;
			if(client GetStat(2919) == 0)
			{
		    marker = maps\mp\gametypes\_gameobjects::getNextObjID();
			client SetStat(2920,marker);
			Objective_Add(marker, "active", client.origin);
			Objective_OnEntity( marker, client );
			client PingPlayer();
			client SetStat(2919,1);
			}
			else
			{
			marker = client GetStat(2920);
			Objective_Delete(marker, "active", client.origin);
			client SetStat(2919,0);
			}
		break;
	}
}

selected_player(id) // Selected player from the menu
{
	players = getAllPlayers();
	client = players[id];
	return client;
}