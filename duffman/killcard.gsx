#include scripts\utility\common;

init() 
{
	//       | NAME | INDEX | COLOR |  ALPHA | SHADER | W | H | ALIGNY | Y
	height = 202;
	//----------------------DEFAULT-------------------------
	addDesign("Default",0,(0.3, 0.3, 0.3),0.6,"white",250,38,"middle",height);
	addDesign("Default",1,(1, 0, 0),0.8,"nightvision_overlay_goggles",250,38,"middle",height);
	//-----------------------BLUE--------------------------
	addDesign("Blue",0,(0, 0, 1),0.6,"white",250,38,"middle",height);
	addDesign("Blue",1,(0, 0, 1),0.8,"nightvision_overlay_goggles",250,38,"middle",height);
	//-----------------------RED--------------------------
	addDesign("Red",0,(1, 0, 0),0.6,"white",250,38,"middle",height);
	addDesign("Red",1,(1, 0, 0),0.8,"nightvision_overlay_goggles",250,38,"middle",height);
	//-----------------------GREEN--------------------------
	addDesign("Green",0,(0, 1, 0),0.6,"white",250,38,"middle",height);
	addDesign("Green",1,(0, 1, 0),0.8,"nightvision_overlay_goggles",250,38,"middle",height);
	//-----------------------YELLOW--------------------------
	addDesign("Yellow",0,(1, 1, 0),0.6,"white",250,38,"middle",height);
	addDesign("Yellow",1,(1, 1, 0),0.8,"nightvision_overlay_goggles",250,38,"middle",height);
	//-----------------------Member--------------------------
	addDesign("Member",0,(1, 1, 1),0.6,"playercard_emblem_4",255,46,"middle",height);
	addDesign("Member",1,(1, 1, 1),0.6,"playercard_emblem_4",253,44,"middle",height);
	//------------------------VIP 1--------------------------
	addDesign("VIP1",0,(1,1,1),0.5,"playercard_emblem_1",255,46,"middle",height);
    addDesign("VIP1",1,(1,1,1),0.5,"playercard_emblem_1",253,43,"middle",height);
	//------------------------VIP 2--------------------------
	addDesign("VIP2",0,(1,1,1),0.5,"playercard_emblem_2",250,40,"middle",height);
    addDesign("VIP2",1,(1,1,1),0.5,"playercard_emblem_2",250,40,"middle",height);
	//------------------------VIP 3--------------------------
	addDesign("VIP3",0,(1,0.5,0.5),0.5,"playercard_emblem_3",250,40,"middle",height);
    addDesign("VIP3",1,(0.5,0.5,0.5),0.5,"playercard_emblem_3",250,40,"middle",height);
	
	shaders = strTok("killiconmelee;killiconsuicide;death_car;hud_us_stungrenade;hud_icon_benelli_m4;hud_us_grenade;hud_icon_c4;weapon_ak47;weapon_aks74u;weapon_barrett50cal;weapon_benelli_m4;weapon_c4;weapon_colt_45;weapon_colt_45_silencer;weapon_concgrenade;weapon_desert_eagle;weapon_desert_eagle_gold;weapon_dragunovsvd;weapon_flashbang;hud_us_grenade;weapon_g3;weapon_g36c;weapon_m14;weapon_m14_scoped;weapon_m16a4;weapon_m249saw;weapon_m40a3;weapon_m4carbine;weapon_m60e4;weapon_m9beretta;weapon_m9beretta_silencer;weapon_mini_uzi;weapon_mp44;weapon_mp5;weapon_p90;weapon_remington700;weapon_rpd;weapon_rpg7;weapon_skorpion;weapon_smokegrenade;weapon_usp_45;weapon_usp_45_silencer;weapon_winchester1200",";");
	for(i=0;i<shaders.size;i++) PreCacheShader(shaders[i]);
	for(;;) 
	{
		level waittill("connected",player);
		level thread onPlayerDisconnect(player);
		player thread Connected();
	}
}

Connected() 
{
	if(!isDefined(self.pers["killstats"])) 
		self.pers["killstats"] = "0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0";
}

setKillStat(pid,stat) 
{
	stats = strTok(self.pers["killstats"],".");
	stats[pid] = stat;
	string = "";
	for(i=0;i<63;i++)
	string += stats[i] + ".";
	self.pers["killstats"] = string;
}

getKillStat(pid) 
{
	return int(strTok(self.pers["killstats"],".")[pid]);
}

