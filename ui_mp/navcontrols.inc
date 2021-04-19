#ifndef ALT_PANEL
#define ALT_PANEL		0
#endif

#ifdef	PC
	itemDef 	
	{ 
		style			WINDOW_STYLE_SHADER 
		rect			-120 -32 378 64 0 0 
		background		"white" 
		forecolor		0.45 0.45 0.45 0.2  // Gore Livo Kocka
		visible			1
		decoration 
	} 
	itemDef 	
	{ 
		style			WINDOW_STYLE_SHADER 
		rect			258 -32 16 -64 0 0 
		origin			0 0 
		background		HIGHLIGHT_SHADER_ART 
		forecolor		0.45 0.45 0.45 0.2  // Gore Desno Trokut Boja MP Meniji
		visible			1
		decoration	
	}
		
	itemDef		
	{
		style			WINDOW_STYLE_SHADER
		rect			56 448 528 40 0 0
		background		"white"
		forecolor		0.45 0.45 0.45 0.2   // SREDINA DOLJE 
		visible			1
		decoration	
	}
	
	itemDef		
	{
		style			WINDOW_STYLE_SHADER
		rect			584 448 16 64 0 0
		origin			0 0
		background		HIGHLIGHT_SHADER_ART
		forecolor		0.45 0.45 0.45 0.2   // Desno DOlje trokut
		visible			1
		decoration	
	}
	itemDef		
	{
		style			WINDOW_STYLE_SHADER
		rect			40 448 -16 64 0 0
		origin			0 0
		background		HIGHLIGHT_SHADER_ART
		forecolor		0.45 0.45 0.45 0.2 // Livo Dolje  trokut
		visible			1
		decoration	
	}
	itemDef		
	{
		style			WINDOW_STYLE_SHADER
		rect			-120 464 160 32 0 0
		background		"white"
		forecolor		0.45 0.45 0.45 0.2  // livo pravokuznik dole polozen
		visible			1
		decoration	
	}
	itemDef		
	{
		style			WINDOW_STYLE_SHADER
		rect			600 464 160 32 0 0
		background		"white"
		forecolor		0.45 0.45 0.45 0.2  // desno pravokutnik plozen
		visible			1
		decoration	
	}
#endif

#ifndef PC
	itemDef 	
	{ 
		style			WINDOW_STYLE_SHADER 
		rect			-120 0 420 68 0 0 
		background		"white" 
		forecolor		0 0 1 1
		visible			when( ENABLE_TITLE_BG ); 
		decoration 	
	} 
	itemDef 	
	{ 
		style			WINDOW_STYLE_SHADER 
		rect			300 0 16 -68 0 0 
		origin			0 0 
		background		HIGHLIGHT_SHADER_ART 
		forecolor		0.1 0.2 1 1
		visible			when( ENABLE_TITLE_BG );
		decoration	
	}
	itemDef		
	{
		style			WINDOW_STYLE_SHADER
		rect			-120 414 1200 64 0 0
		background		"white"
		forecolor		1 1 0 1
		visible			when( ENABLE_TITLE_BG && ALT_PANEL );
		decoration	
	}
	itemDef		
	{
		style			WINDOW_STYLE_SHADER
		rect			-120 416 420 64 0 0
		background		"white"
		forecolor		1 0 1 1
		visible			when( ENABLE_TITLE_BG && (ALT_PANEL == 0) );
		decoration	
	}
	itemDef		
    {
		style			WINDOW_STYLE_SHADER
		rect			300 416 16 64 0 0
		origin			0 0
		background		HIGHLIGHT_SHADER_ART
		forecolor		1 0.25 0 1
		visible			when( ENABLE_TITLE_BG && (ALT_PANEL == 0) );
		decoration	
	}
	itemDef		
	{
		style			WINDOW_STYLE_SHADER
		rect			316 432 440 64 0 0
		background		"white"
		forecolor		0.1 0.2 1 1
		visible			when( ENABLE_TITLE_BG && (ALT_PANEL == 0) );
		decoration	
	}
#endif

#ifdef PC

	#ifndef BACK_ENABLE
	#define BACK_ENABLE	1
	#endif

	#ifndef BACK_OPEN
	#define BACK_OPEN	open main_text;
	#endif
	
	itemDef 
	{
		name			back
		text			"@MENU_BACK"
		type			1
		style			WINDOW_STYLE_FILLED
		textstyle		ITEM_TEXTSTYLE_SHADOWED
		rect			-250 -26 40 20 HORIZONTAL_ALIGN_CENTER VERTICAL_ALIGN_BOTTOM
		textfont		UI_FONT_NORMAL
		textalign		ITEM_ALIGN_LEFT
		textscale		TEXTSIZE_SMALL
		textaligny		18
		visible			when(BACK_ENABLE);
		mouseEnter		{ play "mouse_over"; }
		action 
		{
			play "mouse_click";
			close self;
			BACK_OPEN
		}	
	}
	
#endif // #ifdef PC