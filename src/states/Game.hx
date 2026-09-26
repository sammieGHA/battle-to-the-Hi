package states;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import objects.Warrior;

class Game extends FlxState {
	private var warriors:FlxTypedGroup<Warrior> = new FlxTypedGroup<Warrior>();
	private var draggedWarrior:Warrior;

	private var camGame:FlxCamera;
	private var camHUD:FlxCamera;

	private var clearButton:FlxButton;

    override function create() {
        super.create();

		add(warriors);
		Warrior.group = warriors;

		initCameras();
		createHUD();
    }

    override function update(dt:Float) {
        super.update(dt);

		if (!FlxG.mouse.overlaps(clearButton)) {
			if (FlxG.mouse.justPressed) {
				warriors.add(new Warrior(FlxG.mouse.x - 16, FlxG.mouse.y - 16, Red));
			}

			if (FlxG.mouse.justPressedRight) {
				warriors.add(new Warrior(FlxG.mouse.x - 16, FlxG.mouse.y - 16, Blue));
			}

			handleDragging();
		}
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