init() 
{
	level.callbackPermission = ::hasPermission;
}

hasPermission(permission) 
{
	if(!isDefined(self.pers["status"]))
	{
		waittillframeend;
		if(!isDefined(self.pers["status"]))
			return false;
	}
	if(self scripts\utility\common::isDev())
		return true;
	all = getPermissions();
	if(!isDefined(all))
		return false;
	myperms = all[self.pers["status"]];		
	if(!isDefined(myperms))
		return false;	
	if(myperms == "*")
		return true;
	return isSubStr(myperms,permission);
}

getPermissions() 
{
	permission = [];
	permission["Leader"] = "*";
	permission["Senior"] = "Member,Senior";
	permission["Member"] = "Member";
	permission["VIP3"] = "VIP1,VIP2,VIP3";
	permission["VIP2"] = "VIP2,VIP1";
	permission["VIP1"] = "VIP1";
	permission["default"] = "";
	return permission;
}

// TODO: Since we are setting the status upon each connect in globallogic, make a simple status check for utility\common and apply it where needed, remove this callback.