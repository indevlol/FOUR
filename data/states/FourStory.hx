// ---------------------------------------------------------------------
// FNF Project: VS Four
// State Description: StoryMenuState for the mod
// State Author: Semi
// ---------------------------------------------------------------------

// IMPORTS
import flixel.addons.display.FlxBackdrop;
import flixel.FlxObject;
import funkin.backend.assets.AssetsLibraryList.AssetSource;
import funkin.backend.system.Logs;
import haxe.xml.Access;
import Type;
import Xml;

// INTERNAL VARIABLES
var curSelected:Int = 0;
var camFollow:FlxObject;
var weeks:Array<StoryMenuState.WeekData> = [];
var thumbnailImages:Array<String> = [ "four", "two", "announcer" ];
var selectedSomethin:Bool = true;

// SPRITE VARIABLES
var thumbnails:FlxTypedGroup<FlxSprite>;
var selectSprite:FlxSprite;
var border:FlxSprite;
var weekText:FlxSprite;

// CLASS FUNCTIONS
function create()
{
	camFollow = new FlxObject(0, 0, 1, 1);
	add(camFollow);
	
	var gradient:FlxSprite = new FlxSprite().loadGraphic(Paths.image("game/menus/story/gradient"));
	gradient.scrollFactor.set();
	gradient.scale.set(0.45, 0.4);
	gradient.screenCenter();
	gradient.color = 0xFF0000FF;
	add(gradient);

	var backdrop:FlxSprite = new FlxBackdrop(Paths.image("game/menus/story/backdrop"));
	backdrop.scale.set(0.25, 0.25);
	backdrop.scrollFactor.set(0.25, 0.25);
	backdrop.velocity.set(-50, 50);
	backdrop.alpha = 0.25;
	backdrop.blend = 10;
	add(backdrop);

	thumbnails = new FlxTypedGroup();

	for (i in 0...thumbnailImages.length)
	{
		var thumbnail:FlxSprite = new FlxSprite().loadGraphic(Paths.image("game/menus/story/thumbnails/" + thumbnailImages[i]));
		thumbnail.scale.set(0.5, 0.5);
		thumbnail.updateHitbox();
		thumbnail.antialiasing = true;
		thumbnail.ID = i;
		thumbnail.x = thumbnail.width * (i*1.25);
		thumbnail.y = 150;
		thumbnails.add(thumbnail);
	}

	add(thumbnails);

	selectSprite = new FlxSprite();
	selectSprite.frames = Paths.getFrames("game/menus/story/select");
	selectSprite.scale.set(0.5, 0.5);
	selectSprite.scrollFactor.set();
	selectSprite.screenCenter();
	selectSprite.y -= 75;
	add(selectSprite);

	border = new FlxSprite(0, -FlxG.height);
	border.makeGraphic(FlxG.width, FlxG.height * 2, 0xFF000000);
	border.scrollFactor.set();
	add(border);

	FlxTween.tween(border, {y: FlxG.height - 149}, 2, {ease: FlxEase.cubeOut, onComplete: function() { selectedSomethin = false; }});

	weekText = new FlxSprite();
	weekText.frames = Paths.getFrames("game/menus/story/weeks");
	weekText.scrollFactor.set();
	weekText.screenCenter(0x01);
	add(weekText);

	FlxG.camera.follow(camFollow, null, 0.06);
	loadXMLs();
	changeItem(0);
	CoolUtil.playMenuSong();
}

function update(elapsed:Float)
{
	weekText.y = border.y - 5;
	weekText.animation.frameIndex = curSelected;

	if (!selectedSomethin)
	{
		var leftP = controls.LEFT_P;
		var rightP = controls.RIGHT_P;
		var scroll = FlxG.mouse.wheel;

		if (leftP || rightP || scroll != 0)
			changeItem((leftP ? -1 : 0) + (rightP ? 1 : 0) - scroll);

		if (controls.BACK)
			FlxG.switchState(new MainMenuState());

		if (controls.ACCEPT)
			selectItem();
	}
	
}

function selectItem()
{
	selectedSomethin = true;
	CoolUtil.playMenuSFX(1);
	PlayState.loadWeek(weeks[curSelected], "hard");

	new FlxTimer().start(1, function(tmr:FlxTimer)
	{
		FlxTween.tween(border, {y: -FlxG.height}, 2, {ease: FlxEase.cubeIn, onComplete: function() { FlxG.switchState(new PlayState()); }});
	});
}

