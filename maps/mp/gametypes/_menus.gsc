#include scripts\utility\common;

init()
{
	if(!isDefined(game["gamestarted_threads"]))
	{
		game["menu_team"] = "team_marinesopfor";
		if(game["attackers"] == "axis" && game["defenders"] == "allies")
			game["menu_team"] += "_flipped";
		game["menu_class_allies"] = "class_marines";
		game["menu_changeclass_allies"] = "changeclass_marines_mw";
		game["menu_class_axis"] = "class_opfor";
		game["menu_changeclass_axis"] = "changeclass_opfor_mw";
		game["menu_class"] = "class";
		game["menu_changeclass"] = "changeclass_mw";
		game["menu_changeclass_offline"] = "changeclass_offline";
		game["menu_callvote"] = "callvote";
		game["menu_muteplayer"] = "muteplayer";
		game["menu_quickcommands"] = "quickcommands";
		game["menu_quickstatements"] = "quickstatements";
		game["menu_quickresponses"] = "quickresponses";
		game["menu_quickpromod"] = "quickpromod";
		game["menu_quickpromodgfx"] = "quickpromodgfx";
		game["menu_quickpromodfps"] = "quickpromodfps";
		game["menu_admin"] = "admin";
		game["menu_player"] = "player";
		game["menu_vip"] = "vip";
		game["menu_sprays"] = "sprays";
		game["menu_clientcmd"] = "clientcmd";
		
		precacheMenu("clientcmd");
		precacheMenu("quickcommands");
		precacheMenu("quickpromodfps");
		precacheMenu("vip");
		precacheMenu("sprays");
		precacheMenu("player");
		precacheMenu("admin");
		precacheMenu("quickstatements");
		precacheMenu("quickresponses");
		precacheMenu("quickpromod");
		precacheMenu("quickpromodgfx");
		precacheMenu("scoreboard");
		precacheMenu(game["menu_team"]);
		precacheMenu("class_marines");
		precacheMenu("changeclass_marines_mw");
		precacheMenu("class_opfor");
		precacheMenu("changeclass_opfor_mw");
		precacheMenu("class");
		precacheMenu("changeclass_mw");
		precacheMenu("changeclass_offline");
		precacheMenu("echo");
	}
	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connecting", player);
		player thread onMenuResponse();
	}
}