onPlayerDisconnect(player) 
{
	entity = player getEntityNumber();
	player waittill("disconnect");
	wait .05;
	players = GetEntArray("player","classname");
	for(i=0;i<players.size;i++) 
		if(isDefined(players[i]))
			players[i] setKillStat(entity,0);
}

ShowKillCard(attacker,victim,sMeansOfDeath,sWeapon,sHitLoc) 
{
	if(isDefined(attacker) && isDefined(victim) && isPlayer(attacker) && isPlayer(victim) && attacker != victim && isDefined(sMeansOfDeath) && isDefined(sWeapon) && !isDefined(attacker.pers["isBot"]) && !isDefined(victim.pers["isBot"])) {
		if(sMeansOfDeath == "MOD_MELEE")
			sWeapon = "knife_mp";
		attacker setKillStat(victim GetEntityNumber(),attacker getKillStat(victim GetEntityNumber()) + 1);
		if(!isDefined(attacker GetCurrentWeapon())) 
			return;
		victim thread KillCard(attacker,sWeapon,attacker GetCurrentWeapon());
		attacker thread KillCard(victim,sWeapon,attacker GetCurrentWeapon());
	}
 }

addDesign(name,index,color,alpha,shader,width,height,al,y) 
 {
 	level.designs[name][index][0] = color;
 	level.designs[name][index][1] = alpha;
 	level.designs[name][index][2] = shader;
 	level.designs[name][index][3] = width;
 	level.designs[name][index][4] = height;
 	level.designs[name][index][5] = al;
 	level.designs[name][index][6] = y;
 	precacheShader(shader);
 }

getDesign(index)
{
 	name = self.pers["design"];
	if(!isDefined(self.pers["design"]))
		name = "Default";
 	if(isDefined(level.designs[name]) && isDefined(level.designs[name][index]) && isDefined(level.designs[name][index]))
 		return level.designs[name][index];
 	else
 		return level.designs["Default"][index];
}

setDesign(theme,cancel) 
{
	self notify("new_emblem");
	scripts\sql::db_connect("ebc_b3_pm");
	q_str = "UPDATE player_core SET style= \"" + theme + "\" WHERE guid LIKE "+self GetGuid();
	SQL_Query(q_str);
	SQL_Close();
	self.pers["design"] = theme;	
	if(isDefined(self.killcard))
		for(i=0;i<self.killcard.size;i++)
			if(isDefined(self.killcard[i]))
				self.killcard[i] Destroy();
	self.iswaitingforcard = undefined;
	self.cardinuse = undefined;
	if(isDefined(cancel))return;
	self thread KillCard(self,"ak74u_mp","ak74u_mp");
}

KillCard(from,weap,alternatewep) 
{
	self endon("disconnect");
	self endon("new_emblem");
	wait .05;
	while(isDefined(self.cardinuse)) 
	{
		wait .05;
		self.iswaitingforcard = true;
	}
	if(!isDefined(from) || !isDefined(from.pers) )
		return;	
	self.iswaitingforcard = undefined;
	self.cardinuse = true;
	shader = [];
	for(i=0;i<12;i++) 
	{
		shader[i] = hud( self, 0, 150, 1, "center", "top", 1.4 );
		shader[i].horzAlign = "center";
		shader[i].vertAlign = "middle";
		shader[i].sort = 100+i;
		shader[i].foreground = true;
	}
	design = from getDesign(0);
	shader[0] SetShader(design[2],design[3],design[4]);
	shader[0].color = design[0];
	shader[0].y = design[6];
	shader[0].alignY = design[5];
	shader[0].alpha = design[1];
	design = from getDesign(1);
	shader[1] SetShader(design[2],design[3],design[4]);
	shader[1].color = design[0];
	shader[1].alpha = design[1];
	shader[1].y = design[6];
	shader[1].alignY = design[5];	
	if(!isDefined(weap)) weap = "Define Weapon";
	if(!isDefined(alternatewep)) alternatewep = "Define Weapon";
	shader[2] setWeaponIcon(weap,alternatewep);
	shader[2].x = 80;
	shader[2].y = 204;	
	shader[2].alignX = "center";
	shader[2].alignY = "middle";
	shader[3] setValue(self getKillStat(from GetEntityNumber()));
	shader[3].x = -7;
	shader[3].y = 190;	
	shader[3].alignX = "right";
	shader[3].font = "objective";
	shader[3].fontscale = 2;	
	shader[3].glowColor = (.4,.4,.4);
	shader[3].glowAlpha = 1;
	shader[4].label = &"-&&1";
	shader[4] setValue(from getKillStat(self GetEntityNumber()));
	shader[4].x = -6.6;
	shader[4].y = 190;	
	shader[4].alignX = "left";
	shader[4].font = "objective";
	shader[4].fontscale = 2;
	shader[4].glowColor = (.4,.4,.4);
	shader[4].glowAlpha = 1;
	shader[5].label = &"K/D Ratio: ^1&&1";
	shader[5].alignX = "left";
	shader[5].x = -115;
	shader[5].y = 187;
	if(from.pers[ "deaths" ])
		shader[5] setValue(int( from.pers[ "kills" ] / from.pers[ "deaths" ] * 100 ) / 100);
	else 
		shader[5] setValue(from.pers[ "kills" ]);
	shader[6].label = &"Killstreak: ^1&&1";
	shader[6].x = -115;
	shader[6].y = 202;
	shader[6].alignX = "left";
	shader[6] setValue(from GetStat(2304));

	for(i=0;i<shader.size;i++) 
	{
		old = shader[i].y;
		shader[i].y = 304;
		shader[i] MoveOverTime(.3);
		shader[i].y = old;
	}
	self.killcard = shader;
	wait 2;
	for(i=0;i<25 && !isDefined(self.iswaitingforcard);i++) wait .1;
	for(i=0;i<shader.size;i++) 
	{
		shader[i] MoveOverTime(.3);
		shader[i].y = 304;
	}
	wait .5;
	for(i=0;i<shader.size;i++) 
		if(isDefined(shader[i])) 
			shader[i] Destroy();
	self.cardinuse = undefined;
}

