#define PLAYERSTATS_WIDTH 		265

#ifdef PC
	#define PLAYERSTATS_X			((-(PLAYERSTATS_WIDTH - RIGHTITEM_OFFSET))-80)
	#define PLAYERSTATS_Y			103
	#define FRAME_BG_COLOR			0.1 0.1 0.1 0.3
#else
	#define PLAYERSTATS_X			(-(PLAYERSTATS_WIDTH - RIGHTITEM_OFFSET))
	#define PLAYERSTATS_Y			93
	#define FRAME_BG_COLOR			0.1 0.1 0.1 0.3
#endif	

#define ORIGIN_PLAYERSTATS 		PLAYERSTATS_X PLAYERSTATS_Y
	
#define LABEL_ITEM_SPACING		18
#define SUB_LABEL_INDENT		16
	
#define LABEL_START_X			12
#define LABEL_START_Y			LABEL_ITEM_SPACING
#define ORIGIN_LABEL			LABEL_START_X LABEL_START_Y

#define LABEL_TEXTCOLOR			0.8 0.8 0.85 0.8
#define LABEL_TITLECOLOR		0.8 0.8 0.85 0.8

#define ORIGIN_LABEL_ITEM( itemNumber ) \
		LABEL_START_X (LABEL_START_Y+(LABEL_ITEM_SPACING*(itemNumber-1))) 

#define ORIGIN_SUB_LABEL_ITEM( itemNumber ) \
		(LABEL_START_X+SUB_LABEL_INDENT) (LABEL_START_Y+(LABEL_ITEM_SPACING*(itemNumber-1))) 
		
#define ORIGIN_DIVIDER( itemNumber ) \
		0 (LABEL_START_Y+(LABEL_ITEM_SPACING/2)+(LABEL_ITEM_SPACING*(itemNumber-1))) 

#define PREPROC_LABEL( ptext, itemNumber ) \
itemDef { \
	text			ptext \
	rect			ORIGIN_LABEL_ITEM( itemNumber ) (PLAYERSTATS_WIDTH) LABEL_ITEM_SPACING RIGHTITEM_ALIGN VERTICAL_ALIGN_TOP \
	origin			ORIGIN_PLAYERSTATS \
	textfont		UI_FONT_NORMAL \ 
	textstyle 		ITEM_TEXTSTYLE_SHADOWED \
	textscale		TEXTSIZE_SMALL \
	textalign		ITEM_ALIGN_MIDDLE_LEFT \
	forecolor		LABEL_TITLECOLOR \
	visible			1 \
	decoration }
	
#define PREPROC_DIVIDER( itemNumber ) \
	PREPROC_SHADER_DRAW_ALIGNED( ORIGIN_DIVIDER( itemNumber ) (PLAYERSTATS_WIDTH) 1 RIGHTITEM_ALIGN VERTICAL_ALIGN_TOP, ORIGIN_PLAYERSTATS, "white", 1 1 1 0.1, 0, 0, 0 0 0 0 )

#define PREPROC_SUB_LABEL( ptext, itemNumber ) \
	PREPROC_SUB_LABEL_VIS( ptext, itemNumber, 1 )
	
#define PREPROC_SUB_LABEL_VIS( ptext, itemNumber, visArg ) \
itemDef { \
	text			ptext \
	rect			ORIGIN_SUB_LABEL_ITEM( itemNumber ) (PLAYERSTATS_WIDTH) LABEL_ITEM_SPACING RIGHTITEM_ALIGN VERTICAL_ALIGN_TOP \
	origin			ORIGIN_PLAYERSTATS \
	textfont		UI_FONT_NORMAL \ 
	textstyle 		ITEM_TEXTSTYLE_SHADOWED \
	textscale		TEXTSIZE_SMALL \
	textalign		ITEM_ALIGN_MIDDLE_LEFT \
	forecolor		LABEL_TEXTCOLOR \
	visible			visArg \
	decoration }
	
#define PREPROC_VALUE_TEXT( ptext, itemNumber, px_offset, pcolor ) \
		PREPROC_VALUE_TEXT_VIS( ptext, itemNumber, px_offset, pcolor, 1, ITEM_ALIGN_MIDDLE_RIGHT )

