#define STEP_1 6891
#define STEP_2 9876
#define STEP_3 8444
#define STEP_4 14785

#define OVERLAY_DURATION_MIN 120
#define OVERLAY_DURATION_MAX_ADD 60

// Background
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

// Animated overlay



////////////////////////////////////////////// Animated
itemDef
{
	style			WINDOW_STYLE_SHADER
	rect			FULLSCREEN_WIDE
	background		"bg_front_thunder"
	forecolor		1 1 1 255
	exp forecolor A (0+(cos(milliseconds()/900) * 0.9))
	visible		    1
	decoration
}
itemDef
{
	style			WINDOW_STYLE_SHADER
	rect			FULLSCREEN_WIDE
	background		"bg_front_thunder"
	forecolor		1 1 1 125
	exp forecolor A (0+(cos(milliseconds()/500) * 0.8))
	visible		    1
	decoration
}
/* // THUND
itemDef
{
	style			WINDOW_STYLE_SHADER
	rect			FULLSCREEN_WIDE
	background		"bg_front_thunder"
	forecolor		1 1 1 0.2
	exp forecolor   A(1 - ((milliseconds() % STEP_1) / (OVERLAY_DURATION_MIN + (milliseconds() % OVERLAY_DURATION_MAX_ADD))))
	visible			when((milliseconds() % STEP_1 < (OVERLAY_DURATION_MIN + (milliseconds() % OVERLAY_DURATION_MAX_ADD))) && dvarString("ui_mainmenu_thunder") != "0")
	decoration
}
itemDef
{
	style			WINDOW_STYLE_SHADER
	rect			FULLSCREEN_WIDE
	background		"bg_front_thunder"
	forecolor		1 1 1 0.2
	exp forecolor   A(1 - ((milliseconds() % STEP_2) / (OVERLAY_DURATION_MIN + (milliseconds() % OVERLAY_DURATION_MAX_ADD))))
	visible			when((milliseconds() % STEP_2 < (OVERLAY_DURATION_MIN + (milliseconds() % OVERLAY_DURATION_MAX_ADD))) && dvarString("ui_mainmenu_thunder") != "0")
	decoration
}
itemDef
{
	style			WINDOW_STYLE_SHADER
	rect			FULLSCREEN_WIDE
	background		"bg_front_thunder"
	forecolor		1 1 1 0.2
	exp forecolor   A(1 - ((milliseconds() % STEP_3) / (OVERLAY_DURATION_MIN + (milliseconds() % OVERLAY_DURATION_MAX_ADD))))
	visible			when((milliseconds() % STEP_3 < (OVERLAY_DURATION_MIN + (milliseconds() % OVERLAY_DURATION_MAX_ADD))) && dvarString("ui_mainmenu_thunder") != "0")
	decoration
}
itemDef
{
	style			WINDOW_STYLE_SHADER
	rect			FULLSCREEN_WIDE
	background		"bg_front_thunder"
	forecolor		1 1 1 0.2
	exp forecolor   A(1 - ((milliseconds() % STEP_4) / (OVERLAY_DURATION_MIN + (milliseconds() % OVERLAY_DURATION_MAX_ADD))))
	visible			when((milliseconds() % STEP_4 < (OVERLAY_DURATION_MIN + (milliseconds() % OVERLAY_DURATION_MAX_ADD))) && dvarString("ui_mainmenu_thunder") != "0")
	decoration
}