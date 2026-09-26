package objects.interfaces;

interface IDamageable {
    public var isDead(default, null):Bool;
    public var hp(default, null):Int;

    public function hurt(dmg:Int):Void;
    public function die():Void;
}