#define PREPROC_VALUE_TEXT_LEFT_ALIGNED( ptext, itemNumber, px_offset, pcolor ) \
		PREPROC_VALUE_TEXT_VIS( ptext, itemNumber, px_offset, pcolor, 1, ITEM_ALIGN_MIDDLE_LEFT )
		
#define PREPROC_VALUE_TEXT_VIS( ptext, itemNumber, px_offset, pcolor, visArg, alignment ) \
itemDef { \
	exp				text( ptext ); \
	type			ITEM_TYPE_TEXT \
	rect			ORIGIN_LABEL_ITEM( itemNumber ) (PLAYERSTATS_WIDTH) LABEL_ITEM_SPACING RIGHTITEM_ALIGN VERTICAL_ALIGN_TOP \
	textstyle 		ITEM_TEXTSTYLE_SHADOWED \
	origin			ORIGIN_PLAYERSTATS \
	textfont		UI_FONT_NORMAL \ 
	textalignx		px_offset \
	textscale		TEXTSIZE_SMALL \
	forecolor		pcolor \
	textalign		alignment \
	visible			visArg \
	decoration }
	
#define PREPROC_RANK_ICON( itemNumber, pshader, y_offset ) \
		PREPROC_RANK_ICON_VIS( itemNumber, pshader, y_offset, 1 )

#define PREPROC_RANK_ICON_VIS( itemNumber, pshader, y_offset, visArg ) \
	PREPROC_SHADER_DRAW_ALIGNED_VIS( (LABEL_START_X+PLAYERSTATS_WIDTH-80) (LABEL_START_Y+y_offset+(LABEL_ITEM_SPACING*(itemNumber-1))) 22 22 RIGHTITEM_ALIGN VERTICAL_ALIGN_TOP, ORIGIN_PLAYERSTATS, pshader, 1 1 1 1, 0, 0, 0 0 0 0, visArg )
	
	// UI art
	PREPROC_SHADER_DRAW_ALIGNED( -3 10 (PLAYERSTATS_WIDTH+10) 305 RIGHTITEM_ALIGN VERTICAL_ALIGN_TOP, ORIGIN_PLAYERSTATS, "white", 0 0 0 0.5, 0, 0, 0 0 0 0.5 )

#ifdef PC
	#define FRAME_HEIGHT	340
#else
	#define FRAME_HEIGHT	340
