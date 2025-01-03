// ---------------------------------------------------------------------
// FNF Project: VS Four
// State Description: Hook for PlayState
// State Author: Semi
// ---------------------------------------------------------------------

// FUNCTIONS
function create()
{
	if (!shouldTransition) return;

	var border:FlxSprite = new FlxSprite(0, -FlxG.height);
	border.makeGraphic(FlxG.width, FlxG.height * 2, 0xFF000000);
	border.scrollFactor.set();
	border.camera = camHUD;
	add(border);

	FlxTween.tween(border, {y: FlxG.height}, 2, {ease: FlxEase.cubeOut});
}

function postCreate()
	shouldTransition = true;