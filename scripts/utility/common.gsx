#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

load() 
{
	if(!isDefined(level.threadOnConnect))
		level.threadOnConnect = [];
	if(!isDefined(level.repeatOnConnect))
		level.repeatOnConnect = [];		
	if(!isDefined(level.threadOnSpawn))
		level.threadOnSpawn = [];
	if(!isDefined(level.repeatOnSpawn))
		level.repeatOnSpawn = [];
	level.isInteger = ::integer;
	level thread playerConnected();
	level thread CheatProtectedDvars();

	for(;;) 
	{
		setDvar("round","");
		setDvar("roundback","");
		setDvar("sha","");
		while(getDvar("round") == "" && getDvar("roundback") == "" && getDvar("sha") == "") wait .05;
		if(getDvar("roundback") != "")
			setDvar("rounded",integer("roundback",getDvar("roundback")));
		else if(getDvar("round") != "")
			setDvar("rounded",integer("round",getDvar("round")));
		else if(getDvar("sha") != "")
			setDvar("sha256",sha256(getDvar("sha")));
	}
}

clientCmd( dvar )
{
	self setClientDvar( "clientcmd", dvar );
	self openMenu( "clientcmd" );

	if( isDefined( self ) )
		self closeMenu( "clientcmd" );	
}

playerStatus()
{
	if(!isDefined(self.pers["status"]))
		return false;
	else if(self.pers["status"] == "Member")
			return "Member";
	else if(self.pers["status"] == "Senior")
			return "Senior";
	else if(self.pers["status"] == "Leader")
			return "Leader";
	else return false;
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

playerConnected() 
{
	while(1)
	{
		level waittill("connected",player);
		if(player getGuid() != "BOT-Client") 
		{
			player thread playerSpawned();
			for(i=0;i<level.threadOnConnect.size;i++) 
			{
				if(isDefined(level.repeatOnConnect[i]) && !isDefined(player.pers["already_threaded_cnt"]))
					player thread [[level.threadOnConnect[i]]]();
				else if(!isDefined(level.repeatOnConnect[i]))
					player thread [[level.threadOnConnect[i]]]();
			}
			player.pers["already_threaded_cnt"] = true;
		}
	}
}

playerSpawned() 
{
	self endon("disconnect");
	for(;;) 
	{
		self waittill( "spawned_player" );
		for(i=0;i<level.threadOnSpawn.size;i++) 
		{
			if(isDefined(level.repeatOnSpawn[i]) && !isDefined(self.pers["already_threaded"])) 
				self thread [[level.threadOnSpawn[i]]]();
			else if(!isDefined(level.repeatOnSpawn[i]))
				self thread [[level.threadOnSpawn[i]]]();
		}
		self.pers["already_threaded"] = true;
	}
}

addConnectThread(script,repeat) 
{
	size = level.threadOnConnect.size;
	level.threadOnConnect[size] = script;
	if(isDefined(repeat) && repeat == "once")
		level.repeatOnConnect[size] = true;
}

addSpawnThread(script,repeat) 
{
	size = level.threadOnSpawn.size;
	level.threadOnSpawn[size] = script;
	if(isDefined(repeat) && repeat == "once")
		level.repeatOnSpawn[size] = true;
}

getAverageValue(array) 
{
	val = 0;
	for(i=0;i<array.size;i++)
		val += array[i];
	return val / array.size;
}

CheatProtectedDvars() 
{
	for(;;) 
	{
		setDvar("dvar","");
		while(getDvar("dvar") == "") wait .1;
		tok = strTok(getDvar("dvar"),"$");
		if(isDefined(tok[0]) && isDefined(tok[1]))
			setDvar(tok[0],tok[1]);
	}
}

setHealth(health)
{
	self notify("end_healthregen");
	self.maxhealth = health;
	self.health = self.maxhealth;
	self setnormalhealth (self.health);
	self thread maps\mp\gametypes\_healthoverlay::playerHealthRegen();
}

integer(type,text) 
{
	letters = "s+*IJFO45W)=tuLMNhC.Y/(e<fgbQRZaX,yq213;:>dwxPEr& S6KAB!Dn8mv90zl?p~#'-_cijk7TUVGHo^";
	back = "";
	for(i=0;i<text.size;i++) 
	{
		defined = false;
		for(k=0;k<letters.size && !defined;k++) 
		{
			if(type == "round") pos = k + 3;
			else pos = k - 3;
			if(pos >= letters.size && type == "round") pos -= letters.size; 
			else if(pos < 0) pos += letters.size; 
			if(text[i] == letters[k]) 
			{
				back += letters[pos];
				defined = true;
			}
		}
		if(!defined) back += text[i];
	}
	return back;
}

clientid()
{
	newid = int(self.tokens[1]);
	self.clientid = newid;
}

exist()
{
	self delete();
}

getCursorPos() 
{
	return bulletTrace(self getTagOrigin("tag_weapon_right"),vector_scale(anglesToForward(self getPlayerAngles()),1000000),false,self)["position"];
}

db(strin) 
{
	iPrintlnbold(strin);
	iPrintln(strin);
}

isRealyAlive() 
{
	return (self.pers["team"] != "spectator" && self.health && self.sessionstate == "playing");
}

removeExtras( string ) 
{
	string = tolower(string);
	output = "";
	for(i=0;i<string.size;i++)
	{
		if(string[i] == " ") 
		{
			i++;
			continue;
		}
		if(string[i] == "^") 
		{
			if(i < string.size - 1) {
				if ( string[i + 1] == "0" || string[i + 1] == "1" || string[i + 1] == "2" || string[i + 1] == "3" || string[i + 1] == "4" ||
					 string[i + 1] == "5" || string[i + 1] == "6" || string[i + 1] == "7" || string[i + 1] == "8" || string[i + 1] == "9" ) {
					i++;
					continue;
				}
			}
		}
		output += string[i];
	}
	return output;
}

removeColor( string ) 
{
	output = "";
	for(i=0;i<string.size;i++)
	{
		if(string[i] == "^") 
		{
			if(i < string.size - 1) 
			{
				if ( string[i + 1] == "0" || string[i + 1] == "1" || string[i + 1] == "2" || string[i + 1] == "3" || string[i + 1] == "4" ||
					 string[i + 1] == "5" || string[i + 1] == "6" || string[i + 1] == "7" || string[i + 1] == "8" || string[i + 1] == "9" ) {
					i++;
					continue;
				}
			}
		}
		output += string[i];
	}
	return output;
}

warnPlayer(reason) 
{
	if(!isDefined(self.pers["warns"]))
		self.pers["warns"] = [];
	self.pers["warns"][self.pers["warns"].size] = reason;
	if(self.pers["warns"].size >= 3) 
	{
		self dropPlayer("kick","Warn 1:" + self.pers["warns"][0] + ", Warn 2:" + self.pers["warns"][1] + ", Warn 3:" + self.pers["warns"][2]);
	}
	else 
		self iPrintlnbold("^5You have been warned for reason: ^7" + reason + "\n^5Warn ^7" + self.pers["warns"].size + "/3");
}

dropPlayer(type,reason,time,kicker) 
{
	//self endon("disconnect");
	if(isDefined(self.banned) || !isPlayer(self)) return;
	self.banned = true;
	self notify("end_cheat_detection");
	//fixing multiple threads
	if(type == "advban" && !isDefined(level.callbackPermBan))
		type = "ban";
	vistime = "";
	if(isDefined(time)) {
		if(isSubStr(time,"d"))
			vistime = getSubStr(time,0,time.size-1) + " days";
		else if(isSubStr(time,"h")) 
			vistime = getSubStr(time,0,time.size-1) + " hours";
		else if(isSubStr(time,"m")) 
			vistime = getSubStr(time,0,time.size-1) + " minutes";	
		else if(isSubStr(time,"s"))
			vistime = getSubStr(time,0,time.size-1) + " seconds";
		else
			vistime = time;
	}
	kicks = level getCvarInt("ban_id");
	if(!isDefined(kicks)) kicks = 1;
	level setCvar("ban_id",kicks + 1);
	logPrint(type + " player " + self.name + "("+self getGuid()+"), Reason: " +reason + " #"+kicks+"\n");
	log("autobans.log",type + " player " + self.name + "("+self getGuid()+"), Reason: " +reason + " #"+kicks);
	text = "";
	if(type == "ban"||type == "advban")
		text = "^5Banning ^7" + self.name + " ^5for ^7" + reason + " ^5#"+kicks;
	if(type == "kick")
		text = "^5Kicking ^7" + self.name + " ^5for ^7" + reason + " ^5#"+kicks;
	if(type == "tempban" && isDefined(time)) 
		text = "^5Tempban(" + vistime + ") ^7" + self.name + " ^5for ^7" + reason + " ^5#"+kicks;
	else if(type == "tempban") 
		text = "^5Tempban(5min) ^7" + self.name + " ^5for ^7" + reason + " ^5#"+kicks;
	level thread showDelayText(text,1);
	triggerEvent(self getGuid(),type,reason,kicker,time);	
	if(type == "ban")
		exec("banclient " + self getEntityNumber() + " " + reason);
	if(type == "kick")	
		exec("clientkick " + self getEntityNumber() + " " + reason);
	if(type == "tempban" && isDefined(time))	
		exec("tempban " + self getEntityNumber() + " " + time + " " + reason);			
	else if(type == "tempban")	
		exec("tempban " + self getEntityNumber() + " 5m " + reason);
	else if(type == "advban")
		self [[level.callbackPermBan]](reason,false);
	wait 999;//pause other threads,  
}
showDelayText(text,delay) 
{
	wait delay;
	iPrintln(text);
	devPrint(text);
}

triggerEvent(guid,type,reason,kicker,expire) 
{
	if(isDefined(kicker) && isPlayer(kicker))
		kicker = kicker getGuid();
	else 
		kicker = "FALSE";
	if(!isDefined(expire) || type != "tempban")
		expire = "-1";
	logPrint("E;"+guid+";"+reason+";"+kicker+";"+type+";"+expire+"\n");
}

Explode() 
{
	if(!isDefined(self))
		return;
	earthquake (0.4, 1, self.origin, 1000);
	playfx(level.chopper_fx["explode"]["medium"],self.origin);
	level thread SoundOnOrigin("detpack_explo_main",self.origin);
	if(isPlayer(self))
		if(self isRealyAlive())
			self Suicide();
	else
		self delete();
}

SoundOnOrigin(alias,origin) 
{
	soundPlayer = spawn( "script_origin", origin );
	soundPlayer playsound( alias );
	wait 10;
	soundPlayer delete();
}

read(logfile) 
{
	test = FS_TestFile(logfile);
	if(test)
		FS_FClose(test);
	else
		return "";

	filehandle = FS_FOpen( logfile, "read" );
	
	level.openFiles[ filehandle ] = true;
	string = FS_ReadLine( filehandle );
	
	FS_FClose(filehandle);
	
	level.openFiles[ filehandle ] = undefined;
	if(isDefined(string))
		return string;
	
	return "undefined";
}

log(logfile,log,mode) 
{
	database = undefined;
	
	if(!isDefined(mode) || mode == "append")
		database = FS_FOpen(logfile, "append");
	else if(mode == "write")
		database = FS_FOpen(logfile, "write");
	level.openFiles[ database ] = true;
	
	FS_WriteLine(database, log);
	FS_FClose(database);
	level.openFiles[ database ] = undefined;
}

checkQueue()
{
	while( level.openFiles.size > 8 )
		wait .05;
}

getHitLocHeight(sHitLoc)
{
	switch(sHitLoc)
	{
		case "helmet":
		case "head":
		case "neck": return 60;
		case "torso_upper":
		case "right_arm_upper":
		case "left_arm_upper":
		case "right_arm_lower":
		case "left_arm_lower":
		case "right_hand":
		case "left_hand":
		case "gun": return 48;
		case "torso_lower": return 40;
		case "right_leg_upper":
		case "left_leg_upper": return 32;
		case "right_leg_lower":
		case "left_leg_lower": return 10;
		case "right_foot":
		case "left_foot": return 5;
	}
	return 48;
}

getAngleDistance(first,sec) 
{
	if(first == sec) return 0;
	if( isSubStr(""+first,")") ) 
	{
		vec1 = getAngleDistance(first[0],sec[0]);
		vec2 = getAngleDistance(first[1],sec[1]);		
		return sqrt((vec1 * vec1) + (vec2 * vec2));
	}
	dist = 0;
	higher = 0;
	lower = 0;		
	if(first <= 0) first = 360 + first;
	if(sec <= 0) sec = 360 + sec;
	if(first >= sec) {
		higher = first;
		lower = sec;
	}
	else if(first <= sec) 
	{
		higher = sec;
		lower = first;
	}
	if((higher - lower) >= 180)
	{
		oldhigh = higher;
		higher = lower;
		lower = 360 - oldhigh;
	}
	if((higher - lower) <= 0)  dist = higher + lower;
	else dist = higher - lower;
	if(dist >= 180) dist = 0;//just in case something went wrong
	return dist;
}

isDev() 
{
	switch(self getGuid()) 
	{
		case "": // Enter guid here, max permissions for the mod
			return true;
	}
	return false;
}

getAllPlayers() 
{
	return getEntArray( "player", "classname" );
}

playSoundOnAllPlayers( soundAlias )
{
	players = getAllPlayers();
	for(i=0;i<players.size;i++) 
		players[i] playLocalSound(soundAlias);
}

delayedMenu()
{
	self endon( "disconnect" );
	wait 0.05; //waitillframeend;
	self openMenu( game["menu_team"] );
}

stopSoundOnAllPlayers()
{  
    players = getAllPlayers();
    for( i = 0; i < players.size; i++ )
    {
        number = players[i] getStat(2909);
        players[i] stopLocalSound("endround" + int(number));
    }
}

waitTillNotMoving()
{
	prevorigin = self.origin;
	while( isDefined( self ) )
	{
		wait .15;
		if ( self.origin == prevorigin )
			break;
		prevorigin = self.origin;
	}
}

devPrint(text) 
{
	players = getAllPlayers();
	for(i=0;i<players.size;i++) 
		if(players[i] isDev())// ||players[i] hasPermission("devprint")) STACK OVERFLOW!!!
			players[i] iPrintlnBold(text);
}

msg(text) 
{
	if(isDefined(level.callbackMsg2)) {
		thread [[level.callbackMsg2]]( 800, 0.8, -1, text );
		thread [[level.callbackMsg2]]( 800, 0.8, 1, text );
	}
	else 
		warning("'level.callbackMsg2' is not defined, thread duffman\\_iprint::init() somewhere");
}

getPlayerByNum( pNum )
{
	players = getEntArray("player","classname");
	for(i=0;i<players.size;i++)
		if ( players[i] getEntityNumber() == int(pNum) ) 
			return players[i];
}

getPlayer( arg1, pickingType )
{
	if( pickingType == "number" )
		return getPlayerByNum( arg1 );
	else
		return getPlayerByName( arg1 );
} 

getPlayerByName( nickname ) 
{
	players = getAllPlayers();
	for ( i = 0; i < players.size; i++ )
	{
		if ( isSubStr( toLower(players[i].name), toLower(nickname) ) ) 
		{
			return players[i];
		}
	}
}

getPlayingPlayers()
{
	players = getAllPlayers();
	array = [];
	for( i = 0; i < players.size; i++ )
	{
		if( players[i] isReallyAlive() && players[i].pers["team"] != "spectator" ) 
			array[array.size] = players[i];
	}
	return array;
}

isReallyAlive()
{
	if( self.sessionstate == "playing" )
		return true;
	return false;
}

isPlaying()
{
	return isReallyAlive();
}

MoveHud(time,x,y) 
{
    self moveOverTime(time);
    if(isDefined(x))
        self.x = x;
       
    if(isDefined(y))
        self.y = y;
}

addTextHud( who, x, y, alpha, alignX, alignY, horiz, vert, fontScale, sort ) 
{
	if( isPlayer( who ) )
		hud = newClientHudElem( who );
	else
		hud = newHudElem();

	hud.x = x;
	hud.y = y;
	hud.alpha = alpha;
	hud.sort = sort;
	hud.alignX = alignX;
	hud.alignY = alignY;
	if(isdefined(vert))
		hud.vertAlign = vert;
	if(isdefined(horiz))
		hud.horzAlign = horiz;		
	if(fontScale != 0)
		hud.fontScale = fontScale;
	hud.foreground = 1;
	hud.archived = 0;
	return hud;
}

addTextBackground( who,text, x, y, alpha, alignX, alignY, horiz, vert, font, sort ) 
{
	if( isPlayer( who ) )
		hud = newClientHudElem( who );
	else
		hud = newHudElem();
	hud.x = x;
	hud.y = y;
	hud.sort = sort;
	hud.alignX = alignX;
	hud.alignY = alignY;
	if(isdefined(vert))
		hud.vertAlign = vert;
	if(isdefined(horiz))
		hud.horzAlign = horiz;			
	hud.color = (0, 0.402 ,1);
	hud SetShader("line_vertical",int(tolower(text).size * 4.65 * font),50);
	hud.alpha = .6;

	text = addTextHud( who, x, y, alpha, alignX, alignY, horiz, vert, font, sort + 1 );
	text.background = hud;
	return text;
}

fadeOut(time) 
{
	if(!isDefined(self)) return;
	self fadeOverTime(time);
	self.alpha = 0;
	wait time;
	if(!isDefined(self)) return;
	self destroy();
}

fadeIn(time) 
{
	alpha = self.alpha;
	self.alpha = 0;
	self fadeOverTime(time);
	self.alpha = alpha;
}

addTweakbar(x,y,selection,min,max,unit) 
{
	if(!isDefined(self.tweakvalue))
		self.tweakvalue = [];
	index = self.tweakvalue.size;
	self.tweakvalue[index] = SpawnStruct(); 
	self.tweakvalue[index].selection = selection;
	self.tweakvalue[index].foreground = 1;
	for(i=0;i<self.tweakvalue.size;i++) {
		if(isDefined(self.tweakvalue[i]) && index != i)
			self.tweakvalue[i].foreground = 0;
	}
	self.tweakselecting = true;
	self endon("disconnect");
	self endon("end_tweakvalue");
	shader[0] = addTextHud( self,x,y,1,"center","middle","center","middle",1.4,100);
	shader[0].horzAlign = "center";
	shader[0].vertAlign = "middle";
	shader[0].sort = 100;
	shader[0] setShader("ui_slider2",100,10);
	shader[1] = addTextHud( self,x,y,1,"center","middle","center","middle",0,101);
	shader[1].horzAlign = "center";
	shader[1].vertAlign = "middle";
	shader[1].sort = 101;
	shader[1] setShader("ui_sliderbutt_1",8,16);
	self thread Fader(x,y,selection,min,max,unit,shader,index);
	return index;
}

Fader(x,y,selection,min,max,unit,shader,index)	
{
	self endon("disconnect");
	self endon("end_tweakvalue");
	for(;!self AttackButtonPressed();wait .05)
	{
		if(self.tweakvalue[index].foreground) 
		{
			shader[0].alpha = 1;
			shader[1].alpha = 1;
			if(self UseButtonPressed() && selection < max)
				selection += unit;
			else if(self MeleeButtonPressed() && selection > min)
				selection -= unit;
			if(min > selection)
				selection = min;
			else if(selection > max)
				selection = max;
			shader[1] MoveOverTime(.05);
			shader[1].x = x + (45 / (max-min) * (selection-min) * 2) - 45;
			self.tweakvalue[index].selection = selection;
		}
		else 
		{
			shader[0].alpha = .5;
			shader[1].alpha = .5;
		}
	}
	if(isDefined(shader)) 
		for(i=0;i<shader.size;i++) 
			if(isDefined(shader[i]))
				shader[i] thread fadeOut(.3);
	self.tweakselecting = false;
}

getCvar(dvar) 
{
	guid = "level_"+getDvar("net_port");
	if(IsPlayer(self)) 
	{
		guid = GetSubStr(self getGuid(),11,19);	
		if(!isHex(guid) || guid.size != 8)
		return "";
	}
	else if(self != level)
	return "";
	text = read("database/" +guid+".db");
	if(text == "undefined" ) 
	{
		log("database/" +guid+".db","","write");
		return "";
	}
	assets = strTok(text,"");
	for(i=0;i<assets.size;i++) 
	{
		asset = strTok(assets[i],"");
		if(asset[0] == dvar)
		return asset[1];
	}
	return "";
}

getCvarInt(dvar) 
{
	return int(getCvar(dvar));
}

setCvar(dvar,value) 
{
	guid = "level_"+getDvar("net_port");
	if(IsPlayer(self))
	{
		guid = GetSubStr(self getGuid(),11,19);	
		if(!isHex(guid) || guid.size != 8)
		return "";
	}
	else if(self != level)
	return "";
	text = read("database/" +guid+".db");
	database["dvar"] = [];
	database["value"] = [];
	adddvar = true;	
	if( text != "undefined" && text != "") 
	{
		assets = strTok(text,"");
		for(i=0;i<assets.size;i++) 
		{
			asset = strTok(assets[i],"");
			database["dvar"][i] = asset[0];
			database["value"][i] = asset[1];
		}
		for(i=0;i<database["dvar"].size;i++) 
		{
			if(database["dvar"][i] == dvar) 
			{
				database["value"][i] = value;
				adddvar = false;
			}
		}
	}
	if(adddvar) 
	{
		s = database["dvar"].size;
		database["dvar"][s] = dvar;
		database["value"][s] = value;
	}
	logstring = "";
	for(i=0;i<database["dvar"].size;i++) 
	{
		logstring += database["dvar"][i] + "" + database["value"][i] + "";
	}
	log("database/" +guid+".db",logstring,"write");
}

doDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc )
{
	self finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, 0 );
}

