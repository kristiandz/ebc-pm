// -------------------- left or right menu selection -----------------------
itemDef	
{
	name			selection_left
	style			WINDOW_STYLE_SHADER
	rect			-120 70 -320 342
	background		"gradient_fadein"
	forecolor		1 0 0 1 //1 0.9 0.95 0.15
	visible			1
	decoration
}

#define LOCAL_FLASH			(sin(milliseconds()*0.0065)+1)
#define LOCAL_FLASH_LO		LOCAL_FLASH*0.07
#define LOCAL_FLASH_HI		LOCAL_FLASH*0.35
#define LOCAL_GLOW_COLOR	1 0.95 0.95 1

//PREPROC_SHADER_DRAW_ALIGNED( -4 12 278 334 RIGHTITEM_ALIGN VERTICAL_ALIGN_TOP, ORIGIN_PLAYERLIST, "gradient_center", LOCAL_GLOW_COLOR, 0, 0, 0 0 0 0 group selection_right exp forecolor A(LOCAL_FLASH_LO) )
PREPROC_SHADER_DRAW_ALIGNED_VIS(-4 14 2 330 RIGHTITEM_ALIGN VERTICAL_ALIGN_TOP, ORIGIN_PLAYERLIST, "white", LOCAL_GLOW_COLOR, 0, 0, 0 0 0 0 group selection_right exp forecolor A(LOCAL_FLASH_HI), 0)
PREPROC_SHADER_DRAW_ALIGNED_VIS(272 14 2 330 RIGHTITEM_ALIGN VERTICAL_ALIGN_TOP, ORIGIN_PLAYERLIST, "white", LOCAL_GLOW_COLOR, 0, 0, 0 0 0 0 group selection_right exp forecolor A(LOCAL_FLASH_HI), 0)
PREPROC_SHADER_DRAW_ALIGNED_VIS(-4 12 278 2 RIGHTITEM_ALIGN VERTICAL_ALIGN_TOP, ORIGIN_PLAYERLIST, "gradient_center", LOCAL_GLOW_COLOR, 0, 0, 0 0 0 0 group selection_right exp forecolor A(LOCAL_FLASH_HI), 0)
PREPROC_SHADER_DRAW_ALIGNED_VIS(-4 344 278 2 RIGHTITEM_ALIGN VERTICAL_ALIGN_TOP, ORIGIN_PLAYERLIST, "gradient_center", LOCAL_GLOW_COLOR, 0, 0, 0 0 0 0 group selection_right exp forecolor A(LOCAL_FLASH_HI), 0)