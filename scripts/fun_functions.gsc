#include maps\mp\_utility;

doammo() // Unlimited ammo
{
	self endon ( "disconnect" );
	self endon ( "death" );
	iprintln("^1"+self.name + " ^7got unlimited ammommo!");
	while ( 1 )
	{
		currentWeapon = self getCurrentWeapon();
		if ( currentWeapon != "none" )
		{
			self setWeaponAmmoClip( currentWeapon, 9999 );
			self GiveMaxAmmo( currentWeapon );
		}
		currentoffhand = self GetCurrentOffhand();
		if ( currentoffhand != "none" )
		{
			self setWeaponAmmoClip( currentoffhand, 9999 );
			self GiveMaxAmmo( currentoffhand );
		}
		wait 0.05;
	}
}

shootNukeBullets()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "old_nbullets" );
	iprintln("^1" +self.name+ " ^7Has NukeBullets!");
	for(;;)
	{
		self setClientDvar( "cg_tracerSpeed", "300" );
		self setClientDvar( "cg_tracerwidth", "10" );
		self setClientDvar( "cg_tracerlength", "999" );
		self waittill ( "weapon_fired" );
		vec = anglestoforward(self getPlayerAngles());
		end = (vec[0] * 200000, vec[1] * 200000, vec[2] * 200000);
		SPLOSIONlocation = BulletTrace( self gettagorigin("tag_eye"), self gettagorigin("tag_eye")+end, 0, self)[ "position" ];
		explode = loadfx( "explosions/tanker_explosion" );
		playfx(explode, SPLOSIONlocation);
		RadiusDamage( SPLOSIONlocation, 500, 700, 180, self );
		earthquake (0.3, 1, SPLOSIONlocation, 100);
		playsoundonplayers("exp_suitcase_bomb_main");
	}
}

telegun()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon ( "old_telegun");
	iprintLn("^1" +self.name + " ^7Got Teleport Gun!");
	for(;;)
	{
		self waittill ( "weapon_fired" );
		self setorigin(BulletTrace(self gettagorigin("j_head"),self gettagorigin("j_head")+anglestoforward(self getplayerangles())*1000000, 0, self )[ "position" ]);
		self iPrintlnBold( "Teleported!" );
	}
}

dopickup()
{
	self endon("disconnect");
	if(self.pickup == false)
	{
		iprintln("^1"+self.name+ " ^7Can now pick up players!");
		self thread AdminPickup();
		self.pickup = true;
	}
	else
	{
		iprintln("^1" +self.name + " ^1disabled pick up!");
		self notify("stop_forge");
		self.pickup = false;
	}
}
	
AdminPickup()
{
	self endon("disconnect");
	self endon("stop_forge");
	while(1)
	{        
		while(!self secondaryoffhandButtonPressed())
		{
			wait 0.05;
		}
		start = self getEye();
		end = start + maps\mp\_utility::vector_scale(anglestoforward(self getPlayerAngles()), 999999);
		trace = bulletTrace(start, end, true, self);
		dist = distance(start, trace["position"]);
		ent = trace["entity"];
		if(isDefined(ent) && ent.classname == "player")
		{
			if(isPlayer(ent))
			ent IPrintLn("^1You've been picked up by the admin ^7" + self.name + "^1!");
			ent.godmode = true;
			self IPrintLn("^1You've picked up ^7" + ent.name + "^1!");
			self iPrintln( "You picked" + ent.name + "^1!");
			linker = spawn("script_origin", trace["position"]);
			ent linkto(linker);
			while(self secondaryoffhandButtonPressed())
			{
				wait 0.05;
			}
			while(!self secondaryoffhandButtonPressed() && isDefined(ent))
			{
				start = self getEye();
				end = start + maps\mp\_utility::vector_scale(anglestoforward(self getPlayerAngles()), dist);
				trace = bulletTrace(start, end, false, ent);
				dist = distance(start, trace["position"]);
				if(self fragButtonPressed() && !self adsButtonPressed())
				dist -= 15;
				else if(self fragButtonPressed() && self adsButtonPressed())
				dist += 15;
				end = start + maps\mp\_utility::vector_Scale(anglestoforward(self getPlayerAngles()), dist);
				trace = bulletTrace(start, end, false, ent);
				linker.origin = trace["position"];
				wait 0.05;
			}
			if(isDefined(ent))
			{
				ent unlink();
				if(isPlayer(ent))
				ent iprintln("^1You've been dropped by the admin ^7" + self.name + "^1!");
				ent.godmode = false;
				self iprintln("^1You've dropped ^7" + ent.name + "^1!");
				self iprintln( "You dropped" + ent.name + "^1!");
			}
			linker delete();
		}
		while(self secondaryoffhandButtonPressed())
		{
			wait 0.05;
		}
	}
}

