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

db_verifyConnectedPlayer()
{
		critical_enter_debug("mysql","playerConnect()");
		q_str = "SELECT guid, prestige, backup_pr, season, status, style, award_tier, donation_tier FROM player_core WHERE guid LIKE " + self.guid;
		request = SQL_Query(q_str); 
		AsyncWait(request);
		row = SQL_AffectedRows(request);
		if(row == 0)
		{
			// Clear previous request
			SQL_Free(request);
			name = GetSubStr(self.name, 0, 25);
			atier = self GetStat(3252);
			dtier = self GetStat(3253);
			q_str = "INSERT INTO player_core (guid,name,prestige,backup_pr,season,award_tier,donation_tier) VALUES ("+self.guid+",\""+name+"\","+self.prestige+","+0+",\""+ level.season +"\","+atier+","+dtier+")";
			request = SQL_Query(q_str);
			AsyncWait(request);
			SQL_Free(request);
			critical_leave_debug("mysql");
		}
		else
		{
			row = SQL_FetchRow(request);
			SQL_Free(request);
			critical_leave_debug("mysql");
			self thread maps\mp\gametypes\_globallogic::prcheck(row[1], row[2]);
			self thread maps\mp\gametypes\_globallogic::newseason(row[3]);
			self.pers["status"] = row[4];
			self.pers["design"] = row[5];
			self SetStat(3252, int(row[6]));
			self SetStat(3253, int(row[7]));
			//if(self GetStat(3253) > 0)
			//	self thread checkDonationExpiry(); Not tested yet
		}
}

db_setVip(tier,numeric,date)
{
	critical_enter("mysql");
	q_str = "UPDATE player_core SET status = \"" + tier + "\", donation_tier = " + numeric+ ", donation_date = \"" + date + "\" WHERE guid LIKE " + self.guid;
	request = SQL_Query(q_str);
	AsyncWait(request);
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