#endif

	PREPROC_LABEL( "@MPUI_RANK_PRE", 1 )				
	PREPROC_VALUE_TEXT_LEFT_ALIGNED( "@"+tablelookup("mp/ranktable.csv",0,stat(252),5), 2, SUB_LABEL_INDENT, LABEL_TITLECOLOR )
	PREPROC_VALUE_TEXT( locString( "@MPUI_LEVEL_N", int(tablelookup("mp/ranktable.csv",0,stat(252),14)) ), 1, -24, LABEL_TITLECOLOR )
	PREPROC_RANK_ICON( 1, tablelookup( "mp/rankIconTable.csv", 0, stat(252), stat(2326)+1 ), -4 )
	
	PREPROC_SUB_LABEL( "@MPUI_XP_PRE", 3 )
	PREPROC_VALUE_TEXT( stat( 2301 ), 3, -24, LABEL_TEXTCOLOR )
	
	PREPROC_DIVIDER( 4 )
	PREPROC_LABEL( "@MPUI_NEXT_RANK_PRE", 5 )
	/* rank name */
	PREPROC_VALUE_TEXT_VIS( "@"+tablelookup("mp/ranktable.csv",0,stat(252)+1,5), 6, SUB_LABEL_INDENT, LABEL_TITLECOLOR, when( CAN_RANK_UP && PRESTIGE_NEXT==0 ), ITEM_ALIGN_MIDDLE_LEFT )
	PREPROC_VALUE_TEXT_VIS( "@MPUI_PRESTIGE", 6, SUB_LABEL_INDENT, LABEL_TITLECOLOR, when( CAN_RANK_UP && PRESTIGE_NEXT ), ITEM_ALIGN_MIDDLE_LEFT )
	PREPROC_VALUE_TEXT_VIS( "@MPUI_NONE", 6, SUB_LABEL_INDENT, LABEL_TITLECOLOR, when( CAN_RANK_UP==0 ), ITEM_ALIGN_MIDDLE_LEFT )
	
	/* display level */
	PREPROC_VALUE_TEXT_VIS( locString( "@MPUI_LEVEL_N", int(tablelookup("mp/ranktable.csv",0,stat(252)+1,14)) ), 5, -24, LABEL_TITLECOLOR, when( CAN_RANK_UP && PRESTIGE_NEXT==0 ), ITEM_ALIGN_MIDDLE_RIGHT )
	PREPROC_VALUE_TEXT_VIS( locString( "@MPUI_LEVEL_N", 1 ), 5, -24, LABEL_TITLECOLOR, when( CAN_RANK_UP && PRESTIGE_NEXT ), ITEM_ALIGN_MIDDLE_RIGHT )
	
	/* next rank icon */
	PREPROC_RANK_ICON_VIS( 5, tablelookup( "mp/rankIconTable.csv", 0, stat(252)+1, stat(2326)+1 ), -4, when( CAN_RANK_UP && PRESTIGE_NEXT==0 ) )
	PREPROC_RANK_ICON_VIS( 5, tablelookup( "mp/rankIconTable.csv", 0, 0, stat(2326)+2 ), -4, when( CAN_RANK_UP && PRESTIGE_NEXT ) )

	PREPROC_SUB_LABEL_VIS( "@MPUI_XP_REQUIRED_PRE", 7, when( CAN_RANK_UP ) )
	/* standard xp */
	PREPROC_VALUE_TEXT_VIS( int(tableLookup( "mp/rankTable.csv", 0, stat(252), 7) - stat( 2301 )), 7, -86, LABEL_TEXTCOLOR, when( CAN_RANK_UP ), ITEM_ALIGN_MIDDLE_RIGHT )

	PREPROC_SHADER_DRAW_ALIGNED_VIS( 200 127 60 14 RIGHTITEM_ALIGN VERTICAL_ALIGN_TOP, ORIGIN_PLAYERSTATS, "white", 0.1 0.1 0.1 0.35, 1, 1, 1 1 1 0.2,  when( CAN_RANK_UP ) )
	PREPROC_SHADER_DRAW_ADV_VIS( (PLAYERSTATS_X+202), (PLAYERSTATS_Y+93+36), -58*((int(tableLookup( "mp/rankTable.csv", 0, stat(252), 2 )) - stat(2301)) / int(tableLookup( "mp/rankTable.csv", 0, stat(252), 3 ))), 12, "gradient_fadein", 0.2 0.2 0.6 0.6, 0, 1, 0 0 1 1 rect 0 0 60 0  RIGHTITEM_ALIGN VERTICAL_ALIGN_TOP, when( CAN_RANK_UP ) )
	
	PREPROC_DIVIDER( 8 )	
	PREPROC_LABEL( "@MPUI_SCORE_PRE", 9)	
	PREPROC_VALUE_TEXT( stat(2302), 9, -24, LABEL_TITLECOLOR )	
	
	PREPROC_DIVIDER( 10 )	
	
	PREPROC_LABEL( "Prestige Level", 11)	
	PREPROC_VALUE_TEXT( stat(2326), 11, -24, LABEL_TITLECOLOR )	
	
	PREPROC_DIVIDER( 12 )
	
	PREPROC_LABEL( "@MPUI_KILLS_PRE", 13)
	PREPROC_VALUE_TEXT( stat(2303), 13, -24, LABEL_TITLECOLOR )
	
	PREPROC_LABEL( "@MPUI_DEATHS_PRE", 14)
	PREPROC_VALUE_TEXT( stat(2305), 14, -24, LABEL_TITLECOLOR )
	
	PREPROC_DIVIDER( 15 )	
	PREPROC_LABEL( "@MPUI_TIME_PLAYED_PRE", 16 )	
	PREPROC_VALUE_TEXT( secondsAsTime( stat( 2311 ) + stat( 2312 ) + stat( 2313 ) ), 16, -24, LABEL_TITLECOLOR )
