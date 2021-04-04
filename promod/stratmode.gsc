main()
{
	precacheItem( "radar_mp" );
	thread onPlayerConnect();
	thread createServerHUD();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connecting", player);
		player thread nadeTraining();
		player thread createHUD();
		player thread monitorKeys();
			player thread bots();
	}
}

bots()
{
	self endon("disconnect");

	self thread spawnthing();
	lastWeapon = undefined;

	for(;;)
	{
		if ( self getCurrentWeapon() != "radar_mp" )
			lastWeapon = self getCurrentWeapon();

		if ( self getCurrentWeapon() == "radar_mp" && ( ( !isDefined(self.inAction) || !self.inAction) && self isOnGround() ) )
		{
			self SwitchToWeapon( lastWeapon );

			origin = self getOrigin();
			angles = self getPlayerAngles();
			self.inAction = true;

			if(isDefined(self.bot))
			{
				wait 0.55;

				if ( distanceSquared( self.origin, origin ) < 4096 )
				{
					self iprintln("Move away to spawn dummy!");

					while ( distanceSquared( self.origin, origin ) < 4096 )
						wait 0.05;
				}

				self.bot setOrigin( origin );
				self.bot SetPlayerAngles( angles );
			}
			else
			{
				newBot = addTestClient();

				wait 0.05;

				if(isdefined(newBot))
				{
					wait 0.5;

					if ( distanceSquared( self.origin, origin ) < 4096 )
					{
						self iprintln("Move away to spawn dummy!");

						while ( distanceSquared( self.origin, origin ) < 4096 )
							wait 0.05;
					}

					newBot.pers["isBot"] = true;
					self.bot = newBot;
					while( !isDefined( newBot.pers ) || !isDefined( newBot.pers["team"] ) )
						wait 0.05;
					newBot notify( "menuresponse", game["menu_team"], self.pers["team"] );
					while(newBot.pers["team"] != "axis" && newBot.pers["team"] != "allies")
						wait 0.05;
					newBot notify( "menuresponse", game["menu_changeclass_" + newBot.pers["team"] ], "assault" );
					while(!isDefined(newBot.pers["class"]))
						wait 0.05;
					newBot notify( "menuresponse", game["menu_changeclass"], "go" );
					while(!isAlive(newBot))
						wait 0.05;

					newBot SetMoveSpeedScale( 0 );
					newBot freezeControls( true );
					newBot setOrigin( origin );
					newBot SetPlayerAngles( angles );
					newBot.maxhealth = 999999999;
					newBot.health = newBot.maxhealth;
					self.hint6 setText( "Move: Press ^3[{+actionslot 1}]" );
				}
				else
					self iprintln("Couldn't add bot, server full?");
			}
			self.inAction = false;
		}

		wait 0.05;
	}
}

spawnthing()
{
	self endon("disconnect");

	for(;;)
	{
		if(!self HasWeapon("radar_mp"))
		{
			self SetActionSlot( 1, "weapon", "radar_mp" );
			self giveWeapon("radar_mp");
		}
		wait 0.5;
	}
}

monitorKeys()
{
	self endon("disconnect");
	for(;;)
	{
		wait 0.05;

		if ( self.sessionstate != "playing" )
			continue;
		if ( self useButtonPressed() && !self meleeButtonPressed() )
		{
			useButtonTime = 0;
			while ( self useButtonPressed() && !self meleeButtonPressed() )
			{
				useButtonTime += 0.05;
				wait 0.05;
			}
			if ( useButtonTime > 0.5 || !useButtonTime )
				continue;
			for ( i = 0; i < 0.5; i += 0.1 )
			{
				wait 0.1;
				if ( self useButtonPressed() && !self meleeButtonPressed() )
				{
					loadPos();
					break;
				}
			}
		}
		if ( self meleeButtonPressed() && !self useButtonPressed() )
		{
			meleeButtonTime = 0;
			while ( self meleeButtonPressed() && !self useButtonPressed() )
			{
				meleeButtonTime += 0.05;
				wait 0.05;
			}
			if ( meleeButtonTime > 0.5 || !meleeButtonTime )
				continue;

			for ( i = 0; i < 0.5; i += 0.1 )
			{
				wait 0.1;

				if ( self meleeButtonPressed() && !self useButtonPressed() )
				{
					savePos();
					break;
				}
			}
		}

		if ( self meleeButtonPressed() || self useButtonPressed() )
		{
			wait 0.1;
			bothButtonTime = 0;
			while ( bothButtonTime < 0.5 && self meleeButtonPressed() && self useButtonPressed() )
			{
				bothButtonTime += 0.05;
				wait 0.05;
			}
			if ( bothButtonTime > 0.35 )
			{
				if ( !isDefined( self.nofly ) )
				{
					self.nofly = true;
					self.hint1 setText( "Enable: Hold ^1[{+melee}] ^7+ ^1[{+activate}]" );
					self.hint2.color = (0.5, 0.5, 0.5);
					self.hint3.color = (0.5, 0.5, 0.5);
				}
				else
				{
					self.nofly = undefined;
					self.hint1 setText( "Disable: Hold ^1[{+melee}] ^7+ ^1[{+activate}]" );
					self.hint2.color = (0.8, 1, 1);
					self.hint3.color = (0.8, 1, 1);
				}
			}
			while ( self meleeButtonPressed() && self useButtonPressed() )
				wait 0.05;
		}
	}
}

