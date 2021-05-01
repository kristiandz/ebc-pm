#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include scripts\utility\common;

knifegame()
{
	self endon( "disconnect" );
	self endon( "knife_arena" );
	level endon ( "game_ended" );
	self iprintln("[^1Melee^7] To Join Knife");
	for(;;wait 0.35)
	{
		if(!isAlive(self))
		{
			if(self MeleeButtonPressed())
			{
				if(self GetStat(1190) == 0)
				{
					self thread knifeicon(3);
					self thread timer(3);
				}
				self.isKnifing = true;
				switch(level.script)
				{
					case "mp_crash":
						if ( RandomInt( 100 ) > 50 ) self delayedSpawn((2553,1471,91));
						else self delayedSpawn((2292,1980,91));
						break;
					
					case "mp_crash_snow":
						if ( RandomInt( 100 ) > 50 ) self delayedSpawn((2553,1471,91));
						else self delayedSpawn((2292,1980,91));
						break;
						
					case "mp_crossfire":
						if ( RandomInt( 100 ) > 50 ) self delayedSpawn((6497,-6,345));
						else self delayedSpawn((6822,837,345));
						break;
						
					case "mp_backlot":
						if ( RandomInt( 100 ) > 50 ) self delayedSpawn((-976,2742,67));
						else self delayedSpawn((-1436,2312,75));
						break;
						
					case "mp_strike":
						if ( RandomInt( 100 ) > 50 ) self delayedSpawn((2748,-257,27));
						else self delayedSpawn((2748,616,27));
						break;
						
					case "mp_vacant":
						if ( RandomInt( 100 ) > 50 ) self delayedSpawn((-2813,1122,-101));
						else self delayedSpawn((-3449,279,-101));
						break;
						
					case "mp_citystreets":
						if ( RandomInt( 100 ) > 50 ) self delayedSpawn((2993,-2027,-101));
						else self delayedSpawn((2698,-2773,-101));
						break;
						
					case "mp_convoy":
						if ( RandomInt( 100 ) > 50 ) self delayedSpawn((-3276,634,-61));
						else self delayedSpawn((-3292,-120,-45));
						break;
						
					case "mp_bloc":
						if ( RandomInt( 100 ) > 50 ) self delayedSpawn((2079,-8328,19));
						else self delayedSpawn((1351,-9061,19));
						break;
						
					case "mp_bog":
						if ( RandomInt( 100 ) > 50 ) self delayedSpawn((6511,-15,345));
						else self delayedSpawn((6814,639,345));
						break;
						
					case "mp_cargoship":
						if ( RandomInt( 100 ) > 50 ) self delayedSpawn((-2510,510,763));
						else self delayedSpawn((-2512,-516,763));
						break;
						
					case "mp_countdown":
						if ( RandomInt( 100 ) > 50 ) self delayedSpawn((2396,4087,-1));
						else self delayedSpawn((1555,5056,-1));
						break;
						
					case "mp_farm":
						if ( RandomInt( 100 ) > 50 ) self delayedSpawn((505,-2040,135));
						else self delayedSpawn((975,-1543,144));
						break;

					case "mp_overgrown":
						if ( RandomInt( 100 ) > 50 ) self delayedSpawn((3274,-1663,-117));
						else self delayedSpawn((3930,-1299,-117));
						break;
						
					case "mp_pipeline":
						if ( RandomInt( 100 ) > 50 ) self delayedSpawn((-1632,-3399, 368));
						else self delayedSpawn((-2012,-3924, 295));
						break;
						
					case "mp_showdown":
						if ( RandomInt( 100 ) > 50 ) self delayedSpawn((1316,-272, 403));
						else self delayedSpawn((1641,903, 403));
						break;
						
					case "mp_shipment":
						if ( RandomInt( 100 ) > 50 ) self delayedSpawn((-2264,1822, 203));
						else self delayedSpawn((-3021,967, 203));
						break;
						
					case "mp_nuketown":
						if ( RandomInt( 100 ) > 50 ) self delayedSpawn((1313,-1349,247));
						else self delayedSpawn((870,-1090,209));
						break;
						
					case "mp_marketcenter":
						if ( RandomInt( 100 ) > 50 ) self delayedSpawn((743,3538,211));
						else self delayedSpawn((1287,3535,211));
						break;
						
					case "mp_naout":
						if ( RandomInt( 100 ) > 50 ) self delayedSpawn((-2996,-195,243));
						else self delayedSpawn((-2949,-537,252));
						break;
						
					case "mp_toujane_beta":
						if ( RandomInt( 100 ) > 50 ) self delayedSpawn((783,1615,25));
						else self delayedSpawn((444,2029,25));
						break;
				}
			}
		}
	}
}

delayedSpawn(origin)
{
	self SetStat(1190,1);
	if( !isDefined(self.spawnedKnifing) )
		wait 3.0;
	self.spawnedKnifing = true;
	self maps\mp\gametypes\_globallogic::roofspawn();
	self setOrigin(origin);
}

knifeicon(time)
{
	knifeiconshader = newClientHudElem(self);
	knifeiconshader.x = 0;
	knifeiconshader.y = 140;
	knifeiconshader.alignX = "center";
	knifeiconshader.alignY = "middle";
	knifeiconshader.horzAlign = "center";
	knifeiconshader.vertAlign = "middle";
	knifeiconshader.sort = 1003;
	knifeiconshader setShader("killiconmelee", 25, 25);
	knifeiconshader.alpha = 0.5;
	knifeiconshader.foreground = false;
	knifeiconshader.hidewheninmenu = false;
	wait time;
	if(isDefined(knifeiconshader)) knifeiconshader destroy();
}

timer(time) 
{
	self endon("disconnect");	
	text = addTextHud( self, 0, 120, 1, "center", "middle", "center", "middle", 1.5, 1001 );
	text SetTenthsTimer(time);
	wait time;
	text destroy();
}