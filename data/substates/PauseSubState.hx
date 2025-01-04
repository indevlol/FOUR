// ---------------------------------------------------------------------
// FNF Project: VS Four
// State Description: Hook for PauseSubState
// State Author: Semi
// ---------------------------------------------------------------------

// IMPORTS
import funkin.editors.charter.Charter;
import funkin.options.OptionsMenu;
import funkin.options.TreeMenu;

// INTERNAL VARIABLES
var pauseCam = new FlxCamera();
menuItems = ["exit", "restart", "options", "menu-"];

var selectedSomethin:Bool = false;

// SPRITE VARIABLES
var grpMenuItems:FlxTypedGroup<FlxSprite>;

// FUNCTIONS
function create(event)
{
	event.cancel();

	cameras = [];

	FlxG.cameras.add(pauseCam, false);

	pauseCam.bgColor = 0x88000000;

	grpMenuItems = new FlxTypedGroup();

	for (i in 0...menuItems.length)
	{
		var menuItem:FlxSprite = new FlxSprite();
		menuItem.frames = Paths.getFrames("game/pausey");
		menuItem.animation.addByPrefix(menuItems[i], menuItems[i] + " instance 1", 0);
		menuItem.animation.play(menuItems[i]);
		menuItem.antialiasing = true;
		menuItem.x = 20;
		menuItem.y = FlxG.height - (menuItems.length - i) * 100;
		menuItem.ID = i;
		grpMenuItems.add(menuItem);
	}

	add(grpMenuItems);

	changeSelection(0);

	cameras = [pauseCam];
}

function update(elapsed)
{
	if (!selectedSomethin)
	{
		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var scroll = FlxG.mouse.wheel;

		if (upP || downP || scroll != 0)
			changeSelection((upP ? -1 : 0) + (downP ? 1 : 0) - scroll);

		if (controls.ACCEPT)
			selectItem();
	}
}

function selectItem()
{
	selectedSomethin = true;

	selectOption();
}

function changeSelection(change:Int)
{
	curSelected = FlxMath.wrap(curSelected + change, 0, menuItems.length-1);

	grpMenuItems.forEach(function(menuItem)
	{
		menuItem.animation.curAnim.curFrame = ((menuItem.ID == curSelected) ? 0 : 1);
	});
}

function onSelectOption(event)
{
	switch(event.name)
	{
		case "exit":
			event.cancel();
			close();

		case "restart":
			event.cancel();
			parentDisabler.reset();
			game.registerSmoothTransition();
			resetState_hook();

		case "options":
			event.cancel();
			TreeMenu.lastState = PlayState;
			FlxG.switchState(new OptionsMenu());

		case "menu-":
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