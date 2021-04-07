#include scripts\utility\file;

init()
{
	level.movingEnding = spawn( "script_model", level.endingPoints[ 0 ][ 0 ] );
	level.movingEnding.angles = level.endingPoints[ 0 ][ 1 ];
	level.movingEnding setModel( "tag_origin" );
	level.movingEnding hide();
	
	time = 30;
	waittillframeend;
	
	players = level.players;
	for( i = 0; i < players.size; i++ )
	{
		player = players[ i ];
		player thread spawnEnding();
		player thread endingAngles();
		player setClientDvars( "ui_hud_hardcore", 1,"cg_drawSpectatorMessages", 0,"g_compassShowEnemies", 0 );
	}
	
	if( level.endingPoints.size < 2 )
		return;
	
	fullDist = 0;
	for( i = 1; i < level.endingPoints.size; i++ )
		fullDist += distance( level.endingPoints[ i - 1 ][ 0 ], level.endingPoints[ i ][ 0 ] );
	
	level.endingMoveSpeed = fullDist / time;

	for( i = 1; i < level.endingPoints.size; i++ )
	{
		duration = distance( level.endingPoints[ i - 1 ][ 0 ], level.endingPoints[ i ][ 0 ] ) / level.endingMoveSpeed;
		level.movingEnding moveTo( level.endingPoints[ i ][ 0 ], duration );
		level.movingEnding rotateTo( level.endingPoints[ i ][ 1 ], duration );
		wait duration;
	}
}

