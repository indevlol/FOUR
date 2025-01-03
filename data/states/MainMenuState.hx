// ---------------------------------------------------------------------
// FNF Project: VS Four
// State Description: Hook for MainMenuState
// State Author: Semi
// ---------------------------------------------------------------------

// FUNCTIONS
function onSelectItem(event)
{
	if (event.name == "story mode") 
	{
		event.cancel();
		FlxG.switchState(new ModState("FourStory"));
	}
}