function changeItem(offset:Int)
{
	curSelected = FlxMath.wrap(curSelected + offset, 0, thumbnails.length-1);

	CoolUtil.playMenuSFX(0, 0.7);

	thumbnails.forEach(function(spr)
	{
		FlxTween.cancelTweensOf(spr);
        FlxTween.cancelTweensOf(spr.scale);

		FlxTween.cancelTweensOf(selectSprite.scale);
		selectSprite.scale.set(0.55, 0.55);
		FlxTween.tween(selectSprite.scale, {x: 0.5, y: 0.5}, 1, {ease: FlxEase.cubeOut});

		if (spr.ID == curSelected)
		{
			FlxTween.tween(spr, {alpha: 1}, 1, {ease: FlxEase.cubeOut});
			FlxTween.tween(spr.scale, {x: 0.5, y: 0.5}, 1, {ease: FlxEase.cubeOut});
			camFollow.setPosition(spr.x + (spr.width/2), (spr.y+75) + (spr.height/2));
		}
		else
		{
			FlxTween.tween(spr, {alpha: 0.5}, 1, {ease: FlxEase.cubeOut});
			FlxTween.tween(spr.scale, {x: 0.4, y: 0.4}, 1, {ease: FlxEase.cubeOut});
		}
	});
}

// FUNCTIONS TAKEN AND EDITED FROM STORYMENUSTATE
function loadXMLs() 
{
	if (getWeeksFromSource(weeks, AssetSource.MODS))
		getWeeksFromSource(weeks, AssetSource.SOURCE);

	for (k => weekName in weeks) 
	{
		var week:Xml = null;
		try 
		{
			var xmlContent = Assets.getText(Paths.xml('weeks/weeks/' + weekName));
			Logs.trace('Parsing XML for week: ' + weekName, 0);
			week = Xml.parse(xmlContent).firstElement();
		} 
		catch (e:Dynamic) 
		{
			Logs.trace('Cannot parse week "' + weekName + '.xml": ' + Std.string(e), 2);
			continue;
		}

		if (week == null || !week.exists("name")) 
		{
			Logs.trace('Story Menu: Week at index ' + k + ' has no name. Skipping...', 1);
			continue;
		}

		var weekObj = {
			name: week.get("name"),
			id: weekName,
			sprite: week.get("sprite") != null ? week.get("sprite") : weekName,
			chars: [null, null, null],
			songs: [],
			difficulties: ['easy', 'normal', 'hard']
		};

		var diffNodes = week.elementsNamed("difficulty");
		if (diffNodes.hasNext()) 
		{
			var diffs:Array<String> = [];
			while (diffNodes.hasNext()) 
			{
				var diff = diffNodes.next();
				if (diff.exists("name")) 
					diffs.push(diff.get("name"));
			}
			if (diffs.length > 0)
				weekObj.difficulties = diffs;
		}

		var songNodes = week.elementsNamed("song");
		while (songNodes.hasNext()) 
		{
			var song = songNodes.next();
			if (song == null) continue;

			try 
			{
				if (song.firstChild() == null) 
				{
					Logs.trace('Story Menu: Song node in week ' + weekObj.name + ' is empty. Skipping...', 1);
					continue;
				}

				var name = StringTools.trim(song.firstChild().toString());
				if (name == "") 
				{
					Logs.trace('Story Menu: Song at index in week ' + weekObj.name + ' has no name. Skipping...', 1);
					continue;
				}
				weekObj.songs.push({
					name: name,
					hide: song.exists("hide") && song.get("hide") == "true"
				});
			} 
			catch (e:Dynamic) 
			{
				Logs.trace('Story Menu: Song in week ' + weekObj.name + ' cannot contain invalid XML.', 1);
				continue;
			}
		}

		if (weekObj.songs.length <= 0) 
		{
			Logs.trace('Story Menu: Week ' + weekObj.name + ' has no songs. Skipping...', 1);
			continue;
		}

		weeks.push(weekObj);
	}

	weeks = weeks.filter(function(week) { return week != null && Type.typeof(week) == "TObject"; });
}

function getWeeksFromSource(weeks:Array<String>, source:AssetSource) 
{
	var path:String = Paths.txt('freeplaySonglist');
	var weeksFound:Array<String> = [];
	if (Paths.assetsTree.existsSpecific(path, "TEXT", source)) 
	{
		var trim = "";
		weeksFound = CoolUtil.coolTextFile(Paths.txt('weeks/weeks'));
	} else 
	{
		weeksFound = [for(c in Paths.getFolderContent('data/weeks/weeks/', false, source)) if (Path.extension(c).toLowerCase() == "xml") Path.withoutExtension(c)];
	}

	if (weeksFound.length > 0) {
		for(s in weeksFound)
			weeks.push(s);
		return false;
	}
	return true;
}