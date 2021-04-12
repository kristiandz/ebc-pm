init()
{
	scripts\_eventmanager::init();
	
	level thread scripts\utility\common::load();
	level thread scripts\player_stats::main();
	level thread scripts\cmd::main();
	
	thread duffman\onlymode::init();
	thread duffman\kdratio::init();
	thread duffman\killcard::init();
	thread duffman\engine_fixes::init();
	
	thread duffman\_antiafk::init();
	thread duffman\_walls::main();
}