#include scripts\utility\common;

main()
{
    addConnectThread(::onPlayerConnect);
}

onPlayerConnect()
{
	fov = self getstat(1322);
	fps = self getstat(1222);

	challenge1 = scripts\utility\challenge_utility::getChallengeData(self getstat(3117));
	self setClientDvar("ui_challenge_1", challenge1[0]);
	self setClientDvar("ui_challenge_stats_1", challenge1[3]);
	self setClientDvar("ui_challenge_stats_2", challenge1[4]);

	challenge2 = scripts\utility\challenge_utility::getChallengeData(self getstat(3118));
	self setClientDvar("ui_challenge_2", challenge2[0]);
	self setClientDvar("ui_challenge_stats_3", challenge2[3]);
	self setClientDvar("ui_challenge_stats_4", challenge2[4]);

	switch(fov)
	{
		case 1:	
			self setClientDvar("cg_fovscale", 1.50);
			break;		
		case 2:	
			self setClientDvar("cg_fovscale", 1);
			break;			
		case 3:	
			self setClientDvar("cg_fovscale", 1.125);
			break;		
		case 4:	
			self setClientDvar("cg_fovscale", 1.15);
			break;	
		case 5:	
			self setClientDvar("cg_fovscale", 1.20);
			break;	
		case 6:	
			self setClientDvar("cg_fovscale", 1.25);
			break;	
		case 7:	
			self setClientDvar("cg_fovscale", 1.30);
			break;	
		case 8:	
			self setClientDvar("cg_fovscale", 1.35);
			break;	
		case 9:	
			self setClientDvar("cg_fovscale", 1.40);
			break;	
		case 10:	
			self setClientDvar("cg_fovscale", 1.45);
			break;			
	}
	switch(fps)
	{
		case 1:
			self setClientDvar("r_fullbright", 1);
			break;
		case 0:
			self setClientDvar("r_fullbright", 0);
			break;
	}
}