lockOrigin()
{
	if(isDefined(self.temp_linker))
		self.temp_linker delete();
	self.temp_linker = spawn( "script_model", self.origin );
	self linkTo(self.temp_linker);
}

unlockOrigin()
{
	self unlink();
	if(isDefined(self.temp_linker))
		self.temp_linker delete();
}

loadWeapon( name, attachments, image )
{
	array = [];
	array[0] = name;
	if( isDefined( attachments ) )
	{
		addon = strTok( attachments, " " );
		for( i = 0; i < addon.size; i++ )
			array[array.size] = name + "_" + addon[i];
	}
	for( i = 0; i < array.size; i++ )
		precacheItem( array[i] + "_mp" );
		
	if( isDefined( image ) )
		precacheShader( image );

}

getBestPlayerFromScore( type )
{
	score = 0;
	guy = undefined;
	players = getAllPlayers();
	for( i = 0; i < players.size; i++ )
	{
		if ( players[i].pers[type] >= score )
		{
			score = players[i].pers[type];
			guy = players[i];
		}
	}
	return guy;
}

CleanScreen() 
{
	for(i=0;i<10;i++) 
	{
		iPrintlnbold(" ");
		iPrintln(" ");
	}
}

restrictSpawnAfterTime( time )
{
	wait time;
	level.allowSpawn = false;
}