setStuff()
{
	array = 0;
	array = [];
	switch( toLower( getDvar( "mapname" ) ) )
	{
		case "mp_backlot":
			array[ array.size ] = (-143.145, -2646.37, 179.588);
			array[ array.size ] = (3.67493, 89.0717, 0);
			array[ array.size ] = (-134.711, -2125.92, 197.96);
			array[ array.size ] = (3.67493, 89.0717, 0);
			array[ array.size ] = (-169.895, -1642.84, 232.569);
			array[ array.size ] = (4.87793, 94.5154, 0);
			array[ array.size ] = (-215.121, -1159.64, 232.569);
			array[ array.size ] = (6.32813, 84.3695, 0);
			array[ array.size ] = (-120.252, -742.343, 232.569);
			array[ array.size ] = (7.25098, 68.4943, 0);
			array[ array.size ] = (78.4288, -327.762, 232.569);
			array[ array.size ] = (7.42676, 58.3649, 0);
			array[ array.size ] = (491.925, 19.9053, 300.147);
			array[ array.size ] = (7.6355, 36.1725, 0);
			array[ array.size ] = (903.28, 346.842, 300.147);
			array[ array.size ] = (9.68994, 42.8247, 0);
			array[ array.size ] = (1421.22, 848.357, 300.147);
			array[ array.size ] = (13.8977, 42.7533, 0);
			break;
			
		case "mp_citystreets":
			array[ array.size ] = (2795.91, 810.76, 345.177);
			array[ array.size ] = (15.4852, -85.3491, 0);
			array[ array.size ] = (2840.02, 268.82, 177.134);
			array[ array.size ] = (13.7164, -85.2777, 0);
			array[ array.size ] = (2875.55, -140.779, 71.7937);
			array[ array.size ] = (8.72864, -84.5361, 0);
			array[ array.size ] = (2950.52, -627.434, 71.7937);
			array[ array.size ] = (7.81128, -75.5878, 0);
			array[ array.size ] = (2996.57, -1040.29, 71.7937);
			array[ array.size ] = (6.56982, -89.3756, 0);
			array[ array.size ] = (2955.37, -1585.19, 71.7937);
			array[ array.size ] = (7.34985, -97.6538, 0);
			array[ array.size ] = (2983.57, -2059.4, 71.7937);
			array[ array.size ] = (8.05847, -81.2073, 0);
			array[ array.size ] = (2960.14, -2548.53, 71.7937);
			array[ array.size ] = (7.42126, -119.967, 0);
			break;
		
		case "mp_crash":
		case "mp_crash_snow":
			array[ array.size ] = (1054.76, -721.808, 363.912);
			array[ array.size ] = (11.8817, 143.289, 0);
			array[ array.size ] = (751.575, -542.137, 363.912);
			array[ array.size ] = (14.8535, 134.341, 0);
			array[ array.size ] = (503.145, -396.441, 298.596);
			array[ array.size ] = (17.2211, 115.988, 0);
			array[ array.size ] = (232.125, -35.3397, 298.596);
			array[ array.size ] = (16.441, 88.9069, 0);
			array[ array.size ] = (354.919, 326.268, 298.596);
			array[ array.size ] = (11.3159, 40.7648, 0);
			array[ array.size ] = (653.949, 570.573, 298.596);
			array[ array.size ] = (11.0303, 39.1937, 0);
			array[ array.size ] = (1147.17, 1021.98, 298.596);
			array[ array.size ] = (11.0303, 49.6967, 0);
			break;
		
		case "mp_crossfire":
			array[ array.size ] = (5447.18, -2141.09, 143.832);
			array[ array.size ] = (4.10339, 130.538, 0);
			array[ array.size ] = (4912.82, -1631.7, 123.15);
			array[ array.size ] = (4.70215, 141.639, 0);
			array[ array.size ] = (4420, -1340.69, 72.2144);
			array[ array.size ] = (4.84497, 155.856, 0);
			array[ array.size ] = (3662.6, -897.086, 72.2144);
			array[ array.size ] = (5.16357, 134.108, 0);
			array[ array.size ] = (3461.06, -522.221, 78.1446);
			array[ array.size ] = (4.31213, 96.7658, 0);
			array[ array.size ] = (3464.77, 134.899, 78.1446);
			array[ array.size ] = (3.46619, 78.0286, 0);
			array[ array.size ] = (3509.27, 1237.39, 78.1446);
			array[ array.size ] = (3.46619, 96.3977, 0);
			break;
		
		case "mp_strike":
			array[ array.size ] = (-2235.26, 54.6286, 194.778);
			array[ array.size ] = (4.91638, -22.8186, 0);
			array[ array.size ] = (-1886.67, -73.6843, 194.778);
			array[ array.size ] = (4.06494, -17.1991, 0);
			array[ array.size ] = (-1390.22, -177.71, 194.778);
			array[ array.size ] = (3.81775, -6.30615, 0);
			array[ array.size ] = (-554.717, -218.721, 194.778);
			array[ array.size ] = (3.8562, -1.32385, 0);
			array[ array.size ] = (-58.3819, -152.318, 194.778);
			array[ array.size ] = (10.3986, 24.95, 0);
			array[ array.size ] = (353.996, 93.9715, 194.778);
			array[ array.size ] = (8.47046, 44.5056, 0);
			array[ array.size ] = (533.165, 492.633, 194.778);
			array[ array.size ] = (6.86096, 86.2097, 0);
			break;
		
		case "mp_vacant":
			array[ array.size ] = (-983.715, -1277.43, 10.5097);
			array[ array.size ] = (2.90039, 89.7693, 0);
			array[ array.size ] = (-980.542, -489.911, 10.5097);
			array[ array.size ] = (2.90039, 89.7693, 0);
			array[ array.size ] = (-1051.48, 634.467, 10.5097);
			array[ array.size ] = (2.04895, 70.9607, 0);
			array[ array.size ] = (-724.291, 983.923, 10.5097);
			array[ array.size ] = (0.422974, 32.9865, 0);
			array[ array.size ] = (-221.002, 1235.61, 10.5097);
			array[ array.size ] = (1.16455, 21.8079, 0);
			array[ array.size ] = (164.353, 1426.93, 111.357);
			array[ array.size ] = (4.1748, 23.8293, 0);
			break;
			
		case "mp_broadcast":
			array[ array.size ] = (-1702.85, 938.383, 131.184);
			array[ array.size ] = (11.5302, 56.944, 0);
			array[ array.size ] = (-1249.72, 1632.92, 131.184);
			array[ array.size ] = (11.2445, 54.1534, 0);
			array[ array.size ] = (-826.844, 1995.49, 191.492);
			array[ array.size ] = (7.0697, 29.3683, 0);
			array[ array.size ] = (-516.317, 2249.64, 191.492);
			array[ array.size ] = (3.74634, -19.9603, 0);
			array[ array.size ] = (-46.8097, 2387.1, 191.492);
			array[ array.size ] = (4.06494, -47.6074, 0);
			array[ array.size ] = (748.583, 2359.01, 191.492);
			array[ array.size ] = (4.50989, -79.9292, 0);
			array[ array.size ] = (1339.8, 1742.11, 124.712);
			array[ array.size ] = (6.68518, -101.429, 0);
			break;
		
		case "mp_naout":
			array[ array.size ] = (277.819, -1277.81, 305.695);
			array[ array.size ] = (6.82251, 105.062, 0);
			array[ array.size ] = (169.57, -889.659, 305.695);
			array[ array.size ] = (7.84973, 112.242, 0);
			array[ array.size ] = (-8.42813, -445.122, 305.695);
			array[ array.size ] = (8.09692, 107.891, 0);
			array[ array.size ] = (-177.057, -47.7558, 305.695);
			array[ array.size ] = (7.10815, 97.5311, 0);
			array[ array.size ] = (-272.473, 340.537, 305.695);
			array[ array.size ] = (3.92761, 59.8096, 0);
			array[ array.size ] = (-31.7911, 594.447, 363.629);
			array[ array.size ] = (4.20776, 11.3983, 0);
			array[ array.size ] = (359.192, 641.604, 363.629);
			array[ array.size ] = (4.63074, -3.66394, 0);
			array[ array.size ] = (700.42, 542.512, 363.629);
			array[ array.size ] = (6.25671, -31.5253, 0);
			break;
			
		case "mp_marketcenter":
			array[ array.size ] = (2085.62, 1681.5, 292.462);
			array[ array.size ] = (8.31116, -122.926, 0);
			array[ array.size ] = (1892.57, 1325, 218.74);
			array[ array.size ] = (10.0415, -127.491, 0);
			array[ array.size ] = (1547.87, 901.361, 154.273);
			array[ array.size ] = (5.25146, -143.19, 0);
			array[ array.size ] = (1166.05, 438.466, 163.111);
			array[ array.size ] = (5.16357, -152.611, 0);
			array[ array.size ] = (630.515, 221.433, 72.4249);
			array[ array.size ] = (4.03198, -165.641, 0);
			array[ array.size ] = (13.4318, 22.7564, 72.4249);
			array[ array.size ] = (2.72461, 179.583, 0);
			array[ array.size ] = (-345.857, 245.743, 154.006);
			array[ array.size ] = (3.14758, 122.866, 0);
			array[ array.size ] = (-628.404, 1027.79, 154.006);
			array[ array.size ] = (4.10339, 101.261, 0);
			break;
		
		case "mp_toujane_beta":
			array[ array.size ] = (182.175, 28.6012, 150.979);
			array[ array.size ] = (6.64673, 26.1951, 0);
			array[ array.size ] = (525.283, 270.653, 150.979);
			array[ array.size ] = (6.08093, 11.6657, 0);
			array[ array.size ] = (1240.49, 301.914, 150.979);
			array[ array.size ] = (6.22375, -1.76513, 0);
			array[ array.size ] = (1654.07, 311.352, 150.979);
			array[ array.size ] = (4.98779, 41.543, 0);
			array[ array.size ] = (1978.86, 748.263, 150.979);
			array[ array.size ] = (3.71338, 64.6692, 0);
			array[ array.size ] = (2207.87, 1081.67, 150.979);
			array[ array.size ] = (3.60901, 42.6416, 0);
			array[ array.size ] = (2770.58, 1313.6, 293.157);
			array[ array.size ] = (-6.11389, 20.1141, 0);
			break;
			
		case "mp_slick":
			array[ array.size ] = (1381.64, -336.401, 20);
			array[ array.size ] = (0.0823975, 94.812, 0);
			array[ array.size ] = (1340.54, 511.113, 24);
			array[ array.size ] = (-4.22424, 91.2305, 0);
			array[ array.size ] = (1291.16, 1284.42, 248);
			array[ array.size ] = (-0.131836, 96.2128, 0);
			array[ array.size ] = (1098.61, 2086.21, 395.78);
			array[ array.size ] = (2.20825, 118.169, 0);
			array[ array.size ] = (754.204, 2691.74, 493.781);
			array[ array.size ] = (7.03125, 127.705, 0);
			array[ array.size ] = (174.224, 3302.48, 493.781);
			array[ array.size ] = (7.72888, 135.192, 0);
			array[ array.size ] = (-419.987, 4028.74, 493.781);
			array[ array.size ] = (6.92139, 119.081, 0);
			break;
		
		default:
			array[ array.size ] = ( -50, 50, 400 );
			array[ array.size ] = ( 0, 0, 0 );
			break;
	}
	n = 0;
	points = array.size / 2;
	for( i = 0; i < points; i++ )
	{
		level.endingPoints[ i ][ 0 ] = array[ n ];
		level.endingPoints[ i ][ 1 ] = array[ n + 1 ];
		n += 2;
		
	}
}

