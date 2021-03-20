player(response)
{
	self endon ( "disconnect" );
	
	switch(response)
	{
		// GENRE SELECTION
        case "hardbass":
			if(self getstat(2901) == 0 )
			{
				self setstat(2901,1);
				self setstat(1224,1);
			}
		    else if(self getstat(2901) == 1 )
				self setstat(2901,0);
		break;

        case "edm":
			if(self getstat(2902) == 0 )
			{
				self setstat(2902,1);
				self setstat(1224,1);
			}
		    else if(self getstat(2902) == 1 )
				self setstat(2902,0);
		break;
		
		case "rock":
			if(self getstat(2903) == 0 )
			{
				self setstat(2903,1);
				self setstat(1224,1);
			}
		    else if(self getstat(2903) == 1 )
				self setstat(2903,0);
		break;

		case "pop":
			if(self getstat(2904) == 0 )
			{
				self setstat(2904,1);
				self setstat(1224,1);
			}
		    else if(self getstat(2904) == 1 )
				self setstat(2904,0);
		break;

		case "troll":
			if(self getstat(2905) == 0 )
			{
				self setstat(2905,1);
				self setstat(1224,1);
			}
		    else if(self getstat(2905) == 1 )
				self setstat(2905,0);
		break;
		
		case "balkan":
			if(self getstat(2906) == 0 )
			{
				self setstat(2906,1);
				self setstat(1224,1);
			}
		    else if(self getstat(2906) == 1 )
				self setstat(2906,0);
		break;
		
		case "trap":
			if(self getstat(2907) == 0 )
			{
				self setstat(2907,1);
				self setstat(1224,1);	
			}
		    else if(self getstat(2907) == 1 )
		break;
		
		case "rave":
			if(self getstat(2908) == 0 )
			{
				self setstat(2908,1);
				self setstat(1224,1);
			}
		    else if(self getstat(2908) == 1 )
				self setstat(2908,0);
		break;
		
		case "musicoff":
			if(self getstat(1224) == 0 )
			{
				self setstat(1224,1);
			}
		       else if(self getstat(1224) == 1 )
			{
				self setstat(1224,0);
				self setStat(2908,0);
				self setStat(2907,0);
				self setStat(2906,0);
				self setStat(2905,0);
				self setStat(2904,0);
				self setStat(2903,0);
				self setStat(2902,0);
				self setStat(2901,0);					
			}
		break;		
		
		// FOV
		case "fov1":
			self setstat(1322,2);
			self setClientDvar( "cg_fovscale", 1 );
			break;
			
		case "fov2":
			self setstat(1322,3);
			self setClientDvar( "cg_fovscale", 1.1 );
			break;

		case "fov3":
			self setstat(1322,4);
			self setClientDvar( "cg_fovscale", 1.15 );
			break;

		case "fov4":
			self setstat(1322,5);
			self setClientDvar( "cg_fovscale", 1.20 );
			break;

		case "fov5":
			self setstat(1322,6);
			self setClientDvar( "cg_fovscale", 1.25 );
			break;

		case "fov6":
			self setstat(1322,7);
			self setClientDvar( "cg_fovscale", 1.30 );
			break;

		case "fov7":
			self setstat(1322,8);
			self setClientDvar( "cg_fovscale", 1.35 );
			break;

		case "fov8":
			self setstat(1322,9);
			self setClientDvar( "cg_fovscale", 1.40 );
			break;

		case "fov9":
			self setstat(1322,10);
			self setClientDvar( "cg_fovscale", 1.45 );
			break;

		case "fpson":
			self setClientDvar( "r_fullbright", 1 );
			self setstat(1222,1);
			break;
	
		case "fpsoff":
			self setClientDvar( "r_fullbright", 0 );
			self setstat(1222,0);
			break;
				
		// EMBLEMS
		case "emblem_default":
			self duffman\killcard::setDesign("default");
			break;
			
		case "emblem_blue":
			self duffman\killcard::setDesign("blue");
			break;
			
		case "emblem_red":
			self duffman\killcard::setDesign("red");
			break;
			
		case "emblem_green":
			self duffman\killcard::setDesign("green");
			break;
			
		case "emblem_yellow":
			self duffman\killcard::setDesign("yellow");
			break;
			
		case "emblem_member":
			//TODO: Status check
			self duffman\killcard::setDesign("member");
			break;
	}
}