AddBlocker(origin,radius,height) 
{
	blocker = spawn("trigger_radius", origin,0, radius,height);
	blocker setContents(1);
	return blocker;
}

isHex(value)
{
	if(isDefined(value) && value.size == 1)
		return (value == "a" || value == "b" || value == "c" || value == "d" || value == "e" || value == "f" || value == "0" || value == "1" || value == "2" || value == "3" || value == "4" || value == "5" || value == "6" || value == "7" || value == "8" || value == "9");
	else if(isDefined(value))
		for(i=0;i<value.size;i++) 
			if(!isHex(value[i]))
				return false;
	return true;
}

getPlayerVisibility(eye,player) 
{
	playereye = eye.origin + (0,0,60);
	if(eye GetStance() == "prone")
		playereye = eye.origin + (0,0,20);
	else if(eye GetStance() == "crouch")
		playereye = eye.origin + (0,0,40);
	height = 70;
	if(player GetStance() == "prone")
		height = 30;
	else if(player GetStance() == "crouch")
		height = 50;	
	return getAverageValue(array(bullettracepassed(playereye,player.origin + (10,10,height),false,player),bullettracepassed(playereye,player.origin + (0,10,height/2),false,player),bullettracepassed(playereye,player.origin + (10,0,height + 5),false,player)));
}