setWeaponIcon(wep,alternate) 
{
	x = 75;
	y = 35;
	s = "white";
	wep = strTok(wep,"_")[0];
	switch(wep) 
	{
		case"destructible": s = "death_car"; x = 40; break;
		case"ak47": s = "weapon_ak47";  break;
		case"ak74u": s = "weapon_aks74u";  break;
		case"m1014": s = "hud_icon_benelli_m4";  break;
		case"barrett": s = "weapon_barrett50cal";  break;
		case"c4": s = "hud_icon_c4"; x = 40; break;
		case"colt45": s = "weapon_colt_45";  x = 45; y = 45;; break;
		case"deserteagle": s = "weapon_desert_eagle"; x = 45; y = 45; break;
		case"deserteaglegold": s = "weapon_desert_eagle_gold"; x = 45; y = 45; break;
		case"dragunov": s = "weapon_dragunovsvd";  break;
		case"g3": s = "weapon_g3";  break;
		case"g36c": s = "weapon_g36c"; break;
		case"m14": s = "weapon_m14"; break;
		case"m21": s = "weapon_m14_scoped"; break;
		case"m16": s = "weapon_m16a4";  break;
		case"saw": s = "weapon_m249saw";  break;
		case"m40a3": s = "weapon_m40a3";  break;
		case"m4": s = "weapon_m4carbine";  break;
		case"m60e4": s = "weapon_m60e4";  break;
		case"beretta": s = "weapon_m9beretta"; x = 45; y = 45; break;
		case"uzi": s = "weapon_mini_uzi"; break;
		case"mp44": s = "weapon_mp44"; break;
		case"mp5": s = "weapon_mp5"; break;
		case"p90": s = "weapon_p90"; break;
		case"remington700": s = "weapon_remington700"; break;
		case"rpd": s = "weapon_rpd"; break;
		case"rpg": s = "weapon_rpg7"; break;
		case"skorpion": s = "weapon_skorpion"; break;
		case"usp": s = "weapon_usp_45"; x = 45; y = 45; break;
		case"winchester1200": s = "weapon_winchester1200"; break;
		case"frag": s = "hud_us_grenade"; x = 40; y = 40; break; 
		case"stun": s = "hud_us_stungrenade"; x = 40; break;
		case"flash": s = "weapon_concgrenade"; x = 40; break;
		case"knife": s = "killiconmelee"; x = 33; y = 33; break;
		default: s = "killiconsuicide"; x = 36; y = 36; break;
	}
	self setShader(s,int(x),int(y));
}

hud( who, x, y, alpha, alignX, alignY, fontScale )
{
	if( isPlayer( who ) ) hud = newClientHudElem( who );
	else hud = newHudElem();
	hud.x = x;
	hud.y = y;
	hud.alpha = alpha;
	hud.alignX = alignX;
	hud.alignY = alignY;
	hud.fontScale = fontScale;
	return hud;
}