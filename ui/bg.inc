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
//////////////////////////////////////////////////////// THUNDER ///////////////////////////////////////////////////////////////////
itemDef
{
	style			WINDOW_STYLE_SHADER
	rect			FULLSCREEN_WIDE
	background		"bg_front_thunder"
	forecolor		1 1 1 255
	exp forecolor A (0+(cos(milliseconds()/700) * 0.7))
	visible		    1
	decoration
}

itemDef
{
	style			WINDOW_STYLE_SHADER
	rect			FULLSCREEN_WIDE
	background		"bg_front_thunder"
	forecolor		1 1 1 125
	exp forecolor A (0+(cos(milliseconds()/500) * 1))
	visible		    1
	decoration
}
itemDef
{
	style			WINDOW_STYLE_SHADER
	rect			FULLSCREEN_WIDE
	background		"bg_front_thunder"
	forecolor		1 1 1 200
	exp forecolor A (0+(cos(milliseconds()/1000) * 0.5))
	visible		    1
	decoration
}
