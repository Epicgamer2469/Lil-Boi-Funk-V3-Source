package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.system.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var ending:Bool = false;
	var skipText:FlxText;
	var imPRESSED:Bool = false;
	var holdShit:Float = .5;
	var canInput:Bool = true;
	var stopSound:Bool = false;
	var funnySound:FlxSound;

	var box:FlxSprite;
	var bottomImage:FlxSprite;
	var topImage:FlxSprite;

	var curCharacter:String = '';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	var swagDialogue:FlxTypeText;

	var titleText:FlxText;

	public var finishThing:Void->Void;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;

	var portTween:FlxTween;
	public var doEndTween = true;

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFF000000);
		bgFade.scrollFactor.set();
		bgFade.alpha = .3;
		add(bgFade);

		bottomImage = new FlxSprite(0, 0);
		bottomImage.visible = false;
		bottomImage.antialiasing = ClientPrefs.globalAntialiasing;
		add(bottomImage);

		box = new FlxSprite(50, 375);

		this.dialogueList = dialogueList;
		
		box.loadGraphic(Paths.image('lbf/dialogue/box', 'shared'));
		box.updateHitbox();
		box.alpha = .75;
		box.antialiasing = ClientPrefs.globalAntialiasing;
		add(box);

		swagDialogue = new FlxTypeText(85, 470, Std.int(FlxG.width * 0.6), "", 32);
		swagDialogue.font = Paths.font("generis.ttf");
		swagDialogue.color = FlxColor.WHITE;
		swagDialogue.borderColor = FlxColor.BLACK;
		swagDialogue.borderStyle = OUTLINE;
		swagDialogue.borderSize = 2;
		swagDialogue.antialiasing = ClientPrefs.globalAntialiasing;
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.3)];
		add(swagDialogue);

		titleText = new FlxText(120, 420, 0, "", 34);
		titleText.font = Paths.font("generis.ttf");
		titleText.color = FlxColor.WHITE;
		titleText.borderColor = FlxColor.BLACK;
		titleText.borderStyle = OUTLINE;
		titleText.borderSize = 2;
		titleText.antialiasing = ClientPrefs.globalAntialiasing;
		add(titleText);

		skipText = new FlxText(10, 680, 0, "Hold [SHIFT] to skip dialogue", 22);
		skipText.screenCenter(X);
		skipText.x += 50;
		skipText.font = Paths.font("vcr.ttf");
		skipText.color = FlxColor.WHITE;
		skipText.borderColor = FlxColor.BLACK;
		skipText.borderStyle = OUTLINE;
		skipText.borderSize = 2;
		skipText.antialiasing = ClientPrefs.globalAntialiasing;
		add(skipText);

		dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);
	}

	var dialogueOpened:Bool = true;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if (PlayerSettings.player1.controls.ACCEPT && dialogueStarted == true && canInput)
		{
			addDialogue();
		}

		if (FlxG.keys.pressed.SHIFT && !ending)
			{
				holdShit += 0.005;
				imPRESSED = true;

				if (holdShit >= 1)
					{
						ending = true;
						FlxG.camera.flash(FlxColor.WHITE, .5);
						endIt();
					}
			}
		else if (imPRESSED = true)
			{
				holdShit = .5;
				imPRESSED = false;
			}

		skipText.alpha = holdShit;
		
		super.update(elapsed);
	}

	function addDialogue(playSound:Bool = true)
		{
				remove(dialogue);
				
				if (playSound)
					FlxG.sound.play(Paths.sound('clickText'), 0.5);
		
				if (dialogueList[1] == null && dialogueList[0] != null)
					{
						if (!isEnding)
						{
							endIt();
						}
					}
				else
					{
						dialogueList.remove(dialogueList[0]);
						startDialogue();
					}
		}

	var isEnding:Bool = false;

	function startDialogue():Void
	{
		cleanDialog();
		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.03, true);

		switch (curCharacter)
		{
			//DIALOGUE PORTRAITS
			//hotchick, pinky, eve, tarr, rocky
			case 'hotchick':
				titleText.text = "Hotchick";
				titleText.color = 0xf4eebe;
				titleText.borderColor = 0xFF635e3b;
			case 'pinky':
				titleText.text = "Pinky";
				titleText.color = 0xf481b7;
				titleText.borderColor = 0xFF883467;
			case 'eve':
				titleText.text = "Eve";
				titleText.color = 0xf0569e;
				titleText.borderColor = 0xFFc7367a;
			case '???':
				titleText.text = "???";
				titleText.color = 0x2a2c31;
				titleText.borderColor = 0xFF4f4f4f;
			case 'rocky':
				titleText.text = "Rocky";
				titleText.color = 0x3372f3;
				titleText.borderColor = 0xFF1a2890;
			//OTHER DIALOGUE MECHANICS

			//input control
			case 'stopInputs':
				canInput = false;
				addDialogue(false);
			case 'startInputs':
				canInput = true;
				addDialogue(false);

			case 'hideBox':
				box.visible = false;
				titleText.visible = false;
				addDialogue(false);
			case 'showBox':
				box.visible = true;
				titleText.visible = true;
				addDialogue(false);

			//image below dialogue
			case 'hideBottomImage':
				bottomImage.visible = false;
				addDialogue(false);
			case 'showBottomImage':
				bottomImage.loadGraphic(Paths.image(dialogueList[0], 'shared'));
				bottomImage.setGraphicSize(FlxG.width, FlxG.height);
				bottomImage.screenCenter();
				bottomImage.visible = true;
				addDialogue(false);
			
			//music control
			case 'playMusic':
				FlxG.sound.playMusic(Paths.music(dialogueList[0], 'shared'), .35);
				addDialogue(false);
			case 'pauseMusic':
				FlxG.sound.music.pause();
				addDialogue(false);
			case 'resumeMusic':
				FlxG.sound.music.resume();
				addDialogue(false);
				
			//sound control
			case 'playSound':
				funnySound = new FlxSound().loadEmbedded((Paths.sound(dialogueList[0], 'shared')));
				funnySound.play(true);
				//FlxG.sound.play(Paths.sound(dialogueList[0], 'shared'));
				addDialogue(false);
			case 'stopSound':
				funnySound.stop();
				addDialogue(false);

			//timing and stuff
			case 'timer':
				new FlxTimer().start(Std.parseFloat(dialogueList[0]), function(tmr:FlxTimer) 
				{
					addDialogue(false);
				});
			case 'buffer':
				//do nothing wait for an input
		}
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		dialogueList[0] = dialogueList[0].substr(splitName[1].length + 2).trim();
	}

	function endIt()
		{
			isEnding = true;
				
			FlxG.sound.music.fadeOut(1, 0);

			if(doEndTween){

			FlxTween.tween(box, {y: 1200}, 1, {ease: FlxEase.quartIn});
			FlxTween.tween(titleText, {y: 1375}, 1, {ease: FlxEase.quartIn});
			FlxTween.tween(swagDialogue, {y: 1450}, 1, {ease: FlxEase.quartIn});
			FlxTween.tween(bgFade, {alpha: 0}, 1, {ease: FlxEase.quartIn});
			FlxTween.tween(bottomImage, {alpha: 0}, 1, {ease: FlxEase.quartIn});
			FlxTween.tween(skipText, {alpha: 0}, 1, {ease: FlxEase.quartIn});

			new FlxTimer().start(1.2, function(tmr:FlxTimer)
				{
					finishThing();
					kill();
				});
			}
			else{
				FlxG.sound.music.fadeOut(1, 0);
				finishThing();
				kill();
			}
		}
}