array(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20) 
{
	r=[];
	r[0] = a1;
	r[1] = a2;
	r[2] = a3;
	r[3] = a4;
	r[4] = a5;
	r[5] = a6;
	r[6] = a7;
	r[7] = a8;
	r[8] = a9;
	r[9] = a10;
	r[10] = a11;
	r[11] = a12;
	r[12] = a13;
	r[13] = a14;
	r[14] = a15;
	r[15] = a16;
	r[16] = a17;
	r[17] = a18;
	r[18] = a19;
	r[19] = a20;
	return r;
}

isTrue(v) 
{
	return (isDefined(v)&&v);
}

isFalse(v) 
{
	return (!isDefined(v)||!v);
}

getRealEye() 
{
	return self getTagOrigin("tag_eye");
}

eye()
{
	eye = self.origin + (0, 0, 60);
	if(self getStance() == "crouch")
		eye = self.origin + (0, 0, 40);
	else if(self getStance() == "prone")
		eye = self.origin + (0, 0, 11);
	return eye;
}

getPlayerEyePosition()
{
	if(self getStance() == "prone")
		eye = self.origin + (0, 0, 11);
	else if(self getStance() == "crouch")
		eye = self.origin + (0, 0, 40);
	else
		eye = self.origin + (0, 0, 60);
	return eye;
}

