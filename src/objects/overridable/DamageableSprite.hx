package objects.overridable;

import flixel.FlxSprite;
import objects.interfaces.IDamageable;

class DamageableSprite extends FlxSprite implements IDamageable {
    public var hp(default, null):Int;
    public var isDead(default, null):Bool = false;

    private var deathAnimName:String = 'death';

    public function new(x:Float, y:Float, startingHp:Int = 100) {
        super(x, y);
        hp = startingHp;
        animation.onFinish.add(animComplete);
    }

    public function play(anim:String, ?force:Bool = false) {
        if (isDead) return;
        animation.play(anim, force);
    }

    public function hurt(dmg:Int) {
        if (isDead) return;

        hp -= dmg;
        onHurt(dmg);

        if (hp <= 0) {
            hp = 0;
            die();
        }
    }

    public function die() {
        if (isDead) return;

        isDead = true;
        animation.play(deathAnimName, true);
    }

    private function animComplete(n:String) {
        if (n == deathAnimName) {
            onDeathComplete();
        }
    }

    // this is for overriding shit

    private function onHurt(dmg:Int) {}
    private function onDeathComplete() {
        kill();
    }
}