loadPos()
{
	self endon( "disconnect" );
	if ( !isDefined( self.savedorg ) )
		self iprintln("No Previous Position Saved");
	else
	{
		self freezecontrols( true );
		wait 0.05;
		self setOrigin( self.savedorg );
		self SetPlayerAngles ( self.savedang );
		self freezecontrols( false );
		self iprintln("Position Loaded");
	}
}

savePos()
{
	if ( !self isOnGround() )
		return;
	self.savedorg = self.origin;
	self.savedang = self GetPlayerAngles();
	self iprintln("Position Saved");
}

nadeTraining()
{
	self endon( "disconnect" );
	for(;;)
	{
		self waittill ( "grenade_fire", grenade, weaponName );
		grenades = getentarray("grenade","classname");
		for ( i = 0; i < grenades.size; i++ )
		{
			self giveWeapon( weaponName );
			self setWeaponAmmoClip( weaponName, 1 );
			if ( isDefined( grenades[i].origin ) && !isDefined( self.flying ) && !isDefined( self.nofly ) )
			{
				if ( distance( grenades[i].origin, self.origin ) < 140 )
				{
					self.flying = true;
					grenades[i] thread nadeFlying( self, weaponName );
				}
			}
		}
		wait 0.1;
	}
}

nadeFlying( player, weaponName )
{
	player endon( "disconnect" );
	time = 3;
	if ( weaponName == "frag_grenade_mp" )
		time = 3;
	else if ( weaponName == "flash_grenade_mp" )
		time = 1.5;
	else
		time = 1;

	old_player_origin = player.origin;
	player.flyobject = spawn( "script_model", player.origin );
	player.flyobject linkto( self );
	player linkto( player.flyobject );
	stop_flying = false;
	return_flying = false;

	while ( isDefined( self ) )
	{
		if ( player attackButtonPressed() )
		{
			stop_flying = true;
			break;
		}
		if ( player useButtonPressed() )
		{
			return_flying = true;
			break;
		}
		wait 0.05;
	}
	if ( stop_flying || return_flying )
		wait 0.1;
	else
	{
		for ( i = 0; i < time - 0.5; i += 0.1 )
		{
			wait 0.1;

			if ( player useButtonPressed() )
				break;
		}
	}
	player.flyobject unlink();
	if ( stop_flying )
	{
		for ( i = 0; i < time + 0.4; i += 0.1 )
		{
			wait 0.1;

			if ( player useButtonPressed() )
				break;
		}
	}
	player.flyobject moveto( old_player_origin, 0.1 );
	wait 0.2;
	player unlink();
	player.flying = undefined;

	if ( isDefined( player.flyobject ) )
		player.flyobject delete();
}