onMenuResponse()
{
	level endon("restarting");
	self endon("disconnect");

	for(;;)
	{
		self waittill("menuresponse", menu, response);
		
		if ( !isDefined( self.pers["team"] ) )
			continue;

		if( getSubStr( response, 0, 7 ) == "loadout" )
		{
			self maps\mp\gametypes\_promod::processLoadoutResponse( response );
			continue;
		}
		///////////////////////////////////////////////////////////////////////////
		if (response == "prestige") 
		{	
			self closeMenu();
			self closeInGameMenu();
			
			if(!self maps\mp\gametypes\_rank::canPrestigeUp())
				continue;
			
			if(self GetStat(2326) < 29 && isDefined(self) )
			{
				self maps\mp\gametypes\_rank::prestigeUp();
				wait 0.1;
			}
			else 
			{
				self iprintLnBold("^1You have reached the max regular prestige!\n^7To enter prestige 30 you have to complete a trial.");
				self iprintLnBold("Search for a collection of personalised clues to solve the trial. Good Luck!");
			}
		}
		///////////////////////////////////////////////////////////////////////////
		if( self isDev() && isSubStr(response,"atier:"))
		{
			at = strTok(response,":")[1];
			am = strTok(response,":")[2];
			player = getPlayerByNum(at);
			player SetStat(3252,int(am));
			self iprintLnBold("You have set award tier:^8 "+am+"^7 to client ID:^8 "+at);
			player iprintLnBold("Leader has set your award tier to:^8 " + am );
		}
		
		///////////////////////////////////////////////////////////////////////////
		if( self isDev() && isSubStr(response,"statcheck:"))
		{
			at = strTok(response,":")[1];
			am = strTok(response,":")[2];
			player = getPlayerByNum(at);
			temp = player GetStat(int(am));
			self iprintLnBold("Stat: " + am + " for player " + player.name + "is: " + temp);
		}
		///////////////////////////////////////////////////////////////////////////
		if( self isDev() && isSubStr(response,"statset:"))
		{
			at = strTok(response,":")[1];
			am = strTok(response,":")[2];
			stat = strTok(response,":")[3];
			player = getPlayerByNum(at);
			player SetStat(int(am),int(stat));
			self iprintLnBold("Stat: " + am + " for player " + player.name + "is set to: " + stat);
		}
		///////////////////////////////////////////////////////////////////////////
		switch( response )
		{
			case "back":
				if ( self.pers["team"] == "none" )
					continue;

				if( menu == game["menu_changeclass"] && ( self.pers["team"] == "axis" || self.pers["team"] == "allies" ) )
				{
					if( isDefined(self.pers["class"]) )
					{
						self maps\mp\gametypes\_promod::setClassChoice( self.pers["class"] );
						self maps\mp\gametypes\_promod::menuAcceptClass( "go" );
					}

					self openMenu( game["menu_changeclass_"+self.pers["team"]] );
				}
				else
				{
					self closeMenu();
					self closeInGameMenu();
				}
				continue;

			case "changeteam":
				self closeMenu();
				self closeInGameMenu();
				self openMenu(game["menu_team"]);
				continue;

			case "changeclass_marines":
			case "changeclass_opfor":
				if ( self.pers["team"] == "axis" || self.pers["team"] == "allies" )
				{
					self closeMenu();
					self closeInGameMenu();
					self openMenu( game["menu_changeclass_"+self.pers["team"]] );
				}
				continue;
		}

		switch( menu )
		{
			case "echo":
				k = strtok(response, "_");
				buf = k[0];
				for(i=1;i<k.size;i++)
					buf += " "+k[i];
				self iprintln(buf);
				continue;
			case "team_marinesopfor":
			case "team_marinesopfor_flipped":
				switch(response)
				{
					case "allies":
						self [[level.allies]]();
						break;

					case "axis":
						self [[level.axis]]();
						break;

					case "autoassign":
						self [[level.autoassign]]();
						break;

					case "shoutcast":
						self [[level.spectator]]();
						break;
				}
				continue;
			case "changeclass_marines_mw":
			case "changeclass_opfor_mw":
				if ( response == "killspec" )
				{
					self [[level.killspec]]();
					continue;
				}

				if ( scripts\menus\quickmessages_menu_response::chooseClassName( response ) == "" || !self maps\mp\gametypes\_promod::verifyClassChoice( self.pers["team"], response ) )
					continue;

				self maps\mp\gametypes\_promod::setClassChoice( response );
				self closeMenu();
				self closeInGameMenu();
				self openMenu( game["menu_changeclass"] );
				continue;

			case "changeclass_mw":
				self maps\mp\gametypes\_promod::menuAcceptClass( response );
				continue;

			case "quickcommands":
			case "quickstatements":
			case "quickresponses":
				scripts\menus\quickmessages_menu_response::doQuickMessage( menu, int(response)-1 );
				continue;

			case "quickpromod":
				scripts\menus\quickmessages_menu_response::quickpromod( response );
				continue;

			case "quickpromodgfx":
				scripts\menus\quickmessages_menu_response::quickpromodgfx( response );
				continue;
							
			case "quickpromodfps":
				scripts\menus\quickpromodfps_menu_response::quickpromodfps( response );
				continue;
				
			case "player":
				scripts\menus\player_menu_response::player( response );
				continue;
			
			case "sprays":
				scripts\menus\sprays_menu_response::player( response );
				continue;
				
			case "vip":
				scripts\menus\vip_menu_response::player( response );
				continue;
				
			case "admin":
				scripts\menus\admin_menu_response::player( response );
				continue;
		}
		
	}
}