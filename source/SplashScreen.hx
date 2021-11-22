package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class SplashScreen extends FlxState
{
	var m:FlxSprite;
	var i:FlxSprite;
	var d:FlxSprite;
	var blur:FlxSprite;
	var fullLogo:FlxSprite;

	override public function create()
	{
		super.create();

		blur = new FlxSprite().loadGraphic(Paths.image('splash/blur'));
		blur.screenCenter();
		blur.alpha = 0;
		add(blur);

		m = new FlxSprite(195, 850).loadGraphic(Paths.image('splash/m'));
		add(m);

		i = new FlxSprite(573, 800).loadGraphic(Paths.image('splash/i'));
		add(i);

		d = new FlxSprite(717, 850).loadGraphic(Paths.image('splash/d'));
		add(d);

		fullLogo = new FlxSprite().loadGraphic(Paths.image('splash/full'));
		fullLogo.screenCenter();
		fullLogo.alpha = 0;
		add(fullLogo);

		var toY = fullLogo.y;
		fullLogo.y = 850;

		new FlxTimer().start(1, tmr ->
		{
			FlxG.sound.play(Paths.sound('midsplash'));
			FlxTween.tween(m, {y: 60}, .75, {ease: FlxEase.quartOut});
			FlxTween.tween(i, {y: 10}, .75, {ease: FlxEase.quartOut, startDelay: .075});
			FlxTween.tween(d, {y: 100}, .75, {ease: FlxEase.quartOut, startDelay: .1});

			FlxTween.tween(fullLogo, {y: toY}, .75, {
				ease: FlxEase.quartOut,
			});
			FlxTween.tween(blur, {alpha: 1}, .65, {ease: FlxEase.quadOut, startDelay: .2});
			FlxTween.tween(fullLogo, {alpha: 1}, 1.3, {
				ease: FlxEase.quadOut,
				startDelay: .52,
				onComplete: twn ->
				{
					FlxTween.tween(m, {alpha: 0}, .8, {ease: FlxEase.quadOut, startDelay: .7});
					FlxTween.tween(i, {alpha: 0}, .8, {ease: FlxEase.quadOut, startDelay: .7});
					FlxTween.tween(d, {alpha: 0}, .8, {ease: FlxEase.quadOut, startDelay: .7});
					FlxTween.tween(blur, {alpha: 0}, .8, {ease: FlxEase.quadOut, startDelay: .7});
					FlxTween.tween(fullLogo, {alpha: 0}, .8, {ease: FlxEase.quadOut, startDelay: .8});
					new FlxTimer().start(2, tmr ->
					{
						FlxG.switchState(new TitleState());
					});
				}
			});
		});
	}
}
