package;

import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.ui.Keyboard;
import openfl.Lib;
import openfl.events.MouseEvent;
import Math;

class Main extends Sprite {
    var player:Sprite;
    var circles:Array<Sprite> = [];
    var score:Int = 0;
    var scoreText:TextField;
	var enemies:Array<Sprite> = [];
	var gameOver:Bool = false;
	var restartButton:Sprite;
	var bullets:Array<Sprite> = [];

    var vx = 0;
    var vy = 0;

    public function new() {
        super();
        addEventListener(Event.ADDED_TO_STAGE, init);
    }

    function init(_:Event):Void {
        player = new Sprite();
        player.graphics.beginFill(0xFF0000);
        player.graphics.drawRect(0, 0, 50, 50);
        player.graphics.endFill();
        addChild(player);

        player.x = stage.stageWidth / 2;
        player.y = stage.stageHeight / 2;

        scoreText = new TextField();
        scoreText.defaultTextFormat = new TextFormat("_sans", 24, 0x000000);
        scoreText.width = 200;
        scoreText.height = 40;
        scoreText.text = "Score: 0";
        addChild(scoreText);

        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
        addEventListener(Event.ENTER_FRAME, update);

        spawnCircle();
		spawnEnemy();
    }

    function onKeyDown(e:KeyboardEvent):Void {
        switch (e.keyCode) {
            case Keyboard.A:  vx = -5;
            case Keyboard.D: vx = 5;
            case Keyboard.W:    vy = -5;
            case Keyboard.S:  vy = 5;
			case Keyboard.SPACE:
				shoot();
        }
    }

	function shoot():Void {
		var bullet = new Sprite();
		bullet.graphics.beginFill(0xFFFFFF);
		bullet.graphics.drawRect(0, 0, 5, 10);
		bullet.graphics.endFill();
		bullet.x = player.x + player.width / 2 - 2.5;
		bullet.y = player.y;
		addChild(bullet);
		bullets.push(bullet);
	}

    function onKeyUp(e:KeyboardEvent):Void {
        switch (e.keyCode) {
            case Keyboard.A, Keyboard.D: vx = 0;
            case Keyboard.W, Keyboard.S:    vy = 0;
        }
    }

    function update(e:Event):Void {
		if (gameOver) return;

		player.x += vx;
		player.y += vy;
	
		if (player.x < 0) player.x = 0;
		if (player.x + player.width > stage.stageWidth)
			player.x = stage.stageWidth - player.width;
	
		if (player.y < 0) player.y = 0;
		if (player.y + player.height > stage.stageHeight)
			player.y = stage.stageHeight - player.height;
	
		for (i in 0...circles.length) {
			var circle = circles[i];
			if (circle != null && player.hitTestObject(circle)) {
				removeChild(circle);
				circles[i] = null;
				score++;
				scoreText.text = "Score: " + score;
			}
		}

		for (enemy in enemies) {
			var dx = player.x - enemy.x;
			var dy = player.y - enemy.y;
			var dist = Math.sqrt(dx * dx + dy * dy);
			if (dist != 0) {
				enemy.x += (dx / dist) * 2;
				enemy.y += (dy / dist) * 2;
			}

			if (enemy.hitTestObject(player)) {
				endGame();
			}
		}
	
		circles = circles.filter(c -> c != null);

		for (i in 0...bullets.length) {
			var bullet = bullets[i];
			bullet.y -= 10;
			if (bullet.y < -10) {
				removeChild(bullet);
				bullets[i] = null;
			}
		}
		bullets = bullets.filter(b -> b != null);

		for (i in 0...bullets.length) {
			var bullet = bullets[i];
			for (j in 0...enemies.length) {
				var enemy = enemies[j];
				if (enemy != null && bullet != null && bullet.hitTestObject(enemy)) {
					removeChild(enemy);
					enemies[j] = null;
		
					removeChild(bullet);
					bullets[i] = null;
		
					break;
				}
			}
		}

		enemies = enemies.filter(e -> e != null);
		bullets = bullets.filter(b -> b != null);
	}