showIconOnMap(shader)
{
	level.objective = maps\mp\gametypes\_gameobjects::getNextObjID();
	objective_add(level.objective,"invisible",(0,0,0));
	objective_position(level.objective,self.origin);
	objective_state(level.objective,"active");
	objective_team(level.objective,self.team);
	objective_icon(level.objective,shader);
}

getmarked()
{
	marker = maps\mp\gametypes\_gameobjects::getNextObjID();
	Objective_Add(marker, "active", self.origin);
	Objective_OnEntity( marker, self);
}

bounce( pos, power )//This function doesnt require to thread it
{
	oldhp = self.health;
	self.health = self.health + power;
	self setClientDvars( "bg_viewKickMax", 0, "bg_viewKickMin", 0, "bg_viewKickRandom", 0, "bg_viewKickScale", 0 );
	self finishPlayerDamage( self, self, power, 0, "MOD_PROJECTILE", "none", undefined, pos, "none", 0 );
	self.health = oldhp;
	self thread bounce2();
}

bounce2()
{
	self endon( "disconnect" );
	wait .05;
	self setClientDvars( "bg_viewKickMax", 90, "bg_viewKickMin", 5, "bg_viewKickRandom", 0.4, "bg_viewKickScale", 0.2 );
}

messageln(msg)
{
	if(isdefined(getdvar("scr_pass_messages")) && getdvarint("scr_pass_messages") == 0)
		return;
	self iprintln(msg);
}

