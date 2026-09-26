package objects;

import flixel.FlxSprite;
import objects.overridable.DamageableSprite;

class Warrior extends DamageableSprite {
    private var frameRate:Int = 10;

    public function new(x:Float, y:Float) {
        super(x, y);

		loadGraphic(Paths.image('warrior'), true, 32, 32);
        antialiasing = false;

        animation.add('idle', [0, 1], frameRate, true);
        animation.add('walk', [2, 3], frameRate, true);
        animation.add('death', [4, 5, 6, 7, 8], frameRate, false);

        play('idle', true);
    }

    override private function onDeathComplete() {
        super.onDeathComplete();
    }
}