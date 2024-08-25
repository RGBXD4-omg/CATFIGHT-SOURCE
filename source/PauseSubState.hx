package;

import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.util.FlxStringUtil;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<FlxText>;

	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = ['RESUME', 'RESTART', 'EXIT'];
	var difficultyChoices = [];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var skipTimeText:FlxText;
	var skipTimeTracker:FlxText;
	var curTime:Float = Math.max(0, Conductor.songPosition);
	//var botplayText:FlxText;

	public static var songName:String = '';

	public function new(x:Float, y:Float)
	{
		super();

		if(PlayState.chartingMode)
		{
			menuItemsOG.insert(2, 'LEAVE CM');
			
			var num:Int = 0;
			if(!PlayState.instance.startingSong)
			{
				num = 1;
				menuItemsOG.insert(3, 'SKIP');
			}
			menuItemsOG.insert(3 + num, 'END SONG');
			menuItemsOG.insert(4 + num, 'TOGGLE PM');
		}
		menuItems = menuItemsOG;

		for (i in 0...CoolUtil.difficulties.length) {
			var diff:String = '' + CoolUtil.difficulties[i];
			difficultyChoices.push(diff);
		}
		difficultyChoices.push('BACK');


		pauseMusic = new FlxSound();
		if(songName != null) {
			pauseMusic.loadEmbedded(Paths.music(songName), true, true);
		} else if (songName != 'None') {
			pauseMusic.loadEmbedded(Paths.music(Paths.formatToSongPath(ClientPrefs.pauseMusic)), true, true);
		}
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

        var blackBarThingie:FlxSprite = new FlxSprite(FlxG.height).makeGraphic(FlxG.width, 46, FlxColor.WHITE);
        blackBarThingie.screenCenter(X);
        blackBarThingie.color = 0x2A1E2C;
		add(blackBarThingie);
		
		var levelInfo:FlxText = new FlxText(20, 0, 0, "", 32);
		levelInfo.text += PlayState.SONG.song.toUpperCase() + ' | REWINDS: ' + PlayState.deathCounter;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("fontthingie.ttf"), 32, 0xFEF1E2);
		levelInfo.updateHitbox();
		add(levelInfo);

		FlxTween.tween(bg, {alpha: 0.8}, 0.4, {ease: FlxEase.quartInOut});

		grpMenuShit = new FlxTypedGroup<FlxText>();
		add(grpMenuShit);

		regenMenu();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		#if android
                addVirtualPad(UP_DOWM, A);
		addPadCamera();
		#end

	}

	var holdTime:Float = 0;
	var cantUnpause:Float = 0.1;
	override function update(elapsed:Float)
	{
		cantUnpause -= elapsed;
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);
		updateSkipTextStuff();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		var daSelected:String = menuItems[curSelected];
		switch (daSelected)
		{
			case 'Skip Time':
				if (controls.UI_LEFT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime -= 1000;
					holdTime = 0;
				}
				if (controls.UI_RIGHT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime += 1000;
					holdTime = 0;
				}

				if(controls.UI_LEFT || controls.UI_RIGHT)
				{
					holdTime += elapsed;
					if(holdTime > 0.5)
					{
						curTime += 45000 * elapsed * (controls.UI_LEFT ? -1 : 1);
					}

					if(curTime >= FlxG.sound.music.length) curTime -= FlxG.sound.music.length;
					else if(curTime < 0) curTime += FlxG.sound.music.length;
					updateSkipTimeText();
				}
		}

		if (accepted && (cantUnpause <= 0 || !ClientPrefs.controllerMode))
		{
			if (menuItems == difficultyChoices)
			{
				if(menuItems.length - 1 != curSelected && difficultyChoices.contains(daSelected)) {
					var name:String = PlayState.SONG.song;
					var poop = Highscore.formatSong(name, curSelected);
					PlayState.SONG = Song.loadFromJson(poop, name);
					PlayState.storyDifficulty = curSelected;
					MusicBeatState.resetState();
					FlxG.sound.music.volume = 0;
					PlayState.changedDifficulty = true;
					PlayState.chartingMode = false;
					return;
				}

				menuItems = menuItemsOG;
				regenMenu();
			}

			switch (daSelected)
			{
				case "RESUME":
					close();
				case 'TOGGLE PM':
					PlayState.instance.practiceMode = !PlayState.instance.practiceMode;
					PlayState.changedDifficulty = true;
				case "RESTART":
					restartSong();
				case "LEAVE CM":
					restartSong();
					PlayState.chartingMode = false;
				case 'SKIP':
					if(curTime < Conductor.songPosition)
					{
						PlayState.startOnTime = curTime;
						restartSong(true);
					}
					else
					{
						if (curTime != Conductor.songPosition)
						{
							PlayState.instance.clearNotesBefore(curTime);
							PlayState.instance.setSongTime(curTime);
						}
						close();
					}
				case "END SONG":
					close();
					PlayState.instance.finishSong(true);
				case "EXIT":
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;

					WeekData.loadTheFirstEnabledMod();
					if(PlayState.isStoryMode) {
						MusicBeatState.switchState(new StoryMenuState());
					} else {
						MusicBeatState.switchState(new MainMenuState());
					}
					PlayState.cancelMusicFadeTween();
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
					PlayState.changedDifficulty = false;
					PlayState.chartingMode = false;
			}
		}
	}

	function deleteSkipTimeText()
	{
		if(skipTimeText != null)
		{
			skipTimeText.kill();
			remove(skipTimeText);
			skipTimeText.destroy();
		}
		skipTimeText = null;
		skipTimeTracker = null;
	}

	public static function restartSong(noTrans:Bool = false)
	{
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

		if(noTrans)
		{
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
		}
		else
		{
			MusicBeatState.resetState();
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0, dontTween = false):Void
	{
		curSelected += change;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (i in 0... grpMenuShit.members.length)
		{
			var item = grpMenuShit.members[i];
			item.color = (item.ID == curSelected ? 0xFC7639 : 0xFEF1E2);
			bullShit++;
			var xThing = FlxG.width - (item.pixels.width/2);
			// item.setGraphicSize(Std.int(item.width * 0.8));
			if (item.color == 0xFC7639)
			{
				xThing = FlxG.width - item.pixels.width;
				if(item == skipTimeTracker)
				{
					curTime = Math.max(0, Conductor.songPosition);
					updateSkipTimeText();
				}
				
			}
			if (Math.abs(i - curSelected) == 1) xThing = FlxG.width - (item.pixels.width/1.3333333);
			if (!dontTween) {
				doItUntilTheShitIsDone = false;
				FlxTween.tween(item, {x: xThing}, 0.1, {ease: FlxEase.quartInOut});
			}
		}
	}

	function regenMenu():Void {
		for (i in 0...grpMenuShit.members.length) {
			var obj = grpMenuShit.members[0];
			obj.kill();
			grpMenuShit.remove(obj, true);
			obj.destroy();
		}
		curSelected = 0;
		for (i in 0...menuItems.length) {
			var size = 3 / menuItems.length;
			var item = new FlxText(0,(i * (((428 * 0.675) * size) * 0.75) + (size == 1 ? 16 :0)), menuItems[i]);
			item.ID = i;
			item.setFormat(Paths.font("GILLUBCD.ttf"), Std.int((428 * 0.675) * size));
			item._defaultFormat.letterSpacing = -20*size;
			item.updateDefaultFormat();
			grpMenuShit.add(item);
			item.color = (item.ID == curSelected ? 0xFC7639 : 0xFEF1E2); // good ol hacky fix
			

			if(menuItems[i] == 'Skip Time')
			{
				skipTimeText = new FlxText(0, 0, 0, '', 64);
				skipTimeText.setFormat(Paths.font("lyricfont.ttf"), 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.SHADOW, FlxColor.BLACK);
				skipTimeText.scrollFactor.set();
				skipTimeText.alpha = 0.75;
				skipTimeTracker = item;
				add(skipTimeText);

				updateSkipTextStuff();
				updateSkipTimeText();
			}
		}
		changeSelection(0,true);
	}
	
	var doItUntilTheShitIsDone = true;
	function updateSkipTextStuff()
	{
		if(skipTimeText == null || skipTimeTracker == null) return;
		skipTimeText.x = skipTimeTracker.x - skipTimeText.pixels.width;
		skipTimeText.y = skipTimeTracker.y + (skipTimeTracker.pixels.height/2);
		skipTimeText.visible = (skipTimeTracker.alpha >= 1);
		for (i in 0...grpMenuShit.members.length) {
			var item = grpMenuShit.members[i];
			if (doItUntilTheShitIsDone) {
				if (item.color == 0xFEF1E2) item.x = FlxG.width - (item.pixels.width/2)
				else if (Math.abs(i - curSelected) == 1) item.x = FlxG.width - (item.pixels.width/1.3333333);
				else item.x = FlxG.width - item.pixels.width;
			}
		}
	}

	function updateSkipTimeText()
	{
		skipTimeText.text = FlxStringUtil.formatTime(Math.max(0, Math.floor(curTime / 1000)), false) + ' / ' + FlxStringUtil.formatTime(Math.max(0, Math.floor(FlxG.sound.music.length / 1000)), false);
	}
}
