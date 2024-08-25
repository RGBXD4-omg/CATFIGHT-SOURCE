package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.6.3'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = [
		'start',
		'options'
	];

	var debugKeys:Array<FlxKey>;

	public var selectedOrNotOption:FlxSprite = new FlxSprite();
	public var selectedOrNotStart:FlxSprite = new FlxSprite();

	var tweenButtonThingie:FlxTween;
	var tweenAlphaStart:FlxTween;
	var tweenAlphaOptions:FlxTween;

	override function create()
	{
		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('mainmenu/bg_mm'));
		bg.scale.set(0.675, 0.675);
		bg.scrollFactor.set(0, 0);
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		var sideThing:FlxSprite = new FlxSprite().loadGraphic(Paths.image('mainmenu/side_mm'));
		sideThing.scale.set(0.68, 0.68);
		sideThing.screenCenter(Y);
		sideThing.y = sideThing.y + 5;
		sideThing.x = 535;
		sideThing.scrollFactor.set(0, 0);
		add(sideThing);

		var partsSide:FlxSprite = new FlxSprite();
		partsSide.frames = Paths.getSparrowAtlas('mainmenu/coffee');
		partsSide.animation.addByPrefix('coffeeMove', "coffee", 24);
		partsSide.animation.play('coffeeMove');
		partsSide.scale.set(0.68, 0.68);
		partsSide.y = 10;
		partsSide.x = 615;
		partsSide.scrollFactor.set(0, 0);
		add(partsSide);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		selectedOrNotOption.scale.x = scale - 0.35;
		selectedOrNotOption.scale.y = scale - 0.35;
		selectedOrNotOption.frames = Paths.getSparrowAtlas('mainmenu/options_select');
		selectedOrNotOption.animation.addByPrefix('idle', "options_selected", 24);
		selectedOrNotOption.animation.play('idle');
		selectedOrNotOption.setPosition(-200, -200);
		selectedOrNotOption.scrollFactor.set(0, 0);
		add(selectedOrNotOption);

		selectedOrNotStart.scale.x = scale - 0.35;
		selectedOrNotStart.scale.y = scale - 0.35;
		selectedOrNotStart.frames = Paths.getSparrowAtlas('mainmenu/start_select');
		selectedOrNotStart.animation.addByPrefix('idle', "start_selected", 24);
		selectedOrNotStart.animation.play('idle');
		selectedOrNotStart.setPosition(-200, -200);
		selectedOrNotStart.scrollFactor.set(0, 0);
		add(selectedOrNotStart);

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite();
			menuItem.scale.x = 0.65;
			menuItem.scale.y = 0.65;
			menuItem.loadGraphic(Paths.image('mainmenu/' + optionShit[i]));
			menuItem.ID = i;
			menuItems.add(menuItem);

			tweenButtonThingie = FlxTween.tween(menuItem.scale, {x: 0.65, y: 0.65}, 0.25, {ease: FlxEase.quadInOut});
			tweenAlphaStart = FlxTween.tween(menuItem, {alpha: 1}, 0.25, {ease: FlxEase.quadInOut});
			tweenAlphaOptions = FlxTween.tween(menuItem, {alpha: 1}, 0.25, {ease: FlxEase.quadInOut});

			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.scrollFactor.set(0, 0);
			menuItem.updateHitbox();

			switch (i)
			{
				case 0:
					menuItem.setPosition(375, 15);

				case 1:
					menuItem.setPosition(75, 325);
	
			}

		}


		var versionShit:FlxText = new FlxText(2, FlxG.height - 48, 0, "FNF: CATFIGHT", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font("fontthingie.ttf"), 16, FlxColor.WHITE, LEFT);
		add(versionShit);

		var versionShit:FlxText = new FlxText(2, FlxG.height - 28, 0, "PSYCH ENGINE v"+psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font("fontthingie.ttf"), 16, FlxColor.WHITE, LEFT);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		#if android
		addVirtualPad(UP_DOWN, A_B);
		#end

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}


		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

		if (controls.ACCEPT)
		{
			if (optionShit[curSelected] == 'donate')
			{
				CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
			}
			else
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));

				menuItems.forEach(function(spr:FlxSprite)
				{
					if (curSelected == spr.ID)
					{
						FlxTween.tween(spr.scale, {x: 0.75, y: 0.75}, 0.35, {
							ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween)
								{

									var daChoice:String = optionShit[curSelected];

									switch (daChoice)
									{
										case 'start':
											MusicBeatState.switchState(new ChooseMixState());
										case 'options':
											LoadingState.loadAndSwitchState(new options.OptionsState());
									}

								}
							});
						}
					});
				}
			}

			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		var daChoice:String = optionShit[curSelected];

		switch (daChoice)
		{

			case 'options':
				
			tweenAlphaOptions.cancel();
			tweenAlphaStart.cancel();

			tweenAlphaStart = FlxTween.tween(selectedOrNotStart, {alpha: 0}, 0.15, {ease: FlxEase.quadInOut});
			tweenAlphaOptions = FlxTween.tween(selectedOrNotOption, {alpha: 1}, 0.15, {ease: FlxEase.quadInOut});

			case 'start':

			tweenAlphaOptions.cancel();
			tweenAlphaStart.cancel();

			tweenAlphaStart = FlxTween.tween(selectedOrNotStart, {alpha: 1}, 0.15, {ease: FlxEase.quadInOut});
			tweenAlphaOptions = FlxTween.tween(selectedOrNotOption, {alpha: 0}, 0.15, {ease: FlxEase.quadInOut});

		}

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{

				tweenButtonThingie.cancel();

				spr.scale.set(0.7, 0.7);

				tweenButtonThingie = FlxTween.tween(spr.scale, {x: 0.65, y: 0.65}, 0.25, {ease: FlxEase.quadInOut});

				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
			}
		});
	}
}
