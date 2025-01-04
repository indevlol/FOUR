// ---------------------------------------------------------------------
// FNF Project: VS Four
// Script Description: Essentials for gameplay
// Script Author: Semi (camera utitlies based off of Haven's WI cam script)
// ---------------------------------------------------------------------

// IMPORTS
import Xml;

// INTERNAL VARIABLES 
public var camData = [-1 => {}];

PauseSubState.script = 'data/substates/PauseSubState';

// FUNCTIONS
function onSongStart() camZooming = true;

function postCreate()
	for (sl in strumLines.members)
		generateCamData(sl);

function generateCamData(sl:Strumline)
{
	var offset = 10;
	var zoom = 1.0;
	for (node in Xml.parse(Assets.getText(stage.stagePath)).firstElement().elements()) 
	{
		switch(node.nodeName) 
		{
			case 'character':
				if (node.exists('name') && [for (i in sl.characters) i].contains(node.get('name')))
				{
					if (node.exists('noteOffset')) offset = Std.parseFloat(node.get('noteOffset'));
					if (node.exists('zoomOffset')) zoom = Std.parseFloat(node.get('zoomOffset'));
				}
				else continue;
			case 'dad' | 'opponent':
				if (sl.data.position != 'dad') continue;
				if (node.exists('noteOffset')) offset = Std.parseFloat(node.get('noteOffset'));
				if (node.exists('zoomOffset')) zoom = Std.parseFloat(node.get('zoomOffset'));
			case 'boyfriend' | 'bf' | 'player':
				if (sl.data.position != 'boyfriend') continue;
				if (node.exists('noteOffset')) offset = Std.parseFloat(node.get('noteOffset'));
				if (node.exists('zoomOffset')) zoom = Std.parseFloat(node.get('zoomOffset'));
			case 'girlfriend' | 'gf':
				if (sl.data.position != 'girlfriend') continue;
				if (node.exists('noteOffset')) offset = Std.parseFloat(node.get('noteOffset'));
				if (node.exists('zoomOffset')) zoom = Std.parseFloat(node.get('zoomOffset'));
		};
	}

	camData[strumLines.members.indexOf(sl)] = {noteOffset: offset, zoomOffset: zoom};
}

function onCameraMove(event)
{
	var offset = camData[curCameraTarget].noteOffset;
	defaultCamZoom = camData[curCameraTarget].zoomOffset;

	if (curCameraTarget == 2)
	{
		var dadPos = strumLines.members[0].characters[0].getCameraPosition();
		var boyPos = strumLines.members[1].characters[0].getCameraPosition();

		event.position.x = (dadPos.x + boyPos.x) / 2;
		event.position.y = (dadPos.y + boyPos.y) / 2;
	}

	switch(strumLines.members[curCameraTarget].characters[0].getAnimName())
	{
		case "singLEFT": event.position.x -= offset;
		case "singDOWN": event.position.y += offset;
		case "singUP": event.position.y -= offset;
		case "singRIGHT": event.position.x += offset;
	}
}