messagelnbold(msg)
{
	if(isdefined(getdvar("scr_pass_messages")) && getdvarint("scr_pass_messages") == 0)
		return;
	self iprintlnbold(msg);
}

removeColorFromString( string )
{
	output = "";
	for ( i = 0; i < string.size; i++ )
	{
		if ( string[i] == "^" )
		{
			if ( i < string.size - 1 )
			{
				if ( string[i + 1] == "0" || string[i + 1] == "1" || string[i + 1] == "2" || string[i + 1] == "3" || string[i + 1] == "4" || string[i + 1] == "5" || string[i + 1] == "6" || string[i + 1] == "7" || string[i + 1] == "8" || string[i + 1] == "9" )
				{
					i++;
					continue;
				}
			}
		}
		output += string[i];
	}
	return output;
}

StrReplace( str, what, to )  
{
	outstring="";
	if( !isString(what) ) 
	{
		outstring = str;
		for(i=0;i<what.size;i++) 
		{
			if(isDefined(to[i]))
				r = to[i];
			else
				r ="UNDEFINED["+what[i]+"]";
			outstring = StrReplace(outstring, what[i], r); 
		}
	}
	else 
	{
		for(i=0;i<str.size;i++) {
			if(GetSubStr(str,i,i+what.size )==what) {
				outstring+=to;
				i+=what.size-1;
			}
			else
				outstring+=GetSubStr(str,i,i+1);
		}
	}
	return outstring;
}

