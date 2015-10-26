"use strict";

function OnPlayerDetailsChanged()
{
    var playerId = $.GetContextPanel().GetAttributeInt("player_id", -1);
    $.Msg("js playerId" + playerId);
	var playerInfo = Game.GetPlayerInfo( playerId );
	if ( !playerInfo ){
		$.Msg("playerInfo is empty")
		return;
	}
	$( "#PlayerName" ).text = playerInfo.player_name;
	$( "#PlayerAvatar" ).steamid = playerInfo.player_steamid;
}

OnPlayerDetailsChanged();