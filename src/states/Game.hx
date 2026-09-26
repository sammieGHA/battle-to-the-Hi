package states;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import objects.Warrior;

class Game extends FlxState {
    var warriors:FlxTypedGroup<Warrior> = new FlxTypedGroup<Warrior>();
    var warrior:Warrior;

	private var camGame:FlxCamera;
	private var camHUD:FlxCamera;

    override function create() {
        super.create();

		initCameras();

        warrior = new Warrior(20, 20);
        add(warrior);
		createHUD();
    }

    override function update(dt:Float) {
        super.update(dt);

        testingPurposes();
    }

	private function initCameras() {
		camGame = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
		camHUD = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);

		camGame.bgColor = 0xFF272836;
		camHUD.bgColor = FlxColor.TRANSPARENT;

		FlxG.cameras.add(camGame, true);
		FlxG.cameras.add(camHUD, false);
	}

	private function createHUD() {
		var versionText = new FlxText(8, FlxG.height - 25, 0, 'Version ${openfl.Lib.application.meta.get("version")}', 16);
		versionText.font = 'res/data/fonts/pixel.ttf';
		add(versionText);
	}

    /**
     * THIS IS FOR TESTING
     * REMOVE ONCE EVERYTHINGS MORE FINISHED LOL
     */
    private function testingPurposes() {
        if (FlxG.keys.justPressed.ONE)
            warrior.play('idle', true);
        if (FlxG.keys.justPressed.TWO)
            warrior.play('walk', true);
        if (FlxG.keys.justPressed.THREE)
            warrior.die();
    }
}