/**
 * Original from onedayitwillmake ( http://wonderfl.net/user/onedayitwillmake )
 * MIT License ( http://www.opensource.org/licenses/mit-license.php )
 *
 * Hex to RGB conversion from Richard Yan (http://www.richieyan.com/blog/article.php?artID=32)
 *
 * Rewritten from AS3 to Javascript by Jackson Rollins (jacksonkr.com)
 */


function CirclePacking(canvas) {
	this.canvas = canvas;
	this._ctx = this.canvas.getContext("2d");
	this._circles = [];
	this._dragCircle = null;
	this.CENTER = {x:this.canvas.width/2, y:this.canvas.height/2};
	this._mouseEvent = null;

	var self = this;
	setInterval(function(){self.enterFrame()}, 1000/60);

	this.__defineSetter__("dragCircle", function(obj) {
		this._dragCircle = obj;
	});
	this.__defineGetter__("dragCircle", function() {
		return this._dragCircle;
	});

	this.canvas.onmousedown = function(event) {
		self._mouseDown = true;
		self._mouseEvent = event;
	}
	this.canvas.onmousemove = function(event) {
		self._mouseEvent = event;
	}
	this.canvas.onmouseup = function() {
		self._mouseEvent = undefined;
		self._mouseDown = false;
	}
}
CirclePacking.prototype.addCircle = function(obj) {
	this._circles.push(obj);
}
CirclePacking.prototype.enterFrame = function() {
	this._ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

	this._circles = this._circles.sort(Circle.sortOnDistanceToCenter);
	v = new Vector3D();
	
	// Push them away from each other
	for(var i = this._circles.length - 1; i >= 0 ; --i) {
		var ci = this._circles[i];
		
		for (var j = i + 1; j < this._circles.length; j++) {
			var cj = this._circles[j];
			if(i == j) continue;
			//cj.alpha = Math.random()
			var dx = cj.x - ci.x;
			var dy = cj.y - ci.y;
			var r = ci.size + cj.size;
			var d = (dx*dx) + (dy*dy);
			if (d < (r * r) - 0.01 ) {
				v.x = dx;
				v.y = dy;
				v.normalize();
				v.scaleBy((r - Math.sqrt(d)) * 0.5);
				
				if(cj != this.dragCircle) {
					cj.x += v.x;
					cj.y += v.y;
				}
				
				if(ci != this.dragCircle) {
					ci.x -= v.x;
					ci.y -= v.y;
				}
			}
		}
	}
	
	// push toward center
	var damping = 0.01;//Number(iterationCounter);
	
	for(i = 0; i < this._circles.length; i++) {
		var c = this._circles[i];
		
		if(c == this.dragCircle) continue;

		v.x = c.x - this.CENTER.x;
		v.y = c.y - this.CENTER.y;
		v.scaleBy(damping);
		c.x -= v.x;
		c.y -= v.y;
	}
	
	if(this.dragCircle && this._mouseEvent) {
		this.dragCircle.x = this._mouseEvent.offsetX;//stage.mouseX;
		this.dragCircle.y = this._mouseEvent.offsetY;//stage.mouseY;
	}

	// draw circles
	for(var i = this._circles.length - 1; i >= 0; --i) {
		var obj = this._circles[i];
		this._ctx.beginPath();
		this._ctx.arc(obj.x, obj.y, obj.size, 0, Math.PI*2, true);
		this._ctx.closePath();
		this._ctx.fillStyle = "rgb("+Math.round((obj.color & 0xff0000) >> 16)+", "+Math.round((obj.color & 0x00ff00) >> 8)+", "+Math.round(obj.color & 0x0000ff)+")";
		this._ctx.strokeStyle = "rgba(0,0,0,0.1)";
		this._ctx.lineWidth = obj.size / 5;
		this._ctx.fill();
		this._ctx.stroke();

		if(this._mouseEvent && this._mouseEvent.type == "mousedown") {
			if(this._ctx.isPointInPath(this._mouseEvent.offsetX, this._mouseEvent.offsetY)){
				this.dragCircle = this._circles[i];
			}
		} else if(!this._mouseDown) this.dragCircle = undefined;
	}
}
/*
CirclePacking.prototype.removeCircle = function(obj) {
	if(obj) {
		for(var i = this._circles.length - 1; i >= 0; --i) {
			if(this._circles[i] == obj) {
				this._circles.splice(i, 1);
				return 0;
			}
		}
	} else this._circles.splice(this._circles.length-1, 1);
}
*/

