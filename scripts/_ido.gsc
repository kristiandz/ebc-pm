#include maps\mp\gametypes\_hud_util;
#include scripts\utility\_utility;

circleTime(time)
{		
	level.hud_circleTimer = time; 
	for(i = 1; i <= level.hud_circleTimer;i ++)
		createCircleHud(i);
		
	while( time > 0 && isDefined(level.hud_circleTime))
	{
		if(isDefined(level.hud_circleTime[time]))
		{
			level.hud_circleTime[time] thread fontPulse( level );
			level.hud_circleTime[time].color = game["colors"]["blue"];
			
			if(isDefined(level.hud_circleTime[time+1]))
				level.hud_circleTime[time+1].color = (1,1,1);
		}
		wait 1;
		time--;
	}
	for( i = 1; i <= level.hud_circleTimer;i++)
	{
		level.hud_circleTime[i] fadeOverTime(0.2);
		level.hud_circleTime[i].alpha = 0;
		wait 0.2;
		level.hud_circleTime[i] destroy();
	}
}

remapTime(time)
{
	remapped = remap(time,1,level.hud_circleTimer,0,180); // change 180 to 360 for full circle
	return remapped;
}

createCircleHud(time)
{
	if(!isDefined(level.hud_circleTime))
		level.hud_circleTime = [];
		
	size = time;
	level.hud_circleTime[size] = newHudElem();
	level.hud_circleTime[size].horzAlign = "center";
	level.hud_circleTime[size].vertAlign = "middle";
	level.hud_circleTime[size].alignX = "center";
	level.hud_circleTime[size].alignY = "middle";
	level.hud_circleTime[size] set_origin_in_circle(remapTime(size));
	level.hud_circleTime[size].font = "default";
	level.hud_circleTime[size].fontscale = 1.4;
	level.hud_circleTime[size].alpha = 1;
	level.hud_circleTime[size] setValue(size);
	level.hud_circleTime[size] thread fontPulseInit();
	level.hud_circleTime[size] thread move_in_circle(size);
}

set_origin_in_circle(yx)
{
	r = 60;
	self.xy = yx;
	self.x = r * cos( yx );
	self.y = /*0 - */r * sin( yx ); //remove comments for flip:D
}

move_in_circle(size)
{
	while(isDefined(self))
	{
	r = 60;
	self moveOverTime(level.hud_circleTimer);
	self.x = r * cos(remapTime(size+3));
	self.y = /*0 - */r * sin(remapTime(size+3)); //remove comments for flip:D
	wait level.hud_circleTimer;
	}
}

fontPulseInit()
{
	self.baseFontScale = self.fontScale;
	self.maxFontScale = self.fontScale * 2;
	self.inFrames = 3; 
	self.outFrames = 5;
}

fontPulse(player)
{
	self notify ( "fontPulse" );
	self endon ( "fontPulse" );	
	player endon("disconnect");
	player endon("joined_team");
	player endon("joined_spectators");	
	scaleRange = self.maxFontScale - self.baseFontScale;
	while ( self.fontScale < self.maxFontScale && isDefined(self) )	
	{
		self.fontScale = min( self.maxFontScale, self.fontScale + (scaleRange / self.inFrames) );
		wait 0.05;
	}	
	while ( self.fontScale > self.baseFontScale && isDefined(self) )	
	{
		self.fontScale = max( self.baseFontScale, self.fontScale - (scaleRange / self.outFrames) );
		wait 0.05;
	}
}

setStarttime( time )
{
	self thread fontPulseInit();
	self thread strTime( time );
}

strTime( time )
{
	self.alpha = 0;
	self.x += 10;
	while( isDefined( self ) && time > 0)
	{
		self setValue( time );
		self thread fontPulse( self );
		self fadeOverTime( 0.3 );
		self.alpha = 1;
		self.Color = (0.0, 0.8, 0.0);
		self moveOverTime( 0.3 );
		self.x -= 10;
		wait 0.7;
		self moveOverTime( 0.3 );
		self.x -= 10;
		self fadeOverTime( 0.3 );
		self.alpha = 0;
		time --;
		wait 0.3;
		self.x += 20;
	}
	self destroyElem();
}