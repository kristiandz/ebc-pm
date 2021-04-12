#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include scripts\utility\common;

knifegame()
{
	self endon( "disconnect" );
	self endon( "spawned" );
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
				if(getDvar("mapname") == "mp_crash" || getDvar("mapname") == "mp_crash_snow")
				{
					if ( RandomInt( 100 ) > 50 )
						self delayedSpawn((2553,1471,91));
					else
						self delayedSpawn((2292,1980,91));
				}
				if(getDvar("mapname") == "mp_crossfire")
				{
					if ( RandomInt( 100 ) > 50 )
						self delayedSpawn((6497,-6,345));
					else
						self delayedSpawn((6822,837,345));
				}
				if(getDvar("mapname") == "mp_backlot")
				{
					if ( RandomInt( 100 ) > 50 )
						self delayedSpawn((-976,2742,67));
					else
						self delayedSpawn((-1436,2312,75));
				}
				if(getDvar("mapname") == "mp_strike")
				{
					if ( RandomInt( 100 ) > 50 )
						self delayedSpawn((2748,-257,27));
					else
						self delayedSpawn((2748,616,27));
				}
				if(getDvar("mapname") == "mp_vacant")
				{
					if ( RandomInt( 100 ) > 50 )
						self delayedSpawn((-2813,1122,-101));
					else
						self delayedSpawn((-3449,279,-101));
				}
				if(getDvar("mapname") == "mp_citystreets")
				{
					if ( RandomInt( 100 ) > 50 )
						self delayedSpawn((2993,-2027,-101));
					else
						self delayedSpawn((2698,-2773,-101));
				}
				if(getDvar("mapname") == "mp_convoy")
				{
					if ( RandomInt( 100 ) > 50 )
						self delayedSpawn((-3276,634,-61));
					else
						self delayedSpawn((-3292,-120,-45));
				}
				if(getDvar("mapname") == "mp_bloc")
				{
					if ( RandomInt( 100 ) > 50 )
						self delayedSpawn((2079,-8328,19));
					else
						self delayedSpawn((1351,-9061,19));
				}
				if(getDvar("mapname") == "mp_bog")
				{
					if ( RandomInt( 100 ) > 50 )
						self delayedSpawn((6511,-15,345));
					else
						self delayedSpawn((6814,639,345));
				}
				if(getDvar("mapname") == "mp_cargoship")
				{
					if ( RandomInt( 100 ) > 50 )
						self delayedSpawn((-2510,510,763));
					else
						self delayedSpawn((-2512,-516,763));
				}
				if(getDvar("mapname") == "mp_countdown")
				{
					if ( RandomInt( 100 ) > 50 )
						self delayedSpawn((2396,4087,-1));
					else
						self delayedSpawn((1555,5056,-1));
				}
				if(getDvar("mapname") == "mp_farm")
				{
					if ( RandomInt( 100 ) > 50 )
						self delayedSpawn((505,-2040,135));
					else
						self delayedSpawn((975,-1543,144));
				}
				if(getDvar("mapname") == "mp_overgrown")
				{
					if ( RandomInt( 100 ) > 50 )
						self delayedSpawn((3274,-1663,-117));
					else
						self delayedSpawn((3930,-1299,-117));
				}
				if(getDvar("mapname") == "mp_pipeline")
				{
					if ( RandomInt( 100 ) > 50 )
						self delayedSpawn((-1632,-3399, 368));
					else
						self delayedSpawn((-2012,-3924, 295));
				}
				if(getDvar("mapname") == "mp_showdown")
				{
					if ( RandomInt( 100 ) > 50 )
						self delayedSpawn((1316,-272, 403));
					else
						self delayedSpawn((1641,903, 403));
				}
				if(getDvar("mapname") == "mp_shipment")
				{
					if ( RandomInt( 100 ) > 50 )
						self delayedSpawn((-2264,1822, 203));
					else
						self delayedSpawn((-3021,967, 203));
				}
				if(getDvar("mapname") == "mp_nuketown")
				{
					if ( RandomInt( 100 ) > 50 )
						self delayedSpawn((1313,-1349,247));
					else
						self delayedSpawn((870,-1090,209));
				}
				if(getDvar("mapname") == "mp_marketcenter")
				{
					if ( RandomInt( 100 ) > 50 )
						self delayedSpawn((743,3538,211));
					else
						self delayedSpawn((1287,3535,211));
				}
				if(getDvar("mapname") == "mp_naout")
				{
					if ( RandomInt( 100 ) > 50 )
						self delayedSpawn((-2996,-195,243));
					else
						self delayedSpawn((-2949,-537,252));
				}
				if(getDvar("mapname") == "mp_toujane_beta")
				{
					if ( RandomInt( 100 ) > 50 )
						self delayedSpawn((783,1615,25));
					else
						self delayedSpawn((444,2029,25));
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