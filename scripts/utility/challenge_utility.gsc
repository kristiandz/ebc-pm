// Utility methods for challenges, to keep the response code cleaner and to contain primarily menu responses

getChallengeData(challenge)
{
	// Either as ID or String, in case we need the other data
	switch(challenge)
	{
        case "Ninja":
		case 1:
			data[0] = "Ninja"; // Name
			data[1] = 1; // ID
			data[2] = self GetStat(3121); // Total stat
			data[3] = "Get " + self getstat(3121) + "/" + (5 * (self.prestige+1)) + " stealth kills with a cold weapon"; // Description
			data[4] = "Special Ninja Round must be finished"; // Special round
			data[5] = 5; // Modifier
			/// ...data[6] = "Alternate challenges for category";
			// Stat + 10 is used for total tracking for each category
			return data;
        case "Demolition":
		case 2:
			data[0] = "Demolition";
			data[1] = 2;
			data[2] = self GetStat(3122);
			data[3] = "Get " + self getstat(3122) + "/" + (3 * (self.prestige+1)) + " explosive kills";
			data[4] = "Special Demolition Round must be finished";
			data[5] = 3;
			return data;
		case "Hitman":
		case 3:
			data[0] = "Hitman";
			data[1] = 3;
			data[2] = self GetStat(3123);
			data[3] = "Get " + self getstat(3123) + "/" + (5 * (self.prestige+1)) + " clean headshots";
			data[4] = "Special Hitman Round must be finished";
			data[5] = 5;
			return data;
		case "Juggernaut":
		case 4:
			data[0] = "Juggernaut";
			data[1] = 4;
			data[2] = self GetStat(3124);
			data[3] =  "Get " + self getstat(3124) + "/" + (3 * (self.prestige+1)) + " kills while hurt";
			data[4] = "Special Juggernaut Round must be finished";
			data[5] = 3;
			return data;
		case "Daredevil":
		case 5:
			data[0] = "Daredevil";
			data[1] = 5;
			data[2] = self GetStat(3125);
			data[3] = "Get " + self getstat(3125) + "/" + (5 * (self.prestige+1)) + " kills in the first 15 seconds in total";
			data[4] = "Special Daredevil Round must be finished";
			data[5] = 5;
			return data;
		case "Weirdo":
		case 6:
			data[0] = "Weirdo";
			data[1] = 6;
			data[2] = self GetStat(3126);
			data[3] = "Teabag " + self getstat(3126) + "/" + (10 * (self.prestige+1)) + " dead bodies";
			data[4] = "Special Weirdo Round must be finished";
			data[5] = 10;
			return data;
		case "Assault":
		case 7:
			data[0] = "Assault";
			data[1] = 7;
			data[2] = self GetStat(3127);
			data[3] = "Get " + self getstat(3127) + "/" + (10 * (self.prestige+1)) + " kills with assaults rifles";
			data[4] = "Special Assault Round must be finished";
			data[5] = 10;
			return data;
		case "Tactician":
		case 8:
			data[0] = "Tactician";
			data[1] = 8;
			data[2] = self GetStat(3128);
			data[3] = "Get " + self getstat(3128) + "/" + (3 * (self.prestige+1)) + " kills while last standing";
			data[4] = "Special Tactician Round must be finished";
			data[5] = 3;
			return data;
		case "Trickster":
		case 9:
			data[0] = "Trickster";
			data[1] = 9;
			data[2] = self GetStat(3129);
			data[3] = "Make " + self getstat(3129) + "/" + (2 * (self.prestige+1)) + " attractive kills";
			data[4] = "Special Trickster Round must be finished";
			data[5] = 2;
			return data;
		default:
			// Prevent undefines
			data[0] = "";
			data[1] = 0;
			data[2] = 0;
			data[3] = "";
			data[4] = "";
			data[5] = 0;
			return data;
	}
}

isChallengeCompleted(challenge)
{
	data = getChallengeData(challenge);
	// Challenge must be defined
	if(data[1] == 0)
		return false;
	// If current is lesser than goal value but not total
	if(data[2] < (self.prestige * data[5]))
		return false;
	else
		return true;
}

canActivateChallenge(challenge)
{
	if(level.challengeActive || isDefined(self.pers["challengeCooldown"]))
		return 1;
	if(level.gametype != "sd" && level.gametype != "sr")
		return 2;
	if(maps\mp\gametypes\_globallogic::getTimeRemaining() < 70000)
		return 3;
	if(!isChallengeCompleted(challenge))
		return 4;
	// If all conditionas are met, return 0 to allow the challenge activation
	return 0;
}

getActivationQueue()
{
	// Do we need a queue if multiple players want to start the challenge or do we simply lock it out if started
	// If so, notify the player round by round that his challenge is starting etc.
}