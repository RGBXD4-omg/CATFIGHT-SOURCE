package;

import flixel.group.FlxSpriteGroup;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
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

class ChooseMixState extends MusicBeatState
{

    public static var curSelected:Int = 0;

    var caseGroupYes:FlxSpriteGroup;
    private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;

    var mixesYeah:Array<String> = [
		'fucked',
		'sillied'
	];

    public var blackCatIdle:FlxSprite = new FlxSprite();
    public var blackCatSelected:FlxSprite = new FlxSprite();

	public var whiteCatIdle:FlxSprite = new FlxSprite();
    public var whiteCatSelected:FlxSprite = new FlxSprite();

    public var boltsYes:FlxSprite = new FlxSprite();
    public var cloudsYes:FlxSprite = new FlxSprite();

	public var flowerYes:FlxSprite = new FlxSprite();
    public var waveYes:FlxSprite = new FlxSprite();

    public var selectMixText:FlxText = new FlxText();
    public var blackbarTransition:FlxSprite = new FlxSprite(FlxG.height).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);

    override function create()
    {

        #if desktop
		DiscordClient.changePresence("In the Menus", "Choosing Mix");
		#end

        camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;


		persistentUpdate = persistentDraw = true;

        // bg stuff
        var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('mixSelectShit/bg_mix'));
		bg.scale.set(0.675, 0.675);
		bg.scrollFactor.set(0, 0);
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

        var bgThingie:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('mixSelectShit/collume'));
		bgThingie.scale.set(0.675, 0.675);
		bgThingie.scrollFactor.set(0, 0);
		bgThingie.updateHitbox();
		bgThingie.screenCenter();
		bgThingie.antialiasing = ClientPrefs.globalAntialiasing;
		add(bgThingie);

        var scale:Float = 1;

        // characters idle 'n selected stuff

        // fucked
        blackCatIdle.scale.x = scale - 0.35;
		blackCatIdle.scale.y = scale - 0.35;
		blackCatIdle.frames = Paths.getSparrowAtlas('mixSelectShit/animatedStuff/idle_b');
		blackCatIdle.animation.addByPrefix('idle', "flowers", 24);
		blackCatIdle.animation.play('idle');
		blackCatIdle.setPosition(-175, -200);
		blackCatIdle.scrollFactor.set(0, 0);
		add(blackCatIdle);

        blackCatSelected.scale.x = scale - 0.35;
		blackCatSelected.scale.y = scale - 0.35;
		blackCatSelected.frames = Paths.getSparrowAtlas('mixSelectShit/animatedStuff/selcted_b');
		blackCatSelected.animation.addByPrefix('selected', "flower", 24);
		blackCatSelected.animation.play('selected');
		blackCatSelected.setPosition(-175, -200);
		blackCatSelected.scrollFactor.set(0, 0);
		add(blackCatSelected);

        // silly
		whiteCatIdle.scale.x = scale - 0.35;
		whiteCatIdle.scale.y = scale - 0.35;
		whiteCatIdle.frames = Paths.getSparrowAtlas('mixSelectShit/animatedStuff/idle_w');
		whiteCatIdle.animation.addByPrefix('idle', "flowers", 24);
		whiteCatIdle.animation.play('idle');
		whiteCatIdle.setPosition(450, -200);
		whiteCatIdle.scrollFactor.set(0, 0);
		add(whiteCatIdle);

        whiteCatSelected.scale.x = scale - 0.35;
		whiteCatSelected.scale.y = scale - 0.35;
		whiteCatSelected.frames = Paths.getSparrowAtlas('mixSelectShit/animatedStuff/selcted_w');
        whiteCatSelected.animation.addByPrefix('selected', "flower", 24);
		whiteCatSelected.animation.play('selected');
		whiteCatSelected.setPosition(450, -200);
		whiteCatSelected.scrollFactor.set(0, 0);
		add(whiteCatSelected);

        // auras bgs shit

        // fucked
        waveYes.scale.x = scale - 0.3;
		waveYes.scale.y = scale - 0.3;
		waveYes.frames = Paths.getSparrowAtlas('mixSelectShit/animatedStuff/auras/wave');
		waveYes.animation.addByPrefix('waveSelected', "wave", 24);
		waveYes.animation.play('waveSelected');
        waveYes.screenCenter(X);
        waveYes.y = 400;
		waveYes.scrollFactor.set(0, 0);
		add(waveYes);

        // silly
        cloudsYes.scale.x = scale - 0.3;
		cloudsYes.scale.y = scale - 0.3;
		cloudsYes.frames = Paths.getSparrowAtlas('mixSelectShit/animatedStuff/auras/cloud');
        cloudsYes.animation.addByPrefix('selectedCloud', "cloud", 24);
		cloudsYes.animation.play('selectedCloud');
        cloudsYes.screenCenter(X);
        cloudsYes.y = 400;
		cloudsYes.scrollFactor.set(0, 0);
		add(cloudsYes);

        caseGroupYes = new FlxSpriteGroup();
		add(caseGroupYes);

        for (i in 0...mixesYeah.length)
        {
            var caseThingiesYes:FlxSprite = new FlxSprite();
            caseThingiesYes.scale.x = 0.7;
			caseThingiesYes.scale.y = 0.7;
			caseThingiesYes.loadGraphic(Paths.image('mixSelectShit/' + mixesYeah[i] + '_mix'));
			caseThingiesYes.ID = i;
			caseGroupYes.add(caseThingiesYes);
            caseThingiesYes.scrollFactor.set(0, 0);
			caseThingiesYes.updateHitbox();

            switch (i)
            {
                case 0:
                    caseThingiesYes.setPosition(266, 445);

                case 1:
                    caseThingiesYes.setPosition(275, 474);

            }

        }

                //arua shit

        //fucked
        boltsYes.scale.x = scale - 0.3;
		boltsYes.scale.y = scale - 0.3;
		boltsYes.frames = Paths.getSparrowAtlas('mixSelectShit/animatedStuff/auras/bolt');
		boltsYes.animation.addByPrefix('boltsSelected', "bolts", 24);
		boltsYes.animation.play('boltsSelected');
        boltsYes.screenCenter(X);
        boltsYes.y = 175;
		boltsYes.scrollFactor.set(0, 0);
		add(boltsYes);


        // silly 
        flowerYes.scale.x = scale - 0.3;
		flowerYes.scale.y = scale - 0.3;
		flowerYes.frames = Paths.getSparrowAtlas('mixSelectShit/animatedStuff/auras/flower');
        flowerYes.animation.addByPrefix('selectedFlowers', "flowers", 24);
		flowerYes.animation.play('selectedFlowers');
        flowerYes.screenCenter(X);
        flowerYes.x = flowerYes.x - 25;
        flowerYes.y = 185;
		flowerYes.scrollFactor.set(0, 0);
		add(flowerYes);
        
        var blackBarThingie:FlxSprite = new FlxSprite(FlxG.height).makeGraphic(FlxG.width, 46, FlxColor.WHITE);
        blackBarThingie.screenCenter(X);
        blackBarThingie.color = 0x2A1E2C;
		add(blackBarThingie);

		selectMixText.text = 'SELECT YOUR MIX SELECT YOUR MIX SELECT YOUR MIX SELECT YOUR MIX SELECT YOUR MIX SELECT YOUR MIX SELECT YOUR MIX SELECT YOUR MIX SELECT YOUR MIX SELECT YOUR MIX SELECT YOUR MIX SELECT YOUR MIX SELECT YOUR MIX SELECT YOUR MIX SELECT YOUR MIX SELECT YOUR MIX SELECT YOUR MIX SELECT YOUR MIX SELECT YOUR MIX SELECT YOUR MIX SELECT YOUR MIX SELECT YOUR MIX';
        selectMixText.x = -6100;
		selectMixText.setFormat(Paths.font("fontthingie.ttf"), 30, FlxColor.WHITE);
        selectMixText.color = 0xFEF1E2;
        selectMixText.scale.set(1.0666666666666666667,1.0666666666666666667);
        selectMixText.updateHitbox();
        add(selectMixText);

        blackbarTransition.screenCenter(X);
        blackbarTransition.alpha = 0;
		add(blackbarTransition);

        changeItem();

	    #if android
            addVirtualPad(LEFT_RIGHT, A_B);
	    #end

        super.create();

    }

    var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{

        selectMixText.x = selectMixText.x + 0.5;

        if (selectMixText.x == 0)
        {
            selectMixText.x = -6100;
        }

		if (!selectedSomethin)
		{
			if (controls.UI_LEFT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_RIGHT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

            var lerpVal:Float = CoolUtil.boundTo(elapsed * 6, 0, 1);
            caseGroupYes.y = FlxMath.lerp(caseGroupYes.y, 0, lerpVal);

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}

            if (controls.ACCEPT)
            {

                FlxG.sound.play(Paths.sound('confirmMenu'));
                selectedSomethin = true;
                FlxG.sound.music.fadeOut();
                FlxTween.tween(FlxG.camera, {zoom: 1.5}, 3.5, {ease: FlxEase.quadOut});
                FlxTween.tween(blackbarTransition, {alpha: 1}, 1.5, {
                    ease: FlxEase.quadOut,
                    onComplete: function(twn:FlxTween)
                    {
                        var daChoice:String = mixesYeah[curSelected];

                        switch (daChoice)
                        {
                            case 'fucked':
                                LoadingState.loadAndSwitchState(new PlayState());
                                PlayState.SONG = Song.loadFromJson('mrow-fucked', 'mrow-fucked');

                            case 'sillied':
                                LoadingState.loadAndSwitchState(new PlayState());
                                PlayState.SONG = Song.loadFromJson('mrow-silly', 'mrow-silly');
                        }   
                    }
                });

            }
        }

        super.update(elapsed);

    }


    function changeItem(huh:Int = 0)
        {
            curSelected += huh;
    
            if (curSelected >= caseGroupYes.length)
                curSelected = 0;
            if (curSelected < 0)
                curSelected = caseGroupYes.length - 1;
            caseGroupYes.y+=4;

            var daChoice:String = mixesYeah[curSelected];

            switch (daChoice)
            {
                case 'fucked':

                //characters
                blackCatIdle.visible = false;
                blackCatSelected.visible = true;

                whiteCatIdle.visible = true;
                whiteCatSelected.visible = false;

                //auras
                boltsYes.visible = true;
                waveYes.visible = true;

                flowerYes.visible = false;
                cloudsYes.visible = false;

                case 'sillied':

                //characters
                blackCatIdle.visible = true;
                blackCatSelected.visible = false;

                whiteCatIdle.visible = false;
                whiteCatSelected.visible = true;

                //auras
                boltsYes.visible = false;
                waveYes.visible = false;

                flowerYes.visible = true;
                cloudsYes.visible = true;

            }
    
            caseGroupYes.forEach(function(spr:FlxSprite)
            {
                spr.visible = false;
                spr.updateHitbox();
                
                if (spr.ID == curSelected)
                {
                    spr.visible = true;

                    var add:Float = 0;
                    if(caseGroupYes.length > 4) {
                        add = caseGroupYes.length * 8;
                    }
                }
            });
        }
}