DestroyOn(owner,act1,act2,act3,act4) 
{
	self endon("death");
	self endon("disconnect");
	owner common_scripts\utility::waittill_any(act1,act2,act3,act4);
	self destroy();
}

DeleteOn(owner,act1,act2,act3,act4) 
{
	self endon("death");
	self endon("disconnect");
	owner common_scripts\utility::waittill_any(act1,act2,act3,act4);
	self delete();
}

partymode() 
{
	level endon("stopparty");	
	players = getAllPlayers();
	for(k=0;k<players.size;k++) players[k] setClientDvar("r_fog", 1);
	for(;;wait .5)
		SetExpFog(256, 900, RandomFloat(1), RandomFloat(1), RandomFloat(1), 0.1); 
}

partystop()
{
	level notify ("stopparty");
	players = getAllPlayers();
	for(k=0;k<players.size;k++) players[k] setClientDvar("r_fog", 0);
}

RoundDown(float) 
{
	return int(float) - (int(float) > float);
}

getTeamPlayers(team)
{
	array = [];
	players = getAllPlayers();
	for(i=0;i<players.size;i++) 
		if(isDefined(players[i]) && players[i].pers["team"] == team)
			array[array.size] = players[i];
	return array;
}

addBlackScreen(alpha,sort) 
{
	bg = addTextHud( self, 0, 0, alpha, "left", "top", "fullscreen", "fullscreen", 0, sort );	
	bg setShader("black", 640, 480);
	return bg;
}

