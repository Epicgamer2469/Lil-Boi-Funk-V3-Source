package editors;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.graphics.FlxGraphic;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import openfl.net.FileReference;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import haxe.Json;
import Character;
import flixel.system.debug.interaction.tools.Pointer.GraphicCursorCross;
import lime.system.Clipboard;
import flixel.animation.FlxAnimation;

#if MODS_ALLOWED
import sys.FileSystem;
#end

using StringTools;

/**
	*DEBUG MODE
 */
class EditorPosition extends MusicBeatState
{
	var UI_box:FlxUITabMenu;

	private var daCam:FlxCamera;
	private var camMenu:FlxCamera;
	var daImage:FlxSprite;
	var posText:FlxText;

	override function create()
	{
		FlxG.sound.playMusic(Paths.music('breakfast'), 0.5);

		camMenu = new FlxCamera();
		camMenu.bgColor.alpha = 0;
		daCam = new FlxCamera();
		daCam.bgColor.alpha = 0;

		FlxG.cameras.add(daCam);
		FlxG.cameras.add(camMenu);
		FlxCamera.defaultCameras = [daCam];

		var tipText:FlxText = new FlxText(FlxG.width - 20, FlxG.height - 10, 0,
			"WASD to move the image\n
			JKIL to move the camera\n
			Up/Down arrow keys to change the image size\n
			R to reset position and size\n
			Q/E to zoom in/out", 21
		);
		tipText.cameras = [camMenu];
		tipText.setFormat(null, 21, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tipText.scrollFactor.set();
		tipText.borderSize = 1;
		tipText.x -= tipText.width;
		tipText.y -= tipText.height - 10;
		add(tipText);

		posText = new FlxText(FlxG.width - 1000, FlxG.height - 30, 0,
			"X: 0\n
			Y: 0\n
			X Width: 0\n
			Y Width: 0", 21
		);
		posText.cameras = [camMenu];
		posText.setFormat(null, 21, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		posText.scrollFactor.set();
		posText.borderSize = 1;
		posText.x -= posText.width;
		posText.y -= posText.height - 10;
		add(posText);

		daImage = new FlxSprite(0, 0);
		daImage.loadGraphic(Paths.image('titlelogo'));
		daImage.cameras = [daCam];
		daImage.scrollFactor.set();
		add(daImage);

		var tabs = [
			{name: 'Position Editor', label: 'Position Editor'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.cameras = [camMenu];

		UI_box.resize(250, 120);
		UI_box.x = FlxG.width - 275;
		UI_box.y = 25;
		UI_box.scrollFactor.set();

		add(UI_box);
		
		addSettingsUI();

		FlxG.mouse.visible = true;

		super.create();
	}

	function addSettingsUI() {
		var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "Position Editor";

		var imageInputText:FlxUIInputText = new FlxUIInputText(15, 30, 200, 'titlelogo', 8);
		var reloadImage:FlxButton = new FlxButton( 210, 3, "Reload Image", function()
		{
			daImage.loadGraphic(Paths.image(imageInputText.text));
		});

		tab_group.add(new FlxText(reloadImage.x, reloadImage.y - 18, 0, 'Image file name:'));
		tab_group.add(reloadImage);
		tab_group.add(imageInputText);
		UI_box.addGroup(tab_group);
	}

	override function update(elapsed:Float)
	{
		posText.text = "
			X: " + daImage.x + "\n
			Y: " + daImage.y + "\n
			X Width: " + daImage.scale.x + "\n
			Y Width: " + daImage.scale.y;
		if (FlxG.keys.justPressed.ESCAPE)
		{
			MusicBeatState.switchState(new editors.MasterEditorMenu());
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			FlxG.mouse.visible = false;
		}

		if (FlxG.keys.pressed.E && FlxG.camera.zoom < 3)
		{
			FlxG.camera.zoom += elapsed * FlxG.camera.zoom;

			if(FlxG.camera.zoom > 3) 
				FlxG.camera.zoom = 3;
		}

		if (FlxG.keys.pressed.Q && FlxG.camera.zoom > 0.1)
		{
			FlxG.camera.zoom -= elapsed * FlxG.camera.zoom;

			if(FlxG.camera.zoom < 0.1)
				FlxG.camera.zoom = 0.1;
		}

		if (FlxG.keys.pressed.W)
		{
			daImage.y -= 50;
		}

		if (FlxG.keys.pressed.S)
		{
			daImage.y += 50;
		}

		if (FlxG.keys.pressed.A)
		{
			daImage.x -= 50;
		}

		if (FlxG.keys.pressed.D)
		{
			daImage.x += 50;
		}

		if (FlxG.keys.pressed.R)
		{
			daImage.x = 0;
			daImage.y = 0;
			daImage.scale.set(1, 1);
		}

		if (FlxG.keys.pressed.UP)
		{
			daImage.scale.y -= 0.01;
		}

		if (FlxG.keys.pressed.DOWN)
		{
			daImage.scale.y += 0.01;
		}

		if (FlxG.keys.pressed.LEFT)
		{
			daImage.scale.x -= 0.01;
		}

		if (FlxG.keys.pressed.RIGHT)
		{
			daImage.scale.x += 0.01;
		}

		daCam.zoom = FlxG.camera.zoom;

		super.update(elapsed);
	}

	function updatePresence() {
		#if desktop
			DiscordClient.changePresence("Position Editor", "Image: idfk");
		#end
	}

	public function new()
	{
		super();
	}
}
