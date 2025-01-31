package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import lime.graphics.Image;
import openfl.Lib;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class GameOverSubstate extends MusicBeatSubstate
{
	public var boyfriend:Boyfriend;
	var camFollow:FlxPoint;
	var camFollowPos:FlxObject;
	var updateCamera:Bool = false;
	var playingDeathSound:Bool = false;

	var stageSuffix:String = "";

	public static var characterName:String = 'bf';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';
	public static var cryingsSoundName:String = 'gameOverCryingChavo';
	public static var shitpostingSoundName:String = 'notSong'; //It was thought to add more dialogues but due to lack of time this idea was discarded

	public static var instance:GameOverSubstate;

	public static function resetVariables() {
		characterName = 'bf';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'gameOver';
		endSoundName = 'gameOverEnd';
		cryingsSoundName = 'gameOverCryingChavo';
		shitpostingSoundName = 'notSong';
	}

	override function create()
	{
		instance = this;
		PlayState.instance.callOnLuas('onGameOverStart', []);

		super.create();
	}

	public function new(x:Float, y:Float, camX:Float, camY:Float)
	{
		super();

		PlayState.instance.setOnLuas('inGameOver', true);

		Conductor.songPosition = 0;

		boyfriend = new Boyfriend(x, y, characterName);
		boyfriend.x += boyfriend.positionArray[0];
		boyfriend.y += boyfriend.positionArray[1];
		add(boyfriend);

		camFollow = new FlxPoint(boyfriend.getGraphicMidpoint().x, boyfriend.getGraphicMidpoint().y);

		FlxG.sound.play(Paths.sound(deathSoundName));
		FlxG.sound.play(Paths.sound(shitpostingSoundName));
		Conductor.changeBPM(100);
		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		boyfriend.playAnim('firstDeath');

		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2));
		add(camFollowPos);
	}

	var isFollowingAlready:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		PlayState.instance.callOnLuas('onUpdate', [elapsed]);
		if(updateCamera) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 0.6, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		}

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;
			PlayState.chartingMode = false;

			WeekData.loadTheFirstEnabledMod();
			if(PlayState.isStoryMode) {
				MusicBeatState.switchState(new StoryMenuState());
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				Lib.application.window.title = "Friday Night Funkin': El Chavo";
				Lib.application.window.setIcon(Image.fromBitmapData(Paths.image("iconOG").bitmap));
			} else {
				MusicBeatState.switchState(new FreeplayState());
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				Lib.application.window.title = "Friday Night Funkin': El Chavo";
				Lib.application.window.setIcon(Image.fromBitmapData(Paths.image("iconOG").bitmap));
				PlayState.curDeaths = 0;
			}

			if (PlayState.isFreeplay){
				MusicBeatState.switchState(new FreeplayCategory2State());
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				Lib.application.window.title = "Friday Night Funkin': El Chavo";
				Lib.application.window.setIcon(Image.fromBitmapData(Paths.image("iconOG").bitmap));
				PlayState.curDeaths = 0;
			}

			if (PlayState.isWeekSuicida){
				MusicBeatState.switchState(new StorySuicidaState());
				FlxG.sound.playMusic(Paths.music('freakyMenuVs'));
				Lib.application.window.title = "Friday Night Funkin': Vs El Chavo Suicida";
				Lib.application.window.setIcon(Image.fromBitmapData(Paths.image("VsSuicida/IconSuicida").bitmap));
				PlayState.weekMisses = 0;
			} 
				
			if (PlayState.isNotWeekSuicida){
				MusicBeatState.switchState(new FreeplaySuicidaState());
				FlxG.sound.playMusic(Paths.music('freakyMenuVs'));
				Lib.application.window.title = "Friday Night Funkin': Vs El Chavo Suicida";
				Lib.application.window.setIcon(Image.fromBitmapData(Paths.image("VsSuicida/IconSuicida").bitmap));
				PlayState.curDeaths = 0;
				PlayState.weekMisses = 0;
			}

			if (PlayState.isFreeplayCovers){
				MusicBeatState.switchState(new FreeplayCategoryRoadState());
				FlxG.sound.playMusic(Paths.music('CoversDelOcho/freakyMenu'));
				Lib.application.window.title = "Friday Night Funkin': El Chavo";
				Lib.application.window.setIcon(Image.fromBitmapData(Paths.image("iconOG").bitmap));
				PlayState.curDeaths = 0;				
			}										

			PlayState.instance.callOnLuas('onGameOverConfirm', [false]);
		}

		if (boyfriend.animation.curAnim != null && boyfriend.animation.curAnim.name == 'firstDeath')
		{
			if(boyfriend.animation.curAnim.curFrame >= 12 && !isFollowingAlready)
			{
				FlxG.camera.follow(camFollowPos, LOCKON, 1);
				updateCamera = true;
				isFollowingAlready = true;
			}

			if (boyfriend.animation.curAnim.finished && !playingDeathSound)
			{
				if (PlayState.SONG.stage == 'tank')
				{
					playingDeathSound = true;
					coolStartDeath(0.2);
					
					var exclude:Array<Int> = [];
					//if(!ClientPrefs.cursing) exclude = [1, 3, 8, 13, 17, 21];

					FlxG.sound.play(Paths.sound('jeffGameover/jeffGameover-' + FlxG.random.int(1, 25, exclude)), 1, false, null, true, function() {
						if(!isEnding)
						{
							FlxG.sound.music.fadeIn(0.2, 1, 4);
						}
					});
				}
				else
				{
					coolStartDeath();
				}
				boyfriend.startedDeath = true;
			}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
		PlayState.instance.callOnLuas('onUpdatePost', [elapsed]);
	}

	override function beatHit()
	{
		super.beatHit();

		//FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function coolStartDeath(?volume:Float = 1):Void
	{
		FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			boyfriend.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(endSoundName));
			FlxG.sound.play(Paths.music(cryingsSoundName));
			FlxG.sound.music.volume = 0.3;
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					MusicBeatState.resetState();
				});
			});
			PlayState.instance.callOnLuas('onGameOverConfirm', [true]);
		}
	}
}
