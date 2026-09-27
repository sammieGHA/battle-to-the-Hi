package objects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxVelocity;
import flixel.util.FlxColor;
import objects.overridable.DamageableSprite;

enum WarriorColor {
	Red;
	Blue;
}

enum WarriorState {
	Idle;
	Wandering;
	Seeking;
	Attacking;
}

class Warrior extends DamageableSprite {
	private static var graphicCache:Map<WarriorColor, FlxGraphic> = new Map();
	public static var group:FlxTypedGroup<Warrior>;

	public var w_color(default, null):WarriorColor;
	public var isDragged(default, null):Bool = false;

	public var sightRange:Float = 190;
	public var attackRange:Float = 18;
	public var speed:Float = 40;
	public var attackCooldown:Float = .8;
	public var minDamage:Int = 5;
	public var maxDamage:Int = 10;

	public var wanderSpeed:Float = 20;
	public var minIdleTime:Float = 1;
	public var maxIdleTime:Float = 3;
	public var minWanderTime:Float = .8;
	public var maxWanderTime:Float = 2.0;

	private var idleTimer:Float = 0;
	private var idleDuration:Float = 0;
	private var wanderTimer:Float = 0;
	private var wanderAngle:Float = 0;

	private var state:WarriorState = Idle;
	private var target:Warrior;
	private var attackTimer:Float = 0;
    private var frameRate:Int = 10;

	private var searchInterval:Float = .4;
	private var searchTimer:Float = 0;

	private var separationRadius:Float = 16;
	private var separationForce:Float = 50;

	public function new(x:Float, y:Float, color:WarriorColor) {
        super(x, y);

		this.w_color = color;
		flipX = color == Blue;

		loadGraphic(getGraphic(color), true, 32, 32);
        antialiasing = false;

        animation.add('idle', [0, 1], frameRate, true);
        animation.add('walk', [2, 3], frameRate, true);
        animation.add('death', [4, 5, 6, 7, 8], frameRate, false);
		animation.add('punch', [9, 10, 11, 12], frameRate, false);
		animation.add('dragged', [13, 14], frameRate, true);

        play('idle', true);
		searchTimer = Math.random() * searchInterval;
		idleDuration = FlxG.random.float(minIdleTime, maxIdleTime);
	}

	override function update(dt:Float) {
		if (isDragged) {
			var pos = FlxG.mouse.getWorldPosition(states.Game.camGame);
			setPosition(pos.x - width / 2, pos.y - height / 2);
			pos.put();
		} else if (!isDead) {
			updateAI(dt);
			applySeparation(dt);
		}

		super.update(dt);
	}

	private function applySeparation(dt:Float) {
		if (group == null)
			return;

		var px:Float = 0;
		var py:Float = 0;
		var neighbors = 0;
		var radiusSqrt = separationRadius * separationRadius;

		group.forEachAlive((w:Warrior) -> {
			if (w == this || w.isDead || w.isDragged)
				return;

			var dx = x - w.x;
			var dy = y - w.y;
			var distSq = dx * dx + dy * dy;

			if (distSq < radiusSqrt && distSq > 0) {
				var dist = Math.sqrt(distSq);
				px += dx / dist;
				py += dy / dist;
				neighbors++;
			}
		});

		if (neighbors > 0) {
			px /= neighbors;
			py /= neighbors;

			x += px * separationForce * dt;
			y += py * separationForce * dt;
		}
	}

	public function startDrag() {
		if (isDead)
			return;

		isDragged = true;
		target = null;
		state = Idle;
		velocity.set(0, 0);
		play('dragged', true);
	}

	public function stopDrag() {
		isDragged = false;
		play('idle', true);
		searchTimer = 0;
	}

	private function updateAI(dt:Float) {
		if (target != null && (target.isDead || !target.alive || target.isDragged)) {
			target = null;
		}

		searchTimer -= dt;
		if (target == null && searchTimer <= 0) {
			searchTimer = searchInterval;
			target = findNearest();
		}

		if (target == null) {
			updateWander(dt);
			return;
		}

		var distSqrt = distanceSquared(target);

		flipX = target.x < x;
		if (distSqrt > attackRange * attackRange) {
			state = Seeking;
			FlxVelocity.moveTowardsObject(this, target, speed);
			play('walk');
		} else {
			if (state != Attacking) {
				state = Attacking;
				velocity.set(0, 0);
			}

			velocity.set(0, 0);
			handleAttack(dt);
		}
	}

	override function die() {
		super.die();

		FlxG.sound.play(Paths.sound('die'));
	}

	private function updateWander(dt:Float) {
		switch state {
			case Idle:
				idleTimer += dt;
				if (idleTimer >= idleDuration)
					startWandering();
			case Wandering:
				wanderTimer -= dt;
				if (wanderTimer <= 0)
					startIdling();
				else
					flipX = velocity.x < 0;
			default:
				startIdling();
		}
	}

	private function startIdling() {
		state = Idle;
		idleTimer = 0;
		idleDuration = FlxG.random.float(minIdleTime, maxIdleTime);
		velocity.set(0, 0);
		play('idle');
	}

	private function startWandering() {
		state = Wandering;
		wanderTimer = FlxG.random.float(minWanderTime, maxWanderTime);

		wanderAngle = FlxG.random.float(0, Math.PI * 2);
		velocity.set(Math.cos(wanderAngle) * wanderSpeed, Math.sin(wanderAngle) * wanderSpeed);

		play('walk');
	}

	private function handleAttack(dt:Float) {
		attackTimer -= dt;

		if (attackTimer <= 0) {
			attackTimer = attackCooldown;
			play('punch', true);

			FlxG.sound.play(Paths.sound('hit'));

			var dmg = FlxG.random.int(minDamage, maxDamage);
			target.hurt(dmg);

			if (target.isDead) {
				target = null;
				state = Idle;
			}
		}
	}

	private function findNearest():Warrior {
		if (group == null)
			return null;

		var closest:Warrior = null;
		var closestDistSqrt:Float = sightRange * sightRange;

		group.forEachAlive((w:Warrior) -> {
			if (w == this || w.w_color == w_color || w.isDead || w.isDragged)
				return;

			var dx = w.x - x;
			var dy = w.y - y;

			var distSqrt = dx * dx + dy * dy;
			if (distSqrt <= closestDistSqrt) {
				closestDistSqrt = distSqrt;
				closest = w;
			}
		});

		return closest;
	}

	private inline function distanceSquared(other:FlxSprite):Float {
		var dx = other.x - x;
		var dy = other.y - y;
		return dx * dx + dy * dy;
	}

	private function getGraphic(warriorColor:WarriorColor):FlxGraphic {
		if (graphicCache.exists(warriorColor))
			return graphicCache.get(warriorColor);

		var graphic:FlxGraphic;
		if (warriorColor == Red)
			graphic = FlxG.bitmap.add(Paths.image('warrior'));
		else {
			graphic = FlxG.bitmap.add(Paths.image('warrior'), false, 'warrior_blue');
			graphic.bitmap = graphic.bitmap.clone();

			var temp = new FlxSprite();
			temp.pixels = graphic.bitmap;
			temp.replaceColor(FlxColor.RED, FlxColor.BLUE);
			graphic.bitmap = temp.pixels;
		}

		graphicCache.set(warriorColor, graphic);
		return graphic;
	}

    override private function onDeathComplete() {
        super.onDeathComplete();
    }
}