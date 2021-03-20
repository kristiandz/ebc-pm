init()
{
    level.hostnameSeperator = "-";
 
    if( level.hostnameSeperator.size > 1 )
        return;
 
    if( level.gametype  == "sd" || level.gametype == "sr" )
		addRoundsToHostname( game["roundsplayed"], level.roundLimit );
    else
        setHostName( getOriginalHostname() );
}
 
addRoundsToHostname( currentRound, maxRounds )
{
    setHostName( getOriginalHostname() + " " + level.hostnameSeperator + " Round: " + currentRound + "/" + maxRounds );
}
 
setHostName( newHostName )
{
    SetDvar("sv_hostname", newHostName);
}
 
getOriginalHostname()
{
    hostname = GetDvar("sv_hostname");
    if(IsSubStr(hostname, level.hostnameSeperator + " Round:" ))
            return trimRight( trimAllRightThroughSeperator( hostname, level.hostnameSeperator ));
    return hostname;
}
 
trimAllRightThroughSeperator( string, seperator )
{
    i = string.size;
    for(; i && string[i-1] != seperator; i--){}
    return getSubStr( string, 0, i-1 );
}
 
trimRight( string )
{
    i = string.size;
    for(; i && string[i-1] == " "; i-- ){}
    return getSubStr( string, 0, i );
}