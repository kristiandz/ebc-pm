#include scripts\utility\challenge_utility;

prestige(response)
{
	self endon("disconnect");
	// Handle the menu responses
	switch(response)
	{
		// Challenge selection, two challenges to be selected
        case "ninja":
			self setChallenge("Ninja");
			break;
        case "demolition":
			self setChallenge("Demolition");
			break;
		case "hitman":
			self setChallenge("Hitman");
			break;
		case "juggernaut":
			self setChallenge("Juggernaut");
			break;
		case "daredevil":
			self setChallenge("Daredevil");
			break;
		case "weirdo":
			self setChallenge("Weirdo");
			break;
		case "assault":
			self setChallenge("Assault");
			break;
		case "tactician":
			self setChallenge("Tactician");
			break;
		case "trickster":
			self setChallenge("Trickster");
			break;
		// Challenge activation
		case "selection_1":
			self activateChallenge(response);
			break;
		case "selection_2":
			self activateChallenge(response);
			break;
		// Controls for challenges and prestiges 
		case "prestige_up":
			self prestigeUp();
			break;
		case "prestige_reset":
			if(self GetStat(3110) == 1)
				self prestigeReset();
			else
				self iprintln("Reset is locked, use the toggle button!");
			break;
		case "challenge_reset":
			if(self GetStat(3110) == 1)
				self resetChallenges();
			else
				self iprintln("Reset is locked, use the toggle button!");
			break;
		case "reset_lock_toggle":
			self toggleResetLock();
			break;
	}
}

setChallenge(challenge)
{
	challenge_1 = self GetStat(3117);
	challenge_2 = self GetStat(3118);
	// Returns challenge array
	selectedChallenge = getChallengeData(challenge);

	// Set the challenges
	if(challenge_1 == 0 && challenge_2 == 0)
	{
		self SetStat(3117, selectedChallenge[1]);
		self setClientDvar("ui_challenge_1", challenge);
		self setClientDvar("ui_challenge_stats_1", selectedChallenge[3]);
		self setClientDvar("ui_challenge_stats_2", selectedChallenge[4]);
		self iprintln("Challenge selected: " + challenge);
	}
	else if(challenge_1 != 0 && challenge_2 == 0 && (selectedChallenge[1] != challenge_1))
	{
		self SetStat(3118, selectedChallenge[1]);
		self setClientDvar("ui_challenge_2", challenge);
		self setClientDvar("ui_challenge_stats_3", selectedChallenge[3]);
		self setClientDvar("ui_challenge_stats_4", selectedChallenge[4]);
		self iprintln("Challenge selected: " + challenge);
	}
	else
		return;
	
	// Dump the stats to DB and change the stat ids 
}

activateChallenge(challenge)
{
	// Check the activation conditions
	switch(canActivateChallenge(challenge))
	{
		case 1:
			self iprintln("Challenge ^8cooldown ^7active or another challenge already in progress");
			return;
		case 2:
			self iprintln("Challenge can be only started for ^8Search and Destroy^7 or ^8Search and Rescue ^7gametypes");
			return;
		case 3:
			self iprintln("Not enough ^8time ^7to start the challenge, at least^8 70 ^7seconds is required");
			return;
		case 4:
			self iprintln("Special round cannot be started untill the ^8challenge ^7requirement is not ^8completed^7!");
			return;
	}
	iprintlnBold("Challenge round activated for: ^8" + self.name);
	// Handle the activation for each response
	switch(challenge)
	{
        case "ninja":
			self thread scripts\challenges::challengeRoundNinja();
			break;
        case "demolition":
			self thread scripts\challenges::challengeRoundDemolition();
			break;
		case "hitman":
			self thread scripts\challenges::challengeRoundHitman();
			break;
		case "juggernaut":
			self thread scripts\challenges::challengeRoundJuggernaut();
			break;
		case "daredevil":
			self thread scripts\challenges::challengeRoundDaredevil();
			break;
		case "weirdo":
			self thread scripts\challenges::challengeRoundWeirdo();
			break;
		case "assault":
			self thread scripts\challenges::challengeRoundAssault();
			break;
		case "tactician":
			self thread scripts\challenges::challengeRoundTactician();
			break;
		case "trickster":
			self thread scripts\challenges::challengeRoundTrickster();
			break;
	}
	// Lock new challenges for the round, this is reset on Callback_StartGameType()
	level.challengeActive = true;
	// Lock the challenge reactivation for the map and that person
	self.pers["challengeCooldown"] = true;
}

resetChallenges()
{
	// Reset both challenges and open up activation
	self SetStat(3117, 0);
	self setClientDvar("ui_challenge_stats_1", "");
	self setClientDvar("ui_challenge_stats_2", "");
	self SetStat(3118, 0);
	self setClientDvar("ui_challenge_stats_3", "");
	self setClientDvar("ui_challenge_stats_4", "");
	self iprintln("You have reset your challenges, select new challenges again!");
	// Reset the challenge stats
	self SetStat(3121,0);
	self SetStat(3122,0);
	self SetStat(3123,0);
	self SetStat(3124,0);
	self SetStat(3125,0);
	self SetStat(3126,0);
	self SetStat(3127,0);
	self SetStat(3128,0);
	self SetStat(3129,0);
	// Reset the lock right away
	self toggleResetLock();
}

prestigeUp()
{
	if(isChallengeCompleted(self Getstat(3117)) && isChallengeCompleted(self GetStat(3118)))
	{
		self iprintln("Challenges completed");
		if(self maps\mp\gametypes\_rank::canPrestigeUp())
		{
			guid = self.guid; // Just in case if the client disconnects that we can update the database
			temp = self getStat(2326) + 1; //
			cur = getRealTime();
			time = TimeToString(cur, 1, "%c");
			resetChallenges();
			self scripts\_missions::challengeSplashNotify("Prestige " + temp, "Entered new prestige level");
			self maps\mp\gametypes\_rank::prestigeUp();
			thread scripts\sql::db_prestigeMenuUpdate(temp, guid, self.name, time);
			thread scripts\utility\common::log("prestige_log_"+level.season, self.name + " (" + guid + ") " + "entered prestige: " + temp ); // Remove after SQL Logging is tested
		}
		else
			self iprintln("You have to reach max level before entering a new prestige level!");
	}
	else
		self iprintln("First complete the challenges to be able to prestige up!");
}

prestigeReset()
{
	self iprintln("Prestige levels fully reset!");
	self toggleResetLock();
	// Keep skins ? 
	self maps\mp\gametypes\_rank::resetEverything();
}

toggleResetLock()
{
	// Lock reset buttons to prevent accidental resets, locked by default
	reset_lock = self GetStat(3110);
	if(reset_lock == 0)
	{
		self iprintln("Reset buttons unlocked!");
		self SetStat(3110, 1);
	}
	else if (reset_lock == 1)
	{
		self iprintln("Reset buttons locked!");
		self SetStat(3110, 0);
	}
}