createHUD()
{
	self.hint1 = newClientHudElem(self);
	self.hint1.x = -7;
	self.hint1.y = 69;
	self.hint1.horzAlign = "right";
	self.hint1.vertAlign = "top";
	self.hint1.alignX = "right";
	self.hint1.alignY = "middle";
	self.hint1.fontScale = 1.4;
	self.hint1.font = "default";
	self.hint1.color = (1, 0.8, 0.8);
	self.hint1.hidewheninmenu = true;
	self.hint1 setText( "Disable: Hold ^1[{+melee}] ^7+ ^1[{+activate}]" );

	self.hint2 = newClientHudElem(self);
	self.hint2.x = -7;
	self.hint2.y = 86;
	self.hint2.horzAlign = "right";
	self.hint2.vertAlign = "top";
	self.hint2.alignX = "right";
	self.hint2.alignY = "middle";
	self.hint2.fontScale = 1.4;
	self.hint2.font = "default";
	self.hint2.color = (1, 0.8, 0.8);
	self.hint2.hidewheninmenu = true;
	self.hint2 setText( "Stop: Press ^1[{+attack}]" );

	self.hint3 = newClientHudElem(self);
	self.hint3.x = -7;
	self.hint3.y = 102;
	self.hint3.horzAlign = "right";
	self.hint3.vertAlign = "top";
	self.hint3.alignX = "right";
	self.hint3.alignY = "middle";
	self.hint3.fontScale = 1.4;
	self.hint3.font = "default";
	self.hint3.color = (1, 0.8, 0.8);
	self.hint3.hidewheninmenu = true;
	self.hint3 setText( "Return: Press ^1[{+activate}]" );

	self.hint4 = newClientHudElem(self);
	self.hint4.x = -7;
	self.hint4.y = 145;
	self.hint4.horzAlign = "right";
	self.hint4.vertAlign = "top";
	self.hint4.alignX = "right";
	self.hint4.alignY = "middle";
	self.hint4.fontScale = 1.4;
	self.hint4.font = "default";
	self.hint4.color = (1, 0.8, 0.8);
	self.hint4.hidewheninmenu = true;
	self.hint4 setText( "Save: Press ^1[{+melee}] ^7twice" );

	self.hint5 = newClientHudElem(self);
	self.hint5.x = -7;
	self.hint5.y = 161;
	self.hint5.horzAlign = "right";
	self.hint5.vertAlign = "top";
	self.hint5.alignX = "right";
	self.hint5.alignY = "middle";
	self.hint5.fontScale = 1.4;
	self.hint5.font = "default";
	self.hint5.color = (1, 0.8, 0.8);
	self.hint5.hidewheninmenu = true;
	self.hint5 setText( "Load: Press ^1[{+activate}] ^7twice" );
	
	self.hint6 = newClientHudElem(self);
	self.hint6.x = -7;
	self.hint6.y = 200;
	self.hint6.horzAlign = "right";
	self.hint6.vertAlign = "top";
	self.hint6.alignX = "right";
	self.hint6.alignY = "middle";
	self.hint6.fontScale = 1.4;
	self.hint6.font = "default";
	self.hint6.color = (1, 0.8, 0.8);
	self.hint6.hidewheninmenu = true;

	if(!getDvarInt( "sv_punkbuster" ))
		self.hint6 setText( "Spawn: Press ^1[{+actionslot 1}]" );
	else
	{
		self.hint6 setText( "Spawn: Disable Punkbuster" );
		self.hint6.color = (0.5, 0.5, 0.5);
	}
}

createServerHUD()
{
	header = newHudElem();
	header.x = -7;
	header.y = 15;
	header.horzAlign = "right";
	header.vertAlign = "top";
	header.alignX = "right";
	header.alignY = "middle";
	header.fontScale = 1.4;
	header.font = "default";
	header.color = (1, 0.7, 0.7);
	header.hidewheninmenu = true;
	header setText( "Promod Live V3.00 EU ^1Strat Mode" );
	
	nadetraining = newHudElem();
	nadetraining.x = -7;
	nadetraining.y = 50;
	nadetraining.horzAlign = "right";
	nadetraining.vertAlign = "top";
	nadetraining.alignX = "right";
	nadetraining.alignY = "middle";
	nadetraining.fontScale = 1.4;
	nadetraining.font = "default";
	nadetraining.color = (1, 0.8, 0.8);
	nadetraining.hidewheninmenu = true;
	nadetraining setText( "Nadetraining" );
	
	line1 = newHudElem();
	line1.x = 10;
	line1.y = 58;
	line1.horzAlign = "right";
	line1.vertAlign = "top";
	line1.alignX = "right";
	line1.alignY = "middle";
	line1.color =  (1, 0.8, 0.8);
	line1.hidewheninmenu = true;
	line1 setShader( "line_horizontal", 185, 2 );
	line1.alpha =1;
	
	line2 = newHudElem();
	line2.x = 10;
	line2.y = 134;
	line2.horzAlign = "right";
	line2.vertAlign = "top";
	line2.alignX = "right";
	line2.alignY = "middle";
	line2.color =  (1, 0.8, 0.8);
	line2.hidewheninmenu = true;
	line2 setShader( "line_horizontal", 185, 2 );
	line2.alpha =1;
	
	position = newHudElem();
	position.x = -7;
	position.y = 126;
	position.horzAlign = "right";
	position.vertAlign = "top";
	position.alignX = "right";
	position.alignY = "middle";
	position.fontScale = 1.4;
	position.font = "default";
	position.color = (1, 0.8, 0.8);
	position.hidewheninmenu = true;
	position setText( "Position" );
}