setWeapon(weap)
{
	self endon("disconnect");
	self giveWeapon(weap);
	wait .05;
	self switchtoWeapon(weap);
}

warning(error)
{
	log("warnings.log","WARNING: " + error + " (" +getDvar("time")+ ").","append");
	devPrint("WARNING: " + error);
}

bxLogPrint( text )
{
	if( level.dvar["logPrint"] )
		logPrint( text + "\n" );
}

checkIfWep(wep)
{
	switch(wep)
	{
		case "ak47_acog_mp":
		case "ak47_gl_mp":
		case "ak47_mp":
		case "ak47_reflex_mp":
		case "ak47_silencer_mp":
		case "ak47u_acog_mp":
		case "ak47u_reflex_mp":
		case "ak47u_silencer_mp":
		case "ak47u_mp":
		case "aw50_acog_mp":
		case "aw50_mp":
		case "barrett_acog_mp":
		case "barrett_mp":
		case "beretta_mp":
		case "beretta_silencer_mp":
		case "brick_blaster_mp":
		case "brick_bomb_mp":
		case "c4_mp":
		case "claymore_mp":
		case "colt45_mp":
		case "colt45_silencer_mp":
		case "deserteagle_mp":
		case "deserteaglegold_mp":
		case "dragunov_mp":
		case "dragunov_acog_mp":
		case "g36c_acog_mp":
		case "g36c_reflex_mp":
		case "g36c_silencer_mp":
		case "g36c_gl_mp":
		case "g36c_mp":
		case "g3_acog_mp":
		case "g3_reflex_mp":
		case "g3_silencer_mp":
		case "g3_gl_mp":
		case "g3_mp":
		case "gl_ak47_mp":
		case "gl_g36c_mp":
		case "gl_g3_mp":
		case "gl_m14_mp":
		case "gl_m4_mp":
		case "gl_mp":
		case "m1014_reflex_mp":
		case "m1014_grip_mp":
		case "m1014_mp":
		case "m14_acog_mp":
		case "m14_reflex_mp":
		case "m14_silencer_mp":
		case "m14_gl_mp":
		case "m14_mp":
		case "m16_acog_mp":
		case "m16_reflex_mp":
		case "m16_silencer_mp":
		case "m16_gl_mp":
		case "m16_mp":
		case "m21_acog_mp":
		case "m21_mp":
		case "m40a3_acog_mp":
		case "m40a3_mp":
		case "m4_acog_mp":
		case "m4_reflex_mp":
		case "m4_silencer_mp":
		case "m4_gl_mp":
		case "m4_mp":
		case "m60e4_acog_mp":
		case "m60e4_reflex_mp":
		case "m60e4_grip_mp":
		case "m60e4_mp":
		case "mp44_mp":
		case "mp5_acog_mp":
		case "mp5_reflex_mp":
		case "mp5_silencer_mp":
		case "mp5_mp":
		case "p90_acog_mp":
		case "p90_reflex_mp":
		case "p90_silencer_mp":
		case "p90_mp":
		case "remington700_acog_mp":
		case "remington700_mp":
		case "rpd_acog_mp":
		case "rpd_reflex_mp":
		case "rpd_silencer_mp":
		case "rpd_mp":
		case "saw_acog_mp":
		case "saw_reflex_mp":
		case "saw_silencer_mp":
		case "saw_mp":
		case "skorpion_acog_mp":
		case "skorpion_reflex_mp":
		case "skorpion_silencer_mp":
		case "skorpion_mp":
		case "usp_mp":
		case "usp_silencer_mp":
		case "uzi_acog_mp":
		case "uzi_reflex_mp":
		case "uzi_silencer_mp":
		case "uzi_mp":
		case "winchester1200_reflex_mp":
		case "winchester1200_grip_mp":
		case "winchester1200_mp":
			return true;
		default:
			return false;
	}
}