function Circle(cp, x, y, size, color) {
	this._cp = cp;
	this.x = x || 0;
	this.y = y || 0;
	this.size = size || 10;
	this.color = color || 0xff0000;
}
Circle.prototype.distanceToCenter = function() {
	var dx = this.x - this._cp.CENTER.x;
	var dy = this.y - this._cp.CENTER.y;
	var distance = dx*dx + dy*dy;
	
	return distance;
}
Circle.sortOnDistanceToCenter = function(a, b) {
	var valueA = a.distanceToCenter();
	var valueB = b.distanceToCenter();
	var comparisonValue = 0;
	
	if(valueA > valueB) comparisonValue = -1;
	else if(valueA < valueB) comparisonValue = 1;
	
	return comparisonValue;
}

function Vector3D(x, y, z) {
	this.x = x || 0;
	this.y = y || 0;
	this.z = z || 0;

	this.__defineGetter__("length", function() {
		return Math.sqrt(this.x*this.x + this.y*this.y + this.z*this.z);
	});
}
Vector3D.prototype.normalize = function(len) {
	if(len === undefined) len = 1.0;
	var s = len/this.length;
	this.scaleBy(s, s, s);
}
Vector3D.prototype.scaleBy = function(x, y, z) {
	if(y === undefined) y = x;
	if(z === undefined) z = x;

	this.x *= x;
	this.y *= y;
	this.z *= z;
}

function ColorHSV(h, s, v, a) {
	if(h === undefined) h = 0.0;
	if(s === undefined) s = 1.0;
	if(v === undefined) v = 1.0;
	if(a === undefined) a = 1.0;

	this._r;
	this._g;
	this._b;
	this._h = h;
	this._s = s;
	this._v = v;
	this._a = a;
	this.check_rgb_flg;

	this.__defineSetter__("h", function(val) {
		this._h = val;
		this.check_rgb_flag = true;
		this.update_rgb();
	});
	this.__defineGetter__("value", function() {
		if ( this.check_rgb_flg ) this.update_rgb();
		return this._r << 16 | this._g << 8 | this._b;
	});

	this.hsv(h, s, v);
}
ColorHSV.prototype.hsv = function(h, s, v) {
	if(s === undefined) s = 1.0;
	if(v === undefined) v = 1.0;

	this._h = h;

	if(s > 1.0) _s = 1.0;  
	else if (s < 0.0) _s = 0.0;  
	else _s = s; 
	
	if (v > 1.0) _v = 1.0;  
	else if (v < 0.0) _v = 0.0;  
	else _v = v; 

	this.check_rgb_flg = true;
}
ColorHSV.prototype.update_rgb = function() {
	if ( _s > 0 ){
        var h = ((this._h < 0) ? this._h % 360 + 360 : this._h % 360 ) / 60;
        
        if ( h < 1 ) {
            this._r = Math.round( 255*this._v );
            this._g = Math.round( 255*this._v * ( 1 - this._s * (1 - h) ) );
            this._b = Math.round( 255*this._v * ( 1 - this._s ) );
        } else if (h < 2) {
            this._r = Math.round( 255*this._v * ( 1 - this._s * (h - 1) ) );
            this._g = Math.round( 255*this._v );
            this._b = Math.round( 255*this._v * ( 1 - this._s ) );
        } else if (h < 3) {
            this._r = Math.round( 255*this._v * ( 1 - this._s ) );
            this._g = Math.round( 255*this._v );
            this._b = Math.round( 255*this._v * ( 1 - this._s * (3 - h) ) );
        } else if (h < 4) {
            this._r = Math.round( 255*this._v * ( 1 - this._s ) );
            this._g = Math.round( 255*this._v * ( 1 - this._s * (h - 3) ) );
            this._b = Math.round( 255*this._v );
        } else if (h < 5) {
            this._r = Math.round( 255*this._v * ( 1 - this._s * (5 - h) ) );
            this._g = Math.round( 255*this._v * ( 1 - this._s ) );
            this._b = Math.round( 255*this._v );
        } else {
            this._r = Math.round( 255*this._v );
            this._g = Math.round( 255*this._v * ( 1 - this._s ) );
            this._b = Math.round( 255*this._v * ( 1 - this._s * (h - 5) ) );
        }
    } else {
        this._r = this._g = this._b = Math.round( 255*this._v );
    }

    this.check_rgb_flg = false;
}

window.onload = function() {
	var cp = new CirclePacking(document.getElementById("circle-pack"));
	
	var maxSize = 40
	var color = new ColorHSV(0, 0.8, 1.0);
	
	for(var i = 0; i < 70; i++){
		var size;
		
		if(i< 30) size = Math.random()* maxSize/10 + 5;
		else size = Math.random()* maxSize + 5;
		
		color.h = size/maxSize * 180 + 120;
		
		cp.addCircle(new Circle(cp, i*8, 200 + Math.random(), size, color.value));
	}
}