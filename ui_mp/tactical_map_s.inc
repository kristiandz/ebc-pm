#define MAP_OFFSET				0 0
#define FULL_SCREEN				0 30 640 420

itemDef
{
	name			"mini_map2"
	rect			FULL_SCREEN
	origin			MAP_OFFSET
	forecolor		1 1 1 1
	background		"compass_map_default"
	ownerdraw		CG_PLAYER_FULLMAP_MAP
	visible			1
	decoration
}
itemDef
{
	style			WINDOW_STYLE_SHADER
	name			"mini_map2_overlay"
	rect			FULL_SCREEN
	origin			MAP_OFFSET
	forecolor		1 1 1 1
	exp				material( tableLookup( "mp/mapsTable.csv", 0, dvarString( mapname ), 7 ) )
	visible			1
	decoration
}
itemDef
{
	name			"compasspointers2"
	rect			FULL_SCREEN
	origin			MAP_OFFSET
	forecolor		1 1 1 1
	background		"objective_line"
	ownerdraw		CG_PLAYER_FULLMAP_POINTERS
	visible			1
	decoration
}
itemDef
{
	name			"compassfriendlies2"
	rect			FULL_SCREEN
	origin			MAP_OFFSET
	forecolor		1 1 1 1
	background		"compassping_friendly"
	ownerdraw		CG_PLAYER_FULLMAP_FRIENDS
	visible			1
	decoration
}
itemDef
{
	name			"compassenemies2"
	rect			FULL_SCREEN
	origin			MAP_OFFSET
	forecolor		1 1 1 1
	background		"compassping_enemy"
	ownerdraw		CG_PLAYER_FULLMAP_ENEMIES
	visible			1
	decoration
}
itemDef
{
	name			"compassplayer2"
	rect			FULL_SCREEN
	origin			MAP_OFFSET
	forecolor		1 1 1 1
	background		"compassping_player"
	ownerdraw		CG_PLAYER_FULLMAP_PLAYER
	visible			1
	decoration
}