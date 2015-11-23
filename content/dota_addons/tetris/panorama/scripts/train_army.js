"use strict";

function train_1(target_)
{
	$.Msg(""+target_);//test function args
	GameEvents.SendCustomGameEventToServer( "train_army", {target : "tetris_rock_golem"} );
}

//introduce the unit
function showinfo_1()
{
	$.Msg("showinfo_1");//test function args
}

function closeinfo_1()
{
	$.Msg("closeinfo_1");//test function args
}