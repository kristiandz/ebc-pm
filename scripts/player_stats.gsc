#include scripts\utility\common;

main()
{
    addConnectThread(::onPlayerConnect);
}

onPlayerConnect()
{
	fov = self getstat(1322);
	fps = self getstat(1222);
	self getstat(252);

	switch(fov)
	{
		case 1 :	
			self setClientDvar( "cg_fovscale", 1.50 );
			break;		
		case 2 :	
			self setClientDvar( "cg_fovscale", 1 );
			break;			
		case 3 :	
			self setClientDvar( "cg_fovscale", 1.125 );
			break;		
		case 4 :	
			self setClientDvar( "cg_fovscale", 1.15 );
			break;	
		case 5 :	
			self setClientDvar( "cg_fovscale", 1.20 );
			break;	
		case 6 :	
			self setClientDvar( "cg_fovscale", 1.25 );
			break;	
		case 7 :	
			self setClientDvar( "cg_fovscale", 1.30 );
			break;	
		case 8 :	
			self setClientDvar( "cg_fovscale", 1.35 );
			break;	
		case 9 :	
			self setClientDvar( "cg_fovscale", 1.40 );
			break;	
		case 10 :	
			self setClientDvar( "cg_fovscale", 1.45 );
			break;			
	}
	switch(fps)
	{
		case 1 :
			self setClientDvar( "r_fullbright", 1 );
			break;
		case 0 :
			self setClientDvar( "r_fullbright", 0 );
			break;
	}
}