package states;

import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import objects.Warrior;

class Game extends FlxState {
    var warriors:FlxTypedGroup<Warrior> = new FlxTypedGroup<Warrior>();
    var warrior:Warrior;

    override function create() {
        super.create();

        FlxG.camera.bgColor = flixel.util.FlxColor.GRAY;

        warrior = new Warrior(20, 20);
        add(warrior);
    }

    override function update(dt:Float) {
        super.update(dt);

        testingPurposes();
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