spawnEnding()
{
	self.sessionstate = "spectator";
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.friendlydamage = undefined;
	
	self.statusicon = "";
	
	waittillframeend;
	self hide();
	self disableWeapons();
	self freezeControls( true );
	
	self linkTo( level.movingEnding, "tag_origin", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	self setPlayerAngles( level.movingEnding.angles );
}

endingAngles()
{
	self endon( "disconnect" );
	
	for( ;; )
	{
		self setPlayerAngles( level.movingEnding.angles );
		wait .05;
	}
}

toVector( string )
{
/* 	cleanedString = "";
	for( i = 1; i < string.size - 1; i++ )
		cleanedString += string[ i ];
	
	vec3 = strTok( cleanedString, ", " );
	
	return ( float( vec3[ 0 ] ), float( vec3[ 1 ] ), float( vec3[ 2 ] ) ); */
}

editor()
{
	array = [];
	while( isAlive( self ) )
	{
		if( self useButtonPressed() )
		{
			array[ array.size ] = self GetEye() + ( 0, 0, 20 );
			array[ array.size ] = self getPlayerAngles();
			addSth( array[ array.size - 2 ], array[ array.size - 1 ], array.size - 2 );
			iPrintLnBold( "Point Added!" );
			wait .5;
		}
		
		if( self meleeButtonPressed() )
		{
			if( array.size < 1 )
				iPrintLnBold( "All points have been removed!" );
			else
			{
				remSth( array.size - 2 );
				array[ array.size - 1 ] = undefined;
				array[ array.size - 1 ] = undefined;
				iPrintLnBold( "Point Removed!" );
				if( array.size < 1 )
					iPrintLnBold( "All points have been removed!" );
			}
			
			wait .5;
		}
		
		if( self fragButtonPressed() ) // reload -> frag 
		{
			filename = "./db_map/" + toLower( getDvar( "mapname" ) ) + ".db";
			writeToFile( filename, array );
			iPrintLnBold( "Points have been saved to file!" );
			break;
		}
		
		wait .05;
	}
}

addSth( origin, angle, num )
{
	level.editorPoint[ num ] = spawn( "script_model", origin );
	level.editorPoint[ num ].angles = angle;
	level.editorPoint[ num ] setModel( "projectile_cbu97_clusterbomb" );
	level.editorFX[ num ] = addFX( origin );
}

remSth( num )
{
	if( isDefined( level.editorPoint[ num ] ) )
		level.editorPoint[ num ] delete();
	
	if( isDefined( level.editorFX[ num ] ) )
		level.editorFX[ num ] delete();
}

addFX( origin )
{
	effect = spawnFx( level.pointEffext, origin - ( 0, 0, 60 ), (0,0,1), (1,0,0) );
	triggerFx( effect );
	
	return effect;
}