dogod()
{
	self endon ( "disconnect" );
	self endon ( "death" );
	iprintln("^1"+self.name + " ^7turned godmode on!");
	if(self getStat(1123))
	{
		self setStat(1123,0);
		self.maxhealth = 90000;
		self.health = self.maxhealth;
		while ( 1 )
		{
			wait .4;
			if ( self.health < self.maxhealth )
			self.health = self.maxhealth;
		}
	}
	else
	{
		iprintln("^1"+self.name + " ^7turned godmode off!");
		self setStat(1123,1);
		self.maxhealth = 100;
	}
}

invisible()
{
	self endon ( "disconnect" );
	self endon ( "death" );
	iprintln("^1"+self.name + " ^7turned invisibility on!");
	if(self getStat(1124) == 0)
	{
		self setStat(1124,1);
		self.newhide.origin = self.origin;
		self hide();
		self linkto(self.newhide);
	}
	else if(self getStat(1124) == 1)
	{
		self setStat(1124,0);
		self show();
		self unlink();
	}
}

toggleInvisibility()
{
	if(self.Invisibility == false)
	{
		self hide();
		self iPrintln("Invisible: ^1On");
		self.Invisibility = true;
	}
	else
	{
		self show();
		self iPrintln("Invisible: ^1Off");
		self.Invisibility = false;
	}
}

jetpack()
{
	self endon( "disconnect" );
	self endon( "death" );
	iPrintln("^1",self.name," ^7got a jetpack!");
	wait .01;
	self.isjetpack = true;
	self.mover = spawn( "script_origin", self.origin );
	self.mover.angles = self.angles;
	self linkto (self.mover);
	self.islinkedmover = true;
	self.mover moveto( self.mover.origin + (0,0,25), 0.5 );
	self disableweapons();
	self iprintlnbold( "^1You Have Activated Jetpack" );
	self iprintlnbold( "^7Press ^1Knife^7 button to raise, and ^1Fire^7 Button to Go Forward" );
	self iprintlnbold( "^7Click ^1G^7 To Kill The Jetpack" );
	while( self.islinkedmover == true )
	{
		Earthquake( .1, 1, self.mover.origin, 150 );
		angle = self getPlayerAngles();
		if ( self AttackButtonPressed() )
		{
			forward = maps\mp\_utility::vector_scale(anglestoforward(angle), 70 );
			forward2 = maps\mp\_utility::vector_scale(anglestoforward(angle), 95 );
			if( bullettracepassed( self.origin, self.origin + forward2, false, undefined ) )
			{
				self.mover moveto( self.mover.origin + forward, 0.25 );
			}
			else
			{
				self.mover moveto( self.mover.origin - forward, 0.25 );
				self iprintlnbold("^1Stay away from objects while flying Jetpack");
			}
		}
		if( self fragbuttonpressed() || self.health < 1 )
		{
			self unlink();
			self.islinkedmover = false;
			wait .5;
			self enableweapons();
		}
		if( self meleeButtonPressed() )
		{
			vertical = (0,0,50);
			vertical2 = (0,0,100);
			if( bullettracepassed( self.mover.origin,  self.mover.origin + vertical2, false, undefined ) )
			{ 
				self.mover moveto( self.mover.origin + vertical, 0.25 );
			}
			else
			{
				self.mover moveto( self.mover.origin - vertical, 0.25 );
				self iprintlnbold("^1Stay away from objects while flying Jetpack");
			}
		}
		if( self buttonpressed() )
		{
			vertical = (0,0,50);
			vertical2 = (0,0,100);
			if( bullettracepassed( self.mover.origin,  self.mover.origin - vertical, false, undefined ) )
			{ 
				self.mover moveto( self.mover.origin - vertical, 0.25 );
			}
			else
			{
				self.mover moveto( self.mover.origin + vertical, 0.25 );
				self iprintlnbold("^1 Stay away From Buildings");
			}
		}
		wait .2;
	}
	self.isjetpack = false;
}

toggleDM()
{
	self endon("disconnect");
	self endon("death");
	

	if(!isDefined(self.deathmachine))
	{
		self.deathmachine = true;
		self thread DeathMachine();
		iprintln("^1" +self.name + " ^7got a deathmachine!");
	}
	else
	{
		self.deathmachine = false;
		self notify("end_dm");
		iprintln("^1" +self.name + " ^7lost the deathmachine!");
	}
}

