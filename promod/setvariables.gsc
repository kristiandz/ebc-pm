main()
{
	setDvar( "bg_bobMax", 0 );
	setDvar( "player_sustainAmmo", 0 );
	setDvar( "player_throwBackInnerRadius", 0 );
	setDvar( "player_throwBackOuterRadius", 0 );
	setDvar( "loc_warnings", 0 );

	game["allies_assault_count"] = 0;
	game["allies_specops_count"] = 0;
	game["allies_demolitions_count"] = 0;
	game["allies_sniper_count"] = 0;

	game["axis_assault_count"] = 0;
	game["axis_specops_count"] = 0;
	game["axis_demolitions_count"] = 0;
	game["axis_sniper_count"] = 0;
}