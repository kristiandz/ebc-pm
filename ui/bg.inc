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
