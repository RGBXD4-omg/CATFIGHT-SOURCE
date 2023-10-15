package;

import flixel.group.FlxSpriteGroup;
import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.FlxSubState;
import flixel.FlxSprite;
import flixel.FlxCamera;

class CustomFadeTransition extends MusicBeatSubstate {
	public static var finishCallback:Void->Void;
	private var leTween:FlxTween = null;
	public static var nextCamera:FlxCamera;
	var isTransIn:Bool = false;
	public static var transBarGroup:FlxSpriteGroup;
	public static var transTextGroup:FlxSpriteGroup;

	public function new(duration:Float, isTransIn:Bool) {
		super();

		this.isTransIn = isTransIn;
		var zoom:Float = CoolUtil.boundTo(FlxG.camera.zoom, 0.05, 1);
		var width:Int = Std.int(FlxG.width / zoom);
		var height:Int = Std.int(FlxG.height / zoom);

		var blackBarThingie:FlxSprite = new FlxSprite(0,0).makeGraphic(width, 46, FlxColor.WHITE);
        blackBarThingie.color = 0x2A1E2C;
		add(blackBarThingie);
		var blackBarThingie2:FlxSprite = new FlxSprite(0,0).makeGraphic(width, 46, FlxColor.WHITE);
        blackBarThingie2.color = 0x2A1E2C;
		add(blackBarThingie2);
		var blackThingie:FlxSprite = new FlxSprite(0,0).makeGraphic(width, height, FlxColor.WHITE);
        blackThingie.color = 0x2A1E2C;
		add(blackThingie);
		
		if(nextCamera != null) {
			blackBarThingie.cameras = [nextCamera];
			blackBarThingie2.cameras = [nextCamera];
			blackThingie.cameras = [nextCamera];
		}
		if(!isTransIn) {
			blackBarThingie.y = -46;
			blackBarThingie2.y = height;
			blackThingie.alpha = 0;
			FlxTween.tween(blackThingie, {alpha:1}, duration, {ease: FlxEase.sineInOut});
			FlxTween.tween(blackBarThingie, {y: 0}, duration, {ease: FlxEase.sineInOut});
			FlxTween.tween(blackBarThingie2, {y: height-46}, duration, {
				onComplete: function(twn:FlxTween) {
					finishCallback();
				},
			ease: FlxEase.sineInOut});
		} else {
			blackBarThingie.y = 0;
			blackBarThingie2.y = height-46;
			blackThingie.alpha = 1;
			FlxTween.tween(blackThingie, {alpha: 0}, duration, {ease: FlxEase.sineInOut});
			FlxTween.tween(blackBarThingie, {y: -46}, duration, {ease: FlxEase.sineInOut});
			FlxTween.tween(blackBarThingie2, {y: height}, duration, {
				onComplete: function(twn:FlxTween) {
					if(finishCallback != null) {
						close();
			 		}
				},
			ease: FlxEase.sineInOut});
			// leTween = FlxTween.tween(transGradient, {y: transGradient.height + 50}, duration, {
			// 	onComplete: function(twn:FlxTween) {
			// 		if(finishCallback != null) {
			// 			finishCallback();
			// 		}
			// 	},
			// ease: FlxEase.linear});
		}
		nextCamera = null;
	}

	override function destroy() {
		if(leTween != null) {
			finishCallback();
			leTween.cancel();
		}
		super.destroy();
	}
}