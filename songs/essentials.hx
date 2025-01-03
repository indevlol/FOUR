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
function postCreate()
	for (sl in strumLines.members)
		generateCamData(sl);

function generateCamData(sl:Strumline)
{
	var offset = 10;
	for (node in Xml.parse(Assets.getText(stage.stagePath)).firstElement().elements()) 
	{
		switch(node.nodeName) 
		{
			case 'character':
				if (node.exists('name') && [for (i in sl.characters) i].contains(node.get('name')))
					if (node.exists('noteOffset')) offset = Std.parseFloat(node.get('noteOffset'));
				else continue;
			case 'dad' | 'opponent':
				if (sl.data.position != 'dad') continue;
				if (node.exists('noteOffset')) offset = Std.parseFloat(node.get('noteOffset'));
			case 'boyfriend' | 'bf' | 'player':
				if (sl.data.position != 'boyfriend') continue;
				if (node.exists('noteOffset')) offset = Std.parseFloat(node.get('noteOffset'));
			case 'girlfriend' | 'gf':
				if (sl.data.position != 'girlfriend') continue;
				if (node.exists('noteOffset')) offset = Std.parseFloat(node.get('noteOffset'));
		};
	}

	camData[strumLines.members.indexOf(sl)] = {noteOffset: offset};
}

function onCameraMove(event)
{
	var offset = camData[curCameraTarget].noteOffset;

	switch(strumLines.members[curCameraTarget].characters[0].getAnimName())
	{
		case "singLEFT": event.position.x -= offset;
		case "singDOWN": event.position.y += offset;
		case "singUP": event.position.y -= offset;
		case "singRIGHT": event.position.x += offset;
	}
}