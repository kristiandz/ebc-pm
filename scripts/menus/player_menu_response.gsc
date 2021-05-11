player(response)
{
	self endon ( "disconnect" );
	
	if(!isDefined(self.pers["design"]))
		self.pers["design"] = "Default";
	
	self setClientDvar("ui_killcard", self.pers["design"] );
	
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
				self setstat(1224,1);
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
		case "kc_default":
			self duffman\killcard::setDesign("Default",1);
			self setClientDvar("ui_killcard",self.pers["design"]);
			break;
			
		case "kc_blue":
			self duffman\killcard::setDesign("Blue",1);
			self setClientDvar("ui_killcard",self.pers["design"]);
			break;
			
		case "kc_red":
			self duffman\killcard::setDesign("Red",1);
			self setClientDvar("ui_killcard",self.pers["design"]);
			break;
			
		case "kc_green":
			self duffman\killcard::setDesign("Green",1);
			self setClientDvar("ui_killcard",self.pers["design"]);
			break;
			
		case "kc_yellow":
			self duffman\killcard::setDesign("Yellow",1);
			self setClientDvar("ui_killcard",self.pers["design"]);
			break;
			
		case "kc_member":
			if(!isDefined(self.pers["status"]))
				self iprintLn("^8Unauthorized");
			else if(self.pers["status"] == "Member" || self.pers["status"] == "Senior" || self.pers["status"] == "Leader" && self GetStat(3333) >= 1 )
			{
				self duffman\killcard::setDesign("Member",1);
				self setClientDvar("ui_killcard",self.pers["design"]);
			}
			else self iprintLn("^8Unauthorized");
			break;
	}
}