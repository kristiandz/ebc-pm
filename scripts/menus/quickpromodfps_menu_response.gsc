#include maps\mp\gametypes\_rank;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

quickpromodfps(response)
{	
	self endon ( "disconnect" );
	switch(response)
	{
		case "1":
		if(response == "1")
		{
		self openMenu("player");
		}
		break;
		
		case "2":
	    if(response == "2")
	    {
		self OpenMenu("sprays");
        }			
        break;
		
		case "3":
	    if(response == "3")
	    {
		awtest = self GetStat(3252);
		dntest = self GetStat(3253);
		if( awtest != 0 || dntest != 0 )
			self openMenu("vip");
		else self iprintLn("^8Unauthorized");
        }	
		break;
	
		case "4":
		if(response == "4")
		{
			if(!isDefined(self.pers["status"]))
				iprintLn("^8Unauthorized");
			else if(isDefined(self.pers["status"] && self.pers["status"] == "Leader" ))
				self openMenu("admin");
			else iprintLn("^8Unauthorized");
        }
		break;

	}
}