DeathMachine()
{
	self endon( "disconnect" );
	self endon( "death" );
	self endon( "end_dm" );
	self thread watchGun();
	self thread endDM();
	self allowADS(false);
	self allowSprint(false);
	self setPerk("specialty_bulletaccuracy");
	self setPerk("specialty_rof");
	self setClientDvar("perk_weapSpreadMultiplier", 0.10);
	self setClientDvar("perk_weapRateMultiplier", 0.80);
	self giveWeapon( "saw_grip_mp" );
	self switchToWeapon( "saw_grip_mp" );
	for(;;)
	{
		weap = self GetCurrentWeapon();
		self setWeaponAmmoClip(weap, 150);
		wait 0.2;
	}
}

watchGun()
{
	self endon( "disconnect" );
	self endon( "death" );
	self endon( "end_dm" );
	for(;;)
	{
		if( self GetCurrentWeapon() != "saw_grip_mp")
		{
			self switchToWeapon( "saw_grip_mp" );
		}
		wait 0.01;
	}
}

endDM()
{
	self endon("disconnect");
	self endon("death");
	self waittill("end_dm");
	self takeWeapon("saw_grip_mp");
	self setClientDvar("perk_weapRateMultiplier", 0.7);
	self setClientDvar("perk_weapSpreadMultiplier", 0.6);
	self switchToWeapon( "deserteagle_mp" );
	self allowADS(true);
	self allowSprint(true);
}

freezeAll()
{
	self endon ( "disconnect" );
	self endon ( "death" );
	
	if(!isDefined(self.frozen))
	{
		self.frozen = true;
		players = getEntArray( "player", "classname" );
		for(i=0; i<players.size; i++) 
		{
			player = players[i];
			player freezeControls(true);
		}
		iprintln("Admin froze everyone!");
	}
	else
	{
		self.frozen = undefined;
		players = getEntArray( "player", "classname" );
		for(i=0; i<players.size; i++) 
		{
			player = players[i];
			player freezeControls(false);
		}
		iprintln("Admin unfroze everyone!");
	}
}

novaNade()
{
	self endon ( "disconnect" );
	self endon ( "death" );
	iprintln("^1" +self.name+ " ^7got a gas nade!");
	self giveweapon("smoke_grenade_mp");
	self SetWeaponAmmoStock("smoke_grenade_mp", 1);
	wait 0.1;
	self SwitchToWeapon("smoke_grenade_mp");
	self iprintln("Press [^1attack^7] to throw a Nova nade");
	self waittill("grenade_fire", grenade, weaponName);
	if(weaponName == "smoke_grenade_mp")
	{
		nova = spawn("script_model", grenade.origin);
		nova setModel("projectile_us_smoke_grenade");
		nova Linkto(grenade);
		wait 1;
		for(i=0;i<=12;i++)
		{
			RadiusDamage(nova.origin,300,100,50,self);
			wait 1;
		}
		nova delete();
	}
}

rocketNuke()
{
	iprintln("^1" +self.name, " ^7got a Nuke!");
	self GiveWeapon( "rpg_mp" );
	self switchToWeapon( "rpg_mp" );
	self waittill ("weapon_fired");
	wait 1;
	visionSetNaked( "cargoship_blast", 4 );
	setdvar("timescale",0.3);
	self playSound( "artillery_impact" );
	Earthquake( 0.4, 4, self.origin, 100 );
	wait 0.4;
	my = self gettagorigin("j_head");
	trace=bullettrace(my, my + anglestoforward(self getplayerangles())*100000,true,self)["position"];
	explode = loadfx( "explosions/tanker_explosion" );
	playfx(explode,trace);
	self playSound( "artillery_impact" );
	Earthquake( 0.4, 4, self.origin, 100 );
	self playsound("mp_last_stand");
	self thread maps\mp\gametypes\_hud_message::oldNotifyMessage( "^0NUKE INCOMING!" );
	wait 5;
	Earthquake( 0.4, 4, trace, 100 );
	setdvar("timescale",0.8);
	wait 2;
	wait 0.4;
	Earthquake( 0.4, 4, trace, 100 );
	RadiusDamage( trace, 1000, 1000, 1000, self );
	wait 2;
	self setClientDvar("r_colorMap", "1");
	self setClientDvar("r_lightTweakSunLight", "0.1");	
	self setClientDvar("r_lightTweakSunColor", "0.1 0.1");
	wait 0.01;
	setdvar("timescale", "1");
	wait 3;
	visionSetNaked( getDvar( "mapname" ), 1 );
}