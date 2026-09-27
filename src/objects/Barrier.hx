package objects;

import flixel.FlxSprite;
import flixel.util.FlxColor;

class Barrier extends FlxSprite {
    public function new(x:Float, y:Float) {
        super(x, y);

        loadGraphic(Paths.image('barrier'), true, 16, 16);
        antialiasing = false;
        immovable = true;
    }
}