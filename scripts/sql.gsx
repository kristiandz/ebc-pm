// You can find the table structure @ ebc-b3 source on github

db_connect(database)
{
	if(isDefined(database))
	{
		SQL_Connect("127.0.1",3306,"username","password"); // Set mysql account here
		SQL_SelectDB(database);
	}
}

db_setVip(database,tier,numeric,date)
{
	db_connect(database);
	q_str = "UPDATE player_core SET status = \"" + tier + "\", donation_tier = " + numeric+ ", donation_date = \"" + date + "\" WHERE guid LIKE " + self.guid;
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
	q_str = "UPDATE player_core SET prestige = " + int(prestige) + ", backup_pr = " + int(prestige) + " WHERE guid LIKE " + self.guid;
	SQL_Query(q_str);
	SQL_Close();
}

db_getLastMap(database)
{
	db_connect(database);
	q_str = "SELECT data_value FROM data WHERE data_key = \"last_map\";";
	SQL_Query(q_str);
	row = SQL_FetchRow();
	SQL_Close();
	if(isDefined(row[0]))
		return row[0];
}

db_setLastMap(database)
{
	db_connect(database);
	q_str = "UPDATE data SET data_value = \"" + level.script + "\" WHERE data_key = \"last_map\";";
	SQL_Query(q_str);
	SQL_Close();
}

db_simpleQuery(database,q_str)
{
	db_connect(database);
	SQL_Query(q_str); 
	row = SQL_FetchRow();
	SQL_Close();
	return row;
}
