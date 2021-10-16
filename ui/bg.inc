#define STEP_1 6891
#define STEP_2 9876
#define STEP_3 8444
#define STEP_4 14785

#define THUNDER_DURATION_MIN 120
#define THUNDER_DURATION_MAX_ADD 100

itemDef
{
	style				WINDOW_STYLE_SHADER
	rect				FULLSCREEN_WIDE
	background	        "animbg_back"
	forecolor		    1 1 1 1
	visible			    1
	decoration
}

itemDef
{
	style				WINDOW_STYLE_SHADER
	rect				FULLSCREEN_WIDE
	background	        "animbg_front"
	forecolor		     1 1 1 1
	visible			     1
	decoration
}

itemDef
{
	style				WINDOW_STYLE_SHADER
	rect				FULLSCREEN_WIDE
	background       	"animbg_front2"
	forecolor	     	1 1 1 1
	visible			    1
	decoration
}
////////////////////////////////////////////// Animated
itemDef
{
	style			WINDOW_STYLE_SHADER
	rect			FULLSCREEN_WIDE
	background		"bg_front_thunder"
	forecolor		1 1 1 0.6
	exp forecolor A( 1 - ( (milliseconds() % STEP_1) / (THUNDER_DURATION_MIN + (milliseconds() % THUNDER_DURATION_MAX_ADD) ) ) )
	visible			when( ( milliseconds() % STEP_1 < (THUNDER_DURATION_MIN + (milliseconds() % THUNDER_DURATION_MAX_ADD)) ) && dvarString("ui_mainmenu_thunder") != "0" )
	decoration
}
itemDef
{
	style			WINDOW_STYLE_SHADER
	rect			FULLSCREEN_WIDE
	background		"bg_front_thunder"
	forecolor		1 1 1 0.6
	exp forecolor A( 1 - ( (milliseconds() % STEP_2) / (THUNDER_DURATION_MIN + (milliseconds() % THUNDER_DURATION_MAX_ADD) ) ) )
	visible			when( ( milliseconds() % STEP_2 < (THUNDER_DURATION_MIN + (milliseconds() % THUNDER_DURATION_MAX_ADD)) ) && dvarString("ui_mainmenu_thunder") != "0" )
	decoration
}
itemDef
{
	style			WINDOW_STYLE_SHADER
	rect			FULLSCREEN_WIDE
	background		"bg_front_thunder"
	forecolor		1 1 1 0.6
	exp forecolor A( 1 - ( (milliseconds() % STEP_3) / (THUNDER_DURATION_MIN + (milliseconds() % THUNDER_DURATION_MAX_ADD) ) ) )
	visible			when( ( milliseconds() % STEP_3 < (THUNDER_DURATION_MIN + (milliseconds() % THUNDER_DURATION_MAX_ADD)) ) && dvarString("ui_mainmenu_thunder") != "0" )
	decoration
}
itemDef
{
	style			WINDOW_STYLE_SHADER
	rect			FULLSCREEN_WIDE
	background		"bg_front_thunder"
	forecolor		1 1 1 0.6
	exp forecolor A( 1 - ( (milliseconds() % STEP_4) / (THUNDER_DURATION_MIN + (milliseconds() % THUNDER_DURATION_MAX_ADD) ) ) )
	visible			when( ( milliseconds() % STEP_4 < (THUNDER_DURATION_MIN + (milliseconds() % THUNDER_DURATION_MAX_ADD)) ) && dvarString("ui_mainmenu_thunder") != "0" )
	decoration
}