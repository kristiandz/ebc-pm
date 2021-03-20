#undef FOG_SCROLL_TIME
#define FOG_SCROLL_TIME 30000

itemDef
{
	style			WINDOW_STYLE_SHADER
	rect			FULLSCREEN_WIDE
	background		"animbg_front"
	visible			when( dvarString( fs_game ) == "" );
	decoration
}

itemDef
{
	style			WINDOW_STYLE_SHADER
	rect			-107 0 1708 480
	exp				rect X((-107) - ((float(milliseconds() % FOG_SCROLL_TIME) / FOG_SCROLL_TIME) * (854)))
	background		"animbg_front"
	visible			when( dvarString( fs_game ) == "" );
	decoration
}

itemDef
{
	style			WINDOW_STYLE_SHADER
	rect			FULLSCREEN_WIDE
	background		"animbg_front"
	visible			when( dvarString( fs_game ) == "" );
	decoration
}


itemDef
{
	style			WINDOW_STYLE_SHADER
	rect			FULLSCREEN_WIDE
	background		"animbg_front"
	forecolor		1 1 1 1
	visible			when( dvarString( fs_game ) != "" );
	decoration
}

itemDef
{
	style			WINDOW_STYLE_SHADER
	rect			-107 0 1708 480
	exp				rect X((-107) - ((float(milliseconds() % FOG_SCROLL_TIME) / FOG_SCROLL_TIME) * (854)))
	background		"animbg_front"
	forecolor		1 1 1 1
	visible			when( dvarString( fs_game ) != "" );
	decoration
}

itemDef
{
	style			WINDOW_STYLE_SHADER
	rect			FULLSCREEN_WIDE
	background		"animbg_front"
	forecolor		1 1 1 1
	visible			when( dvarString( fs_game ) != "" );
	decoration
}