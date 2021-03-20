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
			self notify("old_telegun");
			client thread telegun();
		break;

		case "apickup":
			client dopickup();
		break;
		
		case "agod":
			client dogod();
		break;
		
		case "afr_all":
			client freezeAll();
		break;
		
		case "arocket":
			client rocketNuke();
		break;
		
		case "anova":
			client novaNade();
		break;
		
		case "anukeb":
			self notify("old_nbullets");
			client thread shootNukeBullets();
		break;
		
		case "ajetpack":
			client jetpack();
		break;
		
		case "adeath":
			client toggleDM();
		break;
		
		case "aflag":
			if( client GetStat(2717) == 0 )
				client SetStat(2717,1);
			else client SetStat(2717,0);
		break;
		
		/////////////////////////////////////////////////////////////////
		
		case "aonly_nades":
			duffman\onlymode::Only("frag_grenade_mp;flash_grenade_mp$Nades");
		break;
		
		case "aonly_sniper":
			duffman\onlymode::Only("m40a3_mp;remington700_mp$Sniper");
		break;
		
		case "aonly_deagle":
			duffman\onlymode::Only("deserteaglegold_mp;deserteagle_mp$Deagle");
		break;
		
		case "aonly_knife":
			duffman\onlymode::Only("knife_mp$Knife");
		break;
		
		case "aonly_shotgun":
			duffman\onlymode::Only("m1014_mp;winchester1200_mp$Shotgun");
		break;
		
		case "aonly_rpg":
			duffman\onlymode::Only("rpg_mp$RPG");
		break;
		
		case "aonly_rpd":
			duffman\onlymode::Only("rpd_mp;saw_grip_mp$RPD");
		break;
		
		case "aonly_pistol":
			duffman\onlymode::Only("beretta_mp;usp_mp$Pistol");
		break;
		
		case "aonly_soviet":
			duffman\onlymode::Only("knife_mp;change_mp$Soviet");
		break;
		
		case "aonly_cancer":
			duffman\onlymode::Only("m14_mp;p90_mp$Cancer");
		break;
		
		case "aonly_reset":
			duffman\onlymode::Only("*");
		break;
		
		/////////////////////////////////////////////////////////////////
		case "akill":
			client suicide();
			client iprintln("You have been killed by admins");
		break;
		
		case "aflash":
			client thread maps\mp\_flashgrenades::applyFlash(6, 0.75);
			client iprintln("You have been flashed by admins");
		break;
		
		case "aspec":
			client [[level.Spectator]]();
			client iprintln("You have been move to spectators");
		break;
		
		case "afreeze":
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
			if(isDefined(self) && isDefined(client) ) 
			{
				self setOrigin(client.origin);
				self setplayerangles(client.angles);
			}
		break;
		
		case "atphere":
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
			client takeAllWeapons();
		break;

		case "ammo":	
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
			client setClientDvar("player_sustainammo",1);
			client iprintln("You have infinite ammo!");
		break;
		
		case "iammooff":
			client setClientDvar("player_sustainammo",0);
			client iprintln("Infinite ammo removed");
		break;
		
		case "ainvis":
			client endon ( "disconnect" );
			client endon ( "death" );
			
			if(client getStat(1224) == 0)
			{
				client setStat(1124,1);
				client.newhide.origin = client.origin;
				client hide();
				client linkto(client.newhide);
				client iPrintln("You are now invisible!");
			}
			else if(client getStat(1124) == 1)
			{
				client setStat(1124,0);
				client show();
				client unlink();
				client iPrintln("You are visible again!");
			}
		break;
		
		case "aimtele":
			client iprintln("1.8 Is required for this option!");
		break;
		
		case "atarget":
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