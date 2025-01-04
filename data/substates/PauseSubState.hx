// ---------------------------------------------------------------------
// FNF Project: VS Four
// State Description: Hook for PauseSubState
// State Author: Semi
// ---------------------------------------------------------------------

// IMPORTS
import funkin.editors.charter.Charter;

// FUNCTIONS
function onSelectOption(event)
{
	switch(event.name)
	{
		case "Restart Song":
			event.cancel();
			parentDisabler.reset();
			game.registerSmoothTransition();
			resetState_hook();

		case "Exit to menu":
			event.cancel();
			if (PlayState.chartingMode && Charter.undos.unsaved)
				game.saveWarn(false);
			else {
				PlayState.resetSongInfos();
				if (Charter.instance != null) Charter.instance.__clearStatics();

				// prevents certain notes to disappear early when exiting  - Nex
				game.strumLines.forEachAlive(function(grp) grp.notes.__forcedSongPos = Conductor.songPosition);

				CoolUtil.playMenuSong();
				FlxG.switchState(PlayState.isStoryMode ? new ModState("FourStory") : new FreeplayState());
			}
	}
}

function resetState_hook()
{
	shouldTransition = false;
	FlxG.resetState();
}