	function endGame():Void {
		gameOver = true;
	
		var gameOverText = new TextField();
		gameOverText.defaultTextFormat = new TextFormat("_sans", 40, 0xFF0000, true);
		gameOverText.width = stage.stageWidth;
		gameOverText.height = 60;
		gameOverText.text = "GAME OVER";
		gameOverText.selectable = false;
		gameOverText.mouseEnabled = false;
		gameOverText.x = (stage.stageWidth - gameOverText.textWidth) / 2;
		gameOverText.y = stage.stageHeight / 2 - 100;
		addChild(gameOverText);
	
		createRestartButton();
	}

	function createRestartButton():Void {
		var buttonWidth = 200;
		var buttonHeight = 50;
	
		restartButton = new Sprite();
		restartButton.graphics.beginFill(0x00CC00);
		restartButton.graphics.drawRoundRect(0, 0, buttonWidth, buttonHeight, 10);
		restartButton.graphics.endFill();
	
		restartButton.x = (stage.stageWidth - buttonWidth) / 2;
		restartButton.y = stage.stageHeight / 2 - buttonHeight / 2;
	
		var label = new TextField();
		label.defaultTextFormat = new TextFormat("_sans", 20, 0xFFFFFF, true, false, false, null, null, "center");
		label.width = buttonWidth;
		label.height = buttonHeight;
		label.text = "RESTART";
		label.selectable = false;
		label.mouseEnabled = false;
		label.y = (buttonHeight - label.textHeight) / 2 - 2;
	
		restartButton.addChild(label);
		addChild(restartButton);
	
		restartButton.buttonMode = true;
		restartButton.mouseChildren = false;
		restartButton.addEventListener(MouseEvent.MOUSE_DOWN, restartGame);
	}

	function restartGame(_:Event):Void {
		for (enemy in enemies) if (enemy.parent != null) removeChild(enemy);
		for (circle in circles) if (circle != null && circle.parent != null) removeChild(circle);
		enemies = [];
		circles = [];
	
		player.x = stage.stageWidth / 2;
		player.y = stage.stageHeight / 2;
		vx = 0;
		vy = 0;
	
		score = 0;
		scoreText.text = "Score: 0";
	
		if (restartButton != null && restartButton.parent != null)
			removeChild(restartButton);
	
		for (i in 0...numChildren) {
			var tf = Std.downcast(getChildAt(i), TextField);
			if (tf != null && tf.text == "GAME OVER") {
				removeChild(tf);
				break;
			}
		}
	
		gameOver = false;
	}

	function spawnEnemy():Void {
		var enemy = new Sprite();
		enemy.graphics.beginFill(0x00AAFF);
		enemy.graphics.drawRect(0, 0, 30, 30);
		enemy.graphics.endFill();
	
		var side = Std.int(Math.random() * 4);
		switch (side) {
			case 0:
				enemy.x = Math.random() * stage.stageWidth;
				enemy.y = -30;
			case 1:
				enemy.x = Math.random() * stage.stageWidth;
				enemy.y = stage.stageHeight + 30;
			case 2:
				enemy.x = -30;
				enemy.y = Math.random() * stage.stageHeight;
			case 3:
				enemy.x = stage.stageWidth + 30;
				enemy.y = Math.random() * stage.stageHeight;
		}
	
		addChild(enemy);
		enemies.push(enemy);
	
		Lib.setTimeout(spawnEnemy, 2000);
	}

    function spawnCircle():Void {
        var circle = new Sprite();
        circle.graphics.beginFill(0xFFFF00);
        circle.graphics.drawCircle(0, 0, 15);
        circle.graphics.endFill();
        circle.x = Math.random() * (stage.stageWidth - 30) + 15;
        circle.y = Math.random() * (stage.stageHeight - 30) + 15;
        addChild(circle);
        circles.push(circle);

        Lib.setTimeout(() -> {
            if (circle.parent != null) {
                removeChild(circle);
                circles.remove(circle);
            }
        }, 3000);

        Lib.setTimeout(spawnCircle, 1000);
    }
}