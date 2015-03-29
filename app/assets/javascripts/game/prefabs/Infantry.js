'use strict';

var ORIENTATION_MAP = {
    down: 1,
    left: 4,
    right: 7,
    up: 10
}

var DEFAULT_STATS = {
    HP: 100,
    MAX_HP: 100,
    ATK: 10,
    DEF: 10
}

var Infantry = function(game, x, y) {
    Phaser.Sprite.call(this, game, x*32, y*32, 'trainer', 1);
    this.orientation = "down";

    this.animations.add('walk-left', [3, 4, 5, 4]);
    this.animations.add('walk-right', [6, 7, 8, 7]);
    this.animations.add('walk-down', [0, 1, 2, 1]);
    this.animations.add('walk-up', [9, 10, 11, 10]);

    this.inputEnabled = true;
    this.input.useHandCursor = true;

    this.stats = DEFAULT_STATS;
};

Infantry.prototype = Object.create(Phaser.Sprite.prototype);
Infantry.prototype.constructor = Infantry;

Infantry.prototype.changeOrientation = function(orientation) {
    this.orientation = orientation;
    this.frame = ORIENTATION_MAP[orientation];
}

Infantry.prototype.moveAdjacent = function(orientation) {
    this.orientation = orientation;
    var animation = "walk-" + orientation;
    this.animations.play(animation, 6, true);
    var update;
    switch (orientation) {
    case "down":
	update = {y: this.y + 32};
	break;
    case "left":
	update = {x: this.x - 32};
	break;
    case "right":
	update = {x: this.x + 32};
	break;
    case "up":
	update = {y: this.y - 32};
	break;
    }
    return this.game.add.tween(this).to(update, 200, Phaser.Easing.Linear.None, true);
}

Infantry.prototype.stop = function() {
    this.animations.stop();
    this.frame = ORIENTATION_MAP[this.orientation];
}

Infantry.prototype.moveTo = function(x, y) {
    if (this.x/32 < x) {
	this.moveAdjacent("right").onComplete.add(function() {
	    this.moveTo(x, y);
	}, this);
	return;
    }
    if (this.x/32 > x) {
	this.moveAdjacent("left").onComplete.add(function() {
	    this.moveTo(x, y);
	}, this);
	return;
    }
    if (this.y/32 < y) {
	this.moveAdjacent("down").onComplete.add(function() {
	    this.moveTo(x, y);
	}, this);
	return;
    }
    if (this.y/32 > y) {
	this.moveAdjacent("up").onComplete.add(function() {
	    this.moveTo(x, y);
	}, this);
	return;
    }
    this.stop();
}
