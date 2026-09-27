package states;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import objects.Barrier;
import objects.Warrior;

class Game extends FlxState {
	private var warriors:FlxTypedGroup<Warrior> = new FlxTypedGroup<Warrior>();
	private var barriers:FlxTypedGroup<Barrier> = new FlxTypedGroup<Barrier>();
	private var draggedWarrior:Warrior;

	static public var camGame:FlxCamera;
	static public var camHUD:FlxCamera;

	private var clearButton:FlxButton;

    override function create() {
        super.create();

		add(barriers);
		add(warriors);

		Warrior.group = warriors;
		Warrior.barrierGroup = barriers;

		initCameras();
		createHUD();
    }

    override function update(dt:Float) {
        super.update(dt);

		if (!FlxG.mouse.overlaps(clearButton)) {
			if (FlxG.mouse.justPressed) {
				var pos = FlxG.mouse.getWorldPosition(camGame);
				warriors.add(new Warrior(pos.x - 16, pos.y - 16, Red));
				pos.put();
			}

			if (FlxG.mouse.justPressedRight) {
				var pos = FlxG.mouse.getWorldPosition(camGame);
				warriors.add(new Warrior(pos.x - 16, pos.y - 16, Blue));
				pos.put();
			}

			handleDragging();
			warriors.sort(FlxSort.byY, FlxSort.ASCENDING); // WOW???
		}
		var speed = FlxG.keys.pressed.SHIFT ? 10 : 5;

		if (FlxG.keys.anyPressed([A, LEFT]))
			camGame.scroll.x -= speed;
		else if (FlxG.keys.anyPressed([D, RIGHT]))
			camGame.scroll.x += speed;

		if (FlxG.keys.anyPressed([W, UP]))
			camGame.scroll.y -= speed;
		else if (FlxG.keys.anyPressed([S, DOWN]))
			camGame.scroll.y += speed;
		//

		FlxG.collide(warriors, barriers);
	}

	private function handleDragging() {
		if (FlxG.mouse.justPressedMiddle) {
			draggedWarrior = getWarriorUnderMouse();
			if (draggedWarrior != null)
				draggedWarrior.startDrag();
		}

		if (FlxG.mouse.justReleasedMiddle && draggedWarrior != null) {
			draggedWarrior.stopDrag();
			draggedWarrior = null;
		}
	}

	private function getWarriorUnderMouse():Warrior {
		var mouseWorld = FlxG.mouse.getWorldPosition(camGame);
		var closest:Warrior = null;
		var closestDistSq:Float = Math.POSITIVE_INFINITY;

		warriors.forEachAlive((w:Warrior) -> {
			if (w.overlapsPoint(mouseWorld)) {
				var dx = w.getMidpoint().x - mouseWorld.x;
				var dy = w.getMidpoint().y - mouseWorld.y;
				var distSq = dx * dx + dy * dy;

				if (distSq < closestDistSq) {
					closestDistSq = distSq;
					closest = w;
				}
			}
		});

		mouseWorld.put();
		return closest;
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
		versionText.font = Paths.font('pixel');
		add(versionText);
		clearButton = new FlxButton(10, 10, "Clear Warriors", () -> {
			warriors.forEachAlive((w:Warrior) -> w.kill());
			warriors.clear();
		});

		add(clearButton).camera = camHUD;

		versionText.camera = camHUD;
	}
}