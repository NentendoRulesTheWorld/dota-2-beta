"use strict";

function train_1(target_)
{
	$.Msg(""+target_);//test function args
	GameEvents.SendCustomGameEventToServer( "train_army", {target : "train_name"} );
}

//introduce the unit
function showinfo_1()
{
	
}

function closeinfo_1()
{
	
}