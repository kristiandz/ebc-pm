init()
{
	switch(game["allies"])
	{
		case "sas":
			setdvar("g_TeamIcon_Allies", "faction_128_sas");
			setdvar("g_TeamColor_Allies", "0.85 0.25 0.25");
			setdvar("g_ScoresColor_Allies", "0.85 0.25 0.25");
			break;

		default:
			setdvar("g_TeamIcon_Allies", "faction_128_usmc");
			setdvar("g_TeamColor_Allies", "0.85 0.25 0.25");
			setdvar("g_ScoresColor_Allies", "0.85 0.25 0.25");
			break;
	}

	switch(game["axis"])
	{
		case "russian":
			setdvar("g_TeamIcon_Axis", "faction_128_ussr");
			setdvar("g_TeamColor_Axis", "0.55 0.55 0.55");
			setdvar("g_ScoresColor_Axis", "0.3 0.3 0.3");
			break;

		default:
			setdvar("g_TeamIcon_Axis", "faction_128_arab");
			setdvar("g_TeamColor_Axis", "0.55 0.55 0.55");
			setdvar("g_ScoresColor_Axis", "0.3 0.3 0.3");
			break;
	}

	if(game["attackers"] == "allies" && game["defenders"] == "axis")
	{
		setdvar("g_TeamName_Allies", "Attack");
		setdvar("g_TeamName_Axis", "Defence");
	}
	else
	{
		setdvar("g_TeamName_Allies", "Defence");
		setdvar("g_TeamName_Axis", "Attack");
	}
	setdvar("g_ScoresColor_Spectator", "0.25 0.25 0.25");
	setdvar("g_ScoresColor_Free", "0.76 0.78 0.1");
	setdvar("g_teamColor_MyTeam", "0.6 0.8 0.6" );
	setdvar("g_teamColor_EnemyTeam", "0.25 0.25 0.85" );
}