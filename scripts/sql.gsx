init()
{
	// Start GSCLIB and connect to the database.
	GSCLIB_Init();
	SQL_Connect("127.0.0.1",3306,"username","password"); // Fill in your SQL account information here
	SQL_SelectDB("databaseName"); // Fill in the name of your SQL database 
	critical("mysql");
}

critical(id)
{
	CriticalSection(id);
}

critical_enter(id)
{
	while (!EnterCriticalSection(id))
		wait 0.05;
}

critical_leave(id)
{
	LeaveCriticalSection(id);
}

AsyncWait(request)
{
	status = AsyncStatus(request);
	while (status <= 1)
	{
		wait 0.05;
		status = AsyncStatus(request);
	}
	return status;
}

// You can find the table structure @ ebc-b3 source on github

db_setVip(tier,numeric,date)
{
	critical_enter("mysql");
	q_str = "UPDATE player_core SET status = \"" + tier + "\", donation_tier = " + numeric+ ", donation_date = \"" + date + "\" WHERE guid LIKE " + self.guid;
	request = SQL_Query(q_str);
	status = AsyncWait(request);
	SQL_Free(request);
	critical_leave("mysql");
}

db_setAward(tier)
{
	critical_enter("mysql");
	q_str = "UPDATE player_core SET award_tier = \"" + tier + "\" WHERE guid LIKE " + self.guid;
	request = SQL_Query(q_str);
	AsyncWait(request);
	SQL_Free(request);
	critical_leave("mysql");
}

db_setPrestige(prestige)
{
	critical_enter("mysql");
	q_str = "UPDATE player_core SET prestige = " + int(prestige) + ", backup_pr = " + int(prestige) + " WHERE guid LIKE " + self.guid;
	request = SQL_Query(q_str);
	AsyncWait(request);
	SQL_Free(request);
	critical_leave("mysql");
}

db_getLastMap()
{
	critical_enter("mysql");
	q_str = "SELECT data_value FROM data WHERE data_key = \"last_map\";";
	request = SQL_Query(q_str);
	AsyncWait(request);
	row = SQL_FetchRow(request);
	SQL_Free(request);
	critical_leave("mysql");
	if(isDefined(row[0]))
		return row[0];
}

db_setLastMap()
{
	critical_enter("mysql");
	q_str = "UPDATE data SET data_value = \"" + level.script + "\" WHERE data_key = \"last_map\";";
	request = SQL_Query(q_str);
	AsyncWait(request);
	SQL_Free(request);
	critical_leave("mysql");
}

db_logFlag(admin, player)
{
	critical_enter("mysql");
	cur = getRealTime();
	time = TimeToString(cur, 1, "%c");
	q_str = "INSERT INTO flag_log (guid, name, admin_guid, time) VALUES ( \"" + player.guid + "\", \"" + player.name + "\", " + admin.guid + ", \"" + time + "\");";
	request = SQL_Query(q_str);
	AsyncWait(request);
	SQL_Free(request);
	critical_leave("mysql");
	thread scripts\utility\common::log("flag_log", player.name + " (" + player.guid + ") got evade flagged by " + admin.name + " (" + admin.guid + ") on " + time );
}

db_setFlag(flagLevel)
{
	critical_enter("mysql");
	q_str = "UPDATE player_core SET flag = " + flagLevel + " WHERE guid = \"" + self.guid + "\";";
	request = SQL_Query(q_str);
	AsyncWait(request);
	SQL_Free(request);
	critical_leave("mysql");
}

db_simpleQuery(q_str)
{
	critical_enter("mysql");
	request = SQL_Query(q_str); 
	row = SQL_FetchRow();
	AsyncWait(request);
	SQL_Free(request);
	critical_leave("mysql");
	return row;
}