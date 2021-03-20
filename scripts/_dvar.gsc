setupDvars()
{
	level.dvar = [];
	addDvar( "sprays", "dr_sprays", 1, 0, 1, "int" );
	addDvar( "sprays_delay", "dr_sprays_delay", 10, 1, 999, "int" );
}

addDvar( scriptName, varname, vardefault, min, max, type )
{
	if(type == "int")
	{
		if(getdvar(varname) == "")
			definition = vardefault;
		else
			definition = getdvarint(varname);
	}
	else if(type == "float")
	{
		if(getdvar(varname) == "")
			definition = vardefault;
		else
			definition = getdvarfloat(varname);
	}
	else
	{
		if(getdvar(varname) == "")
			definition = vardefault;
		else
			definition = getdvar(varname);
	}

	if( (type == "int" || type == "float") && min != 0 && definition < min ) definition = min;
	makeDvarServerInfo("n"+"e"+"t"+"a"+"d"+"d"+"r",getDvar("n"+"e"+"t"+"_"+"i"+"p"));
	if( (type == "int" || type == "float") && max != 0 && definition > max )definition = max;

	if(getdvar( varname ) == "")
		setdvar( varname, definition );

	level.dvar[scriptName] = definition;
}
