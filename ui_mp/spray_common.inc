#define plevel (stat(2326)+1)
#define SPRAY_TABLE "mp/sprayTable.csv"
#define CHAR_TABLE "mp/characterTable.csv"

#ifndef BUTTON_ALIGN
#define BUTTON_ALIGN HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN
#endif

#define SPRAY( row, column, itemID ) \
itemDef \
{ \
	rect			70 59 44 34 BUTTON_ALIGN \
	origin			(48*row) (45*column) \
	style			WINDOW_STYLE_SHADER \
	exp				material( tableLookup(SPRAY_TABLE, 0, itemID, 3) ) \
	visible			1 \
	border			1 \
	bordercolor		0 0 0 1 \
	decoration \
} \
itemDef \
{ \
	rect			70 59 44 34 BUTTON_ALIGN \
	origin			(48*row) (45*column) \
	style			WINDOW_STYLE_SHADER \
	background		"black" \
	forecolor		0 0 0 0.8 \
	visible			when( plevel < tableLookup(SPRAY_TABLE, 0, itemID, 2) ) \
	decoration \
} \
itemDef \
{ \
	visible		when( plevel < tableLookup(SPRAY_TABLE, 0, itemID, 2) ) \
	rect		70 59 0 0 BUTTON_ALIGN \
	origin		(48*row) (45*column) \
	textalignx	24 \
	textaligny	44 \
	forecolor	1 1 1 0.8 \
	exp			text( "^1Prestige:" + (tableLookup(SPRAY_TABLE, 0, itemID, 2) )-1) \
	textfont	UI_FONT_NORMAL \
	textalign	ITEM_ALIGN_CENTER \
	textscale	0.19 \
	decoration \
} \
itemDef \
{ \
	style		WINDOW_STYLE_FILLED \
	rect		70 59 44 34 BUTTON_ALIGN \
	origin		(48*row) (45*column) \
	forecolor	1 1 1 0.8 \
	type		ITEM_TYPE_BUTTON \
	exp			text( " " ) \
	textfont	UI_FONT_NORMAL \
	textstyle	ITEM_TEXTSTYLE_SHADOWED \
	textalign	ITEM_ALIGN_LEFT \
	textscale	0.32 \
	textalignx	70 \
	textaligny	22 \
	visible		1 /*unlocked*/ \
	mouseEnter \
	{ \
		play "mouse_over"; \
	} \
	action \
	{ \
		scriptMenuResponse itemID; \
		close self; \
	} \
} 

#define CHARACTER( row, column, itemID ) \
itemDef \
{ \
	rect			70 230 44 34 BUTTON_ALIGN \
	origin			(48*row) (45*column) \
	style			WINDOW_STYLE_SHADER \
	exp				material( tableLookup(CHAR_TABLE,0,(itemID-40),3) ) \
	visible			1 \
	border			1 \
	bordercolor		0 0 0 1 \
	decoration \
} \
itemDef \
{ \
	rect			70 230 44 34 BUTTON_ALIGN \
	origin			(48*row) (45*column) \
	style			WINDOW_STYLE_SHADER \
	background		"black" \
	forecolor		0 0 0 0.8 \
	visible			when( plevel < tableLookup(CHAR_TABLE, 0, (itemID-40), 2) ) \
	decoration \
} \
itemDef \
{ \
	visible		when( plevel < tableLookup(CHAR_TABLE, 0 , (itemID-40), 2) ) \
	rect		70 230 0 0 BUTTON_ALIGN \
	origin		(48*row) (45*column) \
	textalignx	24 \
	textaligny	44 \
	forecolor	1 1 1 0.8 \
	exp			text( "^1Prestige:" + (tableLookup(CHAR_TABLE, 0, (itemID-40), 2) )-1) \
	textfont	UI_FONT_NORMAL \
	textalign	ITEM_ALIGN_CENTER \
	textscale	0.19 \
	decoration \
} \
itemDef \
{ \
	style		WINDOW_STYLE_FILLED \
	rect		70 230 44 34 BUTTON_ALIGN \
	origin		(48*row) (45*column) \
	forecolor	1 1 1 0.8 \
	type		ITEM_TYPE_BUTTON \
	exp			text( "  " ) \
	textfont	UI_FONT_NORMAL \
	textstyle	ITEM_TEXTSTYLE_SHADOWED \
	textalign	ITEM_ALIGN_CENTER \
	textscale	0.2 \
	textalignx	0 \
	textaligny	45 \
	visible     1 \
	mouseEnter \
	{ \
		play "mouse_over"; \
	} \
	action \
	{ \
		scriptMenuResponse itemID; \
		close self; \
	} \
} 