// ---------------------------------------------------------------------
// FNF Project: VS Four
// State Description: Hook for MusicBeatTransition
// State Author: Semi
// ---------------------------------------------------------------------

// IMPORTS
import Type;

// INTERNAL VARIABLES
public static var shouldTransition:Bool = true;

// FUNCTIONS
function postCreate()
{
	remove(blackSpr);
	remove(transitionSprite);
}

function update()
{
	if (newState is PlayState)
		shouldTransition = (Type.getClass(FlxG.state) == PlayState) ? false : true;

	if (newState != null)
		FlxG.switchState(newState);
}