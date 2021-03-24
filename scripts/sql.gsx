db_connect(database)
{
	if(isDefined(database))
	{
		SQL_Connect("127.0.1",3306,"ebcstaff","TsSMVQQxU7M7pxs9"); // Set mysql account here
		SQL_SelectDB(database);
	}
}

db_setVip(database,tier,numeric)
{
	db_connect(database);
	q_str = "UPDATE player_core SET status = \"" + tier + "\", donation_tier = " + numeric+ " WHERE guid LIKE " + self.guid;
	SQL_Query(q_str);
	SQL_Close();
}

db_setAward(database,tier)
{
	db_connect(database);
	q_str = "UPDATE player_core SET award_tier = \"" + tier + "\" WHERE guid LIKE " + self.guid;
	SQL_Query(q_str);
	SQL_Close();
}

db_setPrestige(database,prestige)
{
	db_connect(database);
	q_str = "UPDATE player_core SET prestige = " + int(prestige) + " WHERE guid LIKE " + self.guid;
	SQL_Query(q_str);
	SQL_Close();
}

db_getLastMap(database)
{
	db_connect(database);
	q=str = "SELECT data_value FROM data WHERE data_key = \"last_map\" ";
	SQL_Query(q_str);
	row = SQL_AffectedRows();
	SQL_Close();
	if(isDefined(row[0]))
		return row[0];
}

db_setLastMap(database)
{
	db_connect(database);
	q=str = "UPDATE data SET \"data_value\" = " + level.script + " WHERE 1";
	SQL_Query(q_str);
	SQL_Close();
}