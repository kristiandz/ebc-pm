main()
{
	mode = toLower( getDvar( "promod_mode" ) );
	if ( !validMode( mode ) )
	{
		mode = "custom_public";
		setDvar( "promod_mode", mode );
	}
	setMode(mode);
}

validMode( mode )
{
	switch ( mode )
	{
		case "custom_public":
		case "strat":
			return true;
	}
	keys = strtok(mode, "_");
	if(keys.size <= 1) return false;
}

monitorMode()
{
	o_mode = toLower( getDvar( "promod_mode" ) );
	o_cheats = getDvarInt( "sv_cheats" );

	for(;;)
	{
		mode = toLower( getDvar( "promod_mode" ) );
		cheats = getDvarInt( "sv_cheats" );

		if ( mode != o_mode )
		{
			if ( isDefined( game["state"] ) && game["state"] == "postgame" )
			{
				setDvar( "promod_mode", o_mode );
				continue;
			}
			if ( validMode( mode ) )
			{
				level notify ( "restarting" );
				iPrintLN( "Changing To Mode: ^1" + mode + "\nPlease Wait While It Loads..." );
				setMode( mode );
				wait 2;
				map_restart( false );
				setDvar( "promod_mode", mode );
			}
			else
			{
				if ( isDefined( mode ) && mode != "" )
					iPrintLN( "Error Changing To Mode: ^1" + mode + "\nSyntax: custom_public, strat" );
				setDvar( "promod_mode", o_mode );
			}
		}
		else if ( cheats != o_cheats )
		{
			map_restart( false );
			break;
		}
		wait 0.1;
	}
}

setMode( mode )
{
	game["CUSTOM_MODE"] = 0;
	game["PROMOD_STRATTIME"] = 5;
	game["PROMOD_KNIFEROUND"] = 0;
	game["SCORES_ATTACK"] = 0;
	game["SCORES_DEFENCE"] = 0;

	if ( mode == "custom_public" && (level.gametype == "sr" || level.gametype == "sd") )
	{
		promod\custom_public::main();
		game["CUSTOM_MODE"] = 1;
		game["PROMOD_MATCH_MODE"] = "pub";
		game["PROMOD_KNIFEROUND"] = getDvarInt("promod_kniferound");
	}
	else if( mode == "custom_public" && (level.gametype != "sr" || level.gametype != "sd") )
	{
		promod\custom_public::main();
		game["CUSTOM_MODE"] = 1;
		game["PROMOD_MATCH_MODE"] = "pub";
		game["PROMOD_KNIFEROUND"] = 0;
	}
	else if ( mode == "strat" )
	{
		promod\custom_public::main();
		game["PROMOD_MATCH_MODE"] = "strat";
		game["PROMOD_KNIFEROUND"] = 0;
		setDvar( "class_specops_limit", 64 );
		setDvar( "class_demolitions_limit", 64 );
		setDvar( "class_sniper_limit", 64 );
	}
}