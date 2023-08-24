#include scripts\utility\_utility;

init()
{
	if(isDefined(level.modinfo)) level.modinfo destroy();

	level.modinfo = newHudElem();
	level.modinfo.x = 220;
	level.modinfo.y = -10;
	level.modinfo.alignX = "center";
	level.modinfo.alignY = "bottom";
	level.modinfo.horzAlign = "center";
	level.modinfo.vertAlign = "bottom";
	level.modinfo.fontScale = 1.4;
	level.modinfo.glowcolor = (0.8,0.2,0.2);
	level.modinfo.glowalpha = 0.4;
	level.modinfo.sort = 2002;

	modtxt[0] = "Info text here";
	modtxt[1] = "Info text here";
	
	for(;;)
	{
		for(mi=0;mi<modtxt.size;mi++)
		{
			level.modinfo setText(modtxt[mi]);
			level.modinfo fadeOverTime(1);
			level.modinfo.alpha = 1;
			level.modinfo moveOverTime(1);
			level.modinfo.y = -10;

			if(mi == 0)
				wait 12;
			else wait 8;

			level.modinfo fadeOverTime(1);
			level.modinfo.alpha = 0;
			level.modinfo moveOverTime(1);
			level.modinfo.y = 10;
			wait 10;
		}
	}
}