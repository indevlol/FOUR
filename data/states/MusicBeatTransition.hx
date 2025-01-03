// ---------------------------------------------------------------------
// FNF Project: VS Four
// State Description: Hook for MusicBeatTransition
// State Author: Semi
// ---------------------------------------------------------------------

// FUNCTIONS
function postCreate()
{
	remove(blackSpr);
	remove(transitionSprite);
}

function update()
{
	if (newState != null)
		FlxG.switchState(newState);
}